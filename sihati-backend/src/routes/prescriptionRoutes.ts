// src/routes/prescriptionRoutes.ts
import { Router } from 'express';
import * as prescriptionController from '../controllers/prescriptionController';
import { authenticateToken } from '../middlewares/authMiddleware';

const router = Router();

// Toutes les routes nécessitent une authentification
router.use(authenticateToken);

// Routes principales
router.post('/', prescriptionController.createPrescription);
router.get('/patient/:patientId', prescriptionController.getPatientPrescriptions);
router.get('/:id', prescriptionController.getPrescriptionById);
router.put('/:id', prescriptionController.updatePrescription);
router.delete('/:id', prescriptionController.deletePrescription);
router.get('/:id/pdf', prescriptionController.generatePrescriptionPDF);

export default router;