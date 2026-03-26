import { BottomNav } from "../components/BottomNav";
import { Clock, Activity, Target } from "lucide-react";

const exercises = [
  {
    id: 1,
    name: "Squat",
    category: "Lower Body",
    duration: "3 sets × 12 reps",
    difficulty: "Beginner",
    badge: "Patient-Safe",
    color: "bg-blue-50",
    iconBg: "bg-blue-600",
    borderColor: "border-blue-200",
  },
  {
    id: 2,
    name: "Plank",
    category: "Core Stability",
    duration: "3 sets × 30 sec",
    difficulty: "Beginner",
    badge: "Patient-Safe",
    color: "bg-purple-50",
    iconBg: "bg-purple-600",
    borderColor: "border-purple-200",
  },
  {
    id: 3,
    name: "Deadlift",
    category: "Full Body",
    duration: "3 sets × 10 reps",
    difficulty: "Intermediate",
    badge: "Patient-Safe",
    color: "bg-cyan-50",
    iconBg: "bg-cyan-600",
    borderColor: "border-cyan-200",
  },
  {
    id: 4,
    name: "Shoulder Press",
    category: "Upper Body",
    duration: "3 sets × 12 reps",
    difficulty: "Beginner",
    badge: "Patient-Safe",
    color: "bg-emerald-50",
    iconBg: "bg-emerald-600",
    borderColor: "border-emerald-200",
  },
  {
    id: 5,
    name: "Bridge",
    category: "Lower Back",
    duration: "3 sets × 15 reps",
    difficulty: "Beginner",
    badge: "Rehab Focus",
    color: "bg-green-50",
    iconBg: "bg-green-600",
    borderColor: "border-green-200",
  },
];

export function Exercises() {
  return (
    <div className="min-h-screen bg-gray-50 pb-24">
      {/* Status Bar */}
      <div className="pt-4 px-6 flex justify-between items-center text-sm text-gray-700">
        <span>11:39</span>
      </div>

      {/* Header */}
      <div className="px-6 pt-8 pb-6">
        <h1 className="text-4xl mb-3 text-gray-900 tracking-tight">Exercise Library</h1>
        <p className="text-gray-600 font-light">Patient-safe movements with real-time AI guidance</p>
      </div>

      {/* Exercise Grid */}
      <div className="px-6 space-y-4">
        {exercises.map((exercise) => (
          <button
            key={exercise.id}
            className={`w-full ${exercise.color} rounded-3xl p-5 hover:shadow-xl transition-all border ${exercise.borderColor}`}
          >
            <div className="flex items-start gap-4 mb-3">
              <div className={`w-14 h-14 ${exercise.iconBg} rounded-2xl flex items-center justify-center shadow-md`}>
                <Activity className="w-7 h-7 text-white" strokeWidth={2} />
              </div>
              <div className="flex-1 text-left">
                <div className="flex items-center gap-2 mb-1">
                  <h3 className="text-xl text-gray-900 font-medium">{exercise.name}</h3>
                  <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${
                    exercise.difficulty === "Beginner" 
                      ? "bg-green-100 text-green-700 border border-green-200" 
                      : "bg-amber-100 text-amber-700 border border-amber-200"
                  }`}>
                    {exercise.difficulty}
                  </span>
                </div>
                <p className="text-sm text-gray-600 mb-2">{exercise.category}</p>
                <div className="flex items-center gap-3">
                  <div className="flex items-center gap-1.5 bg-white px-2.5 py-1 rounded-lg shadow-sm border border-gray-100">
                    <Target className="w-3.5 h-3.5 text-indigo-600" />
                    <span className="text-xs text-gray-700 font-medium">
                      {exercise.duration}
                    </span>
                  </div>
                  <span className="px-2.5 py-1 rounded-lg text-xs font-medium bg-indigo-100 text-indigo-700 border border-indigo-200">
                    {exercise.badge}
                  </span>
                </div>
              </div>
            </div>
          </button>
        ))}
      </div>

      <BottomNav />
    </div>
  );
}