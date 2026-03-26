import { useNavigate, useLocation } from "react-router";
import { Activity, Camera, Dumbbell, BarChart3, User } from "lucide-react";

export function BottomNav() {
  const navigate = useNavigate();
  const location = useLocation();

  const navItems = [
    { path: "/home", icon: Activity, label: "Track" },
    { path: "/scan", icon: Camera, label: "Scan" },
    { path: "/exercises", icon: Dumbbell, label: "Exercise" },
    { path: "/stats", icon: BarChart3, label: "Stats" },
    { path: "/profile", icon: User, label: "Profile" },
  ];

  return (
    <nav className="fixed bottom-4 left-4 right-4 bg-white rounded-3xl shadow-2xl border border-gray-200">
      <div className="max-w-md mx-auto flex justify-around items-center h-16 px-2">
        {navItems.map((item) => {
          const Icon = item.icon;
          const isActive = location.pathname === item.path;
          return (
            <button
              key={item.path}
              onClick={() => navigate(item.path)}
              className={`flex flex-col items-center justify-center gap-1 px-4 py-2 rounded-2xl transition-all ${
                isActive ? "bg-indigo-600 text-white" : "text-gray-400 hover:text-gray-600 hover:bg-gray-50"
              }`}
            >
              <Icon className="w-5 h-5" strokeWidth={isActive ? 2.5 : 1.5} />
              <span className={`text-xs ${isActive ? "font-semibold" : ""}`}>{item.label}</span>
            </button>
          );
        })}
      </div>
    </nav>
  );
}