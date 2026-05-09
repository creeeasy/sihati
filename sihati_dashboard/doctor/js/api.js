// doctor/js/api.js

class ApiService {
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
          localStorage.removeItem("doctorId");
          window.location.href = "doctor-login.html";
        }
        throw new Error(data.message || `Erreur ${response.status}`);
      }
      return data;
    } catch (error) {
      console.error("API Error:", error);
      throw error;
    }
  }

  // ─── Doctor ID cache ──────────────────────────────────────
  setDoctorId(id) {
    localStorage.setItem("doctorId", id);
  }
  getDoctorId() {
    return localStorage.getItem("doctorId");
  }
  clearDoctorId() {
    localStorage.removeItem("doctorId");
  }

  // ─── Auth ─────────────────────────────────────────────────
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
    this.clearDoctorId();
  }

  async changePassword(currentPassword, newPassword) {
    return this.request("/auth/change-password", {
      method: "POST",
      body: JSON.stringify({ currentPassword, newPassword }),
    });
  }

  // ─── Doctor ───────────────────────────────────────────────
  async getDoctorByUserId(userId) {
    return this.request(`/doctors/by-user/${userId}`);
  }

  async getDoctorById(doctorId) {
    return this.request(`/doctors/${doctorId}`);
  }

  async getCurrentDoctor() {
    const doctorId = this.getDoctorId();
    if (!doctorId) throw new Error("Doctor ID non trouvé");
    return this.getDoctorById(doctorId);
  }

  // ─── Profile update ───────────────────────────────────────
  async updateDoctorProfile(data) {
    const doctorId = this.getDoctorId();
    if (!doctorId) throw new Error("Doctor ID non trouvé");
    return this.request(`/doctors/${doctorId}/profile`, {
      method: "PUT",
      body: JSON.stringify(data),
    });
  }

  // ─── Schedule ─────────────────────────────────────────────
  async getDoctorSchedule() {
    const doctorId = this.getDoctorId();
    if (!doctorId) throw new Error("Doctor ID non trouvé");
    return this.request(`/doctors/${doctorId}/schedule`);
  }

  async updateDoctorSchedule(schedules) {
    const doctorId = this.getDoctorId();
    if (!doctorId) throw new Error("Doctor ID non trouvé");
    return this.request(`/doctors/${doctorId}/schedule`, {
      method: "POST",
      body: JSON.stringify({ schedules }),
    });
  }

  // ─── Appointments ─────────────────────────────────────────
  async getDoctorAppointments(status) {
    const user = STORAGE.getUser();
    if (!user?.id) throw new Error("User ID non trouvé");
    const qs = status ? `?status=${status}` : "";
    return this.request(`/appointments/doctor/${user.id}${qs}`);
  }

  async confirmAppointment(id) {
    return this.request(`/appointments/${id}/confirm`, { method: "PUT" });
  }

  async cancelAppointment(id, reason = "") {
    return this.request(`/appointments/${id}/cancel`, {
      method: "PUT",
      body: JSON.stringify({ reason }),
    });
  }

  async completeAppointment(id) {
    return this.request(`/appointments/${id}/complete`, { method: "PUT" });
  }

  // ─── Reviews ──────────────────────────────────────────────
  async getDoctorReviews() {
    const doctorId = this.getDoctorId();
    if (!doctorId) throw new Error("Doctor ID non trouvé");
    return this.request(`/doctors/${doctorId}/reviews`);
  }

  // ─── Stats ────────────────────────────────────────────────
  async getDoctorStats() {
    const [apptRes, reviewRes] = await Promise.all([
      this.getDoctorAppointments(),
      this.getDoctorReviews().catch(() => ({ data: [] })),
    ]);
    const appts = apptRes.data || [];
    const reviews = reviewRes.data || [];

    // Calcul des revenus du jour
    const today = new Date().toISOString().slice(0, 10);
    const todayAppts = appts.filter(
      (a) => a.status === "completed" && a.appointmentDate === today,
    );
    const todayRevenue = todayAppts.reduce(
      (sum, a) => sum + (a.consultationFee || 0),
      0,
    );

    const avg = reviews.length
      ? (reviews.reduce((s, r) => s + r.rating, 0) / reviews.length).toFixed(1)
      : "–";

    return {
      total: appts.length,
      pending: appts.filter((a) => a.status === "pending").length,
      confirmed: appts.filter((a) => a.status === "confirmed").length,
      completed: appts.filter((a) => a.status === "completed").length,
      cancelled: appts.filter((a) => a.status === "cancelled").length,
      today: appts.filter((a) => a.appointmentDate === today).length,
      todayRevenue,
      averageRating: avg,
    };
  }

  // ─── Patients ─────────────────────────────────────────────
  async searchPatients(query) {
    return this.request(
      `/users/search?q=${encodeURIComponent(query)}&role=patient`,
    );
  }

  // api.js - Modifier getPatientById
  async getPatientById(patientId) {
    // Si vous avez la route /users/:id
    return this.request(`/users/${patientId}`);
  }

  async createPatient(patientData) {
    return this.request("/auth/register", {
      method: "POST",
      body: JSON.stringify({ ...patientData, role: "patient" }),
    });
  }

  // ─── Consultations ────────────────────────────────────────
  async createConsultation(data) {
    // Ne pas inclure doctorId, le backend le récupère via JWT
    return this.request("/consultations", {
      method: "POST",
      body: JSON.stringify(data),
    });
  }

  // ─── Prescriptions ────────────────────────────────────────
  async createPrescription(data) {
    return this.request("/prescriptions", {
      method: "POST",
      body: JSON.stringify(data),
    });
  }
  // Récupérer les allergies d'un patient
  // api.js - Modifier getPatientAllergies
  async getPatientAllergies(patientId) {
    // ✅ Utiliser la bonne route
    return this.request(`/allergies/patient/${patientId}`);
  }

  // Récupérer les consultations d'un patient
  async getPatientConsultations(patientId) {
    return this.request(`/consultations/patient/${patientId}`);
  }

  // Récupérer les prescriptions d'un patient

  async getPatientPrescriptions(patientId) {
    return this.request(`/prescriptions/patient/${patientId}`);
  }

  async getPatientAllergies(patientId) {
    return this.request(`/allergies/patient/${patientId}`);
  }
  // ============================================
  // ALLERGIES
  // ============================================
  async createAllergy(patientId, data) {
    return this.request(`/allergies/patient/${patientId}`, {
      method: "POST",
      body: JSON.stringify(data),
    });
  }

  async deleteAllergy(allergyId) {
    return this.request(`/allergies/${allergyId}`, {
      method: "DELETE",
    });
  }

  async updateAllergy(allergyId, data) {
    return this.request(`/allergies/${allergyId}`, {
      method: "PUT",
      body: JSON.stringify(data),
    });
  }
  // api.js - Ajouter cette méthode
  async searchPatientsByChifa(chifaNumber) {
    return this.request(
      `/users/search?chifaNumber=${encodeURIComponent(chifaNumber)}&role=patient`,
    );
  }
}

const api = new ApiService();
