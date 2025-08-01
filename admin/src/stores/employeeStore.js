import { create } from 'zustand'
import axios from 'axios'
import useAuthStore from './authStore'

const BACKEND_URL = import.meta.env.VITE_BACKEND_URL

// Create axios instance with interceptors
const api = axios.create({
  baseURL: BACKEND_URL,
})

// Add request interceptor to include token
api.interceptors.request.use(
  (config) => {
    const { token } = useAuthStore.getState()
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// Add response interceptor to handle auth errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Token expired or invalid, logout user
      useAuthStore.getState().logout()
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

const initialForm = {
  name: '',
  phone: '',
  position: 'waiter',
  salary: '',
  description: '',
  workingHour: '',
  tableAssigned: '',
  status: 'active',
}

export const useEmployeeStore = create((set, get) => ({
  employees: [],
  loading: false,
  error: null,
  actionLoading: false,
  form: initialForm,
  editId: null,
  showForm: false,
  showFired: false,
  setShowForm: val => set({ showForm: val }),
  setShowFired: val => set({ showFired: val }),
  setForm: form => set({ form }),
  setEditId: id => set({ editId: id }),
  setActionLoading: val => set({ actionLoading: val }),
  setField: (name, value) =>
    set(state => ({ form: { ...state.form, [name]: value } })),
  resetForm: () => set({ form: initialForm, editId: null }),

  fetchEmployees: async () => {
    set({ loading: true, error: null })
    try {
      const res = await api.get('/employees/')
      set({ employees: res.data, error: null })
    } catch (error) {
      console.error('Error fetching employees:', error)
      set({ error: error.response?.data?.message || 'Failed to fetch employees' })
    } finally {
      set({ loading: false })
    }
  },

  openCreate: () => {
    set({ form: initialForm, editId: null, showForm: true })
  },

  openEdit: emp => {
    set({
      form: {
        name: emp.name || '',
        phone: emp.phone || '',
        position: emp.position || 'waiter',
        salary: emp.salary || '',
        description: emp.description || '',
        workingHour: emp.workingHour || '',
        tableAssigned: emp.tableAssigned || '',
        status: emp.status || 'active',
        image: emp.image || '',
      },
      editId: emp._id,
      showForm: true,
    })
  },

  handleSubmit: async e => {
    e.preventDefault()
    set({ actionLoading: true })
    const { form, editId, fetchEmployees, setShowForm } = get()
    try {
      const formData = new FormData()
      Object.entries(form).forEach(([key, value]) => {
        if (value !== undefined && value !== null) formData.append(key, value)
      })
      if (editId) {
        await api.put(`/employees/${editId}`, formData, {
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        })
      } else {
        await api.post('/employees/', formData, {
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        })
      }
      setShowForm(false)
      fetchEmployees()
    } catch (error) {
      console.error('Error saving employee:', error)
      alert(error.response?.data?.message || 'Failed to save employee')
    } finally {
      set({ actionLoading: false })
    }
  },

  handleDelete: async id => {
    if (!window.confirm('Delete this employee?')) return
    set({ actionLoading: true })
    const { fetchEmployees } = get()
    try {
      await api.delete(`/employees/${id}`)
      fetchEmployees()
    } catch (error) {
      console.error('Error deleting employee:', error)
      alert(error.response?.data?.message || 'Failed to delete employee')
    } finally {
      set({ actionLoading: false })
    }
  },
}))
