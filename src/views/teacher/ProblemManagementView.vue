<script setup lang="ts">
import { onMounted, ref, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import StatusTag from '@/components/ui/StatusTag.vue'
import { problemAdminApi } from '@/api'
import type { ProblemAdmin, ProblemSavePayload } from '@/types'

const problems = ref<ProblemAdmin[]>([])
const keyword = ref('')
const loading = ref(false)
const importing = ref(false)
let problemsRequestGeneration = 0
let editingRequestGeneration = 0

const dialogVisible = ref(false)
const dialogTitle = ref('新增题目')
const editingId = ref<number | null>(null)
const saving = ref(false)

const emptyForm = (): ProblemSavePayload => ({
  title: '',
  difficulty: 'EASY',
  tags: [],
  description: '',
  sampleInput: '',
  sampleOutput: '',
  answerSql: '',
  testcases: [''],
  status: 1
})
const form = ref<ProblemSavePayload>(emptyForm())
const tagsText = ref('')

const list = computed(() =>
  problems.value.filter((item) => !keyword.value || item.title.includes(keyword.value))
)

const fetchProblems = async () => {
  const generation = ++problemsRequestGeneration
  loading.value = true
  try {
    const result = await problemAdminApi.list()
    if (generation === problemsRequestGeneration) problems.value = result
  } finally {
    if (generation === problemsRequestGeneration) loading.value = false
  }
}

const openCreateDialog = () => {
  ++editingRequestGeneration
  dialogTitle.value = '新增题目'
  editingId.value = null
  form.value = emptyForm()
  tagsText.value = ''
  dialogVisible.value = true
}

const openEditDialog = async (row: ProblemAdmin) => {
  const id = row.id
  const generation = ++editingRequestGeneration
  dialogTitle.value = '编辑题目'
  editingId.value = id
  const detail = await problemAdminApi.detail(id)
  if (generation !== editingRequestGeneration || editingId.value !== id) return
  form.value = {
    title: detail.title,
    difficulty: detail.difficulty,
    tags: detail.tags ?? [],
    description: detail.description ?? '',
    sampleInput: detail.sampleInput ?? '',
    sampleOutput: detail.sampleOutput ?? '',
    answerSql: detail.answerSql ?? '',
    testcases: detail.testcases?.length ? detail.testcases : [''],
    status: detail.status ?? 1
  }
  tagsText.value = (detail.tags ?? []).join(',')
  dialogVisible.value = true
}

const addTestcase = () => {
  form.value.testcases.push('')
}

const removeTestcase = (index: number) => {
  if (form.value.testcases.length <= 1) {
    ElMessage.warning('至少保留一个测试用例')
    return
  }
  form.value.testcases.splice(index, 1)
}

const submitForm = async () => {
  form.value.tags = tagsText.value.split(',').map((t) => t.trim()).filter(Boolean)
  if (!form.value.title.trim()) {
    ElMessage.warning('请输入题目标题')
    return
  }
  if (!form.value.answerSql.trim()) {
    ElMessage.warning('请输入参考答案 SQL')
    return
  }
  if (!form.value.testcases.some((t) => t.trim())) {
    ElMessage.warning('请至少填写一个测试用例的建表与造数据 SQL')
    return
  }
  saving.value = true
  const id = editingId.value
  const generation = editingRequestGeneration
  const payload = { ...form.value, tags: [...form.value.tags], testcases: [...form.value.testcases] }
  try {
    if (id) {
      await problemAdminApi.update(id, payload)
      if (generation !== editingRequestGeneration || editingId.value !== id) return
      ElMessage.success('题目已更新')
    } else {
      await problemAdminApi.create(payload)
      if (generation !== editingRequestGeneration || editingId.value !== null) return
      ElMessage.success('题目已创建')
    }
    dialogVisible.value = false
    await fetchProblems()
  } finally {
    if (generation === editingRequestGeneration) saving.value = false
  }
}

const deleteProblem = async (row: ProblemAdmin) => {
  const id = row.id
  try {
    await ElMessageBox.confirm(`确认删除题目「${row.title}」？删除后学生端将不可见。`, '删除确认', { type: 'warning' })
    await problemAdminApi.remove(id)
    ElMessage.success('题目已删除')
    await fetchProblems()
  } catch {}
}

const downloadBlob = (blob: Blob, filename: string) => {
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = filename
  a.click()
  URL.revokeObjectURL(url)
}

const handleTemplateExport = async () => {
  try {
    const blob = await problemAdminApi.exportTemplate()
    downloadBlob(blob, 'problem-template.xlsx')
    ElMessage.success('模板已下载')
  } catch {
    ElMessage.error('模板下载失败')
  }
}

const handleImport = () => {
  const input = document.createElement('input')
  input.type = 'file'
  input.accept = '.xlsx,.xls'
  input.onchange = async () => {
    const file = input.files?.[0]
    if (!file) return
    importing.value = true
    try {
      const result = await problemAdminApi.importProblems(file)
      ElMessage.success(`成功导入 ${result.imported} 道题目`)
      await fetchProblems()
    } catch {
      ElMessage.error('导入失败')
    } finally {
      importing.value = false
    }
  }
  input.click()
}

const difficultyLabel = (value: string) =>
  value === 'EASY' ? '简单' : value === 'MEDIUM' ? '中等' : value === 'HARD' ? '困难' : value

onMounted(fetchProblems)
</script>

<!-- PLACEHOLDER_TEMPLATE -->
<template>
  <div class="page">
    <div class="toolbar">
      <div>
        <h1 class="page-title">题库管理</h1>
        <p class="page-subtitle">维护题目、标签、测试用例和标准答案。</p>
      </div>
      <div class="toolbar">
        <el-input v-model="keyword" placeholder="搜索题目" clearable style="width: 220px" />
        <el-button @click="handleTemplateExport">下载模板</el-button>
        <el-button :loading="importing" @click="handleImport">导入题目</el-button>
        <el-button type="primary" @click="openCreateDialog">新增题目</el-button>
      </div>
    </div>
    <el-card class="section-card">
      <el-table :data="list" v-loading="loading">
        <el-table-column prop="title" label="题目" min-width="220" />
        <el-table-column label="难度" width="110">
          <template #default="{ row }">{{ difficultyLabel(row.difficulty) }}</template>
        </el-table-column>
        <el-table-column label="标签" min-width="180">
          <template #default="{ row }">
            <el-tag v-for="tag in row.tags" :key="tag" class="tag">{{ tag }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="测试用例" width="100">
          <template #default="{ row }">{{ row.testcases?.length || 0 }}</template>
        </el-table-column>
        <el-table-column label="状态" width="110">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'">{{ row.status === 1 ? '已上线' : '已下线' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="160">
          <template #default="{ row }">
            <el-button type="primary" link @click="openEditDialog(row)">编辑</el-button>
            <el-button type="danger" link @click="deleteProblem(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- PLACEHOLDER_DIALOG -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="760px" top="6vh" destroy-on-close>
      <el-form :model="form" label-width="92px">
        <el-form-item label="标题" required>
          <el-input v-model="form.title" placeholder="请输入题目标题" />
        </el-form-item>
        <el-form-item label="难度">
          <el-radio-group v-model="form.difficulty">
            <el-radio-button value="EASY">简单</el-radio-button>
            <el-radio-button value="MEDIUM">中等</el-radio-button>
            <el-radio-button value="HARD">困难</el-radio-button>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="标签">
          <el-input v-model="tagsText" placeholder="多个标签用英文逗号分隔，如 SELECT,WHERE" />
        </el-form-item>
        <el-form-item label="题目描述">
          <el-input v-model="form.description" type="textarea" :rows="3" placeholder="题目要求说明" />
        </el-form-item>
        <el-form-item label="输入结构">
          <el-input v-model="form.sampleInput" type="textarea" :rows="2" placeholder="如 student(id, name), score(student_id, course, score)" />
        </el-form-item>
        <el-form-item label="期望输出">
          <el-input v-model="form.sampleOutput" type="textarea" :rows="2" placeholder="如 name | course | score" />
        </el-form-item>
        <el-form-item label="参考答案" required>
          <el-input v-model="form.answerSql" type="textarea" :rows="3" placeholder="标准答案 SQL，判题以其结果集为准" />
        </el-form-item>
        <el-form-item label="测试用例">
          <div style="width: 100%">
            <div v-for="(tc, index) in form.testcases" :key="index" class="testcase-item">
              <div class="testcase-head">
                <span>用例 {{ index + 1 }}（建表 + 造数据 SQL）</span>
                <el-button type="danger" link size="small" @click="removeTestcase(index)">移除</el-button>
              </div>
              <el-input v-model="form.testcases[index]" type="textarea" :rows="3" placeholder="CREATE TABLE ...; INSERT INTO ... ;" />
            </div>
            <el-button type="primary" link @click="addTestcase">+ 添加测试用例</el-button>
          </div>
        </el-form-item>
        <el-form-item label="状态">
          <el-switch v-model="form.status" :active-value="1" :inactive-value="0" active-text="上线" inactive-text="下线" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="submitForm">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.tag {
  margin-right: 6px;
}
.testcase-item {
  margin-bottom: 12px;
}
.testcase-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 6px;
}
</style>

