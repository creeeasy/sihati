import Joi from 'joi';

const historyItemSchema = Joi.object({
  role: Joi.string().valid('user', 'model').required(),
  parts: Joi.array()
    .items(Joi.object({ text: Joi.string().required() }))
    .min(1)
    .required(),
});

export const validateChatMessage = Joi.object({
  message: Joi.string().min(1).max(1000).required().messages({
    'string.min': 'Le message ne peut pas être vide.',
    'string.max': 'Le message ne peut pas dépasser 1000 caractères.',
    'any.required': 'Le message est requis.',
  }),
  history: Joi.array().items(historyItemSchema).max(20).optional(),
  location: Joi.object({
    lat: Joi.number().min(-90).max(90).required(),
    lng: Joi.number().min(-180).max(180).required(),
  }).optional(),
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