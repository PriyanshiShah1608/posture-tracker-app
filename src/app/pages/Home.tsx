import { useState } from "react";
import { Camera, Smartphone } from "lucide-react";
import { BottomNav } from "../components/BottomNav";

export function Home() {
  const [selectedDevice, setSelectedDevice] = useState("camera");

  const devices = [
    { id: "camera", label: "Camera", icon: Camera },
    { id: "phone", label: "Phone", icon: Smartphone },
  ];

  return (
    <div className="min-h-screen bg-gray-50 pb-24">
      {/* Status Bar */}
      <div className="pt-4 px-6 flex justify-between items-center text-sm text-gray-700">
        <span>01:08</span>
      </div>

      {/* Main Content */}
      <div className="px-6 pt-8">
        {/* Welcome Message */}
        <div className="mb-8">
          <h1 className="text-4xl mb-3 text-gray-900 tracking-tight">Welcome Back</h1>
          <p className="text-lg text-gray-600 font-light leading-relaxed">
            Let's continue your journey to better posture and pain-free movement
          </p>
        </div>

        {/* Daily Goal Card */}
        <div className="bg-indigo-600 rounded-3xl p-6 mb-6 shadow-lg">
          <div className="flex items-start justify-between mb-4">
            <div>
              <p className="text-indigo-200 text-sm mb-1 font-medium">Today's Goal</p>
              <p className="text-3xl text-white mb-1">15 minutes</p>
              <p className="text-indigo-200 text-sm">4 min completed</p>
            </div>
            <div className="w-16 h-16 rounded-full bg-white/10 backdrop-blur-sm flex items-center justify-center">
              <svg className="w-16 h-16 transform -rotate-90">
                <circle
                  cx="32"
                  cy="32"
                  r="28"
                  stroke="white"
                  strokeWidth="4"
                  fill="none"
                  opacity="0.3"
                />
                <circle
                  cx="32"
                  cy="32"
                  r="28"
                  stroke="white"
                  strokeWidth="4"
                  fill="none"
                  strokeDasharray={`${2 * Math.PI * 28 * 0.27} ${2 * Math.PI * 28}`}
                  strokeLinecap="round"
                />
              </svg>
              <span className="absolute text-white text-sm font-semibold">27%</span>
            </div>
          </div>
          <div className="w-full bg-white/20 rounded-full h-2">
            <div className="bg-white rounded-full h-2 w-[27%]"></div>
          </div>
        </div>

        {/* Quick Start Section */}
        <div className="mb-6">
          <h2 className="text-xl mb-4 text-gray-900">Quick Start</h2>
          
          {/* Device Selection */}
          <div className="flex gap-3 mb-4">
            {devices.map((device) => {
              const Icon = device.icon;
              return (
                <button
                  key={device.id}
                  onClick={() => setSelectedDevice(device.id)}
                  className={`flex-1 bg-white rounded-2xl p-5 flex flex-col items-center gap-3 transition-all border-2 ${
                    selectedDevice === device.id
                      ? "border-indigo-600 bg-indigo-50 shadow-lg"
                      : "border-gray-100 hover:border-indigo-200 shadow-md"
                  }`}
                >
                  <Icon
                    className={`w-7 h-7 ${
                      selectedDevice === device.id
                        ? "text-indigo-600"
                        : "text-gray-500"
                    }`}
                    strokeWidth={1.5}
                  />
                  <span className={`text-sm font-medium ${
                    selectedDevice === device.id
                      ? "text-indigo-700"
                      : "text-gray-700"
                  }`}>{device.label}</span>
                </button>
              );
            })}
          </div>

          {/* Start Button */}
          <button className="w-full bg-indigo-600 text-white py-5 rounded-2xl text-lg font-medium shadow-lg hover:bg-indigo-700 transition-all">
            Start Exercise Session
          </button>
        </div>

        {/* Today's Progress */}
        <div className="bg-white rounded-3xl p-6 shadow-md border border-gray-100">
          <h2 className="text-xl mb-5 text-gray-900">Today's Progress</h2>
          <div className="grid grid-cols-2 gap-4">
            <div className="bg-blue-50 rounded-2xl p-5 border border-blue-200">
              <div className="flex items-center gap-2 mb-2">
                <div className="w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center">
                  <svg className="w-5 h-5 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                </div>
              </div>
              <p className="text-3xl mb-1 text-blue-700 font-semibold">4m</p>
              <p className="text-sm text-blue-600">Active Time</p>
            </div>
            <div className="bg-green-50 rounded-2xl p-5 border border-green-200">
              <div className="flex items-center gap-2 mb-2">
                <div className="w-8 h-8 bg-green-600 rounded-lg flex items-center justify-center">
                  <svg className="w-5 h-5 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                </div>
              </div>
              <p className="text-3xl mb-1 text-green-700 font-semibold">93</p>
              <p className="text-sm text-green-600">Posture Score</p>
            </div>
          </div>
        </div>
      </div>

      <BottomNav />
    </div>
  );
}