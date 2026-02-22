import { Request, Response, NextFunction } from 'express';
import medicationService from '../services/medicationService';
import { NotFoundError } from '../services/pharmacyService';
import ResponseHandler from '../utils/responseHandler';

// POST /api/medications/search
export const searchMedications = async (
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

    const results = await medicationService.searchMedications(query, location);
    ResponseHandler.success(res, { results, count: results.length });
  } catch (error) {
    next(error);
  }
};

// GET /api/medications/:id
export const getMedicationById = async (
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

    const medication = await medicationService.getMedicationById(id);
    ResponseHandler.success(res, { medication });
  } catch (error) {
    if (error instanceof NotFoundError) {
      ResponseHandler.notFound(res, error.message);
    } else {
      next(error);
    }
  }
};

// GET /api/medications
export const getAllMedications = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { category, requiresPrescription } = req.query;

    const filters: any = {};
    if (category) filters.category = category as string;
    if (requiresPrescription !== undefined)
      filters.requiresPrescription = requiresPrescription === 'true';

    const medications = await medicationService.getAllMedications(filters);
    ResponseHandler.success(res, { medications, count: medications.length });
  } catch (error) {
    next(error);
  }
};

// GET /api/medications/popular
export const getPopularMedications = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const limit = parseInt((req.query.limit as string) || '20');
    const medications = await medicationService.getPopularMedications(limit);
    ResponseHandler.success(res, { medications, count: medications.length });
  } catch (error) {
    next(error);
  }
};

// POST /api/medications (protected)
export const createMedication = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const medication = await medicationService.createMedication(req.body);
    ResponseHandler.created(
      res,
      { medication },
      'Médicament créé avec succès.'
    );
  } catch (error) {
    next(error);
  }
};

// PUT /api/medications/:id/stock (protected)
export const updateMedicationStock = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const medicationId = parseInt(req.params.id);
    const { pharmacyId, inStock, quantity } = req.body;

    if (isNaN(medicationId) || !pharmacyId) {
      ResponseHandler.badRequest(
        res,
        'ID médicament et pharmacyId sont requis.'
      );
      return;
    }

    await medicationService.updateMedicationStock(
      medicationId,
      parseInt(pharmacyId),
      inStock,
      quantity
    );

    ResponseHandler.success(res, null, 'Stock mis à jour.');
  } catch (error) {
    if (error instanceof NotFoundError) {
      ResponseHandler.notFound(res, error.message);
    } else {
      next(error);
    }
  }
};