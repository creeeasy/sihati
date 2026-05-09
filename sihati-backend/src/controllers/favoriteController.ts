// src/controllers/favoriteController.ts
import { Request, Response, NextFunction } from 'express';
import favoriteService from '../services/favoriteService';

interface AuthRequest extends Request {
  user?: { id: string; email: string; role: string };
}

const getId = (param: string | string[] | undefined): string => {
  if (typeof param === 'string') return param;
  if (Array.isArray(param)) return param[0];
  return '';
};

// ============================================
// MÉDECINS FAVORIS
// ============================================

export const getFavoriteDoctors = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const patientId = req.user!.id;
    const doctors = await favoriteService.getFavoriteDoctors(patientId);
    return res.json({ success: true, data: doctors, count: doctors.length });
  } catch (error) {
    return next(error);
  }
};

export const addFavoriteDoctor = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const patientId = req.user!.id;
    const doctorId = getId(req.params.id);
    
    if (!doctorId) {
      return res.status(400).json({ success: false, message: 'ID médecin invalide' });
    }
    
    const favorite = await favoriteService.addFavoriteDoctor(patientId, doctorId);
    return res.status(201).json({ success: true, data: favorite, message: 'Médecin ajouté aux favoris' });
  } catch (error) {
    return next(error);
  }
};

export const removeFavoriteDoctor = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const patientId = req.user!.id;
    const doctorId = getId(req.params.id);
    
    if (!doctorId) {
      return res.status(400).json({ success: false, message: 'ID médecin invalide' });
    }
    
    await favoriteService.removeFavoriteDoctor(patientId, doctorId);
    return res.json({ success: true, message: 'Médecin retiré des favoris' });
  } catch (error) {
    return next(error);
  }
};

export const checkDoctorFavorite = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const patientId = req.user!.id;
    const doctorId = getId(req.params.id);
    
    if (!doctorId) {
      return res.status(400).json({ success: false, message: 'ID médecin invalide' });
    }
    
    const isFavorite = await favoriteService.isDoctorFavorite(patientId, doctorId);
    return res.json({ success: true, data: { isFavorite } });
  } catch (error) {
    return next(error);
  }
};

// ============================================
// PHARMACIES FAVORIS
// ============================================

export const getFavoritePharmacies = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const patientId = req.user!.id;
    const pharmacies = await favoriteService.getFavoritePharmacies(patientId);
    return res.json({ success: true, data: pharmacies, count: pharmacies.length });
  } catch (error) {
    return next(error);
  }
};

export const addFavoritePharmacy = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const patientId = req.user!.id;
    const pharmacyId = getId(req.params.id);
    
    if (!pharmacyId) {
      return res.status(400).json({ success: false, message: 'ID pharmacie invalide' });
    }
    
    const favorite = await favoriteService.addFavoritePharmacy(patientId, pharmacyId);
    return res.status(201).json({ success: true, data: favorite, message: 'Pharmacie ajoutée aux favoris' });
  } catch (error) {
    return next(error);
  }
};

export const removeFavoritePharmacy = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const patientId = req.user!.id;
    const pharmacyId = getId(req.params.id);
    
    if (!pharmacyId) {
      return res.status(400).json({ success: false, message: 'ID pharmacie invalide' });
    }
    
    await favoriteService.removeFavoritePharmacy(patientId, pharmacyId);
    return res.json({ success: true, message: 'Pharmacie retirée des favoris' });
  } catch (error) {
    return next(error);
  }
};

export const checkPharmacyFavorite = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const patientId = req.user!.id;
    const pharmacyId = getId(req.params.id);
    
    if (!pharmacyId) {
      return res.status(400).json({ success: false, message: 'ID pharmacie invalide' });
    }
    
    const isFavorite = await favoriteService.isPharmacyFavorite(patientId, pharmacyId);
    return res.json({ success: true, data: { isFavorite } });
  } catch (error) {
    return next(error);
  }
};

// ============================================
// STATISTIQUES
// ============================================

export const getFavoriteStats = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const patientId = req.user!.id;
    const stats = await favoriteService.getFavoriteCounts(patientId);
    return res.json({ success: true, data: stats });
  } catch (error) {
    return next(error);
  }
};