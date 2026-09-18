import http from './http'
import type { ActivityItem, ClassGroup, Problem, ProblemAdmin, ProblemSavePayload, StudentTodaySolved, Submission, User } from '@/types'

export const authApi = {
  async login(username: string, password: string, role: 'STUDENT' | 'TEACHER') {
    const { data } = await http.post('/auth/login', { username, password, role })
    return {
      token: data.token as string,
      user: mapLoginUser(data)
    }
  },
  async logout() {
    await http.post('/auth/logout')
  },
  async me() {
    const { data } = await http.get('/auth/me')
    return mapLoginUser(data)
  },
  async changePassword(oldPassword: string, newPassword: string) {
    await http.post('/auth/password', { oldPassword, newPassword })
  },
  async updateProfile(payload: { realName?: string; email?: string }) {
    const { data } = await http.put('/auth/profile', payload)
    return mapLoginUser(data)
  }
}

export const problemApi = {
  async list() {
    const { data } = await http.get<Problem[]>('/problem/list')
    return data
  },
  async detail(id: number) {
    const { data } = await http.get<Problem>(`/problem/${id}`)
    return data
  },
  async submit(problemId: number, sql: string) {
    const { data } = await http.post<Submission>('/submission/judge', { problemId, sqlContent: sql }, { timeout: 120000 })
    return data
  },
  async run(problemId: number, sql: string) {
    const { data } = await http.post<{
      status: string
      runtimeMs: number
      message: string
      match: boolean
      columns: string[]
      rows: Record<string, unknown>[]
    }>(
      '/submission/run',
      { problemId, sqlContent: sql }
    )
    return data
  }
}

export const submissionApi = {
  async list(params?: { groupName?: string; studentId?: number }) {
    const { data } = await http.get<Submission[]>('/submission/list', { params })
    return data
  },
  async mine() {
    const { data } = await http.get<Submission[]>('/submission/mine')
    return data
  },
  async get(id: number) {
    const { data } = await http.get<Submission>(`/submission/${id}`)
    return data
  },
  async rejudge(id: number) {
    const { data } = await http.post(`/judge/rejudge/${id}`)
    return data as { submissionId: number; status: string; score: number; runtimeMs: number; message: string }
  }
}

export const statisticsApi = {
  async activity() {
    const { data } = await http.get<ActivityItem[]>('/statistics/me/activity')
    return data
  },
  async overview() {
    const { data } = await http.get('/statistics/me/overview')
    return {
      todaySubmissions: data.todaySubmissions ?? 0,
      acceptedProblems: data.acceptedProblems ?? 0,
      activeDays: data.streakDays ?? 0,
      accuracy: data.accuracy ?? data.passRate ?? 0,
      students: data.students ?? 0,
      problems: data.problems ?? 0,
      submissions: data.submissions ?? 0,
      passRate: data.passRate ?? 0,
      todayAttempted: data.todayAttempted ?? 0,
      todayPassed: data.todayPassed ?? 0
    }
  },
  async teacherActivity(params?: { groupName?: string; studentId?: number }) {
    const { data } = await http.get<ActivityItem[]>('/statistics/teacher/activity', { params })
    return data
  },
  async teacherOverview(params?: { groupName?: string; studentId?: number }) {
    const { data } = await http.get('/statistics/teacher/overview', { params })
    return {
      todaySubmissions: data.todaySubmissions ?? 0,
      acceptedProblems: data.acceptedProblems ?? 0,
      activeDays: data.streakDays ?? 0,
      accuracy: data.accuracy ?? data.passRate ?? 0,
      students: data.students ?? 0,
      problems: data.problems ?? 0,
      submissions: data.submissions ?? 0,
      passRate: data.passRate ?? 0,
      todayAttempted: data.todayAttempted ?? 0,
      todayPassed: data.todayPassed ?? 0
    }
  },
  async teacherTodaySolved(params?: { groupName?: string; studentId?: number }) {
    const { data } = await http.get<StudentTodaySolved[]>('/statistics/teacher/today-solved', { params })
    return data
  }
}

export const teacherApi = {
  async students() {
    const { data } = await http.get<User[]>('/teacher/students')
    return data
  },
  async createStudent(payload: { username: string; realName: string; studentNo?: string; password?: string; groupName?: string }) {
    await http.post('/teacher/students', payload)
  },
  async updateStudent(id: number, payload: { realName: string; studentNo?: string; groupName?: string }) {
    await http.put(`/teacher/students/${id}`, payload)
  },
  async updateStudentStatus(id: number, status: 'ACTIVE' | 'DISABLED') {
    await http.put(`/teacher/students/${id}/status`, { status })
  },
  async resetStudentPassword(id: number, newPassword?: string) {
    await http.post(`/teacher/students/${id}/reset-password`, { newPassword })
  },
  async teachers() {
    const { data } = await http.get<User[]>('/teacher/teachers')
    return data
  },
  async createTeacher(payload: { username: string; realName: string; email?: string; password?: string }) {
    await http.post('/teacher/teachers', payload)
  },
  async updateTeacherStatus(id: number, status: 'ACTIVE' | 'DISABLED') {
    await http.put(`/teacher/teachers/${id}/status`, { status })
  },
  async resetTeacherPassword(id: number, newPassword?: string) {
    await http.post(`/teacher/teachers/${id}/reset-password`, { newPassword })
  },
  async groups() {
    const { data } = await http.get<ClassGroup[]>('/teacher/groups')
    return data
  },
  async problems() {
    return problemApi.list()
  },
  async submissions(params?: { groupName?: string; studentId?: number }) {
    return submissionApi.list(params)
  },
  async exportGrades(request: { groupId?: number; startDate?: string; endDate?: string; format: string }) {
    const { data } = await http.post('/teacher/grades/export', request, { responseType: 'blob' })
    return data
  },
  async exportStudentGrades(studentId: number, format: 'xlsx' | 'csv' = 'xlsx') {
    const { data } = await http.get(`/teacher/grades/export/student/${studentId}`, { params: { format }, responseType: 'blob' })
    return data
  },
  async createGroup(request: { name: string; teacherName?: string; description?: string }) {
    await http.post('/teacher/groups', request)
  },
  async updateGroup(id: number, request: { name: string; teacherName?: string; description?: string }) {
    await http.put(`/teacher/groups/${id}`, request)
  },
  async deleteGroup(id: number) {
    await http.delete(`/teacher/groups/${id}`)
  },
  async getGroupMembers(groupId: number) {
    const { data } = await http.get<User[]>(`/teacher/groups/${groupId}/members`)
    return data
  },
  async addGroupMembers(groupId: number, studentIds: number[]) {
    await http.post(`/teacher/groups/${groupId}/members`, studentIds)
  },
  async removeGroupMembers(groupId: number, studentIds: number[]) {
    await http.delete(`/teacher/groups/${groupId}/members`, { data: studentIds })
  },
  async exportStudentTemplate() {
    const { data } = await http.get('/teacher/students/template', { responseType: 'blob' })
    return data
  },
  async importStudents(file: File) {
    const formData = new FormData()
    formData.append('file', file)
    const { data } = await http.post('/teacher/students/import', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
    return data
  },
  async exportGroupMembers(groupId: number) {
    const { data } = await http.get(`/teacher/groups/${groupId}/members/export`, { responseType: 'blob' })
    return data
  },
  async importGroupMembers(groupId: number, file: File) {
    const formData = new FormData()
    formData.append('file', file)
    const { data } = await http.post(`/teacher/groups/${groupId}/members/import`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
    return data
  }
}

export const aiApi = {
  async requestSuggestion(request: {
    submissionId: number
    problemId: number
    status: string
    errorMessage?: string
    studentSql: string
  }) {
    const { data } = await http.post('/ai/suggestion', request, { timeout: 30000 })
    return data as { suggestion: string; createdAt?: string }
  },
  async history(problemId: number) {
    const { data } = await http.get('/ai/suggestion/history', { params: { problemId } })
    return data as Array<{ suggestion: string; createdAt?: string }>
  }
}

export const problemAdminApi = {
  async list() {
    const { data } = await http.get<ProblemAdmin[]>('/problem/admin/list')
    return data
  },
  async detail(id: number) {
    const { data } = await http.get<ProblemAdmin>(`/problem/admin/${id}`)
    return data
  },
  async create(payload: ProblemSavePayload) {
    const { data } = await http.post<ProblemAdmin>('/problem/admin', payload)
    return data
  },
  async update(id: number, payload: ProblemSavePayload) {
    const { data } = await http.put<ProblemAdmin>(`/problem/admin/${id}`, payload)
    return data
  },
  async remove(id: number) {
    await http.delete(`/problem/admin/${id}`)
  },
  async exportTemplate() {
    const { data } = await http.get('/problem/admin/template', { responseType: 'blob' })
    return data
  },
  async importProblems(file: File) {
    const formData = new FormData()
    formData.append('file', file)
    const { data } = await http.post('/problem/admin/import', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
    return data as { imported: number }
  }
}

function mapLoginUser(data: any): User {
  return {
    id: data.userId,
    username: data.username,
    realName: data.realName,
    role: data.role,
    studentNo: data.studentNo,
    email: data.email,
    groupName: data.groupName,
    status: data.status
  }
}
