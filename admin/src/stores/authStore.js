import { create } from 'zustand'
import axios from 'axios'

const BACKEND_URL = import.meta.env.VITE_BACKEND_URL

const getInitialToken = () => localStorage.getItem('token') || ''
const getInitialUser = () => {
  const user = localStorage.getItem('user')
  return user ? JSON.parse(user) : null
}

const useAuthStore = create(set => ({
  token: getInitialToken(),
  user: getInitialUser(),
  loading: false,
  error: '',

  login: async (phone, password) => {
    set({ loading: true, error: '' })
    try {
      const res = await axios.post(`${BACKEND_URL}/users/login`, {
        phone,
        password,
      })
      const { token, user } = res.data
      localStorage.setItem('token', token)
      localStorage.setItem('user', JSON.stringify(user))
      set({ token, user, loading: false, error: '' })
      return true
    } catch (err) {
      set({
        error: err.response?.data?.message || 'Login failed',
        loading: false,
      })
      return false
    }
  },

  logout: () => {
    localStorage.removeItem('token')
    localStorage.removeItem('user')
    set({ token: '', user: null })
  },

  changePassword: async (oldPassword, newPassword) => {
    set({ loading: true, error: '' })
    try {
      const token = localStorage.getItem('token')
      await axios.post(
        `${BACKEND_URL}/users/change-password`,
        { oldPassword, newPassword },
        { headers: token ? { Authorization: `Bearer ${token}` } : {} }
      )
      set({ loading: false, error: '' })
      return true
    } catch (err) {
      set({
        error: err.response?.data?.message || 'Password change failed',
        loading: false,
      })
      return false
    }
  },

  changePhoneNumber: async (newPhone, password) => {
    set({ loading: true, error: '' })
    try {
      const token = localStorage.getItem('token')
      const res = await axios.post(
        `${BACKEND_URL}/users/change-phone`,
        { newPhone, password },
        { headers: token ? { Authorization: `Bearer ${token}` } : {} }
      )
      const updatedUser = res.data.user
      localStorage.setItem('user', JSON.stringify(updatedUser))
      set({ user: updatedUser, loading: false, error: '' })
      return { success: true, message: res.data.message }
    } catch (err) {
      set({
        error: err.response?.data?.message || 'Phone number change failed',
        loading: false,
      })
      return {
        success: false,
        message: err.response?.data?.message || 'Phone number change failed',
      }
    }
  },
}))

export default useAuthStore
