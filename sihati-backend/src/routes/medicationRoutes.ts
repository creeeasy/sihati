// src/routes/medicationRoutes.ts
import { Router } from 'express';
import * as medicationController from '../controllers/medicationController';
//import { authenticateToken } from '../middlewares/authMiddleware';

const router = Router();

// Routes publiques
router.get('/search', medicationController.searchMedications);
router.get('/popular', medicationController.getPopularMedications);
router.get('/:id', medicationController.getMedicationById);
router.get('/:id/pharmacies', medicationController.getPharmaciesWithStock);
router.post('/barcode', medicationController.searchByBarcode);
/*
// Routes protégées (admin uniquement)
router.post('/', authenticateToken, (req, res, next) => {
  // TODO: Vérifier que l'utilisateur est admin
  next();
}, async (req, res, next) => {
  // À implémenter: création d'un médicament
  return res.status(501).json({ success: false, message: 'Non implémenté' });
});
*/

export default router;