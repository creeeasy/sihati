import { Router } from 'express';
import * as doctorController from '../controllers/doctorController';
import { validate } from '../middlewares/validation';
import { authenticateToken, authorizeRoles } from '../middlewares/authMiddleware';
import { apiLimiter } from '../middlewares/rateLimiter';
import { validateCreate, validateUpdate } from '../validators/doctorValidator';

const router = Router();

router.use(apiLimiter);

// Public routes
router.get('/', doctorController.getAllDoctors);
router.get('/nearby', doctorController.getNearbyDoctors);
router.get('/top-rated', doctorController.getTopRatedDoctors);
router.get('/:id', doctorController.getDoctorById);
router.post('/search', doctorController.searchDoctors);

// Protected routes
router.post(
  '/',
  authenticateToken,
  authorizeRoles('doctor'),
  validate(validateCreate),
  doctorController.createDoctor
);

router.put(
  '/:id',
  authenticateToken,
  authorizeRoles('doctor'),
  validate(validateUpdate),
  doctorController.updateDoctor
);

export default router;