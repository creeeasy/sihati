// src/controllers/medicationController.ts
import { Request, Response, NextFunction } from 'express';
import medicationService from '../services/medicationService';

const getId = (param: string | string[] | undefined): string => {
  if (typeof param === 'string') return param;
  if (Array.isArray(param)) return param[0];
  return '';
};

// 📌 GET /api/medications/search
export const searchMedications = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { q, category, requiresPrescription } = req.query;
    
    if (!q || (q as string).length < 2) {
      return res.status(400).json({ 
        success: false, 
        message: 'Le terme de recherche doit contenir au moins 2 caractères' 
      });
    }
    
    const medications = await medicationService.searchMedications(
      q as string,
      category as string,
      requiresPrescription === 'true'
    );
    
    return res.json({ success: true, data: medications, count: medications.length });
  } catch (error) {
    return next(error);
  }
};

// 📌 GET /api/medications/:id
export const getMedicationById = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const id = getId(req.params.id);
    if (!id) {
      return res.status(400).json({ success: false, message: 'ID invalide' });
    }
    
    const medication = await medicationService.getMedicationById(id);
    return res.json({ success: true, data: medication });
  } catch (error) {
    return next(error);
  }
};

// 📌 GET /api/medications/:id/pharmacies
export const getPharmaciesWithStock = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const id = getId(req.params.id);
    const { lat, lng, radius } = req.query;
    
    if (!id) {
      return res.status(400).json({ success: false, message: 'ID invalide' });
    }
    
    const pharmacies = await medicationService.getPharmaciesWithStock(
      id,
      lat ? parseFloat(lat as string) : undefined,
      lng ? parseFloat(lng as string) : undefined,
      radius ? parseFloat(radius as string) : 10
    );
    
    return res.json({ success: true, data: pharmacies, count: pharmacies.length });
  } catch (error) {
    return next(error);
  }
};

// 📌 POST /api/medications/barcode
export const searchByBarcode = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { barcode } = req.body;
    
    if (!barcode) {
      return res.status(400).json({ success: false, message: 'Code-barres requis' });
    }
    
    const medication = await medicationService.searchByBarcode(barcode);
    
    if (!medication) {
      return res.status(404).json({ success: false, message: 'Aucun médicament trouvé' });
    }
    
    return res.json({ success: true, data: medication });
  } catch (error) {
    return next(error);
  }
};

// 📌 GET /api/medications/popular
export const getPopularMedications = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const limit = req.query.limit ? parseInt(req.query.limit as string) : 10;
    const medications = await medicationService.getPopularMedications(limit);
    return res.json({ success: true, data: medications });
  } catch (error) {
    return next(error);
  }
};