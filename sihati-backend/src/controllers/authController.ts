import { Request, Response, NextFunction } from 'express';
import authService, { AuthenticationError, ConflictError } from '../services/authService';
import ResponseHandler from '../utils/responseHandler';

// POST /api/auth/register
export const register = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { email, password, fullName, phoneNumber, role } = req.body;
    const result = await authService.register({
      email,
      password,
      fullName,
      phoneNumber,
      role,
    });
    ResponseHandler.created(res, result, 'Compte créé avec succès.');
  } catch (error) {
    if (error instanceof ConflictError) {
      ResponseHandler.conflict(res, error.message);
    } else {
      next(error);
    }
  }
};

// POST /api/auth/login
export const login = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { email, password } = req.body;
    const result = await authService.login(email, password);
    ResponseHandler.success(res, result, 'Connexion réussie.');
  } catch (error) {
    if (error instanceof AuthenticationError) {
      ResponseHandler.unauthorized(res, error.message);
    } else {
      next(error);
    }
  }
};

// GET /api/auth/me (protected)
export const getCurrentUser = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    ResponseHandler.success(res, req.user, 'Utilisateur récupéré.');
  } catch (error) {
    next(error);
  }
};

// POST /api/auth/refresh
export const refreshToken = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.id;
    const token = await authService.refreshToken(userId);
    ResponseHandler.success(res, { token }, 'Token rafraîchi.');
  } catch (error) {
    if (error instanceof AuthenticationError) {
      ResponseHandler.unauthorized(res, error.message);
    } else {
      next(error);
    }
  }
};