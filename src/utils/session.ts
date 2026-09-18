import axios from 'axios'

let generation = 0
let controller = new AbortController()

export function sessionSnapshot() {
  return { generation, userId: readUserId(), token: localStorage.getItem('token') ?? '' }
}
export function readUserId(): number | null {
  try { const user = JSON.parse(localStorage.getItem('user') ?? 'null'); return typeof user?.id === 'number' ? user.id : null } catch { return null }
}
export function nextSessionGeneration() {
  generation += 1
  controller.abort()
  controller = new AbortController()
  return generation
}
export function sessionSignal() { return controller.signal }
export function isCurrentSession(snapshot: { generation: number; userId: number | null; token: string }) {
  return snapshot.generation === generation && snapshot.userId === readUserId() && snapshot.token === (localStorage.getItem('token') ?? '')
}
export function isAbortError(error: unknown) { return axios.isCancel(error) || (error instanceof DOMException && error.name === 'AbortError') }
export function clearUserCaches() {
  for (const key of Object.keys(localStorage)) if (/^(sql-draft:|page-cache:|ai-cache:|submission-cache:|statistics-cache:)/.test(key)) localStorage.removeItem(key)
}
