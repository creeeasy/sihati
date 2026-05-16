// src/controllers/consultationController.ts
import { Request, Response, NextFunction } from 'express';
import { Consultation, Doctor, User } from '../models';

interface AuthRequest extends Request {
  user?: { id: string; email: string; role: string };
}

const getId = (param: string | string[] | undefined): string => {
  if (typeof param === 'string') return param;
  if (Array.isArray(param)) return param[0];
  return '';
};

// POST /api/consultations
export const createConsultation = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { patientId, appointmentId, chiefComplaint, symptoms, diagnosis, treatmentPlan, notes } = req.body;
    
    // ✅ Récupérer l'userId du médecin connecté (JWT)
    const doctorUserId = req.user?.id;
    if (!doctorUserId) {
      return res.status(401).json({ success: false, message: 'Utilisateur non authentifié' });
    }
    
    // ✅ Vérifier que l'utilisateur a un profil médecin
    const doctor = await Doctor.findOne({ where: { userId: doctorUserId } });
    if (!doctor) {
      return res.status(404).json({ success: false, message: 'Profil médecin non trouvé' });
    }
    
    const consultation = await Consultation.create({
      patientId,
      doctorId: doctorUserId,  // ✅ doctorId → users.id
      appointmentId,
      chiefComplaint,
      symptoms,
      diagnosis,
      treatmentPlan,
      notes,
      consultationDate: new Date()
    });
    
    return res.status(201).json({ success: true, data: consultation });
  } catch (error) {
    return next(error);
  }
};

// GET /api/consultations/patient/:patientId
export const getPatientConsultations = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const patientId = getId(req.params.patientId);
    const consultations = await Consultation.findAll({
      where: { patientId },
      include: [
        { model: User, as: 'doctor', attributes: ['id', 'fullName', 'profileImage'] }
      ],
      order: [['consultationDate', 'DESC']]
    });
    return res.json({ success: true, data: consultations });
  } catch (error) {
    return next(error);
  }
};

// GET /api/consultations/:id
export const getConsultationById = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const id = getId(req.params.id);
    const consultation = await Consultation.findByPk(id, {
      include: [
        { model: User, as: 'doctor', attributes: ['id', 'fullName', 'profileImage'] }
      ]
    });
    if (!consultation) {
      return res.status(404).json({ success: false, message: 'Consultation non trouvée' });
    }
    return res.json({ success: true, data: consultation });
  } catch (error) {
    return next(error);
  }
};

// PUT /api/consultations/:id
export const updateConsultation = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const id = getId(req.params.id);
    const consultation = await Consultation.findByPk(id);
    if (!consultation) {
      return res.status(404).json({ success: false, message: 'Consultation non trouvée' });
    }
    await consultation.update(req.body);
    return res.json({ success: true, data: consultation });
  } catch (error) {
    return next(error);
  }
};

// DELETE /api/consultations/:id
export const deleteConsultation = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const id = getId(req.params.id);
    const consultation = await Consultation.findByPk(id);
    if (!consultation) {
      return res.status(404).json({ success: false, message: 'Consultation non trouvée' });
    }
    await consultation.destroy();
    return res.json({ success: true, message: 'Consultation supprimée' });
  } catch (error) {
    return next(error);
  }
};