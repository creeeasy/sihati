import { Router } from 'express';
import * as pharmacyController from '../controllers/pharmacyController';
import { authenticateToken } from '../middlewares/authMiddleware';

const router = Router();

// Routes publiques
router.get('/', pharmacyController.getAllPharmacies);
router.get('/duty', pharmacyController.getDutyPharmacies);
router.get('/nearby', pharmacyController.getNearbyPharmacies);
router.get('/search', pharmacyController.searchPharmacies);
router.get('/:id', pharmacyController.getPharmacyById);

// Routes protégées
router.post('/', authenticateToken, pharmacyController.createPharmacy);
router.put('/:id', authenticateToken, pharmacyController.updatePharmacy);
router.delete('/:id', authenticateToken, pharmacyController.deletePharmacy);
router.put('/:id/duty', authenticateToken, pharmacyController.setDutyStatus);
router.get('/:id/stock', authenticateToken, pharmacyController.getPharmacyStock);
router.get('/:id/stock/:medicationId', authenticateToken, pharmacyController.getMedicationStock);
router.put('/:id/stock/:medicationId', authenticateToken, pharmacyController.updateStock);


export default router;