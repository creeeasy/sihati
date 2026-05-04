// ==================== CONFIGURATION ====================
const CONFIG = {
    APP_NAME: "Sihati",
    APP_VERSION: "1.0.0",
    
    ENDPOINTS: {
        AUTH: {
            LOGIN: "/auth/login",
            REGISTER: "/auth/register",
            LOGOUT: "/auth/logout"
        },
        DOCTOR: {
            PROFILE: "/doctor/profile",
            AVAILABILITY: "/doctor/availability",
            APPOINTMENTS: "/doctor/appointments"
        },
        PHARMACY: {
            PROFILE: "/pharmacy/profile",
            STOCK: "/pharmacy/stock",
            ORDERS: "/pharmacy/orders"
        }
    },
    
    WILAYAS: [
        "Adrar", "Chlef", "Laghouat", "Oum El Bouaghi", "Batna", "Béjaïa", "Biskra", "Béchar", "Blida",
        "Bouira", "Tamanrasset", "Tébessa", "Tlemcen", "Tiaret", "Tizi Ouzou", "Alger", "Djelfa", "Jijel",
        "Sétif", "Saïda", "Skikda", "Sidi Bel Abbès", "Annaba", "Guelma", "Constantine", "Médéa", "Mostaganem",
        "M'Sila", "Mascara", "Ouargla", "Oran", "El Bayadh", "Illizi", "Bordj Bou Arreridj", "Boumerdès",
        "El Tarf", "Tindouf", "Tissemsilt", "El Oued", "Khenchela", "Souk Ahras", "Tipaza", "Mila", "Aïn Defla",
        "Naâma", "Aïn Témouchent", "Ghardaïa", "Relizane", "Timimoun", "Bordj Badji Mokhtar", "Ouled Djellal",
        "Béni Abbès", "In Salah", "In Guezzam", "Touggourt", "Djanet", "El M'Ghair", "El Menia"
    ]
};