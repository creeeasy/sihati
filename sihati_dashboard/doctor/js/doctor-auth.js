// doctor/js/doctor-auth.js

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

    // ✅ Récupérer et stocker le doctorId
    await this.loadAndStoreDoctorId();
    await this.loadProfile();
    return true;
  }

  async loadAndStoreDoctorId() {
    try {
      const user = STORAGE.getUser();
      const response = await api.getDoctorByUserId(user.id);

      if (response.success && response.data) {
        const doctorId = response.data.id;
        api.setDoctorId(doctorId);
      } else {
        console.error("Aucun docteur trouvé pour cet utilisateur");
      }
    } catch (error) {
      console.error("Erreur récupération doctorId:", error);
    }
  }

  async loadProfile() {
    try {
      const response = await api.getCurrentDoctor();

      if (response.success) {
        this.displayProfile(response.data);
      }
    } catch (error) {
      console.error("Erreur chargement profil:", error);
    }
  }

  displayProfile(doctor) {
    const doctorNameEl = document.getElementById("doctor-name");
    const doctorSpecialtyEl = document.getElementById("doctor-specialty");
    const doctorClinicEl = document.getElementById("doctor-clinic");
    const doctorAddressEl = document.getElementById("doctor-address");
    const doctorPhoneEl = document.getElementById("doctor-phone");
    const doctorFeeEl = document.getElementById("doctor-fee");
    const doctorRatingEl = document.getElementById("doctor-rating");
    const doctorExperienceEl = document.getElementById("doctor-experience");

    if (doctorNameEl) doctorNameEl.textContent = doctor.doctorName;
    if (doctorSpecialtyEl)
      doctorSpecialtyEl.textContent = doctor.specialty?.nameFr || "";
    if (doctorClinicEl) doctorClinicEl.textContent = doctor.clinicName;
    if (doctorAddressEl) doctorAddressEl.textContent = doctor.clinicAddress;
    if (doctorPhoneEl) doctorPhoneEl.textContent = doctor.phone;
    if (doctorFeeEl) doctorFeeEl.textContent = `${doctor.consultationFee} DA`;
    if (doctorRatingEl)
      doctorRatingEl.textContent =
        doctor.averageRating?.toFixed(1) || "Nouveau";
    if (doctorExperienceEl)
      doctorExperienceEl.textContent = `${doctor.yearsOfExperience || 0} ans`;
  }

  async logout() {
    await api.logout();
    api.clearDoctorId();
    window.location.href = "doctor-login.html";
  }
}

const doctorAuth = new DoctorAuth();
