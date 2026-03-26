import { BottomNav } from "../components/BottomNav";
import { CheckCircle } from "lucide-react";

const scanFeatures = [
  "AI-powered full body posture analysis",
  "Identify muscle imbalances & risk areas",
  "Track recovery and rehabilitation progress",
  "Personalized correction plan",
  "Safe for all fitness levels",
];

export function Scan() {
  return (
    <div className="min-h-screen bg-gray-50 pb-24">
      {/* Status Bar */}
      <div className="pt-4 px-6 flex justify-between items-center text-sm text-gray-700">
        <span>08:51</span>
      </div>

      {/* Header */}
      <div className="px-6 pt-8 pb-6">
        <h1 className="text-4xl mb-8 text-gray-900 text-center tracking-tight">Body Scan</h1>

        {/* Medical Icon Illustration */}
        <div className="flex justify-center mb-8">
          <div className="w-40 h-40 rounded-3xl bg-indigo-600 shadow-2xl flex items-center justify-center relative">
            <svg
              viewBox="0 0 100 100"
              className="w-28 h-28 text-white"
              fill="currentColor"
            >
              {/* Body outline */}
              <circle cx="50" cy="20" r="8" opacity="0.9" />
              <rect x="44" y="28" width="12" height="20" rx="2" opacity="0.9" />
              <rect x="40" y="30" width="6" height="15" rx="2" opacity="0.9" />
              <rect x="54" y="30" width="6" height="15" rx="2" opacity="0.9" />
              <rect x="44" y="48" width="5" height="25" rx="2" opacity="0.9" />
              <rect x="51" y="48" width="5" height="25" rx="2" opacity="0.9" />
              
              {/* Scan lines */}
              <line x1="10" y1="30" x2="90" y2="30" stroke="white" strokeWidth="0.5" opacity="0.6" strokeDasharray="2,2" />
              <line x1="10" y1="45" x2="90" y2="45" stroke="white" strokeWidth="0.5" opacity="0.6" strokeDasharray="2,2" />
              <line x1="10" y1="60" x2="90" y2="60" stroke="white" strokeWidth="0.5" opacity="0.6" strokeDasharray="2,2" />
            </svg>
            
            {/* Animated scan effect */}
            <div className="absolute inset-0 rounded-3xl overflow-hidden">
              <div className="absolute w-full h-1 bg-white/40 animate-pulse" style={{ top: "30%" }}></div>
            </div>
          </div>
        </div>

        {/* Features List */}
        <div className="bg-white rounded-3xl p-6 mb-6 shadow-md border border-gray-100">
          <h2 className="text-lg text-gray-900 mb-4 font-medium">What You'll Get</h2>
          <ul className="space-y-3">
            {scanFeatures.map((feature, index) => (
              <li key={index} className="flex items-start gap-3">
                <div className="w-6 h-6 bg-green-100 rounded-lg flex items-center justify-center flex-shrink-0 mt-0.5">
                  <CheckCircle className="w-4 h-4 text-green-600" strokeWidth={2.5} />
                </div>
                <span className="text-gray-700 leading-relaxed">{feature}</span>
              </li>
            ))}
          </ul>
        </div>

        {/* Info Card */}
        <div className="bg-blue-50 border border-blue-200 rounded-2xl p-5 mb-6">
          <div className="flex items-start gap-3">
            <div className="w-10 h-10 bg-blue-600 rounded-xl flex items-center justify-center flex-shrink-0">
              <svg className="w-5 h-5 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <div>
              <p className="text-sm font-medium text-blue-900 mb-1">Patient-Safe Technology</p>
              <p className="text-sm text-blue-700 leading-relaxed">
                Our AI analysis is designed specifically for rehabilitation and recovery. Takes only 2 minutes.
              </p>
            </div>
          </div>
        </div>

        {/* Buttons */}
        <div className="space-y-3">
          <button className="w-full bg-indigo-600 text-white py-5 rounded-2xl text-lg font-medium shadow-lg hover:bg-indigo-700 transition-all">
            Start Body Scan
          </button>
          <button className="w-full bg-white text-indigo-600 py-5 rounded-2xl text-lg font-medium border-2 border-indigo-600 hover:bg-indigo-50 transition-all">
            View Previous Scans
          </button>
        </div>
      </div>

      <BottomNav />
    </div>
  );
}