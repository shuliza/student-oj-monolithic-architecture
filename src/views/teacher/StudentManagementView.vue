<script setup lang="ts">
import { onMounted, ref, reactive, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import PageHeader from '@/components/ui/PageHeader.vue'
import { teacherApi } from '@/api'
import type { ClassGroup, User } from '@/types'

const students = ref<User[]>([])
const groups = ref<ClassGroup[]>([])
const keyword = ref('')
const group = ref('')
const importing = ref(false)

const createVisible = ref(false)
const createSaving = ref(false)
const createForm = reactive({ username: '', realName: '', studentNo: '', password: '123456', groupName: '' })

const editVisible = ref(false)
const editSaving = ref(false)
const editId = ref<number | null>(null)
const editForm = reactive({ realName: '', studentNo: '', groupName: '' })

const list = computed(() =>
  students.value.filter((item) => {
    const hitKeyword = !keyword.value || item.realName.includes(keyword.value) || item.studentNo?.includes(keyword.value)
    const hitGroup = !group.value || item.groupName === group.value
    return hitKeyword && hitGroup
  })
)

const fetchStudents = async () => {
  students.value = await teacherApi.students()
}

const fetchGroups = async () => {
  groups.value = await teacherApi.groups()
}

const openCreate = () => {
  createForm.username = ''
  createForm.realName = ''
  createForm.studentNo = ''
  createForm.password = '123456'
  createForm.groupName = ''
  createVisible.value = true
}

const submitCreate = async () => {
  if (!createForm.username.trim()) {
    ElMessage.warning('请输入账号')
    return
  }
  if (!createForm.realName.trim()) {
    ElMessage.warning('请输入姓名')
    return
  }
  if (createForm.password.trim() && createForm.password.trim().length < 6) {
    ElMessage.warning('密码长度至少 6 位')
    return
  }
  createSaving.value = true
  try {
    await teacherApi.createStudent({
      username: createForm.username.trim(),
      realName: createForm.realName.trim(),
      studentNo: createForm.studentNo.trim(),
      password: createForm.password.trim() || undefined,
      groupName: createForm.groupName || undefined
    })
    ElMessage.success('学生已导入')
    createVisible.value = false
    await fetchStudents()
  } catch {
    // 错误信息由 http 拦截器统一提示
  } finally {
    createSaving.value = false
  }
}

const openEdit = (row: User) => {
  editId.value = row.id
  editForm.realName = row.realName
  editForm.studentNo = row.studentNo ?? ''
  editForm.groupName = row.groupName ?? ''
  editVisible.value = true
}

const submitEdit = async () => {
  if (!editId.value) return
  if (!editForm.realName.trim()) {
    ElMessage.warning('请输入姓名')
    return
  }
  editSaving.value = true
  try {
    await teacherApi.updateStudent(editId.value, {
      realName: editForm.realName.trim(),
      studentNo: editForm.studentNo.trim(),
      groupName: editForm.groupName || undefined
    })
    ElMessage.success('学生信息已更新')
    editVisible.value = false
    await fetchStudents()
  } catch {
    // 错误信息由 http 拦截器统一提示
  } finally {
    editSaving.value = false
  }
}

const toggleStatus = async (row: User) => {
  const next = row.status === 'ACTIVE' ? 'DISABLED' : 'ACTIVE'
  const action = next === 'DISABLED' ? '禁用' : '启用'
  try {
    await ElMessageBox.confirm(`确认${action}学生「${row.realName}」？`, `${action}确认`, { type: 'warning' })
    await teacherApi.updateStudentStatus(row.id, next)
    ElMessage.success(`已${action}`)
    await fetchStudents()
  } catch {}
}

const resetPassword = async (row: User) => {
  try {
    const { value } = await ElMessageBox.prompt(
      `为学生「${row.realName}」设置新密码（留空则重置为默认密码 123456）`,
      '重置密码',
      { inputPlaceholder: '至少 6 位，留空使用 123456', inputValue: '' }
    )
    await teacherApi.resetStudentPassword(row.id, value?.trim() || undefined)
    ElMessage.success('密码已重置')
  } catch {}
}

const handleTemplateExport = async () => {
  try {
    const blob = await teacherApi.exportStudentTemplate()
    downloadBlob(blob, 'student-template.xlsx')
    ElMessage.success('模板已下载')
  } catch {
    ElMessage.error('模板下载失败')
  }
}

const handleBatchImport = () => {
  const input = document.createElement('input')
  input.type = 'file'
  input.accept = '.xlsx'
  input.onchange = async () => {
    const file = input.files?.[0]
    if (!file) return
    importing.value = true
    try {
      const result = await teacherApi.importStudents(file)
      ElMessage.success(`成功导入 ${result.imported} 名学生`)
      await fetchStudents()
    } catch {
      ElMessage.error('导入失败')
    } finally {
      importing.value = false
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

onMounted(async () => {
  await Promise.all([fetchStudents(), fetchGroups()])
})
</script>

<template>
  <div class="page">
    <PageHeader title="学生管理" subtitle="查看学生账号、班级分组和学习状态。" />
    <div class="toolbar toolbar-controls">
      <el-input v-model="keyword" placeholder="姓名 / 学号" clearable style="width: 220px" />
      <el-select v-model="group" placeholder="班级" clearable style="width: 160px">
        <el-option v-for="item in groups" :key="item.id" :label="item.name" :value="item.name" />
      </el-select>
      <el-button @click="handleTemplateExport">模板导出</el-button>
      <el-button type="success" @click="openCreate">单个导入</el-button>
      <el-button type="primary" :loading="importing" @click="handleBatchImport">批量导入</el-button>
    </div>
    <el-card class="section-card">
      <el-table :data="list">
        <el-table-column prop="studentNo" label="学号" width="140" />
        <el-table-column prop="realName" label="姓名" width="120" />
        <el-table-column prop="username" label="账号" width="140" />
        <el-table-column prop="groupName" label="分组" />
        <el-table-column prop="status" label="状态" width="120">
          <template #default="{ row }"><el-tag :type="row.status === 'ACTIVE' ? 'success' : 'info'">{{ row.status }}</el-tag></template>
        </el-table-column>
        <el-table-column label="操作" width="220" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click="openEdit(row)">编辑</el-button>
            <el-button :type="row.status === 'ACTIVE' ? 'warning' : 'success'" link size="small" @click="toggleStatus(row)">
              {{ row.status === 'ACTIVE' ? '禁用' : '启用' }}
            </el-button>
            <el-button type="info" link size="small" @click="resetPassword(row)">重置密码</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="createVisible" title="单个学生导入" width="480px" destroy-on-close>
      <el-form :model="createForm" label-width="80px">
        <el-form-item label="账号" required>
          <el-input v-model="createForm.username" placeholder="请输入登录账号" />
        </el-form-item>
        <el-form-item label="姓名" required>
          <el-input v-model="createForm.realName" placeholder="请输入姓名" />
        </el-form-item>
        <el-form-item label="学号">
          <el-input v-model="createForm.studentNo" placeholder="请输入学号" />
        </el-form-item>
        <el-form-item label="初始密码">
          <el-input v-model="createForm.password" placeholder="留空使用 123456" show-password />
        </el-form-item>
        <el-form-item label="分组">
          <el-select v-model="createForm.groupName" placeholder="未分组" clearable style="width: 100%">
            <el-option v-for="item in groups" :key="item.id" :label="item.name" :value="item.name" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="createVisible = false">取消</el-button>
        <el-button type="primary" :loading="createSaving" @click="submitCreate">导入</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="editVisible" title="编辑学生" width="480px" destroy-on-close>
      <el-form :model="editForm" label-width="80px">
        <el-form-item label="姓名" required>
          <el-input v-model="editForm.realName" placeholder="请输入姓名" />
        </el-form-item>
        <el-form-item label="学号">
          <el-input v-model="editForm.studentNo" placeholder="请输入学号" />
        </el-form-item>
        <el-form-item label="分组">
          <el-select v-model="editForm.groupName" placeholder="未分组" clearable style="width: 100%">
            <el-option v-for="item in groups" :key="item.id" :label="item.name" :value="item.name" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="editVisible = false">取消</el-button>
        <el-button type="primary" :loading="editSaving" @click="submitEdit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.toolbar-controls {
  justify-content: flex-start;
}
</style>
