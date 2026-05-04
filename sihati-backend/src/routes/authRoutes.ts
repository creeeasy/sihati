// src/routes/auth.routes.ts
import { Router } from 'express';
import * as authController from '../controllers/authController';
import { validate } from '../middlewares/validation';
import { authenticateToken } from '../middlewares/authMiddleware';
import { authLimiter } from '../middlewares/rateLimiter';
import {
  validateRegister,
  validateLogin,
  validateRefreshToken,
} from '../validators/authValidator';

const router = Router();

// ─── Public routes (rate limited) ────────────────────────────────
router.post('/register', authLimiter, validate(validateRegister), authController.register);
router.post('/login', authLimiter, validate(validateLogin), authController.login);
router.post('/refresh-token', validate(validateRefreshToken), authController.refreshToken);
router.post('/logout', authController.logout); // No auth needed, just clear cookies/tokens

// ─── Forgot password (public) ────────────────────────────────────
router.post('/forgot-password', authLimiter, authController.forgotPassword);
router.post('/reset-password', authLimiter, authController.resetPassword);
router.post('/resend-verification', authLimiter, authController.resendVerification);

// ─── Protected routes (authenticated) ────────────────────────────
router.get('/profile', authenticateToken, authController.getProfile);
router.put('/profile', authenticateToken, authController.updateProfile);
router.put('/profile/chifa', authenticateToken, authController.updateChifaNumber); // 🆕 Carte Chifa
router.post('/change-password', authenticateToken, authController.changePassword);
router.post('/upload-photo', authenticateToken, authController.uploadProfilePhoto);
router.delete('/upload-photo', authenticateToken, authController.deleteProfilePhoto);

// ─── Email verification ──────────────────────────────────────────
router.get('/verify-email', authController.verifyEmail);

export default router;