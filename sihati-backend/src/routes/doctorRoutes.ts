import { Router } from 'express';
import * as doctorController from '../controllers/doctorController';
import { authenticateToken } from '../middlewares/authMiddleware';

const router = Router();

// Routes publiques
router.get('/', doctorController.getAllDoctors);
router.get('/search', doctorController.searchDoctors);
router.get('/top-rated', doctorController.getTopRatedDoctors);
router.get('/specialties', doctorController.getAllSpecialties);
router.get('/:id', doctorController.getDoctorById);

// Routes protégées
router.post('/', authenticateToken, doctorController.createDoctor);
router.put('/:id', authenticateToken, doctorController.updateDoctor);
router.delete('/:id', authenticateToken, doctorController.deleteDoctor);
router.post('/:id/reviews', authenticateToken, doctorController.addReview);
router.get('/:id/reviews', doctorController.getDoctorReviews);
router.get('/:id/available-slots', doctorController.getAvailableSlots);

export default router;