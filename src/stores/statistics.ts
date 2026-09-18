import { defineStore } from 'pinia'
import { statisticsApi } from '@/api'
import { useAuthStore } from '@/stores/auth'
import { isCurrentSession, sessionSnapshot } from '@/utils/session'
import type { ActivityItem } from '@/types'

const emptyOverview = () => ({
  todaySubmissions: 0,
  acceptedProblems: 0,
  activeDays: 0,
  accuracy: 0,
  students: 0,
  problems: 0,
  submissions: 0,
  passRate: 0,
  todayAttempted: 0,
  todayPassed: 0
})

export const useStatisticsStore = defineStore('statistics', {
  state: () => ({
    overview: emptyOverview(),
    activity: [] as ActivityItem[]
  }),
  actions: {
    resetState() {
      this.overview = emptyOverview()
      this.activity = []
    },
    async fetchOverview(params?: { groupName?: string; studentId?: number }) {
      const snapshot = sessionSnapshot()
      try {
        const auth = useAuthStore()
        const overview = auth.isTeacher ? await statisticsApi.teacherOverview(params) : await statisticsApi.overview()
        if (isCurrentSession(snapshot)) this.overview = overview
      } catch {
        if (isCurrentSession(snapshot)) this.overview = emptyOverview()
      }
    },
    async fetchActivity(params?: { groupName?: string; studentId?: number }) {
      const snapshot = sessionSnapshot()
      try {
        const auth = useAuthStore()
        const activity = auth.isTeacher ? await statisticsApi.teacherActivity(params) : await statisticsApi.activity()
        if (isCurrentSession(snapshot)) this.activity = activity
      } catch {
        if (isCurrentSession(snapshot)) this.activity = []
      }
    }
  }
})
