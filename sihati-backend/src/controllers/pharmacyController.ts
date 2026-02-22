import { Request, Response, NextFunction } from 'express';
import pharmacyService from '../services/pharmacyService';
import { NotFoundError } from '../services/pharmacyService';
import ResponseHandler from '../utils/responseHandler';

// GET /api/pharmacies
export const getAllPharmacies = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { wilaya, isOnDuty } = req.query;

    const filters: any = {};
    if (wilaya) filters.wilaya = wilaya as string;
    if (isOnDuty !== undefined) filters.isOnDuty = isOnDuty === 'true';

    const pharmacies = await pharmacyService.getAllPharmacies(filters);
    ResponseHandler.success(res, { pharmacies, count: pharmacies.length });
  } catch (error) {
    next(error);
  }
};

// GET /api/pharmacies/nearby
export const getNearbyPharmacies = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { lat, lng, radius } = req.query;

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

    if (isNaN(latitude) || isNaN(longitude)) {
      ResponseHandler.badRequest(res, 'Coordonnées GPS invalides.');
      return;
    }

    const pharmacies = await pharmacyService.getNearbyPharmacies(
      latitude,
      longitude,
      radiusKm
    );
    ResponseHandler.success(res, { pharmacies, count: pharmacies.length });
  } catch (error) {
    next(error);
  }
};

// GET /api/pharmacies/duty
export const getDutyPharmacies = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { wilaya } = req.query;
    const pharmacies = await pharmacyService.getDutyPharmacies(
      wilaya as string | undefined
    );
    ResponseHandler.success(res, { pharmacies, count: pharmacies.length });
  } catch (error) {
    next(error);
  }
};

// GET /api/pharmacies/:id
export const getPharmacyById = async (
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

    const pharmacy = await pharmacyService.getPharmacyById(id);
    ResponseHandler.success(res, { pharmacy });
  } catch (error) {
    if (error instanceof NotFoundError) {
      ResponseHandler.notFound(res, error.message);
    } else {
      next(error);
    }
  }
};

// POST /api/pharmacies/search
export const searchPharmacies = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { query, lat, lng } = req.body;

    if (!query || query.trim().length < 2) {
      ResponseHandler.badRequest(
        res,
        'Le terme de recherche doit contenir au moins 2 caractères.'
      );
      return;
    }

    const location =
      lat && lng ? { lat: parseFloat(lat), lng: parseFloat(lng) } : undefined;

    const pharmacies = await pharmacyService.searchPharmacies(query, location);
    ResponseHandler.success(res, { pharmacies, count: pharmacies.length });
  } catch (error) {
    next(error);
  }
};

// POST /api/pharmacies (protected)
export const createPharmacy = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const pharmacy = await pharmacyService.createPharmacy(req.body);
    ResponseHandler.created(res, { pharmacy }, 'Pharmacie créée avec succès.');
  } catch (error) {
    next(error);
  }
};

// PUT /api/pharmacies/:id (protected)
export const updatePharmacy = async (
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

    const pharmacy = await pharmacyService.updatePharmacy(id, req.body);
    ResponseHandler.success(res, { pharmacy }, 'Pharmacie mise à jour.');
  } catch (error) {
    if (error instanceof NotFoundError) {
      ResponseHandler.notFound(res, error.message);
    } else {
      next(error);
    }
  }
};

// DELETE /api/pharmacies/:id (protected)
export const deletePharmacy = async (
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

    await pharmacyService.deletePharmacy(id);
    ResponseHandler.success(res, null, 'Pharmacie supprimée.');
  } catch (error) {
    if (error instanceof NotFoundError) {
      ResponseHandler.notFound(res, error.message);
    } else {
      next(error);
    }
  }
};