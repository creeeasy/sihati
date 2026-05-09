// src/routes/doctorRoutes.ts
import { Router } from 'express';
import * as doctorController from '../controllers/doctorController';
import { authenticateToken } from '../middlewares/authMiddleware';

const router = Router();

// Routes publiques
router.get('/', doctorController.getAllDoctors);
router.get('/search', doctorController.searchDoctors);
router.get('/top-rated', doctorController.getTopRatedDoctors);
router.get('/specialties', doctorController.getAllSpecialties);
router.get('/by-user/:userId', doctorController.getDoctorByUserId);  
router.get('/:id', doctorController.getDoctorById);
router.get('/:id/available-slots', doctorController.getAvailableSlots);
router.get('/:id/reviews', doctorController.getDoctorReviews);

// Routes protégées (médecin)
router.post('/:id/schedule', authenticateToken, doctorController.updateSchedule);
router.get('/:id/schedule', authenticateToken, doctorController.getSchedule);
router.put('/:id/profile', authenticateToken, doctorController.updateDoctorProfile);

// Routes admin
router.post('/', authenticateToken, doctorController.createDoctor);
router.put('/:id', authenticateToken, doctorController.updateDoctor);
router.delete('/:id', authenticateToken, doctorController.deleteDoctor);
router.post('/:id/reviews', authenticateToken, doctorController.addReview);

export default router;