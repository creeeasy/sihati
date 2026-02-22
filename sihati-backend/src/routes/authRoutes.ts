import { Router } from 'express';
import * as authController from '../controllers/authController';
import { validate } from '../middlewares/validation';
import { authenticateToken } from '../middlewares/authMiddleware';
import { authLimiter } from '../middlewares/rateLimiter';
import {
  validateRegister,
  validateLogin,
} from '../validators/authValidator';

const router = Router();

// Public routes (rate limited)
router.post('/register', authLimiter, validate(validateRegister), authController.register);
router.post('/login', authLimiter, validate(validateLogin), authController.login);

// Protected routes
router.get('/me', authenticateToken, authController.getCurrentUser);
router.post('/refresh', authenticateToken, authController.refreshToken);

export default router;