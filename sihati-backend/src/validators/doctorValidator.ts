import Joi from 'joi';
import { ALGERIAN_WILAYAS } from './pharmacyValidator';

const algerianPhone = /^0[5-7][0-9]{8}$/;

export const validateCreate = Joi.object({
  userId: Joi.number().integer().required().messages({
    'any.required': "L'ID utilisateur est requis.",
  }),
  specialtyId: Joi.number().integer().required().messages({
    'any.required': 'La spécialité est requise.',
  }),
  doctorName: Joi.string().min(3).required().messages({
    'string.min': 'Le nom du médecin doit contenir au moins 3 caractères.',
    'any.required': 'Le nom du médecin est requis.',
  }),
  clinicName: Joi.string().min(3).required().messages({
    'any.required': 'Le nom du cabinet est requis.',
  }),
  clinicAddress: Joi.string().min(10).required().messages({
    'any.required': "L'adresse du cabinet est requise.",
  }),
  wilaya: Joi.string().valid(...ALGERIAN_WILAYAS).required().messages({
    'any.only': 'Wilaya invalide.',
    'any.required': 'La wilaya est requise.',
  }),
  commune: Joi.string().optional(),
  latitude: Joi.number().min(-90).max(90).required(),
  longitude: Joi.number().min(-180).max(180).required(),
  phone: Joi.string().pattern(algerianPhone).required().messages({
    'string.pattern.base': 'Numéro de téléphone invalide.',
    'any.required': 'Le numéro de téléphone est requis.',
  }),
  whatsappNumber: Joi.string().pattern(algerianPhone).optional(),
  consultationFee: Joi.number().min(0).optional(),
  workingHours: Joi.object().optional(),
  bio: Joi.string().optional(),
  yearsOfExperience: Joi.number().integer().min(0).optional(),
});

export const validateUpdate = Joi.object({
  specialtyId: Joi.number().integer().optional(),
  doctorName: Joi.string().min(3).optional(),
  clinicName: Joi.string().min(3).optional(),
  clinicAddress: Joi.string().min(10).optional(),
  wilaya: Joi.string().valid(...ALGERIAN_WILAYAS).optional(),
  commune: Joi.string().optional(),
  latitude: Joi.number().min(-90).max(90).optional(),
  longitude: Joi.number().min(-180).max(180).optional(),
  phone: Joi.string().pattern(algerianPhone).optional(),
  whatsappNumber: Joi.string().pattern(algerianPhone).optional(),
  consultationFee: Joi.number().min(0).optional(),
  workingHours: Joi.object().optional(),
  bio: Joi.string().optional(),
  yearsOfExperience: Joi.number().integer().min(0).optional(),
  isVerified: Joi.boolean().optional(),
});