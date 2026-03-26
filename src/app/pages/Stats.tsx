import { useState } from "react";
import { BottomNav } from "../components/BottomNav";
import { RefreshCw, TrendingUp, Award, Target } from "lucide-react";
import { useNavigate } from "react-router";

type TimeRange = "Week" | "Month" | "Year";

export function Stats() {
  const [timeRange, setTimeRange] = useState<TimeRange>("Week");
  const navigate = useNavigate();

  const weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  const dailyScores = [85, 88, 90, 87, 93, 91, 89];
  const dailyMinutes = [10, 5, 8, 0, 14, 12, 0];

  return (
    <div className="min-h-screen bg-gray-50 pb-24">
      {/* Status Bar */}
      <div className="pt-4 px-6 flex justify-between items-center text-sm text-gray-700">
        <span>08:51</span>
      </div>

      {/* Header */}
      <div className="px-6 pt-8 pb-6">
        <div className="flex items-center justify-between mb-6">
          <h1 className="text-4xl text-gray-900 tracking-tight">Progress</h1>
          <button className="w-10 h-10 bg-white rounded-full flex items-center justify-center shadow-md border border-gray-200 hover:bg-indigo-50 transition-all">
            <RefreshCw className="w-5 h-5 text-indigo-600" />
          </button>
        </div>

        {/* Time Range Selector */}
        <div className="flex gap-2 bg-white rounded-2xl p-1 mb-6 shadow-md border border-gray-100">
          {(["Week", "Month", "Year"] as TimeRange[]).map((range) => (
            <button
              key={range}
              onClick={() => setTimeRange(range)}
              className={`flex-1 py-2.5 rounded-xl text-sm transition-all font-medium ${
                timeRange === range
                  ? "bg-indigo-600 text-white shadow-md"
                  : "text-gray-600 hover:bg-gray-50"
              }`}
            >
              {range}
            </button>
          ))}
        </div>

        {/* Main Score Card */}
        <div className="bg-white rounded-3xl p-6 mb-6 shadow-md border border-gray-100">
          <div className="flex items-center justify-between mb-6">
            <div>
              <p className="text-gray-600 text-sm mb-1 font-medium">Average Posture Score</p>
              <p className="text-5xl text-gray-900 mb-2">89</p>
              <div className="flex items-center gap-2">
                <TrendingUp className="w-4 h-4 text-green-600" />
                <span className="text-sm text-green-600 font-medium">+6% this week</span>
              </div>
            </div>
            <div className="relative w-28 h-28">
              <svg className="w-full h-full transform -rotate-90">
                <circle
                  cx="56"
                  cy="56"
                  r="50"
                  stroke="currentColor"
                  strokeWidth="8"
                  fill="none"
                  className="text-gray-100"
                />
                <circle
                  cx="56"
                  cy="56"
                  r="50"
                  stroke="currentColor"
                  strokeWidth="8"
                  fill="none"
                  strokeDasharray={`${2 * Math.PI * 50 * 0.89} ${2 * Math.PI * 50}`}
                  strokeLinecap="round"
                  className="text-indigo-600"
                />
              </svg>
              <div className="absolute inset-0 flex items-center justify-center">
                <span className="text-2xl text-indigo-600 font-bold">89%</span>
              </div>
            </div>
          </div>

          {/* Weekly Chart */}
          <div>
            <div className="flex justify-between items-end h-32 mb-3">
              {weekDays.map((day, index) => (
                <div key={index} className="flex flex-col items-center gap-2 flex-1">
                  <div className="text-xs text-gray-500 font-medium">{dailyScores[index]}</div>
                  <div className="w-full max-w-[40px] flex flex-col items-center">
                    <div
                      className="w-full bg-indigo-600 rounded-t-lg"
                      style={{
                        height: `${(dailyScores[index] / 100) * 100}%`,
                        minHeight: "8px",
                      }}
                    ></div>
                  </div>
                </div>
              ))}
            </div>
            <div className="flex justify-between text-xs text-gray-600 font-medium">
              {weekDays.map((day, index) => (
                <span key={index} className="flex-1 text-center">{day}</span>
              ))}
            </div>
          </div>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-2 gap-4 mb-6">
          <div className="bg-blue-50 rounded-3xl p-5 border border-blue-200">
            <div className="flex items-center gap-2 mb-3">
              <div className="w-10 h-10 bg-blue-600 rounded-xl flex items-center justify-center shadow-md">
                <svg className="w-5 h-5 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
            </div>
            <p className="text-sm text-blue-700 mb-1 font-medium">Total Time</p>
            <p className="text-3xl text-blue-700 font-semibold">49m</p>
          </div>
          
          <div className="bg-green-50 rounded-3xl p-5 border border-green-200">
            <div className="flex items-center gap-2 mb-3">
              <div className="w-10 h-10 bg-green-600 rounded-xl flex items-center justify-center shadow-md">
                <Award className="w-5 h-5 text-white" strokeWidth={2} />
              </div>
            </div>
            <p className="text-sm text-green-700 mb-1 font-medium">Best Score</p>
            <p className="text-3xl text-green-700 font-semibold">93</p>
          </div>

          <div className="bg-purple-50 rounded-3xl p-5 border border-purple-200">
            <div className="flex items-center gap-2 mb-3">
              <div className="w-10 h-10 bg-purple-600 rounded-xl flex items-center justify-center shadow-md">
                <Target className="w-5 h-5 text-white" strokeWidth={2} />
              </div>
            </div>
            <p className="text-sm text-purple-700 mb-1 font-medium">Sessions</p>
            <p className="text-3xl text-purple-700 font-semibold">12</p>
          </div>

          <div className="bg-orange-50 rounded-3xl p-5 border border-orange-200">
            <div className="flex items-center gap-2 mb-3">
              <div className="w-10 h-10 bg-orange-600 rounded-xl flex items-center justify-center shadow-md">
                <TrendingUp className="w-5 h-5 text-white" strokeWidth={2} />
              </div>
            </div>
            <p className="text-sm text-orange-700 mb-1 font-medium">Streak</p>
            <p className="text-3xl text-orange-700 font-semibold">5 days</p>
          </div>
        </div>

        {/* Activity Chart */}
        <div className="bg-white rounded-3xl p-6 shadow-md border border-gray-100 mb-4">
          <h3 className="text-lg text-gray-900 mb-4 font-medium">Session Activity</h3>
          <div className="flex justify-between items-end h-24 mb-3">
            {weekDays.map((day, index) => (
              <div key={index} className="flex flex-col items-center gap-2 flex-1">
                <div
                  className="w-full max-w-[40px] bg-indigo-600 rounded-t-lg"
                  style={{
                    height: dailyMinutes[index] ? `${(dailyMinutes[index] / 14) * 100}%` : "4px",
                    minHeight: "4px",
                  }}
                ></div>
                <span className="text-xs text-gray-600 font-medium">{day}</span>
              </div>
            ))}
          </div>
        </div>

        {/* View Report Button */}
        <button
          onClick={() => navigate("/report")}
          className="w-full bg-indigo-600 text-white py-5 rounded-2xl text-lg font-medium shadow-lg hover:bg-indigo-700 transition-all"
        >
          View Comprehensive Report
        </button>
      </div>

      <BottomNav />
    </div>
  );
}