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
  config => {
    const { token } = useAuthStore.getState()
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  error => {
    return Promise.reject(error)
  }
)

// Add response interceptor to handle auth errors
api.interceptors.response.use(
  response => response,
  error => {
    if (error.response?.status === 401) {
      // Token expired or invalid, logout user
      useAuthStore.getState().logout()
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

const useMenuStore = create((set, get) => ({
  categories: [],
  menuItems: {},
  loading: false,
  error: null,
  selectedCategory: null,
  // Fetch categories and menu items
  fetchCategoriesAndMenus: async () => {
    set({ loading: true, error: null })
    try {
      const catRes = await api.get('/categories/')
      const categories = catRes.data
      // Fetch menu items for each category
      const menuPromises = categories.map(cat =>
        api.get(`/menus/category/${cat._id}`)
      )
      const menuResults = await Promise.all(menuPromises)
      const menuMap = {}
      categories.forEach((cat, idx) => {
        menuMap[cat._id] = menuResults[idx].data
      })
      set({
        categories,
        menuItems: menuMap,
        selectedCategory: get().selectedCategory || categories[0]?._id || null,
        loading: false,
        error: null,
      })
    } catch (error) {
      console.error('Error fetching categories and menus:', error)
      set({
        error: error.response?.data?.message || 'Failed to fetch data',
        loading: false,
      })
    }
  },
  setSelectedCategory: id => set({ selectedCategory: id }),
  // Category CRUD
  addCategory: async name => {
    try {
      await api.post('/categories/', { name })
      await get().fetchCategoriesAndMenus()
    } catch (error) {
      console.error('Error adding category:', error)
      throw new Error(error.response?.data?.message || 'Failed to add category')
    }
  },
  updateCategory: async (_id, name) => {
    try {
      await api.put(`/categories/${_id}`, { name })
      await get().fetchCategoriesAndMenus()
    } catch (error) {
      console.error('Error updating category:', error)
      throw new Error(
        error.response?.data?.message || 'Failed to update category'
      )
    }
  },
  deleteCategory: async _id => {
    try {
      await api.delete(`/categories/${_id}`)
      await get().fetchCategoriesAndMenus()
    } catch (error) {
      console.error('Error deleting category:', error)
      throw new Error(
        error.response?.data?.message || 'Failed to delete category'
      )
    }
  },
  // Menu CRUD
  addMenuItem: async (categoryId, formData) => {
    try {
      await api.post(`/menus/category/${categoryId}`, formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      })
      await get().fetchCategoriesAndMenus()
    } catch (error) {
      console.error('Error adding menu item:', error)
      throw new Error(
        error.response?.data?.message || 'Failed to add menu item'
      )
    }
  },
  updateMenuItem: async (_id, formData) => {
    try {
      await api.put(`/menus/${_id}`, formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      })
      await get().fetchCategoriesAndMenus()
    } catch (error) {
      console.error('Error updating menu item:', error)
      throw new Error(
        error.response?.data?.message || 'Failed to update menu item'
      )
    }
  },
  deleteMenuItem: async _id => {
    try {
      await api.delete(`/menus/${_id}`)
      await get().fetchCategoriesAndMenus()
    } catch (error) {
      console.error('Error deleting menu item:', error)
      throw new Error(
        error.response?.data?.message || 'Failed to delete menu item'
      )
    }
  },
}))

export default useMenuStore
