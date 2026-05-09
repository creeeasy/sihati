// src/controllers/allergyController.ts
import { Request, Response, NextFunction } from 'express';
import { PatientAllergy } from '../models';

const getId = (param: string | string[] | undefined): string => {
  if (typeof param === 'string') return param;
  if (Array.isArray(param)) return param[0];
  return '';
};

// GET /api/allergies/patient/:patientId
export const getPatientAllergies = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const patientId = getId(req.params.patientId);
    const allergies = await PatientAllergy.findAll({
      where: { patientId },
      order: [['severity', 'DESC'], ['createdAt', 'DESC']]
    });
    return res.json({ success: true, data: allergies });
  } catch (error) {
    return next(error);
  }
};

// POST /api/allergies/patient/:patientId
export const addAllergy = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const patientId = getId(req.params.patientId);
    const { allergyName, allergyType, severity, reaction } = req.body;
    
    const allergy = await PatientAllergy.create({
      patientId,
      allergyName,
      allergyType: allergyType || 'medication',
      severity: severity || 'mild',
      reaction,
      declaredAt: new Date()
    });
    
    return res.status(201).json({ success: true, data: allergy });
  } catch (error) {
    return next(error);
  }
};

// DELETE /api/allergies/:id
export const deleteAllergy = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const id = getId(req.params.id);
    const allergy = await PatientAllergy.findByPk(id);
    if (!allergy) {
      return res.status(404).json({ success: false, message: 'Allergie non trouvée' });
    }
    await allergy.destroy();
    return res.json({ success: true, message: 'Allergie supprimée' });
  } catch (error) {
    return next(error);
  }
};

// PUT /api/allergies/:id
export const updateAllergy = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const id = getId(req.params.id);
    const allergy = await PatientAllergy.findByPk(id);
    if (!allergy) {
      return res.status(404).json({ success: false, message: 'Allergie non trouvée' });
    }
    await allergy.update(req.body);
    return res.json({ success: true, data: allergy });
  } catch (error) {
    return next(error);
  }
};