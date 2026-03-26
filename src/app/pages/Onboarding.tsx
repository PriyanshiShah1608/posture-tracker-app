import { useState } from "react";
import { useNavigate } from "react-router";
import {
  Monitor,
  TrendingUp,
  Zap,
  Heart,
  Wind,
  Battery,
  Frown,
} from "lucide-react";

const onboardingSteps = [
  {
    title: "Why Posture Matters",
    subtitle: "You don't notice your posture... until it starts hurting.",
    content: (
      <div className="bg-gradient-to-br from-red-50 to-orange-50 rounded-3xl p-8 space-y-4 border border-red-200 shadow-md">
        <h3 className="text-2xl text-gray-900 mb-4 font-medium">Effects of Poor Posture</h3>
        <div className="space-y-3">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-red-100 rounded-xl flex items-center justify-center">
              <Zap className="w-5 h-5 text-red-600" strokeWidth={2} />
            </div>
            <span className="text-gray-800 font-medium">Neck and Back Pain</span>
          </div>
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-orange-100 rounded-xl flex items-center justify-center">
              <Wind className="w-5 h-5 text-orange-600" strokeWidth={2} />
            </div>
            <span className="text-gray-800 font-medium">Shallow Breathing</span>
          </div>
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-amber-100 rounded-xl flex items-center justify-center">
              <Battery className="w-5 h-5 text-amber-600" strokeWidth={2} />
            </div>
            <span className="text-gray-800 font-medium">Low Energy</span>
          </div>
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-red-100 rounded-xl flex items-center justify-center">
              <Frown className="w-5 h-5 text-red-600" strokeWidth={2} />
            </div>
            <span className="text-gray-800 font-medium">Reduced Confidence</span>
          </div>
        </div>
      </div>
    ),
  },
  {
    title: "Real-Time Monitoring",
    subtitle:
      "Posturely keeps an eye on you while you work, study, or scroll. The app gives instant feedback the moment you start slouching, so you can correct your posture before discomfort builds up.",
    icon: Monitor,
  },
  {
    title: "Valuable Insights",
    subtitle:
      "The app compiles your posture history into clear daily, weekly, and monthly insights. You'll see trends, progress scores, and actionable tips, helping you stay consistent and motivated.",
    icon: TrendingUp,
  },
  {
    title: "Digital Device Usage",
    subtitle:
      '"Text neck" has become a clinical term. A biomechanics case study revealed that tilting the head forward 60° while looking at a phone increases cervical spine stress from 10–12 lbs to 60 lbs—equivalent to carrying a child on your neck.',
    isCaseStudy: true,
  },
];

export function Onboarding() {
  const [currentStep, setCurrentStep] = useState(0);
  const navigate = useNavigate();

  const handleNext = () => {
    if (currentStep < onboardingSteps.length - 1) {
      setCurrentStep(currentStep + 1);
    } else {
      navigate("/home");
    }
  };

  const handleSkip = () => {
    navigate("/home");
  };

  const step = onboardingSteps[currentStep];

  return (
    <div className="h-screen bg-white flex flex-col px-6 pt-12 pb-8">
      {/* Skip Button */}
      {currentStep < onboardingSteps.length - 1 && (
        <button
          onClick={handleSkip}
          className="self-end text-gray-500 hover:text-indigo-600 font-medium"
        >
          Skip
        </button>
      )}

      {/* Logo */}
      <div className="flex items-center gap-3 mb-8">
        <div className="w-14 h-14 rounded-2xl bg-indigo-600 flex items-center justify-center shadow-lg">
          <svg
            viewBox="0 0 100 100"
            className="w-10 h-10 text-white"
            fill="currentColor"
          >
            <rect x="35" y="20" width="30" height="60" rx="4" />
            <rect x="20" y="35" width="60" height="30" rx="4" />
            <circle cx="50" cy="50" r="8" fill="white" opacity="0.4" />
          </svg>
        </div>
        <div>
          <h2 className="text-2xl text-gray-900 font-medium">Posturely</h2>
          <p className="text-sm text-gray-600">AI-Powered Posture Care</p>
        </div>
      </div>

      {/* Title */}
      <h1 className="text-3xl mb-4 text-gray-900 tracking-tight">
        {step.isCaseStudy ? "Success Stories" : `Welcome to Better Health`}
      </h1>

      {/* Content */}
      <div className="flex-1 flex flex-col items-center justify-center">
        {step.content ? (
          <div className="w-full">{step.content}</div>
        ) : step.isCaseStudy ? (
          <div className="bg-teal-50 rounded-3xl p-8 border border-teal-200 shadow-md">
            <div className="w-20 h-20 mx-auto mb-6 rounded-2xl bg-gradient-to-br from-teal-500 to-cyan-500 flex items-center justify-center shadow-lg">
              <Heart className="w-10 h-10 text-white" strokeWidth={2} />
            </div>
            <h3 className="text-2xl text-gray-900 mb-4 font-medium text-center">
              Clinical Evidence
            </h3>
            <p className="text-gray-700 leading-relaxed">{step.subtitle}</p>
          </div>
        ) : (
          <>
            <div className="w-24 h-24 mb-8 rounded-2xl bg-gradient-to-br from-teal-100 to-cyan-100 flex items-center justify-center shadow-lg border border-teal-200">
              {step.icon && <step.icon className="w-12 h-12 text-teal-600" strokeWidth={1.5} />}
            </div>
            <h2 className="text-2xl mb-4 text-gray-900 font-medium">{step.title}</h2>
            <p className="text-center text-gray-700 leading-relaxed px-4">
              {step.subtitle}
            </p>
          </>
        )}
      </div>

      {/* Pagination Dots */}
      <div className="flex justify-center gap-2 mb-6">
        {onboardingSteps.map((_, index) => (
          <div
            key={index}
            className={`h-2 rounded-full transition-all ${
              index === currentStep
                ? "bg-indigo-600 w-8"
                : "bg-gray-300 w-2"
            }`}
          />
        ))}
      </div>

      {/* Next/Continue Button */}
      <button
        onClick={handleNext}
        className="w-full bg-indigo-600 text-white py-5 rounded-2xl text-lg font-medium shadow-lg hover:bg-indigo-700 transition-all"
      >
        {currentStep === onboardingSteps.length - 1
          ? "Get Started"
          : step.isCaseStudy
          ? `Next (${currentStep + 1}/${onboardingSteps.length})`
          : "Continue"}
      </button>
    </div>
  );
}