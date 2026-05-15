class DoctorAuth {
  constructor() {
    this.checkAuth();
  }

  async checkAuth() {
    const token = STORAGE.getToken();
    const user = STORAGE.getUser();

    if (!token || !user || user.role !== "doctor") {
      window.location.href = "doctor-login.html";
      return false;
    }

    if (!api.getDoctorId()) {
      await this.loadAndStoreDoctorId();
    }
    await this.loadProfile();
    return true;
  }

  async loadAndStoreDoctorId() {
    try {
      const user = STORAGE.getUser();
      const response = await api.getDoctorByUserId(user.id);
      if (response.success && response.data?.id) {
        api.setDoctorId(response.data.id);
      } else {
        window.location.href = "doctor-login.html";
      }
    } catch (error) {
      window.location.href = "doctor-login.html";
    }
  }

  async loadProfile() {
    try {
      const response = await api.getCurrentDoctor();
      if (response.success) {
        this.displayProfile(response.data);
      }
    } catch (error) {
      console.error(error);
    }
  }

  displayProfile(doctor) {
    const nameEl = document.getElementById("doctorName");
    const specialtyEl = document.getElementById("doctorSpecialty");
    const avatarEl = document.getElementById("doctorAvatar");
    if (nameEl) nameEl.textContent = doctor.doctorName;
    if (specialtyEl)
      specialtyEl.textContent =
        doctor.specialty?.nameFr || doctor.specialty?.name || "Medecin";
    if (avatarEl) {
      const parts = doctor.doctorName?.split(" ") || ["D", "R"];
      const initials = (
        (parts[0]?.[0] || "") + (parts[1]?.[0] || "")
      ).toUpperCase();
      avatarEl.textContent = initials || "DR";
    }
  }

  async logout() {
    await api.logout();
    api.clearDoctorId();
    window.location.href = "doctor-login.html";
  }
}

const doctorAuth = new DoctorAuth();
