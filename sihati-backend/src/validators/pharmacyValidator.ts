import Joi from 'joi';

const algerianPhone = /^0[5-7][0-9]{8}$/;

export const ALGERIAN_WILAYAS = [
  'Adrar', 'Chlef', 'Laghouat', 'Oum El Bouaghi', 'Batna', 'Béjaïa',
  'Biskra', 'Béchar', 'Blida', 'Bouira', 'Tamanrasset', 'Tébessa',
  'Tlemcen', 'Tiaret', 'Tizi Ouzou', 'Alger', 'Djelfa', 'Jijel',
  'Sétif', 'Saïda', 'Skikda', 'Sidi Bel Abbès', 'Annaba', 'Guelma',
  'Constantine', 'Médéa', 'Mostaganem', 'M\'Sila', 'Mascara', 'Ouargla',
  'Oran', 'El Bayadh', 'Illizi', 'Bordj Bou Arréridj', 'Boumerdès',
  'El Tarf', 'Tindouf', 'Tissemsilt', 'El Oued', 'Khenchela',
  'Souk Ahras', 'Tipaza', 'Mila', 'Aïn Defla', 'Naâma',
  'Aïn Témouchent', 'Ghardaïa', 'Relizane',
];

export const validateCreate = Joi.object({
  pharmacyName: Joi.string().min(3).required().messages({
    'string.min': 'Le nom de la pharmacie doit contenir au moins 3 caractères.',
    'any.required': 'Le nom de la pharmacie est requis.',
  }),
  address: Joi.string().min(10).required().messages({
    'string.min': "L'adresse doit contenir au moins 10 caractères.",
    'any.required': "L'adresse est requise.",
  }),
  wilaya: Joi.string()
    .valid(...ALGERIAN_WILAYAS)
    .required()
    .messages({
      'any.only': 'Wilaya invalide.',
      'any.required': 'La wilaya est requise.',
    }),
  commune: Joi.string().optional(),
  latitude: Joi.number().min(-90).max(90).required().messages({
    'number.min': 'Latitude invalide.',
    'number.max': 'Latitude invalide.',
    'any.required': 'La latitude est requise.',
  }),
  longitude: Joi.number().min(-180).max(180).required().messages({
    'number.min': 'Longitude invalide.',
    'number.max': 'Longitude invalide.',
    'any.required': 'La longitude est requise.',
  }),
  phone: Joi.string().pattern(algerianPhone).required().messages({
    'string.pattern.base': 'Numéro de téléphone invalide.',
    'any.required': 'Le numéro de téléphone est requis.',
  }),
  whatsappNumber: Joi.string().pattern(algerianPhone).optional().messages({
    'string.pattern.base': 'Numéro WhatsApp invalide.',
  }),
  email: Joi.string().email().optional(),
  openingHours: Joi.object().optional(),
  isOnDutyTonight: Joi.boolean().optional(),
});

export const validateUpdate = Joi.object({
  pharmacyName: Joi.string().min(3).optional(),
  address: Joi.string().min(10).optional(),
  wilaya: Joi.string().valid(...ALGERIAN_WILAYAS).optional(),
  commune: Joi.string().optional(),
  latitude: Joi.number().min(-90).max(90).optional(),
  longitude: Joi.number().min(-180).max(180).optional(),
  phone: Joi.string().pattern(algerianPhone).optional(),
  whatsappNumber: Joi.string().pattern(algerianPhone).optional(),
  email: Joi.string().email().optional(),
  openingHours: Joi.object().optional(),
  isOnDutyTonight: Joi.boolean().optional(),
  isVerified: Joi.boolean().optional(),
});

export const validateSearch = Joi.object({
  query: Joi.string().min(2).required().messages({
    'string.min': 'Le terme de recherche doit contenir au moins 2 caractères.',
    'any.required': 'Le terme de recherche est requis.',
  }),
  lat: Joi.number().min(-90).max(90).optional(),
  lng: Joi.number().min(-180).max(180).optional(),
  wilaya: Joi.string().optional(),
});