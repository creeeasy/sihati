class PharmacyApiService {
  constructor() {
    this.baseUrl = API_CONFIG.BASE_URL;
  }

  getHeaders() {
    const token = STORAGE.getToken();
    return {
      "Content-Type": "application/json",
      ...(token && { Authorization: `Bearer ${token}` }),
    };
  }

  async request(endpoint, options = {}) {
    const url = `${this.baseUrl}${endpoint}`;
    console.log("📡", options.method || "GET", url);
    try {
      const response = await fetch(url, {
        ...options,
        headers: this.getHeaders(),
      });
      const data = await response.json();
      if (!response.ok) {
        if (response.status === 401) {
          STORAGE.clear();
          localStorage.removeItem("pharmacyId");
          window.location.href = "pharmacy-login.html";
        }
        throw new Error(data.message || `Erreur ${response.status}`);
      }
      return data;
    } catch (error) {
      console.error("API Error:", error);
      throw error;
    }
  }

  setPharmacyId(id) {
    localStorage.setItem("pharmacyId", id);
  }
  getPharmacyId() {
    return localStorage.getItem("pharmacyId");
  }
  clearPharmacyId() {
    localStorage.removeItem("pharmacyId");
  }

  async login(email, password) {
    const data = await this.request("/auth/login", {
      method: "POST",
      body: JSON.stringify({ email, password }),
    });
    if (data.success) {
      STORAGE.setToken(data.data.accessToken);
      STORAGE.setRefreshToken(data.data.refreshToken);
      STORAGE.setUser(data.data.user);
    }
    return data;
  }

  async logout() {
    try {
      await this.request("/auth/logout", { method: "POST" });
    } catch (_) {}
    STORAGE.clear();
    this.clearPharmacyId();
  }

  async getPharmacyByUserId(userId) {
    const response = await this.request(`/pharmacies?userId=${userId}`);
    if (response.success && response.data) {
      const filtered = response.data.filter((p) => p.userId === userId);
      return { ...response, data: filtered };
    }
    return response;
  }

  async getPharmacyById(pharmacyId) {
    return this.request(`/pharmacies/${pharmacyId}`);
  }

  async getCurrentPharmacy() {
    const pharmacyId = this.getPharmacyId();
    if (!pharmacyId) throw new Error("Pharmacy ID non trouvé");
    return this.getPharmacyById(pharmacyId);
  }

  async updatePharmacyProfile(data) {
    const pharmacyId = this.getPharmacyId();
    if (!pharmacyId) throw new Error("Pharmacy ID non trouvé");
    return this.request(`/pharmacies/${pharmacyId}`, {
      method: "PUT",
      body: JSON.stringify(data),
    });
  }

  async setDutyStatus(isOnDuty) {
    const pharmacyId = this.getPharmacyId();
    return this.request(`/pharmacies/${pharmacyId}/duty`, {
      method: "PUT",
      body: JSON.stringify({ isOnDuty }),
    });
  }

  async getStock(medicationId) {
    const pharmacyId = this.getPharmacyId();
    return this.request(`/pharmacies/${pharmacyId}/stock/${medicationId}`);
  }

  async updateStock(medicationId, data) {
    const pharmacyId = this.getPharmacyId();
    return this.request(`/pharmacies/${pharmacyId}/stock/${medicationId}`, {
      method: "PUT",
      body: JSON.stringify(data),
    });
  }

  async getAllStock() {
    const pharmacyId = this.getPharmacyId();
    return this.request(`/pharmacies/${pharmacyId}/stock`);
  }

  async searchMedications(query) {
    return this.request(`/medications/search?q=${encodeURIComponent(query)}`);
  }

  async getMedicationById(id) {
    return this.request(`/medications/${id}`);
  }

  async getPharmaciesWithStock(medicationId, lat, lng) {
    let url = `/medications/${medicationId}/pharmacies`;
    const params = [];
    if (lat) params.push(`lat=${lat}`);
    if (lng) params.push(`lng=${lng}`);
    if (params.length) url += `?${params.join("&")}`;
    return this.request(url);
  }

  async searchByBarcode(barcode) {
    return this.request("/medications/barcode", {
      method: "POST",
      body: JSON.stringify({ barcode }),
    });
  }

  async getPopularMedications(limit = 10) {
    return this.request(`/medications/popular?limit=${limit}`);
  }

  async getPrescriptions() {
    return this.request("/prescriptions/pharmacy");
  }

  async verifyPrescription(code) {
    return this.request(`/prescriptions/verify/${code}`);
  }

  async register(userData) {
    const userRes = await this.request("/auth/register", {
      method: "POST",
      body: JSON.stringify(userData),
    });

    if (!userRes.success) {
      throw new Error(userRes.message);
    }

    // Si l'utilisateur est une pharmacie et que pharmacyData existe
    if (userData.role === "pharmacy" && userData.pharmacyData) {
      const fullPharmacyData = {
        ...userData.pharmacyData,
        userId: userRes.data.id,
      };

      const pharmacyRes = await this.request("/pharmacies", {
        method: "POST",
        body: JSON.stringify(fullPharmacyData),
      });

      if (!pharmacyRes.success) {
        throw new Error(pharmacyRes.message);
      }
    }

    return userRes;
  }
}

const api = new PharmacyApiService();
