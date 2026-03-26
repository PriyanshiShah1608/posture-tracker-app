import { ArrowLeft, TrendingUp, AlertTriangle, CheckCircle2 } from "lucide-react";
import { useNavigate } from "react-router";

export function Feedback() {
  const navigate = useNavigate();

  const corrections = [
    {
      area: "Lower Back",
      issue: "Slight forward tilt detected",
      tip: "Engage core muscles and maintain neutral spine",
      severity: "moderate",
    },
    {
      area: "Knee Alignment",
      issue: "Knees tracking well over toes",
      tip: "Excellent form - maintain this positioning",
      severity: "good",
    },
    {
      area: "Chest Position",
      issue: "Keep chest lifted throughout movement",
      tip: "Focus on proud chest position",
      severity: "minor",
    },
  ];

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="pt-4 px-6 flex justify-between items-center text-sm text-gray-700">
        <span>02:34</span>
      </div>

      <div className="px-6 pt-4 pb-6 flex items-center gap-3">
        <button
          onClick={() => navigate("/exercises")}
          className="w-10 h-10 bg-white rounded-full flex items-center justify-center shadow-md border border-gray-200"
        >
          <ArrowLeft className="w-5 h-5 text-gray-700" />
        </button>
        <h1 className="text-2xl text-gray-900 font-medium">Exercise Feedback</h1>
      </div>

      {/* Content */}
      <div className="px-6 space-y-6 pb-8">
        {/* Performance Score */}
        <div className="bg-indigo-600 rounded-3xl p-6 shadow-lg">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-indigo-200 text-sm mb-1 font-medium">Overall Score</p>
              <p className="text-5xl text-white mb-2">87/100</p>
              <div className="flex items-center gap-2">
                <TrendingUp className="w-5 h-5 text-white" />
                <span className="text-white text-sm">+5 from last session</span>
              </div>
            </div>
            <div className="w-24 h-24">
              <svg className="w-full h-full transform -rotate-90">
                <circle
                  cx="48"
                  cy="48"
                  r="40"
                  stroke="white"
                  strokeWidth="6"
                  fill="none"
                  opacity="0.2"
                />
                <circle
                  cx="48"
                  cy="48"
                  r="40"
                  stroke="white"
                  strokeWidth="6"
                  fill="none"
                  strokeDasharray={`${2 * Math.PI * 40 * 0.87} ${2 * Math.PI * 40}`}
                  strokeLinecap="round"
                />
              </svg>
            </div>
          </div>
        </div>

        {/* Comparison Section */}
        <div className="bg-white rounded-3xl p-6 shadow-md border border-gray-100">
          <h2 className="text-xl mb-4 text-gray-900 font-medium">Form Comparison</h2>
          
          <div className="grid grid-cols-2 gap-4 mb-4">
            {/* Your Form */}
            <div>
              <p className="text-sm text-gray-600 mb-2 font-medium">Your Form</p>
              <div className="aspect-[3/4] bg-gradient-to-br from-orange-50 to-orange-100 rounded-2xl border border-orange-200 flex items-center justify-center relative overflow-hidden">
                <svg className="w-full h-full" viewBox="0 0 100 140">
                  {/* Simplified stick figure - your form */}
                  <circle cx="50" cy="20" r="8" fill="#f97316" opacity="0.6" />
                  <line x1="50" y1="28" x2="50" y2="65" stroke="#f97316" strokeWidth="3" strokeLinecap="round" />
                  <line x1="50" y1="40" x2="30" y2="55" stroke="#f97316" strokeWidth="3" strokeLinecap="round" />
                  <line x1="50" y1="40" x2="70" y2="55" stroke="#f97316" strokeWidth="3" strokeLinecap="round" />
                  <line x1="50" y1="65" x2="35" y2="95" stroke="#f97316" strokeWidth="3" strokeLinecap="round" />
                  <line x1="50" y1="65" x2="65" y2="95" stroke="#f97316" strokeWidth="3" strokeLinecap="round" />
                  <line x1="35" y1="95" x2="30" y2="120" stroke="#f97316" strokeWidth="3" strokeLinecap="round" />
                  <line x1="65" y1="95" x2="70" y2="120" stroke="#f97316" strokeWidth="3" strokeLinecap="round" />
                  {/* Warning indicator */}
                  <circle cx="50" cy="50" r="4" fill="#ef4444" />
                </svg>
                <div className="absolute bottom-2 left-2 right-2 bg-white/90 backdrop-blur-sm rounded-lg px-2 py-1">
                  <p className="text-xs text-gray-700 text-center">Slight lean detected</p>
                </div>
              </div>
            </div>

            {/* Ideal Form */}
            <div>
              <p className="text-sm text-gray-600 mb-2 font-medium">Ideal Form</p>
              <div className="aspect-[3/4] bg-gradient-to-br from-green-50 to-green-100 rounded-2xl border border-green-200 flex items-center justify-center relative overflow-hidden">
                <svg className="w-full h-full" viewBox="0 0 100 140">
                  {/* Simplified stick figure - ideal form */}
                  <circle cx="50" cy="20" r="8" fill="#10b981" opacity="0.6" />
                  <line x1="50" y1="28" x2="50" y2="65" stroke="#10b981" strokeWidth="3" strokeLinecap="round" />
                  <line x1="50" y1="40" x2="30" y2="55" stroke="#10b981" strokeWidth="3" strokeLinecap="round" />
                  <line x1="50" y1="40" x2="70" y2="55" stroke="#10b981" strokeWidth="3" strokeLinecap="round" />
                  <line x1="50" y1="65" x2="35" y2="95" stroke="#10b981" strokeWidth="3" strokeLinecap="round" />
                  <line x1="50" y1="65" x2="65" y2="95" stroke="#10b981" strokeWidth="3" strokeLinecap="round" />
                  <line x1="35" y1="95" x2="30" y2="120" stroke="#10b981" strokeWidth="3" strokeLinecap="round" />
                  <line x1="65" y1="95" x2="70" y2="120" stroke="#10b981" strokeWidth="3" strokeLinecap="round" />
                  {/* Check indicator */}
                  <circle cx="50" cy="50" r="4" fill="#10b981" />
                </svg>
                <div className="absolute bottom-2 left-2 right-2 bg-white/90 backdrop-blur-sm rounded-lg px-2 py-1">
                  <p className="text-xs text-gray-700 text-center">Perfect alignment</p>
                </div>
              </div>
            </div>
          </div>

          <div className="bg-blue-50 border border-blue-200 rounded-xl p-4">
            <div className="flex items-start gap-3">
              <div className="w-8 h-8 bg-blue-500 rounded-lg flex items-center justify-center flex-shrink-0 mt-0.5">
                <TrendingUp className="w-5 h-5 text-white" />
              </div>
              <div>
                <p className="text-sm font-medium text-blue-900 mb-1">Key Improvement</p>
                <p className="text-sm text-blue-700 leading-relaxed">
                  Focus on maintaining a neutral spine throughout the movement. Your form is 87% accurate.
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Detailed Corrections */}
        <div className="bg-white rounded-3xl p-6 shadow-md border border-gray-100">
          <h2 className="text-xl mb-4 text-gray-900 font-medium">Improvement Tips</h2>
          
          <div className="space-y-3">
            {corrections.map((correction, index) => (
              <div
                key={index}
                className={`rounded-2xl p-4 border ${
                  correction.severity === "good"
                    ? "bg-green-50 border-green-200"
                    : correction.severity === "moderate"
                    ? "bg-orange-50 border-orange-200"
                    : "bg-blue-50 border-blue-200"
                }`}
              >
                <div className="flex items-start gap-3">
                  <div
                    className={`w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0 ${
                      correction.severity === "good"
                        ? "bg-green-500"
                        : correction.severity === "moderate"
                        ? "bg-orange-500"
                        : "bg-blue-500"
                    }`}
                  >
                    {correction.severity === "good" ? (
                      <CheckCircle2 className="w-5 h-5 text-white" strokeWidth={2.5} />
                    ) : (
                      <AlertTriangle className="w-5 h-5 text-white" strokeWidth={2.5} />
                    )}
                  </div>
                  <div className="flex-1">
                    <h3
                      className={`font-medium mb-1 ${
                        correction.severity === "good"
                          ? "text-green-900"
                          : correction.severity === "moderate"
                          ? "text-orange-900"
                          : "text-blue-900"
                      }`}
                    >
                      {correction.area}
                    </h3>
                    <p
                      className={`text-sm mb-2 ${
                        correction.severity === "good"
                          ? "text-green-700"
                          : correction.severity === "moderate"
                          ? "text-orange-700"
                          : "text-blue-700"
                      }`}
                    >
                      {correction.issue}
                    </p>
                    <p
                      className={`text-xs ${
                        correction.severity === "good"
                          ? "text-green-600"
                          : correction.severity === "moderate"
                          ? "text-orange-600"
                          : "text-blue-600"
                      }`}
                    >
                      💡 {correction.tip}
                    </p>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Action Buttons */}
        <div className="space-y-3">
          <button className="w-full bg-indigo-600 text-white py-5 rounded-2xl text-lg font-medium shadow-lg hover:bg-indigo-700 transition-all">
            Try Again with Tips
          </button>
          <button className="w-full bg-white text-indigo-600 py-5 rounded-2xl text-lg font-medium border-2 border-indigo-600 hover:bg-indigo-50 transition-all">
            View Detailed Report
          </button>
        </div>
      </div>
    </div>
  );
}