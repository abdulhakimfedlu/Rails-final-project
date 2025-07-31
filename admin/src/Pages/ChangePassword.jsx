import React, { useState } from 'react'
import useAuthStore from '../stores/authStore'

const ChangePassword = () => {
  const { changePassword, changePhoneNumber, loading, error } = useAuthStore()
  const [oldPassword, setOldPassword] = useState('')
  const [newPassword, setNewPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [success, setSuccess] = useState('')

  // Phone number change state
  const [newPhone, setNewPhone] = useState('')
  const [phonePassword, setPhonePassword] = useState('')
  const [phoneSuccess, setPhoneSuccess] = useState('')
  const [phoneError, setPhoneError] = useState('')

  const handleSubmit = async e => {
    e.preventDefault()
    setSuccess('')
    if (newPassword !== confirmPassword) {
      return alert('New passwords do not match.')
    }
    const result = await changePassword(oldPassword, newPassword)
    if (result) {
      setSuccess('Password changed successfully.')
      setOldPassword('')
      setNewPassword('')
      setConfirmPassword('')
    }
  }

  const handlePhoneSubmit = async e => {
    e.preventDefault()
    setPhoneSuccess('')
    setPhoneError('')
    if (!newPhone || !phonePassword) {
      setPhoneError('Both fields are required.')
      return
    }
    const result = await changePhoneNumber(newPhone, phonePassword)
    if (result.success) {
      setPhoneSuccess(result.message)
      setNewPhone('')
      setPhonePassword('')
    } else {
      setPhoneError(result.message)
    }
  }

  return (
    <div className="flex items-center justify-center min-h-screen bg-gray-50">
      <div className="bg-white p-8 rounded shadow-md w-full max-w-md">
        <form onSubmit={handleSubmit}>
          <h2 className="text-2xl font-bold mb-6 text-center">
            Change Password
          </h2>
          <div className="mb-4">
            <label className="block mb-1 font-medium">Old Password</label>
            <input
              type="password"
              className="w-full border rounded px-3 py-2"
              value={oldPassword}
              onChange={e => setOldPassword(e.target.value)}
              required
              autoComplete="current-password"
            />
          </div>
          <div className="mb-4">
            <label className="block mb-1 font-medium">New Password</label>
            <input
              type="password"
              className="w-full border rounded px-3 py-2"
              value={newPassword}
              onChange={e => setNewPassword(e.target.value)}
              required
              autoComplete="new-password"
              minLength={6}
            />
          </div>
          <div className="mb-4">
            <label className="block mb-1 font-medium">
              Confirm New Password
            </label>
            <input
              type="password"
              className="w-full border rounded px-3 py-2"
              value={confirmPassword}
              onChange={e => setConfirmPassword(e.target.value)}
              required
              autoComplete="new-password"
              minLength={6}
            />
          </div>
          {error && <div className="mb-4 text-red-600 text-sm">{error}</div>}
          {success && (
            <div className="mb-4 text-green-600 text-sm">{success}</div>
          )}
          <button
            type="submit"
            className="w-full bg-blue-600 text-white py-2 rounded hover:bg-blue-700 transition mb-8"
            disabled={loading}
          >
            {loading ? 'Changing...' : 'Change Password'}
          </button>
        </form>

        <form onSubmit={handlePhoneSubmit}>
          <h2 className="text-2xl font-bold mb-6 text-center mt-8">
            Change Phone Number
          </h2>
          <div className="mb-4">
            <label className="block mb-1 font-medium">New Phone Number</label>
            <input
              type="text"
              className="w-full border rounded px-3 py-2"
              value={newPhone}
              onChange={e => setNewPhone(e.target.value)}
              required
              autoComplete="tel"
            />
          </div>
          <div className="mb-4">
            <label className="block mb-1 font-medium">Password</label>
            <input
              type="password"
              className="w-full border rounded px-3 py-2"
              value={phonePassword}
              onChange={e => setPhonePassword(e.target.value)}
              required
              autoComplete="current-password"
            />
          </div>
          {phoneError && (
            <div className="mb-4 text-red-600 text-sm">{phoneError}</div>
          )}
          {phoneSuccess && (
            <div className="mb-4 text-green-600 text-sm">{phoneSuccess}</div>
          )}
          <button
            type="submit"
            className="w-full bg-green-600 text-white py-2 rounded hover:bg-green-700 transition"
            disabled={loading}
          >
            {loading ? 'Changing...' : 'Change Phone Number'}
          </button>
        </form>
      </div>
    </div>
  )
}

export default ChangePassword
