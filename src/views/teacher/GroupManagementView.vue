<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import PageHeader from '@/components/ui/PageHeader.vue'
import EmptyState from '@/components/ui/EmptyState.vue'
import { teacherApi } from '@/api'
import type { ClassGroup, User } from '@/types'

const groups = ref<ClassGroup[]>([])
const loading = ref(false)

// Create/Edit dialog
const dialogVisible = ref(false)
const dialogTitle = ref('新建分组')
const editingId = ref<number | null>(null)
const form = ref({ name: '', teacherName: '', description: '' })

// Member drawer
const memberDrawerVisible = ref(false)
const memberGroupId = ref<number | null>(null)
const memberGroupName = ref('')
const members = ref<User[]>([])
const memberLoading = ref(false)
let groupsRequestGeneration = 0
let editingRequestGeneration = 0
let membersRequestGeneration = 0
let studentsRequestGeneration = 0

// Add-member dialog
const addMemberVisible = ref(false)
const addMemberSaving = ref(false)
const allStudents = ref<User[]>([])
const selectedStudentIds = ref<number[]>([])

const fetchGroups = async () => {
  const generation = ++groupsRequestGeneration
  loading.value = true
  try {
    const result = await teacherApi.groups()
    if (generation === groupsRequestGeneration) groups.value = result
  } finally {
    if (generation === groupsRequestGeneration) loading.value = false
  }
}

const openCreateDialog = () => {
  ++editingRequestGeneration
  dialogTitle.value = '新建分组'
  editingId.value = null
  form.value = { name: '', teacherName: '', description: '' }
  dialogVisible.value = true
}

const openEditDialog = (item: ClassGroup) => {
  ++editingRequestGeneration
  dialogTitle.value = '编辑分组'
  editingId.value = item.id
  form.value = { name: item.name, teacherName: item.teacherName, description: item.description }
  dialogVisible.value = true
}

const submitGroup = async () => {
  if (!form.value.name.trim()) {
    ElMessage.warning('请输入分组名称')
    return
  }
  const id = editingId.value
  const generation = editingRequestGeneration
  const payload = { ...form.value }
  try {
    if (id) {
      await teacherApi.updateGroup(id, payload)
      if (generation !== editingRequestGeneration || editingId.value !== id) return
      ElMessage.success('分组已更新')
    } else {
      await teacherApi.createGroup(payload)
      if (generation !== editingRequestGeneration || editingId.value !== null) return
      ElMessage.success('分组已创建')
    }
    dialogVisible.value = false
    await fetchGroups()
  } catch {
    ElMessage.error('操作失败')
  }
}

const deleteGroup = async (item: ClassGroup) => {
  const id = item.id
  try {
    await ElMessageBox.confirm(`确认删除分组「${item.name}」？该分组内的学生将被移出。`, '删除确认', { type: 'warning' })
    await teacherApi.deleteGroup(id)
    ElMessage.success('分组已删除')
    await fetchGroups()
  } catch {}
}

const openMemberDrawer = async (item: ClassGroup) => {
  memberGroupId.value = item.id
  memberGroupName.value = item.name
  memberDrawerVisible.value = true
  await fetchMembers(item.id)
}

const fetchMembers = async (groupId = memberGroupId.value) => {
  if (!groupId) return
  const generation = ++membersRequestGeneration
  memberLoading.value = true
  try {
    const result = await teacherApi.getGroupMembers(groupId)
    if (generation === membersRequestGeneration && memberGroupId.value === groupId) members.value = result
  } finally {
    if (generation === membersRequestGeneration && memberGroupId.value === groupId) memberLoading.value = false
  }
}

const removeMember = async (student: User) => {
  const groupId = memberGroupId.value
  const studentId = student.id
  if (!groupId) return
  try {
    await ElMessageBox.confirm(`确认将「${student.realName}」移出分组？`, '移出确认', { type: 'warning' })
    await teacherApi.removeGroupMembers(groupId, [studentId])
    if (memberGroupId.value !== groupId) return
    ElMessage.success('已移出')
    await fetchMembers(groupId)
    await fetchGroups()
  } catch {}
}

const openAddMember = async () => {
  selectedStudentIds.value = []
  addMemberVisible.value = true
  if (!allStudents.value.length) {
    const generation = ++studentsRequestGeneration
    const result = await teacherApi.students()
    if (generation === studentsRequestGeneration && addMemberVisible.value) allStudents.value = result
  }
}

const candidateStudents = computed(() => {
  const memberIds = new Set(members.value.map((m) => m.id))
  return allStudents.value.filter((s) => !memberIds.has(s.id))
})

const submitAddMembers = async () => {
  if (!memberGroupId.value || !selectedStudentIds.value.length) {
    ElMessage.warning('请选择要添加的学生')
    return
  }
  addMemberSaving.value = true
  const groupId = memberGroupId.value
  const studentIds = [...selectedStudentIds.value]
  try {
    await teacherApi.addGroupMembers(groupId, studentIds)
    if (memberGroupId.value !== groupId) return
    ElMessage.success(`已添加 ${studentIds.length} 名学生`)
    addMemberVisible.value = false
    await fetchMembers(groupId)
    await fetchGroups()
  } catch {
    ElMessage.error('添加失败')
  } finally {
    if (memberGroupId.value === groupId) addMemberSaving.value = false
  }
}

const handleMemberExport = async () => {
  const groupId = memberGroupId.value
  const groupName = memberGroupName.value
  if (!groupId) return
  try {
    const blob = await teacherApi.exportGroupMembers(groupId)
    downloadBlob(blob, `${groupName}-成员.xlsx`)
  } catch {
    ElMessage.error('导出失败')
  }
}

const handleMemberImport = async () => {
  if (!memberGroupId.value) return
  const input = document.createElement('input')
  input.type = 'file'
  input.accept = '.xlsx,.xls,.csv'
  input.onchange = async () => {
    const file = input.files?.[0]
    const groupId = memberGroupId.value
    if (!file || !groupId) return
    try {
      await teacherApi.importGroupMembers(groupId, file)
      if (memberGroupId.value !== groupId) return
      ElMessage.success('导入成功')
      await fetchMembers(groupId)
      await fetchGroups()
    } catch {
      ElMessage.error('导入失败')
    }
  }
  input.click()
}

const downloadBlob = (blob: Blob, filename: string) => {
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = filename
  a.click()
  URL.revokeObjectURL(url)
}

onMounted(fetchGroups)
</script>

<template>
  <div class="page">
    <PageHeader title="学生分组" subtitle="按班级、实验批次或专项练习组织学生。">
      <template #actions>
        <el-button type="primary" :icon="Plus" @click="openCreateDialog">新建分组</el-button>
      </template>
    </PageHeader>
    <EmptyState v-if="!loading && !groups.length" description="还没有分组，点右上角新建一个吧" />
    <div v-else class="grid-2">
      <el-card v-for="item in groups" :key="item.id" class="section-card" v-loading="loading">
        <div class="toolbar">
          <h2 class="card-title">{{ item.name }}</h2>
          <el-tag>{{ item.studentCount }} 人</el-tag>
        </div>
        <p class="muted">{{ item.description }}</p>
        <el-divider />
        <div class="toolbar">
          <span>负责教师：{{ item.teacherName }}</span>
          <div>
            <el-button type="primary" link @click="openMemberDrawer(item)">成员</el-button>
            <el-button type="primary" link @click="openEditDialog(item)">编辑</el-button>
            <el-button type="danger" link @click="deleteGroup(item)">删除</el-button>
          </div>
        </div>
      </el-card>
    </div>

    <!-- Create/Edit Dialog -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="480px" destroy-on-close>
      <el-form :model="form" label-width="90px">
        <el-form-item label="分组名称" required>
          <el-input v-model="form.name" placeholder="请输入分组名称" />
        </el-form-item>
        <el-form-item label="负责教师">
          <el-input v-model="form.teacherName" placeholder="请输入负责教师姓名" />
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="form.description" type="textarea" :rows="3" placeholder="分组描述（可选）" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitGroup">确定</el-button>
      </template>
    </el-dialog>

    <!-- Member Drawer -->
    <el-drawer v-model="memberDrawerVisible" :title="`${memberGroupName} - 分组成员`" size="600px" destroy-on-close>
      <template #header>
        <div class="toolbar" style="width: 100%">
          <span style="font-size: 18px; font-weight: 700">{{ memberGroupName }} - 分组成员</span>
          <div>
            <el-button size="small" type="primary" @click="openAddMember">添加成员</el-button>
            <el-button size="small" @click="handleMemberExport">导出成员</el-button>
            <el-button size="small" type="primary" @click="handleMemberImport">导入成员</el-button>
          </div>
        </div>
      </template>
      <el-table :data="members" v-loading="memberLoading" stripe>
        <el-table-column prop="studentNo" label="学号" width="120" />
        <el-table-column prop="realName" label="姓名" width="100" />
        <el-table-column prop="username" label="账号" />
        <el-table-column prop="status" label="状态" width="90">
          <template #default="{ row }">
            <el-tag :type="row.status === 'ACTIVE' ? 'success' : 'info'" size="small">{{ row.status }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="80">
          <template #default="{ row }">
            <el-button type="danger" link size="small" @click="removeMember(row)">移出</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-drawer>

    <!-- Add Member Dialog -->
    <el-dialog v-model="addMemberVisible" title="添加成员" width="520px" destroy-on-close>
      <el-select
        v-model="selectedStudentIds"
        multiple
        filterable
        placeholder="选择要加入分组的学生"
        style="width: 100%"
      >
        <el-option
          v-for="s in candidateStudents"
          :key="s.id"
          :label="`${s.realName}${s.studentNo ? ' (' + s.studentNo + ')' : ''}${s.groupName ? ' · ' + s.groupName : ''}`"
          :value="s.id"
        />
      </el-select>
      <p class="muted" style="margin-top: 10px">已选择学生原有分组将被替换为当前分组。</p>
      <template #footer>
        <el-button @click="addMemberVisible = false">取消</el-button>
        <el-button type="primary" :loading="addMemberSaving" @click="submitAddMembers">确定添加</el-button>
      </template>
    </el-dialog>
  </div>
</template>
