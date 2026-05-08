// src/validators/authValidator.ts
import Joi from 'joi';

const algerianPhone = /^0[5-7][0-9]{8}$/;

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
  role: Joi.string()
    .valid('patient', 'pharmacy', 'doctor')
    .default('patient')
    .messages({
      'any.only': 'Rôle invalide.',
    }),
  chifaNumber: Joi.string().pattern(/^\d+$/).min(13).max(15).optional().messages({
    'string.pattern.base': 'Le numéro Chifa ne doit contenir que des chiffres.',
    'string.min': 'Le numéro Chifa doit contenir au moins 13 chiffres.',
    'string.max': 'Le numéro Chifa doit contenir au maximum 15 chiffres.',
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

// 🆕 VALIDATE REFRESH TOKEN
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