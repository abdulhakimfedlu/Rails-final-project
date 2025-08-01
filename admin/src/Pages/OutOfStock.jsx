import React, { useEffect, useState } from 'react'
import axios from 'axios'
import useMenuStore from '../stores/menuStore'

const BACKEND_URL = import.meta.env.VITE_BACKEND_URL

const OutOfStock = () => {
  const { updateMenuItem } = useMenuStore()
  const [categories, setCategories] = useState([])
  const [outOfStockItems, setOutOfStockItems] = useState({})
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  const [updatingId, setUpdatingId] = useState(null)
  const [statusMsg, setStatusMsg] = useState('')

  useEffect(() => {
    const fetchOutOfStock = async () => {
      try {
        setLoading(true)
        // Fetch all categories
        const catRes = await axios.get(`${BACKEND_URL}/categories/`)
        setCategories(catRes.data)
        // Fetch menu items for each category
        const menuPromises = catRes.data.map(cat =>
          axios.get(`${BACKEND_URL}/menus/category/${cat._id}`)
        )
        const menuResults = await Promise.all(menuPromises)
        const outMap = {}
        catRes.data.forEach((cat, idx) => {
          outMap[cat._id] = menuResults[idx].data.filter(
            item => item.outOfStock
          )
        })
        setOutOfStockItems(outMap)
      } catch {
        setError('Failed to fetch data')
      } finally {
        setLoading(false)
      }
    }
    fetchOutOfStock()
  }, [])

  const toggleStockStatus = async (item) => {
    try {
      setUpdatingId(item._id)
      setStatusMsg('')
      
      // Toggle the outOfStock status
      const updatedItem = { ...item, outOfStock: !item.outOfStock }
      const formData = new FormData()
      Object.entries(updatedItem).forEach(([key, value]) => {
        if (value !== null && value !== undefined) {
          formData.append(key, value)
        }
      })
      
      await updateMenuItem(item._id, formData)
      
      // Update local state to reflect the change
      const updatedItems = { ...outOfStockItems }
      Object.keys(updatedItems).forEach(categoryId => {
        updatedItems[categoryId] = updatedItems[categoryId].filter(
          i => i._id !== item._id
        )
      })
      
      setOutOfStockItems(updatedItems)
      setStatusMsg(`"${item.name}" marked as ${updatedItem.outOfStock ? 'out of stock' : 'in stock'}`)
      
      // Clear status message after 3 seconds
      setTimeout(() => {
        setStatusMsg('')
      }, 3000)
      
    } catch (error) {
      console.error('Error updating stock status:', error)
      setError('Failed to update stock status')
    } finally {
      setUpdatingId(null)
    }
  }

  if (loading)
    return (
      <div className="flex items-center justify-center h-64">
        <span className="loader"></span> Loading...
      </div>
    )
  if (error)
    return (
      <div className="text-red-500 text-center text-sm sm:text-base">
        {error}
      </div>
    )

  return (
    <div className="p-4 sm:p-6 max-w-7xl mx-auto">
      <h1 className="text-2xl sm:text-3xl font-bold mb-4 sm:mb-6 text-center text-pink-700">
        Out of Stock Menu Items
      </h1>
      {categories.length === 0 && (
        <div className="text-center text-sm sm:text-base">
          No categories found.
        </div>
      )}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6">
        {categories.some(cat => outOfStockItems[cat._id]?.length > 0) ? (
          categories.map(category =>
            outOfStockItems[category._id]?.map(item => (
              <div
                key={item._id}
                className="border rounded-lg p-4 sm:p-5 shadow bg-gray-50 relative"
              >
                <h3 className="font-bold text-base sm:text-lg text-pink-700">
                  {item.name}
                </h3>
                <p className="text-gray-600 text-sm sm:text-base mb-1">
                  {item.ingredients}
                </p>
                <p className="text-pink-600 font-semibold text-sm sm:text-base mb-1">
                  ${item.price}
                </p>
                {item.badge && (
                  <span className="inline-block mt-1 px-2 py-1 bg-pink-200 text-pink-800 rounded text-xs sm:text-sm">
                    {item.badge}
                  </span>
                )}
                {item.image && (
                  <img
                    src={item.image}
                    alt={item.name}
                    className="mt-2 w-full h-24 sm:h-32 object-cover rounded"
                  />
                )}
                <button
                  onClick={() => toggleStockStatus(item)}
                  disabled={updatingId === item._id}
                  className={`absolute top-2 right-2 px-2 py-1 rounded text-xs sm:text-sm ${
                    item.outOfStock 
                      ? 'bg-green-100 text-green-700 hover:bg-green-200' 
                      : 'bg-red-100 text-red-700 hover:bg-red-200'
                  }`}
                >
                  {updatingId === item._id 
                    ? 'Updating...' 
                    : item.outOfStock ? 'Mark In Stock' : 'Mark Out of Stock'}
                </button>
              </div>
            ))
          )
        ) : (
          <div className="col-span-full text-center text-gray-400 py-6 sm:py-8 text-sm sm:text-base">
            LOL, looks like everything's in stock! Time to feast!
          </div>
        )}
      </div>
      {statusMsg && (
        <div className="fixed bottom-4 right-4 bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded">
          {statusMsg}
        </div>
      )}
    </div>
  )
}

export default OutOfStock
