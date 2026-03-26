import { useState } from "react";
import { X, Video, VideoOff, AlertCircle } from "lucide-react";
import { useNavigate } from "react-router";

export function LiveAnalysis() {
  const navigate = useNavigate();
  const [isAnalyzing, setIsAnalyzing] = useState(true);

  const posturePoints = [
    { x: 50, y: 25, status: "good" }, // Head
    { x: 50, y: 40, status: "good" }, // Neck
    { x: 50, y: 55, status: "warning" }, // Upper back
    { x: 50, y: 70, status: "good" }, // Lower back
    { x: 50, y: 85, status: "good" }, // Hips
  ];

  const feedback = [
    { text: "Keep your back neutral", status: "warning", icon: "⚠️" },
    { text: "Excellent knee alignment", status: "good", icon: "✓" },
    { text: "Maintain chest up", status: "good", icon: "✓" },
  ];

  return (
    <div className="h-screen bg-gradient-to-b from-gray-900 to-gray-800 flex flex-col">
      {/* Top Bar */}
      <div className="pt-4 px-6 flex justify-between items-center text-white z-10">
        <button
          onClick={() => navigate("/exercises")}
          className="w-10 h-10 bg-white/10 backdrop-blur-sm rounded-full flex items-center justify-center hover:bg-white/20 transition-all"
        >
          <X className="w-5 h-5" />
        </button>
        <div className="flex items-center gap-2">
          <div className="w-2 h-2 bg-red-500 rounded-full animate-pulse"></div>
          <span className="text-sm font-medium">Live Analysis</span>
        </div>
        <button
          onClick={() => setIsAnalyzing(!isAnalyzing)}
          className="w-10 h-10 bg-white/10 backdrop-blur-sm rounded-full flex items-center justify-center hover:bg-white/20 transition-all"
        >
          {isAnalyzing ? (
            <Video className="w-5 h-5" />
          ) : (
            <VideoOff className="w-5 h-5" />
          )}
        </button>
      </div>

      {/* Camera View with AI Overlay */}
      <div className="flex-1 relative mx-6 my-4 rounded-3xl overflow-hidden bg-gradient-to-br from-gray-700 to-gray-600 shadow-2xl">
        {/* Simulated Camera Feed Background */}
        <div className="absolute inset-0 bg-gradient-to-br from-teal-900/20 to-blue-900/20"></div>

        {/* AI Skeleton Overlay */}
        <svg className="absolute inset-0 w-full h-full" viewBox="0 0 100 100">
          {/* Skeleton Lines */}
          {posturePoints.map((point, index) => {
            if (index < posturePoints.length - 1) {
              const nextPoint = posturePoints[index + 1];
              return (
                <line
                  key={`line-${index}`}
                  x1={point.x}
                  y1={point.y}
                  x2={nextPoint.x}
                  y2={nextPoint.y}
                  stroke={point.status === "warning" ? "#fb923c" : "#10b981"}
                  strokeWidth="0.5"
                  strokeLinecap="round"
                />
              );
            }
            return null;
          })}

          {/* Posture Points */}
          {posturePoints.map((point, index) => (
            <g key={`point-${index}`}>
              <circle
                cx={point.x}
                cy={point.y}
                r="2"
                fill={point.status === "warning" ? "#fb923c" : "#10b981"}
                opacity="0.8"
              />
              <circle
                cx={point.x}
                cy={point.y}
                r="3"
                fill="none"
                stroke={point.status === "warning" ? "#fb923c" : "#10b981"}
                strokeWidth="0.3"
                opacity="0.5"
              >
                <animate
                  attributeName="r"
                  from="3"
                  to="5"
                  dur="1.5s"
                  repeatCount="indefinite"
                />
                <animate
                  attributeName="opacity"
                  from="0.5"
                  to="0"
                  dur="1.5s"
                  repeatCount="indefinite"
                />
              </circle>
            </g>
          ))}
        </svg>

        {/* Exercise Label */}
        <div className="absolute top-6 left-6 bg-teal-500 text-white px-4 py-2 rounded-xl shadow-lg font-medium">
          Squat Analysis
        </div>

        {/* Confidence Score */}
        <div className="absolute top-6 right-6 bg-white/95 backdrop-blur-sm rounded-2xl p-3 shadow-lg">
          <div className="text-xs text-gray-600 mb-1">AI Confidence</div>
          <div className="flex items-center gap-2">
            <div className="text-2xl font-bold text-indigo-600">94%</div>
            <div className="w-12 h-12">
              <svg className="w-full h-full transform -rotate-90">
                <circle
                  cx="24"
                  cy="24"
                  r="20"
                  stroke="currentColor"
                  strokeWidth="3"
                  fill="none"
                  className="text-gray-200"
                />
                <circle
                  cx="24"
                  cy="24"
                  r="20"
                  stroke="currentColor"
                  strokeWidth="3"
                  fill="none"
                  strokeDasharray={`${2 * Math.PI * 20 * 0.94} ${2 * Math.PI * 20}`}
                  strokeLinecap="round"
                  className="text-indigo-600"
                />
              </svg>
            </div>
          </div>
        </div>

        {/* Real-time Feedback */}
        <div className="absolute bottom-6 left-6 right-6 space-y-2">
          {feedback.map((item, index) => (
            <div
              key={index}
              className={`flex items-center gap-3 rounded-xl p-3 shadow-lg backdrop-blur-md ${
                item.status === "good"
                  ? "bg-green-500/90 text-white"
                  : "bg-orange-500/90 text-white"
              }`}
            >
              <div className="w-8 h-8 bg-white/20 rounded-lg flex items-center justify-center text-lg">
                {item.icon}
              </div>
              <span className="flex-1 font-medium">{item.text}</span>
              {item.status === "warning" && (
                <AlertCircle className="w-5 h-5" strokeWidth={2.5} />
              )}
            </div>
          ))}
        </div>
      </div>

      {/* Bottom Controls */}
      <div className="px-6 pb-8 flex items-center justify-center gap-6">
        <button className="px-8 py-4 bg-indigo-600 text-white rounded-2xl font-medium shadow-lg hover:bg-indigo-700 transition-all">
          Complete Set
        </button>
        <button className="px-8 py-4 bg-white/10 backdrop-blur-sm text-white rounded-2xl font-medium hover:bg-white/20 transition-all">
          Pause
        </button>
      </div>
    </div>
  );
}