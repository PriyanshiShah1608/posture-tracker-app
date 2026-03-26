import { BottomNav } from "../components/BottomNav";
import {
  User,
  Settings,
  Bell,
  HelpCircle,
  Shield,
  LogOut,
  ChevronRight,
  Heart,
} from "lucide-react";

export function Profile() {
  const menuItems = [
    { icon: Settings, label: "Account Settings", hasChevron: true },
    { icon: Bell, label: "Notifications", hasChevron: true },
    { icon: Heart, label: "Health Data", hasChevron: true },
    { icon: Shield, label: "Privacy & Security", hasChevron: true },
    { icon: HelpCircle, label: "Help & Support", hasChevron: true },
  ];

  return (
    <div className="min-h-screen bg-gray-50 pb-24">
      {/* Status Bar */}
      <div className="pt-4 px-6 flex justify-between items-center text-sm text-gray-700">
        <span>08:51</span>
      </div>

      {/* Header */}
      <div className="px-6 pt-8 pb-6">
        <h1 className="text-4xl mb-8 text-gray-900 tracking-tight">Profile</h1>

        {/* Profile Picture & Info */}
        <div className="bg-white rounded-3xl p-6 mb-6 shadow-md border border-gray-100">
          <div className="flex items-center gap-4 mb-4">
            <div className="w-20 h-20 bg-indigo-600 rounded-2xl flex items-center justify-center shadow-lg">
              <User className="w-10 h-10 text-white" strokeWidth={1.5} />
            </div>
            <div className="flex-1">
              <h2 className="text-2xl mb-1 text-gray-900 font-medium">Sarah Johnson</h2>
              <p className="text-gray-600">sarah.j@email.com</p>
            </div>
          </div>
          
          {/* Quick Stats */}
          <div className="grid grid-cols-3 gap-3 pt-4 border-t border-gray-100">
            <div className="text-center">
              <p className="text-2xl text-indigo-600 font-semibold mb-1">12</p>
              <p className="text-xs text-gray-600">Sessions</p>
            </div>
            <div className="text-center border-x border-gray-100">
              <p className="text-2xl text-purple-600 font-semibold mb-1">5</p>
              <p className="text-xs text-gray-600">Day Streak</p>
            </div>
            <div className="text-center">
              <p className="text-2xl text-green-600 font-semibold mb-1">89</p>
              <p className="text-xs text-gray-600">Avg Score</p>
            </div>
          </div>
        </div>

        {/* Menu Items */}
        <div className="space-y-2 mb-6">
          {menuItems.map((item, index) => {
            const Icon = item.icon;
            return (
              <button
                key={index}
                className="w-full bg-white rounded-2xl p-4 flex items-center gap-4 hover:shadow-lg transition-all border border-gray-100 group"
              >
                <div className="w-11 h-11 bg-indigo-50 rounded-xl flex items-center justify-center group-hover:bg-indigo-100 transition-all">
                  <Icon className="w-5 h-5 text-indigo-600" strokeWidth={1.5} />
                </div>
                <span className="flex-1 text-left text-gray-900 font-medium">
                  {item.label}
                </span>
                {item.hasChevron && (
                  <ChevronRight className="w-5 h-5 text-gray-400 group-hover:text-indigo-600 transition-all" />
                )}
              </button>
            );
          })}
        </div>

        {/* Logout Button */}
        <button className="w-full bg-red-600 text-white py-5 rounded-2xl text-lg font-medium flex items-center justify-center gap-2 shadow-lg hover:bg-red-700 transition-all">
          <LogOut className="w-5 h-5" strokeWidth={2} />
          Sign Out
        </button>

        {/* App Version */}
        <p className="text-center text-gray-500 text-sm mt-6">
          Posturely v2.0.0 • Medical Edition
        </p>
      </div>

      <BottomNav />
    </div>
  );
}