// ==================== MOCK API - PHARMACIE ====================

let pharmaciesDB = JSON.parse(localStorage.getItem('pharmacies_db')) || [];

function saveDB() {
    localStorage.setItem('pharmacies_db', JSON.stringify(pharmaciesDB));
}

const MockAPI = {
    // Inscription pharmacie
    registerPharmacy: async (formData) => {
        return new Promise((resolve, reject) => {
            setTimeout(() => {
                const existing = pharmaciesDB.find(p => p.email === formData.email);
                if (existing) {
                    reject({ message: "Cet email est déjà utilisé" });
                    return;
                }
                
                const newPharmacy = {
                    id: Date.now(),
                    email: formData.email,
                    password: btoa(formData.password),
                    pharmacyName: formData.pharmacyName,
                    licenseNumber: formData.licenseNumber,
                    address: formData.address,
                    wilaya: formData.wilaya,
                    commune: formData.commune,
                    phone: formData.phone,
                    whatsapp: formData.whatsapp || "",
                    openingHours: formData.openingHours || {},
                    createdAt: new Date().toISOString()
                };
                
                pharmaciesDB.push(newPharmacy);
                saveDB();
                
                resolve({
                    token: "mock-token-pharma-" + newPharmacy.id,
                    user: {
                        id: newPharmacy.id,
                        email: newPharmacy.email,
                        name: newPharmacy.pharmacyName
                    },
                    pharmacy: newPharmacy
                });
            }, 500);
        });
    },
    
    // Connexion pharmacie
    loginPharmacy: async (email, password) => {
        return new Promise((resolve, reject) => {
            setTimeout(() => {
                const pharmacy = pharmaciesDB.find(p => p.email === email && atob(p.password) === password);
                
                if (!pharmacy) {
                    reject({ message: "Email ou mot de passe incorrect" });
                    return;
                }
                
                resolve({
                    token: "mock-token-pharma-" + pharmacy.id,
                    user: {
                        id: pharmacy.id,
                        email: pharmacy.email,
                        name: pharmacy.pharmacyName
                    },
                    pharmacy: pharmacy
                });
            }, 500);
        });
    }
};