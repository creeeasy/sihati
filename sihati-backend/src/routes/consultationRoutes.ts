// src/routes/consultationRoutes.ts
import { Router } from 'express';
import * as consultationController from '../controllers/consultationController';
import { authenticateToken } from '../middlewares/authMiddleware';

const router = Router();

// Toutes les routes nécessitent une authentification
router.use(authenticateToken);

router.post('/', consultationController.createConsultation);
router.get('/patient/:patientId', consultationController.getPatientConsultations);
router.get('/:id', consultationController.getConsultationById);
router.put('/:id', consultationController.updateConsultation);
router.delete('/:id', consultationController.deleteConsultation);

export default router;