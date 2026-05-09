// src/routes/patientRoutes.ts
import { Router } from 'express';
import * as patientController from '../controllers/patientController';
import { authenticateToken } from '../middlewares/authMiddleware';

const router = Router();

// Toutes les routes patient nécessitent une authentification
router.use(authenticateToken);

// Profil
router.get('/profile', patientController.getPatientProfile);
router.put('/profile', patientController.updatePatientProfile);

// Allergies
router.get('/allergies', patientController.getAllergies);
router.post('/allergies', patientController.addAllergy);
router.delete('/allergies/:id', patientController.deleteAllergy);

// Prescriptions
router.get('/prescriptions', patientController.getPrescriptions);
router.get('/prescriptions/:id', patientController.getPrescriptionById);

// Consultations
router.get('/consultations', patientController.getConsultations);
router.get('/consultations/:id', patientController.getConsultationById);

// Documents
router.get('/documents', patientController.getDocuments);
router.post('/documents', patientController.addDocument);
router.delete('/documents/:id', patientController.deleteDocument);

// Statistiques
router.get('/stats', patientController.getPatientStats);

export default router;