import { Router } from 'express';
import authRoutes from './authRoutes';
import aiRoutes from './aiRoutes';
import pharmacyRoutes from './pharmacyRoutes';
import doctorRoutes from './doctorRoutes';
import medicationRoutes from './medicationRoutes';
import appointmentRoutes from './appointmentRoutes';
import patientRoutes from './patientRoutes';
import favoriteRoutes from './favoriteRoutes';
import consultationRoutes from './consultationRoutes';  // ✅ AJOUTER
import prescriptionRoutes from './prescriptionRoutes';
import allergyRoutes from './allergyRoutes';
import userRoutes from './userRoutes';
import waitingQueueRoutes from './waitingQueueRoutes';

const router = Router();

router.use('/auth', authRoutes);
router.use('/ai', aiRoutes);
router.use('/pharmacies', pharmacyRoutes);
router.use('/doctors', doctorRoutes);
router.use('/medications', medicationRoutes);
router.use('/appointments', appointmentRoutes);
router.use('/patient', patientRoutes);
router.use('/favorites', favoriteRoutes); 
router.use('/consultations', consultationRoutes);  // ✅ AJOUTER
router.use('/prescriptions', prescriptionRoutes);  // ✅ AJOUTER
router.use('/allergies', allergyRoutes);          // ✅ AJOUTER
router.use('/users', userRoutes);
router.use('/waiting-queue', waitingQueueRoutes);
export default router;