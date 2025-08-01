import React, { useState, useEffect } from 'react'
import { Menu as MenuIcon, X } from 'lucide-react'
import { Link, useLocation } from 'react-router-dom'

const Navbar = () => {
  const [isOpen, setIsOpen] = useState(false)
  const [scrolled, setScrolled] = useState(false)
  const [_mousePosition, setMousePosition] = useState({ x: 0, y: 0 })
  const location = useLocation()

  const navigation = [
    { name: 'Home', id: 'home', icon: '🏠', path: '/' },
    { name: 'Menu', id: 'menu', icon: '🍵', path: '/menu' },
    { name: 'About', id: 'about', icon: '💫', path: '/about' },
    { name: 'Contact Us', id: 'contact', icon: '📞', path: '/contact' },
  ]

  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 20)
    }
    window.addEventListener('scroll', handleScroll)
    return () => window.removeEventListener('scroll', handleScroll)
  }, [])

  useEffect(() => {
    const handleMouseMove = e => {
      setMousePosition({ x: e.clientX, y: e.clientY })
    }
    window.addEventListener('mousemove', handleMouseMove)
    return () => window.removeEventListener('mousemove', handleMouseMove)
  }, [])

  // Get active tab from location
  const getActiveTab = () => {
    // Special case: '/' is Home
    if (location.pathname === '/') return 'Home'
    const found = navigation.find(item => item.path === location.pathname)
    return found ? found.name : ''
  }
  const activeTab = getActiveTab()

  return (
    <div className="position-relative relative overflow-hidden">
      {/* Navigation Bar */}
      <nav
        className={`fixed top-0 left-0 right-0 z-50 transition-all duration-500 ${
          scrolled
            ? 'bg-white/10 backdrop-blur-2xl border-b border-white/20 shadow-2xl'
            : 'bg-transparent'
        }`}
      >
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-20">
            {/* Logo */}
            <div className="flex-shrink-0 group">
              <Link
                to="/"
                className="flex items-center cursor-pointer transform transition-all duration-300 hover:scale-110"
                onClick={() => setIsOpen(false)}
              >
                <div className="relative flex items-center">
                  <img
                    src="/image.png"
                    alt="Akaka Coffee Logo"
                    className="h-12 w-12 rounded-2xl shadow-2xl object-cover"
                  />
                </div>
                <div className="ml-3">
                  <span className="text-2xl font-black bg-gradient-to-r from-purple-600 via-pink-600 to-orange-600 bg-clip-text text-transparent">
                    Akaka Coffee
                  </span>
                  <div className="text-xs text-gray-500 font-medium tracking-wider">
                    PREMIUM EXPERIENCE
                  </div>
                </div>
              </Link>
            </div>

            {/* Desktop Navigation */}
            <div className="hidden md:block">
              <div className="flex items-center space-x-2 bg-white/10 backdrop-blur-xl rounded-2xl p-2 border border-white/20 shadow-2xl">
                {navigation.map((item, index) => (
                  <Link
                    key={item.name}
                    to={item.path}
                    onClick={() => setIsOpen(false)}
                    className={`group relative px-6 py-3 rounded-xl text-sm font-bold transition-all duration-300 overflow-hidden ${
                      activeTab === item.name
                        ? 'bg-gradient-to-r from-gray-800 to-brown-900 text-white shadow-2xl shadow-brown-500/50 transform scale-105'
                        : 'text-gray-300 hover:text-white hover:bg-gradient-to-r hover:from-black-800 hover:to-brown-400 hover:scale-110 hover:shadow-lg'
                    }`}
                    style={{
                      animationDelay: `${index * 0.1}s`,
                      textShadow:
                        '0 1px 6px rgba(0,0,0,0.18), 0 0px 1px rgba(0,0,0,0.12)',
                    }}
                  >
                    <div className="flex items-center space-x-2 relative z-10">
                      <span className="text-lg">{item.icon}</span>
                      <span>{item.name}</span>
                    </div>
                    {activeTab === item.name && (
                      <div className="absolute inset-0 bg-gradient-to-r from-purple-600 to-pink-600 opacity-80 animate-pulse" />
                    )}
                    <div className="absolute inset-0 bg-gradient-to-r from-white/0 via-white/20 to-white/0 transform -skew-x-12 -translate-x-full group-hover:translate-x-full transition-transform duration-700" />
                  </Link>
                ))}
              </div>
            </div>

            {/* Mobile menu button */}
            <div className="md:hidden">
              <button
                onClick={() => setIsOpen(!isOpen)}
                className="relative p-3 rounded-2xl bg-gradient-to-r from-purple-500 to-pink-500 text-white shadow-2xl shadow-purple-500/50 transition-all duration-300 hover:scale-110 hover:rotate-12"
              >
                <div className="relative z-10">
                  {isOpen ? (
                    <X className="h-6 w-6 animate-spin" />
                  ) : (
                    <MenuIcon className="h-6 w-6" />
                  )}
                </div>
                <div className="absolute inset-0 bg-gradient-to-r from-pink-600 to-purple-600 rounded-2xl opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
              </button>
            </div>
          </div>
        </div>

        {/* Mobile Navigation Menu */}
        <div
          className={`md:hidden transition-all duration-500 ease-out ${
            isOpen
              ? 'max-h-96 opacity-100 translate-y-0'
              : 'max-h-0 opacity-0 -translate-y-4 overflow-hidden'
          }`}
        >
          <div className="mx-4 mb-4 bg-white/10 backdrop-blur-2xl rounded-2xl border border-white/20 shadow-2xl overflow-hidden">
            {navigation.map((item, index) => (
              <Link
                key={item.name}
                to={item.path}
                onClick={() => setIsOpen(false)}
                className={`w-full flex items-center space-x-3 px-6 py-4 text-left font-bold transition-all duration-300 ${
                  activeTab === item.name
                    ? 'bg-gradient-to-r from-purple-500 to-pink-500 text-white shadow-lg'
                    : 'text-gray-700 hover:bg-gradient-to-r hover:from-purple-100 hover:to-pink-100 hover:text-gray-900'
                } ${index !== navigation.length - 1 ? 'border-b border-white/10' : ''}`}
                style={{
                  animationDelay: `${index * 0.1}s`,
                  transform: isOpen ? 'translateX(0)' : 'translateX(-20px)',
                  textShadow:
                    '0 1px 6px rgba(0,0,0,0.18), 0 0px 1px rgba(0,0,0,0.12)',
                }}
              >
                <span className="text-2xl">{item.icon}</span>
                <span className="text-lg">{item.name}</span>
                {activeTab === item.name && (
                  <div className="ml-auto">
                    <div className="w-2 h-2 bg-white rounded-full animate-pulse" />
                  </div>
                )}
              </Link>
            ))}
          </div>
        </div>
      </nav>
    </div>
  )
}

export default Navbar
