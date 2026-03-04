import { Router } from 'express';
import * as aiController from '../controllers/aiController';
import { validate } from '../middlewares/validation';
import { optionalAuth, authenticateToken } from '../middlewares/authMiddleware';
import { aiLimiter } from '../middlewares/rateLimiter';
import {
  validateChatMessage,
  validateSymptoms,
  validateDrugInteraction,
  validateMedicationName,
} from '../validators/aiValidator';

const router = Router();

// conversation/:id must be registered BEFORE aiLimiter so it is not rate-limited
router.get('/conversation/:id', authenticateToken, aiController.getConversation);

router.use(aiLimiter);

// POST /api/ai/chat — accepts history[] and optional location
router.post('/chat', optionalAuth, validate(validateChatMessage), aiController.chat);

// POST /api/ai/interaction
router.post('/interaction', validate(validateDrugInteraction), aiController.checkInteraction);

// POST /api/ai/medication-info
router.post('/medication-info', validate(validateMedicationName), aiController.getMedicationInfo);

// POST /api/ai/specialty
router.post('/specialty', validate(validateSymptoms), aiController.suggestSpecialty);

// GET /api/ai/history — requires auth
router.get('/history', authenticateToken, aiController.getHistory);



export default router;