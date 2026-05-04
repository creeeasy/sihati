const Auth = {
  saveToken(token) {
    localStorage.setItem(CONFIG.STORAGE_KEYS.TOKEN, token);
  },
  
  getToken() {
    return localStorage.getItem(CONFIG.STORAGE_KEYS.TOKEN);
  },
  
  saveUser(user) {
    localStorage.setItem(CONFIG.STORAGE_KEYS.USER, JSON.stringify(user));
  },
  
  getUser() {
    const user = localStorage.getItem(CONFIG.STORAGE_KEYS.USER);
    return user ? JSON.parse(user) : null;
  },
  
  savePharmacy(pharmacy) {
    localStorage.setItem(CONFIG.STORAGE_KEYS.PHARMACY, JSON.stringify(pharmacy));
  },
  
  getPharmacy() {
    const pharmacy = localStorage.getItem(CONFIG.STORAGE_KEYS.PHARMACY);
    return pharmacy ? JSON.parse(pharmacy) : null;
  },
  
  isLoggedIn() {
    return !!this.getToken();
  },
  
  logout() {
    localStorage.removeItem(CONFIG.STORAGE_KEYS.TOKEN);
    localStorage.removeItem(CONFIG.STORAGE_KEYS.USER);
    localStorage.removeItem(CONFIG.STORAGE_KEYS.PHARMACY);
    window.location.href = 'pharmacy-login.html';
  },
  
  checkAuth() {
    if (!this.isLoggedIn()) {
      window.location.href = 'pharmacy-login.html';
      return false;
    }
    return true;
  }
};