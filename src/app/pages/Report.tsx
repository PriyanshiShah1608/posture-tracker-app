import { useNavigate } from "react-router";
import { ArrowLeft, CheckCircle2, AlertCircle } from "lucide-react";

export function Report() {
  const navigate = useNavigate();

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Status Bar */}
      <div className="pt-4 px-6 flex justify-between items-center text-sm text-gray-700">
        <span>11:40</span>
        <button
          onClick={() => navigate("/stats")}
          className="text-indigo-600 hover:text-indigo-700 font-medium"
        >
          Done
        </button>
      </div>

      {/* Header */}
      <div className="px-6 pt-4 pb-6 flex items-center gap-3">
        <button
          onClick={() => navigate("/stats")}
          className="w-10 h-10 bg-white rounded-full flex items-center justify-center shadow-md border border-gray-200"
        >
          <ArrowLeft className="w-5 h-5 text-gray-700" />
        </button>
        <h1 className="text-2xl text-gray-900 font-medium">Posture Report</h1>
      </div>

      {/* Report Content */}
      <div className="px-6 space-y-5 pb-8">
        {/* Overall Assessment */}
        <div className="bg-indigo-600 rounded-3xl p-6 shadow-lg">
          <div className="flex items-center justify-between mb-4">
            <div>
              <p className="text-indigo-200 text-sm mb-1 font-medium">Overall Assessment</p>
              <p className="text-4xl text-white mb-2">Good Progress</p>
              <p className="text-indigo-200 text-sm">Date: March 26, 2026</p>
            </div>
            <div className="w-16 h-16 bg-white/20 backdrop-blur-sm rounded-2xl flex items-center justify-center">
              <CheckCircle2 className="w-10 h-10 text-white" strokeWidth={2} />
            </div>
          </div>
        </div>

        {/* Front Analysis */}
        <div className="bg-white rounded-3xl p-6 shadow-md border border-gray-100">
          <div className="flex items-center gap-3 mb-4">
            <div className="w-12 h-12 bg-green-100 rounded-2xl flex items-center justify-center">
              <CheckCircle2 className="w-6 h-6 text-green-600" strokeWidth={2.5} />
            </div>
            <div>
              <h2 className="text-xl text-gray-900 font-medium">Front View Analysis</h2>
              <p className="text-sm text-green-600 font-medium">Score: 87/100</p>
            </div>
          </div>

          <div className="space-y-4">
            <div className="bg-green-50 border border-green-200 rounded-2xl p-4">
              <h3 className="text-base mb-2 text-green-900 font-medium">✓ Positive Findings</h3>
              <ul className="space-y-1.5 text-sm text-green-800">
                <li>• Head held straight and centered</li>
                <li>• Shoulders nearly level and relaxed</li>
                <li>• Arms hanging naturally by sides</li>
                <li>• Knees properly aligned</li>
                <li>• Feet positioned correctly</li>
              </ul>
            </div>

            <div className="bg-blue-50 border border-blue-200 rounded-2xl p-4">
              <h3 className="text-base mb-2 text-blue-900 font-medium">💡 Recommendations</h3>
              <p className="text-sm text-blue-800 leading-relaxed">
                Continue maintaining balanced shoulder position. Ensure weight distribution remains equal across both feet. Regular posture check-ins recommended.
              </p>
            </div>
          </div>
        </div>

        {/* Side Analysis */}
        <div className="bg-white rounded-3xl p-6 shadow-md border border-gray-100">
          <div className="flex items-center gap-3 mb-4">
            <div className="w-12 h-12 bg-orange-100 rounded-2xl flex items-center justify-center">
              <AlertCircle className="w-6 h-6 text-orange-600" strokeWidth={2.5} />
            </div>
            <div>
              <h2 className="text-xl text-gray-900 font-medium">Side View Analysis</h2>
              <p className="text-sm text-orange-600 font-medium">Score: 62/100</p>
            </div>
          </div>

          <div className="space-y-4">
            <div className="bg-orange-50 border border-orange-200 rounded-2xl p-4">
              <h3 className="text-base mb-2 text-orange-900 font-medium">⚠ Areas for Improvement</h3>
              <ul className="space-y-1.5 text-sm text-orange-800">
                <li>• Forward head position detected</li>
                <li>• Slight rounding in shoulders</li>
                <li>• Minor upper back curvature</li>
                <li>• Minimal knee hyperextension noted</li>
              </ul>
            </div>

            <div className="bg-teal-50 border border-teal-200 rounded-2xl p-4">
              <h3 className="text-base mb-2 text-teal-900 font-medium">🎯 Action Plan</h3>
              <ul className="space-y-2 text-sm text-teal-800">
                <li className="flex items-start gap-2">
                  <span className="text-teal-600 font-bold">1.</span>
                  <span>Practice chin tucks daily to improve head alignment</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-teal-600 font-bold">2.</span>
                  <span>Strengthen upper back muscles with rows and band pulls</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-teal-600 font-bold">3.</span>
                  <span>Regular chest and shoulder stretching exercises</span>
                </li>
              </ul>
            </div>

            <div className="bg-blue-50 border border-blue-200 rounded-2xl p-4">
              <div className="flex items-start gap-3">
                <div className="w-8 h-8 bg-blue-500 rounded-lg flex items-center justify-center flex-shrink-0 mt-0.5">
                  <svg className="w-5 h-5 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                </div>
                <div>
                  <p className="text-sm font-medium text-blue-900 mb-1">Recovery Note</p>
                  <p className="text-sm text-blue-700 leading-relaxed">
                    These improvements typically show progress within 2-4 weeks of consistent practice. Consider booking a follow-up scan to track progress.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Next Steps */}
        <div className="space-y-3">
          <button className="w-full bg-indigo-600 text-white py-5 rounded-2xl text-lg font-medium shadow-lg hover:bg-indigo-700 transition-all">
            Start Recommended Exercises
          </button>
          <button className="w-full bg-white text-indigo-600 py-5 rounded-2xl text-lg font-medium border-2 border-indigo-600 hover:bg-indigo-50 transition-all">
            Schedule Follow-up Scan
          </button>
        </div>
      </div>
    </div>
  );
}