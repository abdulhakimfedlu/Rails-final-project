import React, { useEffect, useState, useRef } from 'react'
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
  const [showConfirmModal, setShowConfirmModal] = useState(false)
  const [itemToUpdate, setItemToUpdate] = useState(null)
  const modalRef = useRef()

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

  const handleConfirmClick = (item) => {
    setItemToUpdate(item)
    setShowConfirmModal(true)
  }

  const handleConfirmToggle = async () => {
    if (!itemToUpdate) return
    
    setShowConfirmModal(false)
    
    try {
      setUpdatingId(itemToUpdate._id)
      setStatusMsg('')
      
      // Toggle the outOfStock status
      const updatedItem = { ...itemToUpdate, outOfStock: !itemToUpdate.outOfStock }
      const formData = new FormData()
      Object.entries(updatedItem).forEach(([key, value]) => {
        if (value !== null && value !== undefined) {
          formData.append(key, value)
        }
      })
      
      await updateMenuItem(itemToUpdate._id, formData)
      
      // Update local state to reflect the change
      const updatedItems = { ...outOfStockItems }
      Object.keys(updatedItems).forEach(categoryId => {
        updatedItems[categoryId] = updatedItems[categoryId].filter(
          i => i._id !== itemToUpdate._id
        )
      })
      
      setOutOfStockItems(updatedItems)
      setStatusMsg(`"${itemToUpdate.name}" marked as ${updatedItem.outOfStock ? 'out of stock' : 'in stock'}`)
      
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
                  onClick={() => handleConfirmClick(item)}
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

      {/* Confirmation Modal */}
      {showConfirmModal && itemToUpdate && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 px-4">
          <div 
            ref={modalRef}
            className="bg-white rounded-lg p-6 w-full max-w-md mx-4 shadow-xl"
          >
            <h3 className="text-lg font-semibold mb-4">
              Confirm Status Change
            </h3>
            <p className="mb-6">
              Are you sure you want to mark "{itemToUpdate.name}" as {itemToUpdate.outOfStock ? 'IN STOCK' : 'OUT OF STOCK'}?
            </p>
            <div className="flex justify-end space-x-3">
              <button
                onClick={() => setShowConfirmModal(false)}
                className="px-4 py-2 text-gray-600 hover:bg-gray-100 rounded"
              >
                Cancel
              </button>
              <button
                onClick={handleConfirmToggle}
                className={`px-4 py-2 text-white rounded ${
                  itemToUpdate.outOfStock 
                    ? 'bg-green-600 hover:bg-green-700' 
                    : 'bg-red-600 hover:bg-red-700'
                }`}
              >
                Confirm
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

export default OutOfStock
