import { Request, Response, NextFunction } from 'express';
import authService from '../services/authService';
import ResponseHandler from '../utils/responseHandler';

// Verify JWT and attach user to req.user
export const authenticateToken = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      ResponseHandler.unauthorized(res, 'Token d\'authentification manquant.');
      return;
    }

    const token = authHeader.split(' ')[1];
    const user = await authService.verifyToken(token);
    req.user = user;
    next();
  } catch (error) {
    ResponseHandler.unauthorized(res, 'Token invalide ou expiré.');
  }
};

// Optional auth — attaches user if token present, but doesn't block if missing
export const optionalAuth = async (
  req: Request,
  _: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.split(' ')[1];
      const user = await authService.verifyToken(token);
      req.user = user;
    }
  } catch {
    // Token invalid — continue as guest, don't block
  }
  next();
};

// Role-based authorization middleware factory
export const authorizeRoles = (...roles: string[]) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    if (!req.user) {
      ResponseHandler.unauthorized(res, 'Authentification requise.');
      return;
    }

    if (!roles.includes(req.user.role)) {
      ResponseHandler.forbidden(
        res,
        'Vous n\'avez pas les droits nécessaires pour cette action.'
      );
      return;
    }

    next();
  };
};