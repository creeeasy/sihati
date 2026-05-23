import { Router } from 'express';
import * as medicationController from '../controllers/medicationController';

const router = Router();

// GET /medications — list all (paginated)
router.get('/', medicationController.getAllMedications);

// Routes publiques
router.get('/search', medicationController.searchMedications);
router.get('/popular', medicationController.getPopularMedications);
router.get('/:id', medicationController.getMedicationById);
router.get('/:id/pharmacies', medicationController.getPharmaciesWithStock);
router.post('/barcode', medicationController.searchByBarcode);

export default router;