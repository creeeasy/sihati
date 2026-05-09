// src/routes/allergyRoutes.ts
import { Router } from 'express';
import * as allergyController from '../controllers/allergyController';
import { authenticateToken } from '../middlewares/authMiddleware';

const router = Router();

// Toutes les routes nécessitent une authentification
router.use(authenticateToken);

router.get('/patient/:patientId', allergyController.getPatientAllergies);
router.post('/patient/:patientId', allergyController.addAllergy);
router.delete('/:id', allergyController.deleteAllergy);
router.put('/:id', allergyController.updateAllergy);

export default router;