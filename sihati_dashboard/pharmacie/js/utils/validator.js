const Validator = {
  // Valider un email
  isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  },
  
  // Valider un mot de passe (minimum 6 caractères)
  isValidPassword(password) {
    return password && password.length >= 6;
  },
  
  // Valider un numéro de téléphone algérien
  isValidPhone(phone) {
    const phoneRegex = /^(0)(5|6|7)[0-9]{8}$/;
    return phoneRegex.test(phone.replace(/\s/g, ''));
  },
  
  // Vérifier si un champ est vide
  isEmpty(value) {
    return !value || value.trim() === '';
  },
  
  // Valider un formulaire de connexion
  validateLoginForm(email, password) {
    const errors = {};
    
    if (this.isEmpty(email)) {
      errors.email = 'L\'email est requis';
    } else if (!this.isValidEmail(email)) {
      errors.email = 'Email invalide';
    }
    
    if (this.isEmpty(password)) {
      errors.password = 'Le mot de passe est requis';
    } else if (!this.isValidPassword(password)) {
      errors.password = 'Le mot de passe doit contenir au moins 6 caractères';
    }
    
    return {
      isValid: Object.keys(errors).length === 0,
      errors
    };
  },
  
  // Afficher une erreur sur un champ
  showError(inputId, message) {
    const input = document.getElementById(inputId);
    const errorDiv = input.parentElement.querySelector('.error-message') || 
                     document.createElement('div');
    
    errorDiv.className = 'error-message text-danger small mt-1';
    errorDiv.textContent = message;
    
    if (!input.parentElement.querySelector('.error-message')) {
      input.parentElement.appendChild(errorDiv);
    }
    
    input.classList.add('is-invalid');
  },
  
  // Effacer les erreurs
  clearErrors(inputId) {
    const input = document.getElementById(inputId);
    const errorDiv = input.parentElement.querySelector('.error-message');
    
    if (errorDiv) {
      errorDiv.remove();
    }
    
    input.classList.remove('is-invalid');
  },
  
  // Effacer toutes les erreurs d'un formulaire
  clearAllErrors(formId) {
    const form = document.getElementById(formId);
    const errors = form.querySelectorAll('.error-message');
    const invalidInputs = form.querySelectorAll('.is-invalid');
    
    errors.forEach(error => error.remove());
    invalidInputs.forEach(input => input.classList.remove('is-invalid'));
  }
};