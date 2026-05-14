// doctor/js/config.js
const API_CONFIG = {
  BASE_URL: "http://localhost:7500/api",
  ENDPOINTS: {
    LOGIN: "/auth/login",
    REGISTER: "/auth/register",
    PROFILE: "/auth/profile",
    DOCTORS: "/doctors",
    APPOINTMENTS: "/appointments",
    REVIEWS: "/reviews",
    AVAILABLE_SLOTS: "/doctors/:id/available-slots",
  },
};

// Stockage local
const STORAGE = {
  getToken: () => localStorage.getItem("accessToken"),
  setToken: (token) => localStorage.setItem("accessToken", token),
  getRefreshToken: () => localStorage.getItem("refreshToken"),
  setRefreshToken: (token) => localStorage.setItem("refreshToken", token),
  getUser: () => {
    const user = localStorage.getItem("user");
    return user ? JSON.parse(user) : null;
  },
  setUser: (user) => localStorage.setItem("user", JSON.stringify(user)),
  clear: () => {
    localStorage.removeItem("accessToken");
    localStorage.removeItem("refreshToken");
    localStorage.removeItem("user");
  },
};
