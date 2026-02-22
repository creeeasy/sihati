import { Router } from 'express';
import * as pharmacyController from '../controllers/pharmacyController';
import { validate } from '../middlewares/validation';
import { authenticateToken, authorizeRoles } from '../middlewares/authMiddleware';
import { apiLimiter } from '../middlewares/rateLimiter';
import { validateCreate, validateUpdate, validateSearch } from '../validators/pharmacyValidator';

const router = Router();

router.use(apiLimiter);

// Public routes
router.get('/', pharmacyController.getAllPharmacies);
router.get('/nearby', pharmacyController.getNearbyPharmacies);
router.get('/duty', pharmacyController.getDutyPharmacies);
router.get('/:id', pharmacyController.getPharmacyById);
router.post('/search', validate(validateSearch), pharmacyController.searchPharmacies);

// Protected routes
router.post(
  '/',
  authenticateToken,
  authorizeRoles('pharmacy', 'doctor'),
  validate(validateCreate),
  pharmacyController.createPharmacy
);

router.put(
  '/:id',
  authenticateToken,
  authorizeRoles('pharmacy', 'doctor'),
  validate(validateUpdate),
  pharmacyController.updatePharmacy
);

router.delete(
  '/:id',
  authenticateToken,
  authorizeRoles('pharmacy'),
  pharmacyController.deletePharmacy
);

export default router;