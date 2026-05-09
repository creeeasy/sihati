// src/controllers/prescriptionController.ts
import { Request, Response, NextFunction } from 'express';
import { Prescription, PrescriptionMedication, Doctor, User, Medication } from '../models';
import { Op } from 'sequelize';

interface AuthRequest extends Request {
  user?: { id: string; email: string; role: string };
}

const getId = (param: string | string[] | undefined): string => {
  if (typeof param === 'string') return param;
  if (Array.isArray(param)) return param[0];
  return '';
};

// POST /api/prescriptions
export const createPrescription = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { patientId, consultationId, diagnosis, medications, validityDays, isRenewable, notes } = req.body;
    
    const doctorUserId = req.user?.id;
    if (!doctorUserId) {
      return res.status(401).json({ success: false, message: 'Utilisateur non authentifié' });
    }
    
    const doctor = await Doctor.findOne({ where: { userId: doctorUserId } });
    if (!doctor) {
      return res.status(404).json({ success: false, message: 'Profil médecin non trouvé' });
    }
    
    // Créer la prescription
    const prescription = await Prescription.create({
      patientId,
      doctorId: doctorUserId,
      consultationId,
      diagnosis,
      notes,
      validityDays: validityDays || 30,
      isRenewable: isRenewable || false,
      prescriptionDate: new Date()
    });
    
    // Créer les médicaments de la prescription
    if (medications && medications.length > 0) {
      for (const med of medications) {
        // Chercher si le médicament existe déjà
        let medication = await Medication.findOne({ where: { name: { [Op.iLike]: med.name } } });
        
        if (!medication) {
          medication = await Medication.create({
            name: med.name,
            genericName: med.genericName,
            form: med.form,
            dosage: med.dosage,
            requiresPrescription: true
          });
        }
        
        // ✅ Correction : utiliser undefined au lieu de null
        await PrescriptionMedication.create({
          prescriptionId: prescription.id,
          medicationId: medication.id,
          medicationName: med.name,
          dosage: med.dosage,
          frequency: med.frequency,
          durationDays: med.durationDays ? parseInt(med.durationDays) : undefined,
          quantity: med.quantity ? parseInt(med.quantity) : undefined,
          instructions: med.instructions
        });
      }
    }
    
    const fullPrescription = await Prescription.findByPk(prescription.id, {
      include: [
        { model: PrescriptionMedication, as: 'medications' }
      ]
    });
    
    return res.status(201).json({ success: true, data: fullPrescription });
  } catch (error) {
    return next(error);
  }
};

// GET /api/prescriptions/patient/:patientId
export const getPatientPrescriptions = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const patientId = getId(req.params.patientId);
    const prescriptions = await Prescription.findAll({
      where: { patientId },
      include: [
        { model: PrescriptionMedication, as: 'medications' },
        { model: Doctor, as: 'doctor', include: [{ model: User, as: 'user', attributes: { exclude: ['password'] } }] }
      ],
      order: [['prescriptionDate', 'DESC']]
    });
    return res.json({ success: true, data: prescriptions });
  } catch (error) {
    return next(error);
  }
};

// GET /api/prescriptions/:id
export const getPrescriptionById = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const id = getId(req.params.id);
    const prescription = await Prescription.findByPk(id, {
      include: [
        { model: PrescriptionMedication, as: 'medications' },
        { model: Doctor, as: 'doctor', include: [{ model: User, as: 'user', attributes: { exclude: ['password'] } }] }
      ]
    });
    if (!prescription) {
      return res.status(404).json({ success: false, message: 'Ordonnance non trouvée' });
    }
    return res.json({ success: true, data: prescription });
  } catch (error) {
    return next(error);
  }
};

// PUT /api/prescriptions/:id
export const updatePrescription = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const id = getId(req.params.id);
    const prescription = await Prescription.findByPk(id);
    if (!prescription) {
      return res.status(404).json({ success: false, message: 'Ordonnance non trouvée' });
    }
    await prescription.update(req.body);
    return res.json({ success: true, data: prescription });
  } catch (error) {
    return next(error);
  }
};

// DELETE /api/prescriptions/:id
export const deletePrescription = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const id = getId(req.params.id);
    const prescription = await Prescription.findByPk(id);
    if (!prescription) {
      return res.status(404).json({ success: false, message: 'Ordonnance non trouvée' });
    }
    await prescription.destroy();
    return res.json({ success: true, message: 'Ordonnance supprimée' });
  } catch (error) {
    return next(error);
  }
};

// GET /api/prescriptions/:id/pdf
export const generatePrescriptionPDF = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const id = getId(req.params.id);
    const prescription = await Prescription.findByPk(id, {
      include: [
        { model: PrescriptionMedication, as: 'medications' },
        { model: Doctor, as: 'doctor', include: [{ model: User, as: 'user', attributes: { exclude: ['password'] } }] }
      ]
    });
    
    if (!prescription) {
      return res.status(404).json({ success: false, message: 'Ordonnance non trouvée' });
    }
    
    // TODO: Générer un vrai PDF avec une bibliothèque comme pdfkit
    return res.json({
      success: true,
      data: prescription
    });
  } catch (error) {
    return next(error);
  }
};