// ==================== AUTH ====================
const Auth = {
    saveToken: (token) => {
        localStorage.setItem('sihati_token', token);
    },
    
    getToken: () => {
        return localStorage.getItem('sihati_token');
    },
    
    saveUser: (user) => {
        localStorage.setItem('sihati_user', JSON.stringify(user));
    },
    
    getUser: () => {
        const user = localStorage.getItem('sihati_user');
        return user ? JSON.parse(user) : null;
    },
    
    saveDoctor: (doctor) => {
        localStorage.setItem('doctor_data', JSON.stringify(doctor));
    },
    
    getDoctor: () => {
        const doctor = localStorage.getItem('doctor_data');
        return doctor ? JSON.parse(doctor) : null;
    },
    
    isLoggedIn: () => {
        return !!localStorage.getItem('sihati_token');
    },
    
    checkAuth: () => {
        if (!Auth.isLoggedIn()) {
            window.location.href = 'doctor-login.html';
            return false;
        }
        return true;
    },
    
    // Déconnexion
logout: () => {
    localStorage.removeItem('sihati_token');
    localStorage.removeItem('sihati_user');
    localStorage.removeItem('doctor_data');
    window.location.href = '../../index.html';}
};