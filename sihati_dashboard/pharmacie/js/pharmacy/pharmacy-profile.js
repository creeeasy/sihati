// Pharmacy Profile Management Module
const PharmacyProfile = {
  /**
   * Load pharmacy profile data
   */
  async loadProfile() {
    try {
      const response = await API.get(CONFIG.ENDPOINTS.PHARMACY.PROFILE);
      
      // Save to local storage
      Auth.savePharmacy(response.pharmacy);
      
      // Update UI
      this.displayProfile(response.pharmacy);
      
      return response.pharmacy;
    } catch (error) {
      console.error('Load profile error:', error);
      Helpers.showToast('Erreur lors du chargement du profil', 'error');
      throw error;
    }
  },
  
  /**
   * Display pharmacy profile in the form
   */
  displayProfile(pharmacy) {
    // Basic info
    document.getElementById('pharmacyName').value = pharmacy.name || '';
    document.getElementById('licenseNumber').value = pharmacy.licenseNumber || '';
    document.getElementById('address').value = pharmacy.address || '';
    document.getElementById('commune').value = pharmacy.commune || '';
    document.getElementById('phone').value = pharmacy.phone || '';
    document.getElementById('whatsapp').value = pharmacy.whatsapp || '';
    document.getElementById('email').value = pharmacy.email || '';
    
    // Wilaya dropdown
    const wilayaSelect = document.getElementById('wilaya');
    if (wilayaSelect) {
      // Populate wilaya options
      wilayaSelect.innerHTML = '<option value="">Sélectionner une wilaya</option>';
      CONFIG.WILAYAS.forEach(wilaya => {
        const option = document.createElement('option');
        option.value = wilaya;
        option.textContent = wilaya;
        if (wilaya === pharmacy.wilaya) {
          option.selected = true;
        }
        wilayaSelect.appendChild(option);
      });
    }
    
    // Opening hours (if available)
    if (pharmacy.openingHours) {
      this.displayOpeningHours(pharmacy.openingHours);
    }
  },
  
  /**
   * Display opening hours
   */
  displayOpeningHours(openingHours) {
    // This would populate time inputs for each day
    // Example structure: { monday: { open: "08:00", close: "18:00" }, ... }
    
    if (openingHours.weekdays) {
      const weekdayInputs = document.querySelectorAll('[data-day="weekdays"]');
      if (weekdayInputs.length >= 2) {
        weekdayInputs[0].value = openingHours.weekdays.open || '08:00';
        weekdayInputs[1].value = openingHours.weekdays.close || '18:00';
      }
    }
    
    if (openingHours.friday) {
      const fridayInputs = document.querySelectorAll('[data-day="friday"]');
      if (fridayInputs.length >= 2) {
        fridayInputs[0].value = openingHours.friday.open || '14:00';
        fridayInputs[1].value = openingHours.friday.close || '18:00';
      }
    }
  },
  
  /**
   * Update pharmacy profile
   */
  async updateProfile(formData) {
    try {
      // Validate form data
      const validation = this.validateProfileData(formData);
      if (!validation.isValid) {
        // Show validation errors
        Object.keys(validation.errors).forEach(field => {
          Validator.showError(field, validation.errors[field]);
        });
        return false;
      }
      
      // Call API
      const response = await API.put(
        CONFIG.ENDPOINTS.PHARMACY.PROFILE,
        formData
      );
      
      // Update local storage
      Auth.savePharmacy(response.pharmacy);
      
      // Show success message
      Helpers.showToast('Profil mis à jour avec succès !', 'success');
      
      // Update displayed data
      this.displayProfile(response.pharmacy);
      
      return response.pharmacy;
    } catch (error) {
      console.error('Update profile error:', error);
      Helpers.showToast(
        error.message || 'Erreur lors de la mise à jour du profil',
        'error'
      );
      throw error;
    }
  },
  
  /**
   * Validate profile data
   */
  validateProfileData(data) {
    const errors = {};
    
    // Pharmacy name
    if (Validator.isEmpty(data.name)) {
      errors.pharmacyName = 'Le nom de la pharmacie est requis';
    }
    
    // Address
    if (Validator.isEmpty(data.address)) {
      errors.address = 'L\'adresse est requise';
    }
    
    // Wilaya
    if (Validator.isEmpty(data.wilaya)) {
      errors.wilaya = 'La wilaya est requise';
    }
    
    // Commune
    if (Validator.isEmpty(data.commune)) {
      errors.commune = 'La commune est requise';
    }
    
    // Phone
    if (Validator.isEmpty(data.phone)) {
      errors.phone = 'Le téléphone est requis';
    } else if (!Validator.isValidPhone(data.phone)) {
      errors.phone = 'Numéro de téléphone invalide';
    }
    
    // WhatsApp (optional but validate if provided)
    if (data.whatsapp && !Validator.isEmpty(data.whatsapp)) {
      if (!Validator.isValidPhone(data.whatsapp)) {
        errors.whatsapp = 'Numéro WhatsApp invalide';
      }
    }
    
    // Email
    if (Validator.isEmpty(data.email)) {
      errors.email = 'L\'email est requis';
    } else if (!Validator.isValidEmail(data.email)) {
      errors.email = 'Email invalide';
    }
    
    return {
      isValid: Object.keys(errors).length === 0,
      errors: errors
    };
  },
  
  /**
   * Get form data from profile form
   */
  getFormData() {
    const formData = {
      name: document.getElementById('pharmacyName').value.trim(),
      address: document.getElementById('address').value.trim(),
      wilaya: document.getElementById('wilaya').value,
      commune: document.getElementById('commune').value.trim(),
      phone: document.getElementById('phone').value.trim(),
      whatsapp: document.getElementById('whatsapp').value.trim(),
      email: document.getElementById('email').value.trim(),
      openingHours: this.getOpeningHours()
    };
    
    return formData;
  },
  
  /**
   * Get opening hours from form
   */
  getOpeningHours() {
    const weekdayInputs = document.querySelectorAll('[data-day="weekdays"]');
    const fridayInputs = document.querySelectorAll('[data-day="friday"]');
    
    return {
      weekdays: {
        open: weekdayInputs[0]?.value || '08:00',
        close: weekdayInputs[1]?.value || '18:00'
      },
      friday: {
        open: fridayInputs[0]?.value || '14:00',
        close: fridayInputs[1]?.value || '18:00'
      }
    };
  },
  
  /**
   * Enable edit mode
   */
  enableEditMode() {
    const form = document.getElementById('profileForm');
    const inputs = form.querySelectorAll('input:not([readonly]), select');
    
    inputs.forEach(input => {
      input.disabled = false;
    });
    
    // Show action buttons
    document.getElementById('profileActions').style.display = 'flex';
    document.getElementById('editProfileBtn').style.display = 'none';
  },
  
  /**
   * Disable edit mode
   */
  disableEditMode() {
    const form = document.getElementById('profileForm');
    const inputs = form.querySelectorAll('input:not([readonly]), select');
    
    inputs.forEach(input => {
      input.disabled = true;
    });
    
    // Hide action buttons
    document.getElementById('profileActions').style.display = 'none';
    document.getElementById('editProfileBtn').style.display = 'inline-flex';
    
    // Clear validation errors
    Validator.clearAllErrors('profileForm');
    
    // Reload original data
    const pharmacy = Auth.getPharmacy();
    if (pharmacy) {
      this.displayProfile(pharmacy);
    }
  },
  
  /**
   * Initialize profile management
   */
  init() {
    // Load profile on page load
    const pharmacy = Auth.getPharmacy();
    if (pharmacy) {
      this.displayProfile(pharmacy);
    } else {
      this.loadProfile();
    }
    
    // Edit button handler
    const editBtn = document.getElementById('editProfileBtn');
    if (editBtn) {
      editBtn.addEventListener('click', () => {
        this.enableEditMode();
      });
    }
    
    // Cancel button handler
    const cancelBtn = document.getElementById('cancelEditBtn');
    if (cancelBtn) {
      cancelBtn.addEventListener('click', () => {
        this.disableEditMode();
      });
    }
    
    // Form submit handler
    const form = document.getElementById('profileForm');
    if (form) {
      form.addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const formData = this.getFormData();
        const success = await this.updateProfile(formData);
        
        if (success) {
          this.disableEditMode();
        }
      });
    }
  }
};

// Auto-initialize when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => {
    if (document.getElementById('profileForm')) {
      PharmacyProfile.init();
    }
  });
} else {
  if (document.getElementById('profileForm')) {
    PharmacyProfile.init();
  }
}