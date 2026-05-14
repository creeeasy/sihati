class PharmacyAuth {
  async checkAuth() {
    const token = STORAGE.getToken();
    const user = STORAGE.getUser();

    if (!token || !user || user.role !== "pharmacy") {
      window.location.href = "pharmacy-login.html";
      return false;
    }

    if (!api.getPharmacyId()) {
      await this.loadAndStorePharmacyId();
    }
    await this.loadProfile();
    return true;
  }

  async loadAndStorePharmacyId() {
    try {
      const user = STORAGE.getUser();
      const response = await api.getPharmacyByUserId(user.id);
      if (response.success && response.data && response.data.length > 0) {
        api.setPharmacyId(response.data[0].id);
      } else {
        window.location.href = "pharmacy-login.html";
      }
    } catch (error) {
      window.location.href = "pharmacy-login.html";
    }
  }

  async loadProfile() {
    try {
      const response = await api.getCurrentPharmacy();
      if (response.success) {
        this.displayProfile(response.data);
      }
    } catch (error) {
      console.error(error);
    }
  }

  displayProfile(pharmacy) {
    const nameEl = document.getElementById("pharmacyName");
    const addressEl = document.getElementById("pharmacyAddress");
    const avatarEl = document.getElementById("pharmacyAvatar");
    if (nameEl) nameEl.textContent = pharmacy.pharmacyName;
    if (addressEl) addressEl.textContent = pharmacy.address;
    if (avatarEl) {
      const initials = (pharmacy.pharmacyName || "P").slice(0, 2).toUpperCase();
      avatarEl.textContent = initials;
    }
  }

  async logout() {
    await api.logout();
    api.clearPharmacyId();
    window.location.href = "pharmacy-login.html";
  }
}

const pharmacyAuth = new PharmacyAuth();
