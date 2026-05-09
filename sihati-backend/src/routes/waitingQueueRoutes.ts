// src/routes/waitingQueueRoutes.ts
import { Router } from 'express';
import * as waitingQueueController from '../controllers/waitingQueueController';
import { authenticateToken } from '../middlewares/authMiddleware';

const router = Router();

router.use(authenticateToken);

router.get('/doctor/:doctorId', waitingQueueController.getQueue);
router.post('/', waitingQueueController.addPatient);
router.put('/:id/next', waitingQueueController.callNext);
router.put('/:id/complete', waitingQueueController.completeConsultation);
router.put('/:id/priority', waitingQueueController.setPriority);
router.delete('/:id', waitingQueueController.removePatient);

export default router;