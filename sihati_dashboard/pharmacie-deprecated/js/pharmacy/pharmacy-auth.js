// Pharmacy Authentication Module
const PharmacyAuth = {
  /**
   * Handle pharmacy login
   */
  async login(email, password, rememberMe = false) {
    try {
      // Call login API
      const response = await API.post(CONFIG.ENDPOINTS.AUTH.LOGIN, {
        email: email,
        password: password,
        userType: 'pharmacy'
      });
      
      // Save authentication data
      Auth.saveToken(response.token);
      Auth.saveUser(response.user);
      Auth.savePharmacy(response.pharmacy);
      
      // Save remember me preference
      if (rememberMe) {
        localStorage.setItem('remember_me', 'true');
      }
      
      return response;
    } catch (error) {
      console.error('Login error:', error);
      throw error;
    }
  },
  
  /**
   * Handle pharmacy logout
   */
  logout() {
    // Clear all stored data
    Auth.logout();
  },
  
  /**
   * Check if user is authenticated pharmacy
   */
  isAuthenticated() {
    return Auth.isLoggedIn() && Auth.getPharmacy() !== null;
  },
  
  /**
   * Get current pharmacy data
   */
  getCurrentPharmacy() {
    return Auth.getPharmacy();
  },
  
  /**
   * Update pharmacy profile
   */
  async updateProfile(pharmacyData) {
    try {
      const response = await API.put(
        CONFIG.ENDPOINTS.PHARMACY.PROFILE,
        pharmacyData
      );
      
      // Update stored pharmacy data
      Auth.savePharmacy(response.pharmacy);
      
      return response;
    } catch (error) {
      console.error('Update profile error:', error);
      throw error;
    }
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
   * Delete pharmacy account
   */
  async deleteAccount() {
    try {
      const response = await API.delete('/auth/account');
      
      // Logout after deletion
      this.logout();
      
      return response;
    } catch (error) {
      console.error('Delete account error:', error);
      throw error;
    }
  }
};