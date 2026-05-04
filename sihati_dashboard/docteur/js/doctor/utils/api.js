// ==================== API ====================
const API = {
    post: async (endpoint, data) => {
        console.log(`API call to: ${endpoint}`, data);
        
        if (endpoint === '/auth/doctor/register') {
            return await MockAPI.registerDoctor(data);
        }
        
        if (endpoint === '/auth/login') {
            if (data.userType === 'doctor') {
                return await MockAPI.loginDoctor(data.email, data.password);
            }
        }
        
        if (endpoint === '/doctor/profile') {
            const userId = Auth.getUser()?.id;
            return await MockAPI.getDoctorProfile(userId);
        }
        
        throw new Error(`Endpoint non supporté: ${endpoint}`);
    },
    
    get: async (endpoint) => {
        console.log(`API GET: ${endpoint}`);
        throw new Error(`GET non supporté: ${endpoint}`);
    },
    
    put: async (endpoint, data) => {
        console.log(`API PUT: ${endpoint}`, data);
        throw new Error(`PUT non supporté: ${endpoint}`);
    },
    
    delete: async (endpoint) => {
        console.log(`API DELETE: ${endpoint}`);
        throw new Error(`DELETE non supporté: ${endpoint}`);
    }
};