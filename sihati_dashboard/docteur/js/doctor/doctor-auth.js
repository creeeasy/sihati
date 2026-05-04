// Doctor Authentication Module
const DoctorAuth = {
  /**
   * Handle doctor login
   */
  async login(email, password) {
    try {
      const response = await API.post(CONFIG.ENDPOINTS.AUTH.LOGIN, {
        email: email,
        password: password,
        userType: 'doctor'
      });
      
      // Save authentication data
      Auth.saveToken(response.token);
      Auth.saveUser(response.user);
      localStorage.setItem('doctor_data', JSON.stringify(response.doctor));
      
      return response;
    } catch (error) {
      console.error('Login error:', error);
      throw error;
    }
  },
  
  /**
   * Handle doctor logout
   */
  logout() {
    localStorage.removeItem('doctor_data');
    Auth.logout();
  },
  
  /**
   * Check if doctor is authenticated
   */
  isAuthenticated() {
    return Auth.isLoggedIn() && !!localStorage.getItem('doctor_data');
  },
  
  /**
   * Get current doctor data
   */
  getCurrentDoctor() {
    const data = localStorage.getItem('doctor_data');
    return data ? JSON.parse(data) : null;
  },
  
  /**
   * Change password
   */
  async changePassword(currentPassword, newPassword) {
    try {
      const response = await API.post('/auth/change-password', {
        currentPassword: currentPassword,
        newPassword: newPassword
      });
      return response;
    } catch (error) {
      console.error('Change password error:', error);
      throw error;
    }
  },
  
  /**
   * Delete doctor account
   */
  async deleteAccount() {
    try {
      await API.delete('/auth/account');
      this.logout();
    } catch (error) {
      console.error('Delete account error:', error);
      throw error;
    }
  }
};