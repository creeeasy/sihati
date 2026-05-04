// ==================== MOCK API - SIMULATION BACKEND ====================

let doctorsDB = JSON.parse(localStorage.getItem('doctors_db')) || [];

function saveDB() {
    localStorage.setItem('doctors_db', JSON.stringify(doctorsDB));
}

const MockAPI = {
    registerDoctor: async (formData) => {
        return new Promise((resolve, reject) => {
            setTimeout(() => {
                const existing = doctorsDB.find(d => d.email === formData.email);
                if (existing) {
                    reject({ message: "Cet email est déjà utilisé" });
                    return;
                }
                
                const newDoctor = {
                    id: Date.now(),
                    firstName: formData.firstName,
                    lastName: formData.lastName,
                    email: formData.email,
                    password: btoa(formData.password),
                    specialty: formData.specialty,
                    licenseNumber: formData.licenseNumber,
                    wilaya: formData.wilaya,
                    commune: formData.commune,
                    phone: formData.phone,
                    address: formData.address || "",
                    bio: formData.bio || "",
                    availability: formData.availability || {},
                    createdAt: new Date().toISOString()
                };
                
                doctorsDB.push(newDoctor);
                saveDB();
                
                resolve({
                    token: "mock-token-" + newDoctor.id,
                    user: {
                        id: newDoctor.id,
                        email: newDoctor.email,
                        name: `Dr. ${newDoctor.firstName} ${newDoctor.lastName}`,
                        specialty: newDoctor.specialty
                    },
                    doctor: newDoctor
                });
            }, 500);
        });
    },
    
    loginDoctor: async (email, password) => {
        return new Promise((resolve, reject) => {
            setTimeout(() => {
                const doctor = doctorsDB.find(d => d.email === email && atob(d.password) === password);
                
                if (!doctor) {
                    reject({ message: "Email ou mot de passe incorrect" });
                    return;
                }
                
                resolve({
                    token: "mock-token-" + doctor.id,
                    user: {
                        id: doctor.id,
                        email: doctor.email,
                        name: `Dr. ${doctor.firstName} ${doctor.lastName}`,
                        specialty: doctor.specialty
                    },
                    doctor: doctor
                });
            }, 500);
        });
    },
    
    getDoctorProfile: async (userId) => {
        return new Promise((resolve, reject) => {
            const doctor = doctorsDB.find(d => d.id == userId);
            if (!doctor) {
                reject({ message: "Médecin non trouvé" });
                return;
            }
            resolve(doctor);
        });
    },
    
    updateDoctorProfile: async (userId, data) => {
        return new Promise((resolve, reject) => {
            const index = doctorsDB.findIndex(d => d.id == userId);
            if (index === -1) {
                reject({ message: "Médecin non trouvé" });
                return;
            }
            doctorsDB[index] = { ...doctorsDB[index], ...data };
            saveDB();
            resolve(doctorsDB[index]);
        });
    }
};