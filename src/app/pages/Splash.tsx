import { useEffect } from "react";
import { useNavigate } from "react-router-dom";

export function Splash() {
  const navigate = useNavigate();

  useEffect(() => {
    const timer = setTimeout(() => {
      navigate("/onboarding");
    }, 2000);
    return () => clearTimeout(timer);
  }, [navigate]);

  return (
    <div className="h-screen bg-indigo-600 flex flex-col items-center justify-center px-6">
      <div className="flex flex-col items-center gap-6">
        {/* Medical Cross Logo */}
        <div className="w-32 h-32 rounded-3xl bg-white shadow-2xl flex items-center justify-center">
          <svg
            viewBox="0 0 100 100"
            className="w-20 h-20 text-indigo-600"
            fill="currentColor"
          >
            <rect x="35" y="20" width="30" height="60" rx="4" />
            <rect x="20" y="35" width="60" height="30" rx="4" />
            <circle cx="50" cy="50" r="8" fill="white" />
          </svg>
        </div>
        <div className="text-center">
          <h1 className="text-5xl mb-3 text-white tracking-tight">Posturely</h1>
          <p className="text-xl text-white/90 font-light">AI-Powered Posture Care</p>
        </div>
      </div>
    </div>
  );
}