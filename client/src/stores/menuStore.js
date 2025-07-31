import { create } from 'zustand'
import axios from 'axios'

const API_URL = import.meta.env.VITE_BACKEND_URL
const CACHE_DURATION = 5 * 60 * 1000 // 5 minutes cache duration

const useMenuStore = create((set, get) => ({
  // State
  categories: [],
  selectedCategory: null,
  menuItems: [],
  loading: true,
  error: null,
  menuLoading: false,
  rating: {},
  ratingMsg: {},
  menuRatings: {},
  // Cache for menu items by category
  _menuItemsCache: {},
  _lastFetchTimes: {},

  // Actions
  fetchCategories: async () => {
    try {
      set({ loading: true, error: null })
      const { data } = await axios.get(`${API_URL}/categories`)
      set({ categories: data })

      // Automatically fetch menu items for the first category
      if (data.length > 0) {
        get().fetchMenuItems(data[0]._id || data[0].id)
      }
      return data
    } catch (error) {
      set({ error: 'Failed to fetch categories' })
      throw error
    } finally {
      set({ loading: false })
    }
  },

  fetchMenuItems: async (categoryId, forceRefresh = false) => {
    const { _menuItemsCache, _lastFetchTimes } = get()
    const now = Date.now()

    // Check if we have a cached version that's still valid
    if (
      !forceRefresh &&
      _menuItemsCache[categoryId] &&
      now - (_lastFetchTimes[categoryId] || 0) < CACHE_DURATION
    ) {
      set({
        menuItems: _menuItemsCache[categoryId].items,
        menuRatings: _menuItemsCache[categoryId].ratings,
        selectedCategory: categoryId,
        menuLoading: false,
      })
      return _menuItemsCache[categoryId].items
    }

    try {
      set({ menuLoading: true, menuItems: [], selectedCategory: categoryId })

      // Fetch menu items
      const { data: menuItems } = await axios.get(
        `${API_URL}/menus/category/${categoryId}`
      )

      // Only proceed with ratings if we have items
      let ratingsObj = {}
      if (menuItems && menuItems.length > 0) {
        // Fetch ratings for all menu items in parallel
        const ratingsPromises = menuItems.map(async item => {
          try {
            const { data } = await axios.get(
              `${API_URL}/ratings/menu/${item._id || item.id}/average`
            )
            return { id: item._id || item.id, ...data }
          } catch {
            return { id: item._id || item.id, avgRating: 0, count: 0 }
          }
        })

        const ratings = await Promise.all(ratingsPromises)
        ratingsObj = ratings.reduce(
          (acc, r) => ({
            ...acc,
            [r.id]: { avgRating: r.avgRating, count: r.count },
          }),
          {}
        )
      }

      // Update cache
      const cacheEntry = {
        items: menuItems,
        ratings: ratingsObj,
        timestamp: now,
      }

      set({
        menuItems,
        menuRatings: ratingsObj,
        _menuItemsCache: {
          ..._menuItemsCache,
          [categoryId]: cacheEntry,
        },
        _lastFetchTimes: {
          ..._lastFetchTimes,
          [categoryId]: now,
        },
      })

      return menuItems
    } catch (error) {
      set({ error: 'Failed to fetch menu items' })
      throw error
    } finally {
      set({ menuLoading: false })
    }
  },

  // Force refresh the current category
  refreshCurrentCategory: async () => {
    const { selectedCategory } = get()
    if (selectedCategory) {
      return get().fetchMenuItems(selectedCategory, true)
    }
  },

  handleRatingChange: (menuId, value) => {
    set(state => ({
      rating: {
        ...state.rating,
        [menuId]: state.rating[menuId] === value ? 0 : value,
      },
      ratingMsg: {
        ...state.ratingMsg,
        [menuId]: '', // Clear any previous messages
      },
    }))
  },

  submitRating: async menuId => {
    const { rating, menuRatings } = get()
    if (!rating[menuId]) return

    const today = new Date().toISOString().slice(0, 10)
    const userRatingKey = `user_rated_${menuId}_${today}`

    // Check if user has already rated this item today
    const hasRatedToday = localStorage.getItem(userRatingKey)
    if (hasRatedToday) {
      set(state => ({
        ratingMsg: {
          ...state.ratingMsg,
          [menuId]: 'You have already rated this item today.',
        },
      }))
      return
    }

    try {
      const _response = await axios.post(`${API_URL}/ratings`, {
        menu: menuId,
        stars: rating[menuId],
      })

      // Mark that user has rated this item today
      localStorage.setItem(userRatingKey, 'true')

      // Fetch updated rating average from server
      try {
        const { data: avgData } = await axios.get(
          `${API_URL}/ratings/menu/${menuId}/average`
        )

        set(state => ({
          menuRatings: {
            ...state.menuRatings,
            [menuId]: {
              avgRating: avgData.avgRating || 0,
              count: avgData.count || 0,
            },
          },
          rating: {
            ...state.rating,
            [menuId]: 0, // Reset the selected rating
          },
          ratingMsg: {
            ...state.ratingMsg,
            [menuId]: 'Thank you for your rating!',
          },
        }))
      } catch {
        // If fetching average fails, update with local calculation
        const currentRating = menuRatings[menuId] || { avgRating: 0, count: 0 }
        const newCount = currentRating.count + 1
        const newAvg =
          (currentRating.avgRating * currentRating.count + rating[menuId]) /
          newCount

        set(state => ({
          menuRatings: {
            ...state.menuRatings,
            [menuId]: {
              avgRating: newAvg,
              count: newCount,
            },
          },
          rating: {
            ...state.rating,
            [menuId]: 0, // Reset the selected rating
          },
          ratingMsg: {
            ...state.ratingMsg,
            [menuId]: 'Thank you for your rating!',
          },
        }))
      }
    } catch (error) {
      console.error('Rating submission error:', error)
      console.error('Error details:', {
        status: error.response?.status,
        data: error.response?.data,
        message: error.message,
      })
      const errorMessage =
        error.response?.data?.message ||
        'Failed to submit rating. Please try again.'
      set(state => ({
        ratingMsg: {
          ...state.ratingMsg,
          [menuId]: errorMessage,
        },
      }))
    }
  },

  // Reset state when needed
  reset: () =>
    set({
      categories: [],
      selectedCategory: null,
      menuItems: [],
      loading: false,
      error: null,
      menuLoading: false,
      rating: {},
      ratingMsg: {},
      menuRatings: {},
      _menuItemsCache: {},
      _lastFetchTimes: {},
    }),
}))

export default useMenuStore
