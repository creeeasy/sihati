// pharmacy/js/config.js
const API_CONFIG = {
  BASE_URL: "https://sihati.wassla-delivery.com/api", // Même backend que doctor
  ENDPOINTS: {
    LOGIN: "/auth/login",
    REGISTER: "/auth/register",
    PHARMACIES: "/pharmacies",
    MEDICATIONS: "/medications",
    STOCK: "/stock",
  },
};

// Stockage local (identique à doctor)
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
    localStorage.removeItem("pharmacyId");
  },
};
