import { Request, Response, NextFunction } from 'express';
import doctorService from '../services/doctorService';
import { DoctorSchedule, Doctor } from '../models';

const getId = (param: string | string[] | undefined): string => {
  if (typeof param === 'string') return param;
  if (Array.isArray(param)) return param[0];
  return '';
};

// 📌 GET /api/doctors
export const getAllDoctors = async (_: Request, res: Response, next: NextFunction) => {
  try {
    const doctors = await doctorService.getAllDoctors();
    return res.json({ success: true, data: doctors });
  } catch (error) {
    return next(error);
  }
};

// 📌 GET /api/doctors/search
export const searchDoctors = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const doctors = await doctorService.searchDoctors({
      q: req.query.q as string,
      specialtyId: req.query.specialtyId as string,
      wilaya: req.query.wilaya as string,
      minRating: req.query.minRating ? Number(req.query.minRating) : undefined,
      maxPrice: req.query.maxPrice ? Number(req.query.maxPrice) : undefined,
      lat: req.query.lat ? Number(req.query.lat) : undefined,
      lng: req.query.lng ? Number(req.query.lng) : undefined,
      radius: req.query.radius ? Number(req.query.radius) : undefined
    });
    return res.json({ success: true, data: doctors, count: doctors.length });
  } catch (error) {
    return next(error);
  }
};

// 📌 GET /api/doctors/top-rated
export const getTopRatedDoctors = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const limit = req.query.limit ? Number(req.query.limit) : 10;
    const doctors = await doctorService.getTopRatedDoctors(limit);
    return res.json({ success: true, data: doctors });
  } catch (error) {
    return next(error);
  }
};

// 📌 GET /api/doctors/specialties
export const getAllSpecialties = async (_: Request, res: Response, next: NextFunction) => {
  try {
    const specialties = await doctorService.getAllSpecialties();
    return res.json({ success: true, data: specialties });
  } catch (error) {
    return next(error);
  }
};

// 📌 GET /api/doctors/:id
export const getDoctorById = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const id = getId(req.params.id);
    if (!id) {
      return res.status(400).json({ success: false, message: 'ID invalide' });
    }
    const doctor = await doctorService.getDoctorById(id);
    return res.json({ success: true, data: doctor });
  } catch (error) {
    return next(error);
  }
};

// 📌 POST /api/doctors
export const createDoctor = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const doctor = await doctorService.createDoctor(req.body);
    return res.status(201).json({ success: true, data: doctor });
  } catch (error) {
    return next(error);
  }
};

// 📌 PUT /api/doctors/:id
export const updateDoctor = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const id = getId(req.params.id);
    if (!id) {
      return res.status(400).json({ success: false, message: 'ID invalide' });
    }
    const doctor = await doctorService.updateDoctor(id, req.body);
    return res.json({ success: true, data: doctor });
  } catch (error) {
    return next(error);
  }
};

// 📌 DELETE /api/doctors/:id
export const deleteDoctor = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const id = getId(req.params.id);
    if (!id) {
      return res.status(400).json({ success: false, message: 'ID invalide' });
    }
    await doctorService.deleteDoctor(id);
    return res.json({ success: true, message: 'Médecin supprimé' });
  } catch (error) {
    return next(error);
  }
};

// 📌 GET /api/doctors/:id/reviews
export const getDoctorReviews = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const id = getId(req.params.id);
    if (!id) {
      return res.status(400).json({ success: false, message: 'ID invalide' });
    }
    const reviews = await doctorService.getDoctorReviews(id);
    return res.json({ success: true, data: reviews });
  } catch (error) {
    return next(error);
  }
};

// 📌 POST /api/doctors/:id/reviews
export const addReview = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const id = getId(req.params.id);
    const userId = (req as any).user.id;
    const { rating, comment } = req.body;

    if (!id) {
      return res.status(400).json({ success: false, message: 'ID invalide' });
    }
    if (!rating || rating < 1 || rating > 5) {
      return res.status(400).json({ success: false, message: 'La note doit être comprise entre 1 et 5' });
    }

    const review = await doctorService.addReview(id, userId, rating, comment);
    return res.status(201).json({ success: true, data: review });
  } catch (error) {
    return next(error);
  }
};

// 📌 GET /api/doctors/:id/available-slots
export const getAvailableSlots = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const id = getId(req.params.id);
    const { date, officeId } = req.query;
    console.log(req.query);

    if (!id) {
      return res.status(400).json({ success: false, message: 'ID invalide' });
    }
    if (!date) {
      return res.status(400).json({ success: false, message: 'La date est requise' });
    }

    const slots = await doctorService.getAvailableSlots(id, new Date(date as string), officeId as string);
    return res.json({ success: true, data: slots });
  } catch (error) {
    return next(error);
  }
};
// src/controllers/doctorController.ts (ajouter ces méthodes)

// ============================================
// GESTION DES DISPONIBILITÉS
// ============================================

// GET /api/doctors/:id/schedule
export const getSchedule = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const doctorId = getId(req.params.id);
    const schedules = await DoctorSchedule.findAll({
      where: { doctorId },
      order: [['dayOfWeek', 'ASC'], ['startTime', 'ASC']]
    });
    return res.json({ success: true, data: schedules });
  } catch (error) {
    return next(error);
  }
};

// POST /api/doctors/:id/schedule
export const updateSchedule = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const doctorId = getId(req.params.id);
    const { schedules } = req.body; // Tableau des disponibilités
    
    // Supprimer les anciennes disponibilités
    await DoctorSchedule.destroy({ where: { doctorId } });
    
    // Ajouter les nouvelles
    const newSchedules = await DoctorSchedule.bulkCreate(
      schedules.map((s: any) => ({ ...s, doctorId }))
    );
    
    return res.json({ success: true, data: newSchedules });
  } catch (error) {
    return next(error);
  }
};

// PUT /api/doctors/:id/profile
export const updateDoctorProfile = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const doctorId = getId(req.params.id);
    const allowedFields = [
      'doctorName', 'clinicName', 'clinicAddress', 'phone', 
      'whatsappNumber', 'consultationFee', 'bio', 'yearsOfExperience'
    ];
    
    const updateData: any = {};
    for (const field of allowedFields) {
      if (req.body[field] !== undefined) {
        updateData[field] = req.body[field];
      }
    }
    
    const doctor = await Doctor.findByPk(doctorId);
    if (!doctor) {
      return res.status(404).json({ success: false, message: 'Médecin non trouvé' });
    }
    
    await doctor.update(updateData);
    return res.json({ success: true, data: doctor });
  } catch (error) {
    return next(error);
  }
  
};
// GET /api/doctors/by-user/:userId
export const getDoctorByUserId = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const userId = getId(req.params.userId);
        const doctor = await doctorService.getDoctorByUserId(userId);
        return res.json({ success: true, data: doctor });
    } catch (error) {
        return next(error);
    }
};