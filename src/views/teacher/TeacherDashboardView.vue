<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { Collection, DataLine, TrendCharts, UserFilled } from '@element-plus/icons-vue'
import ActivityHeatmap from '@/components/ActivityHeatmap.vue'
import StatusTag from '@/components/ui/StatusTag.vue'
import PageHeader from '@/components/ui/PageHeader.vue'
import StatCard from '@/components/ui/StatCard.vue'
import ChartBox from '@/components/ui/ChartBox.vue'
import { statisticsApi, submissionApi, teacherApi } from '@/api'
import { useProblemStore } from '@/stores/problem'
import { useStatisticsStore } from '@/stores/statistics'
import type { ClassGroup, StudentTodaySolved, User } from '@/types'
import { recentActivity } from '@/utils/activity'

const problemStore = useProblemStore()
const statisticsStore = useStatisticsStore()

const students = ref<User[]>([])
const groups = ref<ClassGroup[]>([])
const selectedGroup = ref('')
const selectedStudentId = ref<number | ''>('')
const todaySolvedList = ref<StudentTodaySolved[]>([])
const rejudgingId = ref<number | null>(null)
let scopedRequestGeneration = 0
let studentsRequestGeneration = 0
let groupsRequestGeneration = 0

const groupOptions = computed(() => {
  const names = new Set<string>()
  groups.value.forEach((item) => names.add(item.name))
  students.value.forEach((item) => {
    if (item.groupName) names.add(item.groupName)
  })
  return Array.from(names)
})

const studentsInGroup = computed(() =>
  students.value.filter((item) => !selectedGroup.value || item.groupName === selectedGroup.value)
)

const scopeName = computed(() => {
  if (!selectedGroup.value) return '全部班级'
  const selectedStudent = studentsInGroup.value.find((item) => item.id === selectedStudentId.value)
  return selectedStudent ? `${selectedGroup.value} / ${selectedStudent.realName}` : selectedGroup.value
})

// 题目难度分布（饼图）
const difficultyOption = computed(() => {
  const counter = { EASY: 0, MEDIUM: 0, HARD: 0 }
  problemStore.problems.forEach((p) => {
    counter[p.difficulty] = (counter[p.difficulty] ?? 0) + 1
  })
  return {
    tooltip: { trigger: 'item' },
    legend: { bottom: 0, textStyle: { color: 'var(--color-text)' } },
    series: [
      {
        type: 'pie',
        radius: ['52%', '74%'],
        avoidLabelOverlap: true,
        itemStyle: { borderColor: 'var(--color-surface)', borderWidth: 2 },
        label: { show: false },
        data: [
          { value: counter.EASY, name: '简单', itemStyle: { color: '#16a34a' } },
          { value: counter.MEDIUM, name: '中等', itemStyle: { color: '#d97706' } },
          { value: counter.HARD, name: '困难', itemStyle: { color: '#dc2626' } }
        ]
      }
    ]
  }
})

// 近 14 天提交趋势（柱图）
const submissionTrendOption = computed(() => {
  const days = recentActivity(statisticsStore.activity, 14)
  return {
    grid: { left: 8, right: 12, top: 24, bottom: 24, containLabel: true },
    tooltip: { trigger: 'axis' },
    xAxis: {
      type: 'category',
      data: days.map((d) => d.date.slice(5)),
      axisLabel: { color: 'var(--color-text)' }
    },
    yAxis: {
      type: 'value',
      splitLine: { lineStyle: { color: 'var(--color-border)' } },
      axisLabel: { color: 'var(--color-text)' }
    },
    series: [
      {
        type: 'bar',
        data: days.map((d) => d.count),
        barWidth: '52%',
        itemStyle: { color: 'var(--color-primary)', borderRadius: [4, 4, 0, 0] }
      }
    ]
  }
})

watch(selectedGroup, async () => {
  selectedStudentId.value = ''
  await loadScopedData()
})

watch(selectedStudentId, async () => {
  await loadScopedData()
})

onMounted(async () => {
  const studentGeneration = ++studentsRequestGeneration
  const groupGeneration = ++groupsRequestGeneration
  const [studentResult, groupResult] = await Promise.all([teacherApi.students(), teacherApi.groups()])
  if (studentGeneration === studentsRequestGeneration) students.value = studentResult
  if (groupGeneration === groupsRequestGeneration) groups.value = groupResult
  await loadScopedData()
})

async function loadScopedData() {
  const generation = ++scopedRequestGeneration
  const groupName = selectedGroup.value
  const studentId = selectedStudentId.value
  const params = groupName
    ? { groupName, studentId: studentId === '' ? undefined : studentId }
    : undefined

  const [overview, activity, submissions, todaySolved] = await Promise.all([
    statisticsApi.teacherOverview(params),
    statisticsApi.teacherActivity(params),
    submissionApi.list(params),
    statisticsApi.teacherTodaySolved(params)
  ])
  if (generation === scopedRequestGeneration && selectedGroup.value === groupName && selectedStudentId.value === studentId) {
    statisticsStore.overview = overview
    statisticsStore.activity = activity
    problemStore.submissions = submissions
    todaySolvedList.value = todaySolved
  }
}

async function rejudge(row: { id: number }) {
  const id = row.id
  rejudgingId.value = id
  try {
    const result = await submissionApi.rejudge(id)
    if (rejudgingId.value !== id) return
    ElMessage.success(`重判完成：${result.status}`)
    await loadScopedData()
  } catch {
    // 错误信息由 http 拦截器统一提示
  } finally {
    if (rejudgingId.value === id) rejudgingId.value = null
  }
}
</script>

<template>
  <div class="page">
    <PageHeader title="教学数据看板" subtitle="班级、题库、提交与通过率概览。">
      <template #actions>
        <el-select v-model="selectedGroup" placeholder="班级" clearable style="width: 170px">
          <el-option v-for="name in groupOptions" :key="name" :label="name" :value="name" />
        </el-select>
        <el-select
          v-model="selectedStudentId"
          placeholder="学生"
          clearable
          filterable
          :disabled="!selectedGroup"
          style="width: 170px"
        >
          <el-option
            v-for="student in studentsInGroup"
            :key="student.id"
            :label="`${student.realName} ${student.studentNo ?? ''}`"
            :value="student.id"
          />
        </el-select>
      </template>
    </PageHeader>

    <div class="scope-line">当前范围：{{ scopeName }}</div>

    <div class="metric-grid">
      <StatCard label="学生数量" :value="statisticsStore.overview.students" :icon="UserFilled" accent="primary" />
      <StatCard label="题目数量" :value="statisticsStore.overview.problems" :icon="Collection" accent="info" />
      <StatCard label="今日做题数量" :value="statisticsStore.overview.todaySubmissions" :icon="DataLine" accent="success" />
      <StatCard label="提交次数" :value="statisticsStore.overview.submissions.toLocaleString()" :icon="DataLine" accent="warning" />
      <StatCard label="平均通过率" :value="`${statisticsStore.overview.passRate}%`" :icon="TrendCharts" accent="danger" />
    </div>

    <div class="grid-2">
      <el-card class="section-card">
        <h2 class="card-title">近 14 天提交趋势</h2>
        <ChartBox :option="submissionTrendOption" height="260px" />
      </el-card>
      <el-card class="section-card">
        <h2 class="card-title">题目难度分布</h2>
        <ChartBox :option="difficultyOption" height="260px" />
      </el-card>
    </div>

    <div class="grid-2">
      <el-card class="section-card">
        <h2 class="card-title">{{ selectedStudentId === '' ? '班级活跃图' : '学生活跃图' }}</h2>
        <ActivityHeatmap :data="statisticsStore.activity" :months="3" />
      </el-card>
      <el-card class="section-card">
        <h2 class="card-title">最近提交</h2>
        <el-table :data="problemStore.submissions" height="280" empty-text="暂无提交记录">
          <el-table-column prop="userName" label="学生" width="100" />
          <el-table-column prop="problemTitle" label="题目" />
          <el-table-column label="结果" width="120"><template #default="{ row }"><StatusTag :status="row.status" /></template></el-table-column>
          <el-table-column prop="runtimeMs" label="耗时" width="80" />
          <el-table-column label="操作" width="90">
            <template #default="{ row }">
              <el-button type="primary" link size="small" :loading="rejudgingId === row.id" @click="rejudge(row)">重判</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-card>
    </div>

    <el-card class="section-card">
      <h2 class="card-title">学生今日做题数量</h2>
      <el-table :data="todaySolvedList" empty-text="暂无学生数据">
        <el-table-column prop="studentNo" label="学号" width="140" />
        <el-table-column prop="realName" label="学生" width="120" />
        <el-table-column prop="groupName" label="班级" />
        <el-table-column prop="todaySolved" label="今日通过新题数" width="160" />
      </el-table>
    </el-card>
  </div>
</template>

<style scoped>
.scope-line {
  margin-top: -8px;
  color: var(--color-muted);
  font-size: 14px;
}
</style>
