import { Request, Response, NextFunction } from 'express';
import pharmacyService from '../services/pharmacyService';
import {PharmacyMedication,Medication,Pharmacy} from "../models"

const getId = (param: string | string[] | undefined): string => {
  if (typeof param === 'string') return param;
  if (Array.isArray(param)) return param[0];
  return '';
};

// 📌 GET /api/pharmacies
export const getAllPharmacies = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { wilaya, onDuty, userId } = req.query;
    const whereClause: any = {};
    
    if (wilaya) whereClause.wilaya = wilaya;
    if (onDuty === 'true') whereClause.isOnDutyTonight = true;
    if (userId) whereClause.userId = userId;  // ✅ Sequelize convertit automatiquement en user_id
    
    console.log("Where clause:", whereClause);
    console.log("UserId reçu:", userId);
    
    const pharmacies = await Pharmacy.findAll({ where: whereClause });
    console.log("Pharmacies trouvées:", pharmacies.length);
    
    return res.json({ success: true, data: pharmacies, count: pharmacies.length });
  } catch (error) {
    return next(error);
  }
};

// 📌 GET /api/pharmacies/duty
export const getDutyPharmacies = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { wilaya } = req.query;
    const pharmacies = await pharmacyService.getDutyPharmacies(wilaya as string);
    return res.json({ success: true, data: pharmacies, count: pharmacies.length });
  } catch (error) {
    return next(error);
  }
};

// 📌 GET /api/pharmacies/nearby
export const getNearbyPharmacies = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { lat, lng, radius, wilaya } = req.query;
    if (!lat || !lng) {
      return res.status(400).json({ success: false, message: 'Latitude et longitude requises' });
    }
    const pharmacies = await pharmacyService.getNearbyPharmacies(
      Number(lat), Number(lng), radius ? Number(radius) : 5, wilaya as string
    );
    return res.json({ success: true, data: pharmacies, count: pharmacies.length });
  } catch (error) {
    return next(error);
  }
};

// 📌 GET /api/pharmacies/search
export const searchPharmacies = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { q, wilaya } = req.query;
    if (!q) {
      return res.status(400).json({ success: false, message: 'Terme de recherche requis' });
    }
    const pharmacies = await pharmacyService.searchPharmacies(q as string, wilaya as string);
    return res.json({ success: true, data: pharmacies, count: pharmacies.length });
  } catch (error) {
    return next(error);
  }
};

// 📌 GET /api/pharmacies/:id
export const getPharmacyById = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const id = getId(req.params.id);
    if (!id) {
      return res.status(400).json({ success: false, message: 'ID invalide' });
    }
    const pharmacy = await pharmacyService.getPharmacyById(id);
    return res.json({ success: true, data: pharmacy });
  } catch (error) {
    return next(error);
  }
};

// 📌 POST /api/pharmacies
export const createPharmacy = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const pharmacy = await pharmacyService.createPharmacy(req.body);
    return res.status(201).json({ success: true, data: pharmacy });
  } catch (error) {
    return next(error);
  }
};

// 📌 PUT /api/pharmacies/:id
export const updatePharmacy = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const id = getId(req.params.id);
    if (!id) {
      return res.status(400).json({ success: false, message: 'ID invalide' });
    }
    const pharmacy = await pharmacyService.updatePharmacy(id, req.body);
    return res.json({ success: true, data: pharmacy });
  } catch (error) {
    return next(error);
  }
};

// 📌 DELETE /api/pharmacies/:id
export const deletePharmacy = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const id = getId(req.params.id);
    if (!id) {
      return res.status(400).json({ success: false, message: 'ID invalide' });
    }
    await pharmacyService.deletePharmacy(id);
    return res.json({ success: true, message: 'Pharmacie supprimée' });
  } catch (error) {
    return next(error);
  }
};

// 📌 PUT /api/pharmacies/:id/duty
export const setDutyStatus = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const id = getId(req.params.id);
    const { isOnDuty } = req.body;
    if (!id) {
      return res.status(400).json({ success: false, message: 'ID invalide' });
    }
    if (typeof isOnDuty !== 'boolean') {
      return res.status(400).json({ success: false, message: 'isOnDuty doit être un booléen' });
    }
    const pharmacy = await pharmacyService.setDutyStatus(id, isOnDuty);
    return res.json({ success: true, data: pharmacy });
  } catch (error) {
    return next(error);
  }
};

// 📌 GET /api/pharmacies/:id/stock/:medicationId
export const getMedicationStock = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const pharmacyId = getId(req.params.id);
    const medicationId = getId(req.params.medicationId);
    if (!pharmacyId || !medicationId) {
      return res.status(400).json({ success: false, message: 'IDs invalides' });
    }
    const stock = await pharmacyService.getMedicationStock(pharmacyId, medicationId);
    return res.json({ success: true, data: stock });
  } catch (error) {
    return next(error);
  }
};

// 📌 PUT /api/pharmacies/:id/stock/:medicationId
export const updateStock = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const pharmacyId = getId(req.params.id);
    const medicationId = getId(req.params.medicationId);
    const { inStock, quantity, price } = req.body;
    if (!pharmacyId || !medicationId) {
      return res.status(400).json({ success: false, message: 'IDs invalides' });
    }
    const stock = await pharmacyService.updateStock(pharmacyId, medicationId, { inStock, quantity, price });
    return res.json({ success: true, data: stock });
  } catch (error) {
    return next(error);
  }

};
export const getPharmacyStock = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const pharmacyId = req.params.id;
    const stock = await PharmacyMedication.findAll({
      where: { pharmacyId },
      include: [{ model: Medication, as: 'medication' }]  // 'medication' est l'alias
    });
    const formattedStock = stock.map(item => {
      // Accéder à medication via l'alias 'medication'
      const medication = (item as any).medication;
      return {
        medication_id: item.medicationId,
        medication_name: medication?.name || 'Médicament',
        quantity: item.quantity || 0,
        price: item.price,
        inStock: item.inStock
      };
    });
    return res.json({ success: true, data: formattedStock });
  } catch (error) {
    return next(error);
  }
};