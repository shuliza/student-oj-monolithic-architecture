import { defineStore } from 'pinia'
import { authApi } from '@/api'
import { useProblemStore } from '@/stores/problem'
import { useStatisticsStore } from '@/stores/statistics'
import { clearUserCaches, isCurrentSession, nextSessionGeneration, sessionSnapshot } from '@/utils/session'
import type { User } from '@/types'

interface AuthState { token: string; user: User | null; profileLoaded: boolean }
export const useAuthStore = defineStore('auth', {
  state: (): AuthState => ({ token: localStorage.getItem('token') ?? '', user: JSON.parse(localStorage.getItem('user') ?? 'null') as User | null, profileLoaded: false }),
  getters: { isLoggedIn: s => Boolean(s.token), isTeacher: s => s.user?.role === 'TEACHER' || s.user?.role === 'ADMIN' },
  actions: {
    resetUserState() {
      nextSessionGeneration()
      useProblemStore().resetState()
      useStatisticsStore().resetState()
      clearUserCaches()
    },
    async login(username: string, password: string, role: 'STUDENT' | 'TEACHER') {
      this.resetUserState()
      this.token = ''; this.user = null; this.profileLoaded = false
      localStorage.removeItem('token'); localStorage.removeItem('user')
      const snapshot = sessionSnapshot()
      const result = await authApi.login(username, password, role)
      if (!isCurrentSession(snapshot)) return
      nextSessionGeneration()
      this.token = result.token; this.user = result.user; this.profileLoaded = true
      localStorage.setItem('token', result.token); localStorage.setItem('user', JSON.stringify(result.user))
    },
    async refreshProfile(force = false) {
      if (!this.token || (!force && this.profileLoaded)) return
      const snapshot = sessionSnapshot()
      const user = await authApi.me()
      if (!isCurrentSession(snapshot)) return
      this.user = user; this.profileLoaded = true; localStorage.setItem('user', JSON.stringify(user))
    },
    async logout() {
      const token = this.token
      this.resetUserState()
      this.token = ''; this.user = null; this.profileLoaded = false
      localStorage.removeItem('token'); localStorage.removeItem('user')
      if (token) await authApi.logout().catch(() => undefined)
    }
  }
})
