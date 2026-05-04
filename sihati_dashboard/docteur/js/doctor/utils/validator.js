// ==================== VALIDATOR ====================
const Validator = {
    // Vérifier si une chaîne est vide
    isEmpty: (value) => {
        return !value || value.trim() === '';
    },
    
    // Valider email
    isValidEmail: (email) => {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    },
    
    // Valider mot de passe (au moins 6 caractères)
    isValidPassword: (password) => {
        return password && password.length >= 6;
    },
    
    // Valider téléphone algérien
    isValidPhone: (phone) => {
        const phoneRegex = /^(0[567])\d{8}$|^(05|06|07)\d{8}$/;
        return phoneRegex.test(phone);
    },
    
    // Valifier le formulaire de connexion
    validateLoginForm: (email, password) => {
        const errors = {};
        
        if (!email) {
            errors.email = "L'email est requis";
        } else if (!Validator.isValidEmail(email)) {
            errors.email = "Email invalide";
        }
        
        if (!password) {
            errors.password = "Le mot de passe est requis";
        } else if (!Validator.isValidPassword(password)) {
            errors.password = "Le mot de passe doit contenir au moins 6 caractères";
        }
        
        return {
            isValid: Object.keys(errors).length === 0,
            errors: errors
        };
    },
    
    // Valider le formulaire d'inscription médecin (étape 1)
    validateDoctorRegisterStep1: (firstName, lastName, email, password, confirmPassword, terms) => {
        const errors = {};
        
        if (!firstName) errors.firstName = "Le prénom est requis";
        if (!lastName) errors.lastName = "Le nom est requis";
        if (!email) errors.email = "L'email est requis";
        else if (!Validator.isValidEmail(email)) errors.email = "Email invalide";
        
        if (!password) errors.password = "Le mot de passe est requis";
        else if (!Validator.isValidPassword(password)) errors.password = "Le mot de passe doit contenir au moins 6 caractères";
        
        if (password !== confirmPassword) errors.confirmPassword = "Les mots de passe ne correspondent pas";
        if (!terms) errors.terms = "Vous devez accepter les conditions d'utilisation";
        
        return {
            isValid: Object.keys(errors).length === 0,
            errors: errors
        };
    },
    
    // Valider le formulaire d'inscription médecin (étape 2)
    validateDoctorRegisterStep2: (specialty, licenseNumber, wilaya, commune, phone) => {
        const errors = {};
        
        if (!specialty) errors.specialty = "La spécialité est requise";
        if (!licenseNumber) errors.licenseNumber = "Le numéro de licence est requis";
        if (!wilaya) errors.wilaya = "La wilaya est requise";
        if (!commune) errors.commune = "La commune est requise";
        if (!phone) errors.phone = "Le téléphone est requis";
        else if (!Validator.isValidPhone(phone)) errors.phone = "Numéro de téléphone invalide";
        
        return {
            isValid: Object.keys(errors).length === 0,
            errors: errors
        };
    }
};