import { Router } from 'express';
import * as medicationController from '../controllers/medicationController';
import { validate } from '../middlewares/validation';
import { authenticateToken, authorizeRoles } from '../middlewares/authMiddleware';
import { apiLimiter } from '../middlewares/rateLimiter';
import { validateCreate, validateSearch, validateStockUpdate } from '../validators/medicationValidator';

const router = Router();

router.use(apiLimiter);

// Public routes
// IMPORTANT: /popular must be before /:id to avoid being caught as an id param
router.get('/popular', medicationController.getPopularMedications);
router.get('/', medicationController.getAllMedications);
router.get('/:id', medicationController.getMedicationById);
router.post('/search', validate(validateSearch), medicationController.searchMedications);

// Protected routes
router.post(
  '/',
  authenticateToken,
  authorizeRoles('doctor'),
  validate(validateCreate),
  medicationController.createMedication
);

router.put(
  '/:id/stock',
  authenticateToken,
  authorizeRoles('pharmacy'),
  validate(validateStockUpdate),
  medicationController.updateMedicationStock
);

export default router;