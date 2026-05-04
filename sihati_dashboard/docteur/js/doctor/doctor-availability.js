// Doctor Availability Management Module
const DoctorAvailability = {
  availability: {
    saturday:  { active: true,  open: '08:00', close: '17:00' },
    sunday:    { active: true,  open: '08:00', close: '17:00' },
    monday:    { active: true,  open: '08:00', close: '17:00' },
    tuesday:   { active: true,  open: '08:00', close: '17:00' },
    wednesday: { active: false, open: '08:00', close: '17:00' },
    thursday:  { active: true,  open: '08:00', close: '12:00' },
    friday:    { active: false, open: '08:00', close: '12:00' }
  },
  
  /**
   * Load availability from API
   */
  async loadAvailability() {
    try {
      const response = await API.get('/doctor/availability');
      this.availability = response.availability;
      this.displayAvailability();
      return this.availability;
    } catch (error) {
      console.error('Load availability error:', error);
      // Use default availability if API fails
      this.displayAvailability();
    }
  },
  
  /**
   * Display availability in the UI
   */
  displayAvailability() {
    Object.keys(this.availability).forEach(day => {
      const dayData = this.availability[day];
      const toggle = document.querySelector(`[data-day="${day}"]`);
      
      if (!toggle) return;
      
      const dayCard = toggle.closest('.day-card');
      const timeInputs = dayCard.querySelectorAll('input[type="time"]');
      
      // Set toggle state
      if (dayData.active) {
        toggle.classList.add('active');
      } else {
        toggle.classList.remove('active');
      }
      
      // Set time values
      if (timeInputs.length >= 2) {
        timeInputs[0].value = dayData.open;
        timeInputs[1].value = dayData.close;
        
        // Enable/disable based on active state
        timeInputs.forEach(input => {
          input.disabled = !dayData.active;
        });
      }
    });
  },
  
  /**
   * Save availability to API
   */
  async saveAvailability() {
    try {
      // Get current availability from UI
      this.availability = this.getAvailabilityFromUI();
      
      // Call API
      const response = await API.put('/doctor/availability', {
        availability: this.availability
      });
      
      Helpers.showToast('Disponibilités enregistrées avec succès !', 'success');
      
      return response;
    } catch (error) {
      console.error('Save availability error:', error);
      Helpers.showToast(
        error.message || 'Erreur lors de la sauvegarde',
        'error'
      );
      throw error;
    }
  },
  
  /**
   * Get availability data from UI
   */
  getAvailabilityFromUI() {
    const availability = {};
    
    document.querySelectorAll('.day-toggle').forEach(toggle => {
      const day = toggle.dataset.day;
      const dayCard = toggle.closest('.day-card');
      const timeInputs = dayCard.querySelectorAll('input[type="time"]');
      
      availability[day] = {
        active: toggle.classList.contains('active'),
        open: timeInputs[0]?.value || '08:00',
        close: timeInputs[1]?.value || '17:00'
      };
    });
    
    return availability;
  },
  
  /**
   * Toggle day availability
   */
  toggleDay(day) {
    const toggle = document.querySelector(`[data-day="${day}"]`);
    if (!toggle) return;
    
    toggle.classList.toggle('active');
    const isActive = toggle.classList.contains('active');
    
    const dayCard = toggle.closest('.day-card');
    const timeInputs = dayCard.querySelectorAll('input[type="time"]');
    timeInputs.forEach(input => {
      input.disabled = !isActive;
    });
    
    // Update local data
    if (this.availability[day]) {
      this.availability[day].active = isActive;
    }
  },
  
  /**
   * Initialize availability management
   */
  init() {
    // Load from API or use defaults
    this.loadAvailability();
    
    // Toggle buttons
    document.querySelectorAll('.day-toggle').forEach(toggle => {
      toggle.addEventListener('click', () => {
        const day = toggle.dataset.day;
        this.toggleDay(day);
      });
    });
    
    // Save button
    const saveBtn = document.getElementById('saveAvailabilityBtn');
    if (saveBtn) {
      saveBtn.addEventListener('click', () => {
        this.saveAvailability();
      });
    }
  }
};

// Auto-initialize
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => {
    if (document.getElementById('availabilitySection')) {
      DoctorAvailability.init();
    }
  });
} else {
  if (document.getElementById('availabilitySection')) {
    DoctorAvailability.init();
  }
}