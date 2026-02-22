import { Router } from 'express';
import * as aiController from '../controllers/aiController';
import { validate } from '../middlewares/validation';
import { optionalAuth } from '../middlewares/authMiddleware';
import { aiLimiter } from '../middlewares/rateLimiter';
import {
  validateChatMessage,
  validateSymptoms,
  validateDrugInteraction,
  validateMedicationName,
} from '../validators/aiValidator';

const router = Router();

// Apply AI rate limiter to all routes
router.use(aiLimiter);

// All AI routes are public but optionally save history if authenticated
router.post('/chat', optionalAuth, validate(validateChatMessage), aiController.chat);
router.post('/medications', validate(validateSymptoms), aiController.getMedicationSuggestions);
router.post('/interaction', validate(validateDrugInteraction), aiController.checkInteraction);
router.post('/medication-info', validate(validateMedicationName), aiController.getMedicationInfo);
router.post('/specialty', validate(validateSymptoms), aiController.suggestSpecialty);

export default router;