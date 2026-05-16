import Joi from 'joi';

const algerianPhone = /^0[5-7][0-9]{8}$/;

const pharmacyDataSchema = Joi.object({
  pharmacyName: Joi.string().min(3).max(100).required().messages({
    'string.min': 'Le nom de la pharmacie doit contenir au moins 3 caractères.',
    'string.max': 'Le nom de la pharmacie ne peut pas dépasser 100 caractères.',
    'any.required': 'Le nom de la pharmacie est requis.',
  }),
  address: Joi.string().min(5).max(255).required().messages({
    'string.min': "L'adresse doit contenir au moins 5 caractères.",
    'string.max': "L'adresse ne peut pas dépasser 255 caractères.",
    'any.required': "L'adresse est requise.",
  }),
  wilaya: Joi.string().required().messages({
    'any.required': 'La wilaya est requise.',
  }),
  commune: Joi.string().allow(null, '').optional(),
  latitude: Joi.number().min(-90).max(90).required().messages({
    'number.min': 'La latitude doit être comprise entre -90 et 90.',
    'number.max': 'La latitude doit être comprise entre -90 et 90.',
    'any.required': 'La latitude est requise.',
  }),
  longitude: Joi.number().min(-180).max(180).required().messages({
    'number.min': 'La longitude doit être comprise entre -180 et 180.',
    'number.max': 'La longitude doit être comprise entre -180 et 180.',
    'any.required': 'La longitude est requise.',
  }),
  phone: Joi.string().pattern(algerianPhone).required().messages({
    'string.pattern.base': 'Numéro de téléphone invalide. Format: 0551234567',
    'any.required': 'Le numéro de téléphone est requis.',
  }),
  whatsappNumber: Joi.string().pattern(algerianPhone).allow(null, '').optional().messages({
    'string.pattern.base': 'Numéro WhatsApp invalide. Format: 0551234567',
  }),
});

const doctorDataSchema = Joi.object({
  specialtyId: Joi.string().uuid().required().messages({
    'string.uuid': 'La spécialité doit être un UUID valide.',
    'any.required': 'La spécialité est requise.',
  }),
  doctorName: Joi.string().min(3).max(100).required().messages({
    'string.min': 'Le nom du médecin doit contenir au moins 3 caractères.',
    'string.max': 'Le nom du médecin ne peut pas dépasser 100 caractères.',
    'any.required': 'Le nom du médecin est requis.',
  }),
  clinicName: Joi.string().min(3).max(100).required().messages({
    'string.min': 'Le nom de la clinique doit contenir au moins 3 caractères.',
    'string.max': 'Le nom de la clinique ne peut pas dépasser 100 caractères.',
    'any.required': 'Le nom de la clinique est requis.',
  }),
  clinicAddress: Joi.string().min(5).max(255).required().messages({
    'string.min': "L'adresse de la clinique doit contenir au moins 5 caractères.",
    'string.max': "L'adresse de la clinique ne peut pas dépasser 255 caractères.",
    'any.required': "L'adresse de la clinique est requise.",
  }),
  wilaya: Joi.string().required().messages({
    'any.required': 'La wilaya est requise.',
  }),
  commune: Joi.string().allow(null, '').optional(),
  latitude: Joi.number().min(-90).max(90).required().messages({
    'number.min': 'La latitude doit être comprise entre -90 et 90.',
    'number.max': 'La latitude doit être comprise entre -90 et 90.',
    'any.required': 'La latitude est requise.',
  }),
  longitude: Joi.number().min(-180).max(180).required().messages({
    'number.min': 'La longitude doit être comprise entre -180 et 180.',
    'number.max': 'La longitude doit être comprise entre -180 et 180.',
    'any.required': 'La longitude est requise.',
  }),
  phone: Joi.string().pattern(algerianPhone).required().messages({
    'string.pattern.base': 'Numéro de téléphone invalide. Format: 0551234567',
    'any.required': 'Le numéro de téléphone est requis.',
  }),
  consultationFee: Joi.number().min(0).allow(null).optional().messages({
    'number.min': 'Les honoraires de consultation ne peuvent pas être négatifs.',
  }),
});

export const validateRegister = Joi.object({
  email: Joi.string().email().required().messages({
    'string.email': 'Adresse email invalide.',
    'any.required': "L'email est requis.",
  }),
  password: Joi.string()
    .min(8)
    .pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
    .required()
    .messages({
      'string.min': 'Le mot de passe doit contenir au moins 8 caractères.',
      'string.pattern.base':
        'Le mot de passe doit contenir au moins une majuscule, une minuscule et un chiffre.',
      'any.required': 'Le mot de passe est requis.',
    }),
  fullName: Joi.string().min(3).required().messages({
    'string.min': 'Le nom complet doit contenir au moins 3 caractères.',
    'any.required': 'Le nom complet est requis.',
  }),
  phoneNumber: Joi.string().pattern(algerianPhone).required().messages({
    'string.pattern.base':
      'Numéro de téléphone invalide. Format algérien requis (ex: 0551234567).',
    'any.required': 'Le numéro de téléphone est requis.',
  }),
  role: Joi.string().valid('patient', 'pharmacy', 'doctor').default('patient').messages({
    'any.only': 'Rôle invalide.',
  }),
  chifaNumber: Joi.string().pattern(/^\d+$/).min(13).max(15).optional().messages({
    'string.pattern.base': 'Le numéro Chifa ne doit contenir que des chiffres.',
    'string.min': 'Le numéro Chifa doit contenir au moins 13 chiffres.',
    'string.max': 'Le numéro Chifa doit contenir au maximum 15 chiffres.',
  }),
  address: Joi.string().optional(),
  wilaya: Joi.string().optional(),
  pharmacyData: Joi.when('role', {
    is: 'pharmacy',
    then: pharmacyDataSchema.required().messages({
      'any.required': 'Les données de la pharmacie sont requises pour le rôle pharmacy.',
    }),
    otherwise: Joi.forbidden().messages({
      'any.unknown': 'Les données de la pharmacie ne sont pas autorisées pour ce rôle.',
    }),
  }),
  doctorProfile: Joi.when('role', {
    is: 'doctor',
    then: doctorDataSchema.required().messages({
      'any.required': 'Les données du médecin sont requises pour le rôle doctor.',
    }),
    otherwise: Joi.forbidden().messages({
      'any.unknown': 'Les données du médecin ne sont pas autorisées pour ce rôle.',
    }),
  }),
});

export const validateLogin = Joi.object({
  email: Joi.string().email().required().messages({
    'string.email': 'Adresse email invalide.',
    'any.required': "L'email est requis.",
  }),
  password: Joi.string().required().messages({
    'any.required': 'Le mot de passe est requis.',
  }),
});

export const validateRefreshToken = Joi.object({
  refreshToken: Joi.string().required().messages({
    'any.required': 'Le refresh token est requis.',
  }),
});

export const validateUpdateProfile = Joi.object({
  fullName: Joi.string().min(3).optional().messages({
    'string.min': 'Le nom complet doit contenir au moins 3 caractères.',
  }),
  phoneNumber: Joi.string().pattern(algerianPhone).optional().messages({
    'string.pattern.base': 'Numéro de téléphone invalide.',
  }),
  chifaNumber: Joi.string().pattern(/^\d+$/).min(13).max(15).optional().messages({
    'string.pattern.base': 'Le numéro Chifa ne doit contenir que des chiffres.',
    'string.min': 'Le numéro Chifa doit contenir au moins 13 chiffres.',
    'string.max': 'Le numéro Chifa doit contenir au maximum 15 chiffres.',
  }),
  address: Joi.string().optional(),
  wilaya: Joi.string().optional(),
  profileImage: Joi.string().uri().optional().messages({
    'string.uri': "L'URL de l'image est invalide.",
  }),
});

export const validateChangePassword = Joi.object({
  currentPassword: Joi.string().required().messages({
    'any.required': 'Le mot de passe actuel est requis.',
  }),
  newPassword: Joi.string()
    .min(8)
    .pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
    .required()
    .messages({
      'string.min': 'Le nouveau mot de passe doit contenir au moins 8 caractères.',
      'string.pattern.base':
        'Le nouveau mot de passe doit contenir au moins une majuscule, une minuscule et un chiffre.',
      'any.required': 'Le nouveau mot de passe est requis.',
    }),
});

export const validateForgotPassword = Joi.object({
  email: Joi.string().email().required().messages({
    'string.email': 'Adresse email invalide.',
    'any.required': "L'email est requis.",
  }),
});

export const validateResetPassword = Joi.object({
  token: Joi.string().required().messages({
    'any.required': 'Le token est requis.',
  }),
  newPassword: Joi.string()
    .min(8)
    .pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
    .required()
    .messages({
      'string.min': 'Le mot de passe doit contenir au moins 8 caractères.',
      'string.pattern.base':
        'Le mot de passe doit contenir au moins une majuscule, une minuscule et un chiffre.',
      'any.required': 'Le mot de passe est requis.',
    }),
});

export const validateResendVerification = Joi.object({
  email: Joi.string().email().required().messages({
    'string.email': 'Adresse email invalide.',
    'any.required': "L'email est requis.",
  }),
});