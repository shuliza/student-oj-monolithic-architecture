import axios from 'axios'
import { ElMessage } from 'element-plus'
import { sessionSignal, nextSessionGeneration, clearUserCaches } from '@/utils/session'

const http = axios.create({
  baseURL: '/api',
  timeout: 15000
})

http.interceptors.request.use((config) => {
  const token = localStorage.getItem('token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  config.signal ??= sessionSignal()
  return config
})

http.interceptors.response.use(
  (response) => response,
  (error) => {
    const status = error.response?.status
    const message = error.response?.data?.message ?? error.response?.data?.error ?? error.message ?? '请求失败'
    if (status === 401) {
      nextSessionGeneration()
      clearUserCaches()
      localStorage.removeItem('token')
      localStorage.removeItem('user')
      ElMessage.error('登录已失效，请重新登录')
      if (window.location.pathname !== '/login') {
        window.location.href = '/login'
      }
    } else {
      ElMessage.error(message)
    }
    return Promise.reject(error)
  }
)

export default http
