import Joi from 'joi';

export const validateChatMessage = Joi.object({
  message: Joi.string().min(1).max(1000).required().messages({
    'string.min': 'Le message ne peut pas être vide.',
    'string.max': 'Le message ne peut pas dépasser 1000 caractères.',
    'any.required': 'Le message est requis.',
  }),
});

export const validateSymptoms = Joi.object({
  symptoms: Joi.string().min(2).max(500).required().messages({
    'string.min': 'Veuillez décrire vos symptômes (min. 2 caractères).',
    'string.max': 'La description des symptômes ne peut pas dépasser 500 caractères.',
    'any.required': 'Les symptômes sont requis.',
  }),
});

export const validateDrugInteraction = Joi.object({
  med1: Joi.string().min(2).required().messages({
    'string.min': 'Le nom du premier médicament est invalide.',
    'any.required': 'Le premier médicament est requis.',
  }),
  med2: Joi.string().min(2).required().messages({
    'string.min': 'Le nom du second médicament est invalide.',
    'any.required': 'Le second médicament est requis.',
  }),
});

export const validateMedicationName = Joi.object({
  medication: Joi.string().min(2).required().messages({
    'string.min': 'Le nom du médicament est invalide.',
    'any.required': 'Le nom du médicament est requis.',
  }),
});