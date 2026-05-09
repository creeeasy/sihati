
import { Request, Response, NextFunction } from 'express';
import patientService from '../services/patientService';

interface AuthRequest extends Request {
  user?: { id: string; email: string; role: string };
}

const getId = (param: string | string[] | undefined): string => {
  if (typeof param === 'string') return param;
  if (Array.isArray(param)) return param[0];
  return '';
};

// ============================================
// PROFIL
// ============================================

export const getPatientProfile = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const userId = req.user!.id;
    const profile = await patientService.getPatientProfile(userId);
    return res.json({ success: true, data: profile });
  } catch (error) {
    return next(error);
  }
};

export const updatePatientProfile = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const userId = req.user!.id;
    const profile = await patientService.updatePatientProfile(userId, req.body);
    return res.json({ success: true, data: profile });
  } catch (error) {
    return next(error);
  }
};

// ============================================
// ALLERGIES
// ============================================

export const getAllergies = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const userId = req.user!.id;
    const allergies = await patientService.getAllergies(userId);
    return res.json({ success: true, data: allergies });
  } catch (error) {
    return next(error);
  }
};

export const addAllergy = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const userId = req.user!.id;
    const allergy = await patientService.addAllergy(userId, req.body);
    return res.status(201).json({ success: true, data: allergy });
  } catch (error) {
    return next(error);
  }
};

export const deleteAllergy = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const allergyId = getId(req.params.id);
    await patientService.deleteAllergy(allergyId);
    return res.json({ success: true, message: 'Allergie supprimée' });
  } catch (error) {
    return next(error);
  }
};

// ============================================
// PRESCRIPTIONS
// ============================================

export const getPrescriptions = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const userId = req.user!.id;
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;
    const result = await patientService.getPrescriptions(userId, page, limit);
    return res.json({ success: true, ...result });
  } catch (error) {
    return next(error);
  }
};

export const getPrescriptionById = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const prescriptionId = getId(req.params.id);
    const prescription = await patientService.getPrescriptionById(prescriptionId);
    return res.json({ success: true, data: prescription });
  } catch (error) {
    return next(error);
  }
};

// ============================================
// CONSULTATIONS
// ============================================

export const getConsultations = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const userId = req.user!.id;
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;
    const result = await patientService.getConsultations(userId, page, limit);
    return res.json({ success: true, ...result });
  } catch (error) {
    return next(error);
  }
};

export const getConsultationById = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const consultationId = getId(req.params.id);
    const consultation = await patientService.getConsultationById(consultationId);
    return res.json({ success: true, data: consultation });
  } catch (error) {
    return next(error);
  }
};

// ============================================
// DOCUMENTS
// ============================================

export const getDocuments = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const userId = req.user!.id;
    const documents = await patientService.getDocuments(userId);
    return res.json({ success: true, data: documents });
  } catch (error) {
    return next(error);
  }
};

export const addDocument = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const userId = req.user!.id;
    const { title, description, documentType, documentDate } = req.body;
    const fileUrl = req.file?.path || req.body.fileUrl;
    
    if (!fileUrl) {
      return res.status(400).json({ success: false, message: 'Fichier requis' });
    }
    
    const document = await patientService.addDocument(userId, {
      title,
      description,
      documentType,
      documentDate
    }, fileUrl);
    
    return res.status(201).json({ success: true, data: document });
  } catch (error) {
    return next(error);
  }
};

export const deleteDocument = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const documentId = getId(req.params.id);
    await patientService.deleteDocument(documentId);
    return res.json({ success: true, message: 'Document supprimé' });
  } catch (error) {
    return next(error);
  }
};

// ============================================
// STATISTIQUES
// ============================================

export const getPatientStats = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const userId = req.user!.id;
    const stats = await patientService.getStats(userId);
    return res.json({ success: true, data: stats });
  } catch (error) {
    return next(error);
  }
};