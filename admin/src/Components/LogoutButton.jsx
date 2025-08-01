import React, { useState } from 'react';
import { LogOut } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import useAuthStore from '../stores/authStore';

const LogoutButton = ({ isCollapsed }) => {
  const navigate = useNavigate();
  const { logout } = useAuthStore();
  const [showLogoutModal, setShowLogoutModal] = useState(false);

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  return (
    <>
      <button
        onClick={() => setShowLogoutModal(true)}
        className={`
          w-full flex items-center space-x-3 px-3 py-3 rounded-xl
          transition-all duration-200 ease-in-out group relative
          text-slate-300 hover:text-white hover:bg-slate-700/50
          mt-4
        `}
      >
        <LogOut
          size={20}
          className="transition-transform duration-200 min-w-5 group-hover:scale-105"
        />
        {!isCollapsed && (
          <span className="font-medium transition-all duration-200">
            Logout
          </span>
        )}
        {isCollapsed && (
          <div className="absolute left-full ml-2 px-2 py-1 bg-slate-800 text-white text-sm rounded-lg opacity-0 group-hover:opacity-100 transition-opacity duration-200 pointer-events-none whitespace-nowrap z-50">
            Logout
            <div className="absolute top-1/2 left-0 transform -translate-y-1/2 -translate-x-1 w-2 h-2 bg-slate-800 rotate-45" />
          </div>
        )}
      </button>

      {/* Logout Confirmation Modal */}
      {showLogoutModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          <div className="fixed inset-0 bg-black bg-opacity-50" onClick={() => setShowLogoutModal(false)}></div>
          <div className="relative bg-slate-800 p-6 rounded-xl w-full max-w-sm">
            <h3 className="text-xl font-bold text-white mb-4">Confirm Logout</h3>
            <p className="text-slate-300 mb-6">Are you sure you want to log out?</p>
            <div className="flex justify-end space-x-3">
              <button
                onClick={() => setShowLogoutModal(false)}
                className="px-4 py-2 text-sm font-medium text-white bg-slate-700 hover:bg-slate-600 rounded-lg transition-colors"
              >
                Cancel
              </button>
              <button
                onClick={handleLogout}
                className="px-4 py-2 text-sm font-medium text-white bg-red-600 hover:bg-red-700 rounded-lg transition-colors"
              >
                Logout
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default LogoutButton;
