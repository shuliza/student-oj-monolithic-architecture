import { defineStore } from 'pinia'
import { problemApi, submissionApi } from '@/api'
import { useAuthStore } from '@/stores/auth'
import { isCurrentSession, sessionSnapshot } from '@/utils/session'
import type { Problem, Submission } from '@/types'

export const useProblemStore = defineStore('problem', {
  state: () => ({
    problems: [] as Problem[],
    submissions: [] as Submission[]
  }),
  actions: {
    resetState() {
      this.problems = []
      this.submissions = []
    },
    async fetchProblems() {
      const snapshot = sessionSnapshot()
      try {
        const problems = await problemApi.list()
        if (isCurrentSession(snapshot)) this.problems = problems
      } catch {
        if (isCurrentSession(snapshot)) this.problems = []
      }
    },
    async fetchSubmissions(params?: { groupName?: string; studentId?: number }) {
      const snapshot = sessionSnapshot()
      try {
        const auth = useAuthStore()
        const submissions = auth.isTeacher ? await submissionApi.list(params) : await submissionApi.mine()
        if (isCurrentSession(snapshot)) this.submissions = submissions
      } catch {
        if (isCurrentSession(snapshot)) this.submissions = []
      }
    }
  }
})
