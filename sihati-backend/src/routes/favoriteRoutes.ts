// src/routes/favoriteRoutes.ts
import { Router } from 'express';
import * as favoriteController from '../controllers/favoriteController';
import { authenticateToken } from '../middlewares/authMiddleware';

const router = Router();

// Toutes les routes nécessitent une authentification
router.use(authenticateToken);

// Statistiques
router.get('/stats', favoriteController.getFavoriteStats);

// Médecins favoris
router.get('/doctors', favoriteController.getFavoriteDoctors);
router.post('/doctors/:id', favoriteController.addFavoriteDoctor);
router.delete('/doctors/:id', favoriteController.removeFavoriteDoctor);
router.get('/doctors/:id/check', favoriteController.checkDoctorFavorite);

// Pharmacies favorites
router.get('/pharmacies', favoriteController.getFavoritePharmacies);
router.post('/pharmacies/:id', favoriteController.addFavoritePharmacy);
router.delete('/pharmacies/:id', favoriteController.removeFavoritePharmacy);
router.get('/pharmacies/:id/check', favoriteController.checkPharmacyFavorite);

export default router;