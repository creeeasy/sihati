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
    
    savePharmacy: (pharmacy) => {
        localStorage.setItem('pharmacy_data', JSON.stringify(pharmacy));
    },
    
    getPharmacy: () => {
        const pharmacy = localStorage.getItem('pharmacy_data');
        return pharmacy ? JSON.parse(pharmacy) : null;
    },
    
    isLoggedIn: () => {
        return !!localStorage.getItem('sihati_token');
    },
    
    checkAuth: () => {
        if (!Auth.isLoggedIn()) {
            window.location.href = 'pharmacy-login.html';
            return false;
        }
        return true;
    },
    
    logout: () => {
        localStorage.removeItem('sihati_token');
        localStorage.removeItem('sihati_user');
        localStorage.removeItem('pharmacy_data');
        window.location.href = '../../index.html';
    }
};