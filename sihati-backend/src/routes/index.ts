import { Router } from 'express';
import authRoutes from './authRoutes';
import aiRoutes from './aiRoutes';
import pharmacyRoutes from './pharmacyRoutes';
import doctorRoutes from './doctorRoutes';
import medicationRoutes from './medicationRoutes';

const router = Router();

router.use('/auth', authRoutes);
router.use('/ai', aiRoutes);
router.use('/pharmacies', pharmacyRoutes);
router.use('/doctors', doctorRoutes);
router.use('/medications', medicationRoutes);

export default router;