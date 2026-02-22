import Joi from 'joi';

export const validateCreate = Joi.object({
  name: Joi.string().min(2).required().messages({
    'string.min': 'Le nom du médicament doit contenir au moins 2 caractères.',
    'any.required': 'Le nom du médicament est requis.',
  }),
  genericName: Joi.string().optional(),
  category: Joi.string().optional(),
  manufacturer: Joi.string().optional(),
  description: Joi.string().optional(),
  dosageForm: Joi.string()
    .valid('Comprimé', 'Sirop', 'Injection', 'Capsule', 'Crème', 'Suppositoire', 'Sachet', 'Gouttes')
    .optional(),
  strength: Joi.string().optional(),
  requiresPrescription: Joi.boolean().optional(),
  price: Joi.number().min(0).optional(),
  barcode: Joi.string().optional(),
  activeIngredients: Joi.array().items(Joi.string()).optional(),
  sideEffects: Joi.string().optional(),
  contraindications: Joi.string().optional(),
});

export const validateSearch = Joi.object({
  query: Joi.string().min(2).required().messages({
    'string.min': 'Le terme de recherche doit contenir au moins 2 caractères.',
    'any.required': 'Le terme de recherche est requis.',
  }),
  lat: Joi.number().min(-90).max(90).optional(),
  lng: Joi.number().min(-180).max(180).optional(),
});

export const validateStockUpdate = Joi.object({
  pharmacyId: Joi.number().integer().required().messages({
    'any.required': "L'ID de la pharmacie est requis.",
  }),
  inStock: Joi.boolean().required().messages({
    'any.required': 'Le statut du stock est requis.',
  }),
  quantity: Joi.number().integer().min(0).optional(),
});