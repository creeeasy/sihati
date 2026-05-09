// src/routes/appointmentRoutes.ts
import { Router } from 'express';
import * as appointmentController from '../controllers/appointmentController';
import { authenticateToken } from '../middlewares/authMiddleware';

const router = Router();

// Routes protégées (authentification requise)
router.get('/doctor/:doctorId', authenticateToken, appointmentController.getDoctorAppointments);
router.get('/patient/:patientId', authenticateToken, appointmentController.getPatientAppointments);
router.get('/:id', authenticateToken, appointmentController.getAppointmentById);
router.post('/', authenticateToken, appointmentController.createAppointment);
router.put('/:id/confirm', authenticateToken, appointmentController.confirmAppointment);
router.put('/:id/cancel', authenticateToken, appointmentController.cancelAppointment);
router.put('/:id/complete', authenticateToken, appointmentController.completeAppointment);

export default router;