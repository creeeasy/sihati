// Doctor Profile Management Module
const DoctorProfile = {
  /**
   * Load doctor profile from API
   */
  async loadProfile() {
    try {
      const response = await API.get('/doctor/profile');
      
      // Save to local storage
      localStorage.setItem('doctor_data', JSON.stringify(response.doctor));
      
      // Update UI
      this.displayProfile(response.doctor);
      
      return response.doctor;
    } catch (error) {
      console.error('Load profile error:', error);
      Helpers.showToast('Erreur lors du chargement du profil', 'error');
      throw error;
    }
  },
  
  /**
   * Display doctor profile in the form
   */
  displayProfile(doctor) {
    // Basic info
    if (document.getElementById('firstName')) {
      document.getElementById('firstName').value = doctor.firstName || '';
    }
    if (document.getElementById('lastName')) {
      document.getElementById('lastName').value = doctor.lastName || '';
    }
    if (document.getElementById('phone')) {
      document.getElementById('phone').value = doctor.phone || '';
    }
    if (document.getElementById('email')) {
      document.getElementById('email').value = doctor.email || '';
    }
    if (document.getElementById('address')) {
      document.getElementById('address').value = doctor.address || '';
    }
    if (document.getElementById('commune')) {
      document.getElementById('commune').value = doctor.commune || '';
    }
    if (document.getElementById('bio')) {
      document.getElementById('bio').value = doctor.bio || '';
    }
    
    // Specialty dropdown
    const specialtySelect = document.getElementById('specialty');
    if (specialtySelect && doctor.specialty) {
      specialtySelect.value = doctor.specialty;
    }
    
    // Wilaya dropdown
    const wilayaSelect = document.getElementById('wilaya');
    if (wilayaSelect) {
      wilayaSelect.innerHTML = '<option value="">Sélectionner une wilaya</option>';
      CONFIG.WILAYAS.forEach(wilaya => {
        const option = document.createElement('option');
        option.value = wilaya;
        option.textContent = wilaya;
        if (wilaya === doctor.wilaya) {
          option.selected = true;
        }
        wilayaSelect.appendChild(option);
      });
    }
    
    // Update displayed name
    const fullName = `Dr. ${doctor.firstName || ''} ${doctor.lastName || ''}`.trim();
    if (document.getElementById('profileName')) {
      document.getElementById('profileName').textContent = fullName;
    }
    if (document.getElementById('userName')) {
      document.getElementById('userName').textContent = fullName;
    }
    if (document.getElementById('userAvatar')) {
      document.getElementById('userAvatar').textContent = 
        (doctor.firstName || 'D').charAt(0).toUpperCase();
    }
  },
  
  /**
   * Update doctor profile
   */
  async updateProfile(formData) {
    try {
      // Validate
      const validation = this.validateProfileData(formData);
      if (!validation.isValid) {
        Object.keys(validation.errors).forEach(field => {
          Helpers.showToast(validation.errors[field], 'error');
        });
        return false;
      }
      
      // Call API
      const response = await API.put('/doctor/profile', formData);
      
      // Update local storage
      localStorage.setItem('doctor_data', JSON.stringify(response.doctor));
      
      // Show success
      Helpers.showToast('Profil mis à jour avec succès !', 'success');
      
      // Update displayed data
      this.displayProfile(response.doctor);
      
      return response.doctor;
    } catch (error) {
      console.error('Update profile error:', error);
      Helpers.showToast(
        error.message || 'Erreur lors de la mise à jour',
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
    
    if (Validator.isEmpty(data.firstName)) {
      errors.firstName = 'Le prénom est requis';
    }
    
    if (Validator.isEmpty(data.lastName)) {
      errors.lastName = 'Le nom est requis';
    }
    
    if (Validator.isEmpty(data.phone)) {
      errors.phone = 'Le téléphone est requis';
    } else if (!Validator.isValidPhone(data.phone)) {
      errors.phone = 'Numéro de téléphone invalide';
    }
    
    if (Validator.isEmpty(data.email)) {
      errors.email = 'L\'email est requis';
    } else if (!Validator.isValidEmail(data.email)) {
      errors.email = 'Email invalide';
    }
    
    if (Validator.isEmpty(data.wilaya)) {
      errors.wilaya = 'La wilaya est requise';
    }
    
    if (Validator.isEmpty(data.specialty)) {
      errors.specialty = 'La spécialité est requise';
    }
    
    return {
      isValid: Object.keys(errors).length === 0,
      errors: errors
    };
  },
  
  /**
   * Get form data
   */
  getFormData() {
    return {
      firstName: document.getElementById('firstName')?.value.trim() || '',
      lastName: document.getElementById('lastName')?.value.trim() || '',
      specialty: document.getElementById('specialty')?.value || '',
      wilaya: document.getElementById('wilaya')?.value || '',
      commune: document.getElementById('commune')?.value.trim() || '',
      phone: document.getElementById('phone')?.value.trim() || '',
      email: document.getElementById('email')?.value.trim() || '',
      address: document.getElementById('address')?.value.trim() || '',
      bio: document.getElementById('bio')?.value.trim() || ''
    };
  },
  
  /**
   * Enable edit mode
   */
  enableEditMode() {
    const form = document.getElementById('profileForm');
    const inputs = form.querySelectorAll('input:not([readonly]), select, textarea');
    inputs.forEach(input => input.disabled = false);
    document.getElementById('profileActions').style.display = 'flex';
    document.getElementById('editProfileBtn').style.display = 'none';
  },
  
  /**
   * Disable edit mode
   */
  disableEditMode() {
    const form = document.getElementById('profileForm');
    const inputs = form.querySelectorAll('input:not([readonly]), select, textarea');
    inputs.forEach(input => input.disabled = true);
    document.getElementById('profileActions').style.display = 'none';
    document.getElementById('editProfileBtn').style.display = 'inline-flex';
    
    // Reload original data
    const doctorData = localStorage.getItem('doctor_data');
    if (doctorData) {
      this.displayProfile(JSON.parse(doctorData));
    }
  },
  
  /**
   * Initialize profile management
   */
  init() {
    // Load from local storage first
    const doctorData = localStorage.getItem('doctor_data');
    if (doctorData) {
      this.displayProfile(JSON.parse(doctorData));
    } else {
      this.loadProfile();
    }
    
    // Edit button
    const editBtn = document.getElementById('editProfileBtn');
    if (editBtn) {
      editBtn.addEventListener('click', () => this.enableEditMode());
    }
    
    // Cancel button
    const cancelBtn = document.getElementById('cancelEditBtn');
    if (cancelBtn) {
      cancelBtn.addEventListener('click', () => this.disableEditMode());
    }
    
    // Form submit
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

// Auto-initialize
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => {
    if (document.getElementById('profileForm')) {
      DoctorProfile.init();
    }
  });
} else {
  if (document.getElementById('profileForm')) {
    DoctorProfile.init();
  }
}