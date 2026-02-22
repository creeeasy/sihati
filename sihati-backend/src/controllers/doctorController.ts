import { Request, Response, NextFunction } from 'express';
import doctorService from '../services/doctorService';
import { NotFoundError } from '../services/pharmacyService';
import ResponseHandler from '../utils/responseHandler';

// GET /api/doctors
export const getAllDoctors = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { specialtyId, wilaya } = req.query;

    const filters: any = {};
    if (specialtyId) filters.specialtyId = parseInt(specialtyId as string);
    if (wilaya) filters.wilaya = wilaya as string;

    const doctors = await doctorService.getAllDoctors(filters);
    ResponseHandler.success(res, { doctors, count: doctors.length });
  } catch (error) {
    next(error);
  }
};

// GET /api/doctors/nearby
export const getNearbyDoctors = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { lat, lng, radius, specialtyId } = req.query;

    if (!lat || !lng) {
      ResponseHandler.badRequest(
        res,
        'Les coordonnées GPS (lat, lng) sont requises.'
      );
      return;
    }

    const latitude = parseFloat(lat as string);
    const longitude = parseFloat(lng as string);
    const radiusKm = parseFloat((radius as string) || '10');
    const specId = specialtyId ? parseInt(specialtyId as string) : undefined;

    if (isNaN(latitude) || isNaN(longitude)) {
      ResponseHandler.badRequest(res, 'Coordonnées GPS invalides.');
      return;
    }

    const doctors = await doctorService.getNearbyDoctors(
      latitude,
      longitude,
      radiusKm,
      specId
    );
    ResponseHandler.success(res, { doctors, count: doctors.length });
  } catch (error) {
    next(error);
  }
};

// GET /api/doctors/top-rated
export const getTopRatedDoctors = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const limit = parseInt((req.query.limit as string) || '10');
    const doctors = await doctorService.getTopRatedDoctors(limit);
    ResponseHandler.success(res, { doctors, count: doctors.length });
  } catch (error) {
    next(error);
  }
};

// GET /api/doctors/:id
export const getDoctorById = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const id = parseInt(req.params.id);
    if (isNaN(id)) {
      ResponseHandler.badRequest(res, 'ID invalide.');
      return;
    }

    const doctor = await doctorService.getDoctorById(id);
    ResponseHandler.success(res, { doctor });
  } catch (error) {
    if (error instanceof NotFoundError) {
      ResponseHandler.notFound(res, error.message);
    } else {
      next(error);
    }
  }
};

// POST /api/doctors/search
export const searchDoctors = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { query, specialtyId, wilaya } = req.body;

    if (!query || query.trim().length < 2) {
      ResponseHandler.badRequest(
        res,
        'Le terme de recherche doit contenir au moins 2 caractères.'
      );
      return;
    }

    const filters: any = {};
    if (specialtyId) filters.specialtyId = parseInt(specialtyId);
    if (wilaya) filters.wilaya = wilaya;

    const doctors = await doctorService.searchDoctors(query, filters);
    ResponseHandler.success(res, { doctors, count: doctors.length });
  } catch (error) {
    next(error);
  }
};

// POST /api/doctors (protected)
export const createDoctor = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const doctor = await doctorService.createDoctor(req.body);
    ResponseHandler.created(res, { doctor }, 'Médecin créé avec succès.');
  } catch (error) {
    if (error instanceof NotFoundError) {
      ResponseHandler.notFound(res, error.message);
    } else {
      next(error);
    }
  }
};

// PUT /api/doctors/:id (protected)
export const updateDoctor = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const id = parseInt(req.params.id);
    if (isNaN(id)) {
      ResponseHandler.badRequest(res, 'ID invalide.');
      return;
    }

    const doctor = await doctorService.updateDoctor(id, req.body);
    ResponseHandler.success(res, { doctor }, 'Médecin mis à jour.');
  } catch (error) {
    if (error instanceof NotFoundError) {
      ResponseHandler.notFound(res, error.message);
    } else {
      next(error);
    }
  }
};