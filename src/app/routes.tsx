import { createBrowserRouter } from "react-router-dom";
import { Splash } from "./pages/Splash";
import { Onboarding } from "./pages/Onboarding";
import { Home } from "./pages/Home";
import { Exercises } from "./pages/Exercises";
import { Scan } from "./pages/Scan";
import { Stats } from "./pages/Stats";
import { Profile } from "./pages/Profile";
import { Report } from "./pages/Report";
import { LiveAnalysis } from "./pages/LiveAnalysis";
import { Feedback } from "./pages/Feedback";

export const router = createBrowserRouter([
  {
    path: "/",
    Component: Splash,
  },
  {
    path: "/onboarding",
    Component: Onboarding,
  },
  {
    path: "/home",
    Component: Home,
  },
  {
    path: "/exercises",
    Component: Exercises,
  },
  {
    path: "/scan",
    Component: Scan,
  },
  {
    path: "/stats",
    Component: Stats,
  },
  {
    path: "/profile",
    Component: Profile,
  },
  {
    path: "/report",
    Component: Report,
  },
  {
    path: "/live-analysis",
    Component: LiveAnalysis,
  },
  {
    path: "/feedback",
    Component: Feedback,
  },
]);