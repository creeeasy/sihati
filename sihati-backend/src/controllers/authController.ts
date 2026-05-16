import _ from "multer";
import { Request, Response, NextFunction } from 'express';
import authService, { AuthenticationError, ConflictError } from '../services/authService';
import ResponseHandler from '../utils/responseHandler';

interface RequestWithUser extends Request {
  user?: {
    id: string;
    email: string;
    role: string;
  };
}

// ─── Public Routes ─────────────────────────────────────────────────

// POST /api/auth/register
export const register = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const {
      email,
      password,
      fullName,
      phoneNumber,
      role,
      chifaNumber,
      pharmacyData,
      doctorProfile,
    } = req.body;

    const result = await authService.register({
      email,
      password,
      fullName,
      phoneNumber,
      role,
      chifaNumber,
      pharmacyData,
      doctorProfile,
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

// POST /api/auth/refresh-token
export const refreshToken = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { refreshToken } = req.body;
    const result = await authService.refreshAccessToken(refreshToken);
    ResponseHandler.success(res, result, 'Token rafraîchi.');
  } catch (error) {
    if (error instanceof AuthenticationError) {
      ResponseHandler.unauthorized(res, error.message);
    } else {
      next(error);
    }
  }
};

// POST /api/auth/logout
export const logout = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { refreshToken } = req.body;
    if (refreshToken) {
      await authService.revokeRefreshToken(refreshToken);
    }
    ResponseHandler.success(res, null, 'Déconnexion réussie.');
  } catch (error) {
    next(error);
  }
};

// ─── Protected Routes (authenticated) ──────────────────────────────

// GET /api/auth/profile
export const getProfile = async (
  req: RequestWithUser,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.id;
    const user = await authService.getUserById(userId);
    ResponseHandler.success(res, user, 'Profil récupéré.');
  } catch (error) {
    next(error);
  }
};

// PUT /api/auth/profile
export const updateProfile = async (
  req: RequestWithUser,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.id;
    const { fullName, phoneNumber } = req.body;
    const updatedUser = await authService.updateProfile(userId, { fullName, phoneNumber });
    ResponseHandler.success(res, updatedUser, 'Profil mis à jour.');
  } catch (error) {
    next(error);
  }
};

// PUT /api/auth/profile/chifa
export const updateChifaNumber = async (
  req: RequestWithUser,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.id;
    const { chifaNumber } = req.body;
    const updatedUser = await authService.updateChifaNumber(userId, chifaNumber);
    ResponseHandler.success(res, updatedUser, 'Numéro Carte Chifa mis à jour.');
  } catch (error) {
    next(error);
  }
};

// POST /api/auth/change-password
export const changePassword = async (
  req: RequestWithUser,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.id;
    const { currentPassword, newPassword } = req.body;
    await authService.changePassword(userId, currentPassword, newPassword);
    ResponseHandler.success(res, null, 'Mot de passe modifié.');
  } catch (error) {
    if (error instanceof AuthenticationError) {
      ResponseHandler.unauthorized(res, error.message);
    } else {
      next(error);
    }
  }
};

// POST /api/auth/upload-photo
export const uploadProfilePhoto = async (
  req: RequestWithUser,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.id;
    const file = req.file;
    if (!file) {
      ResponseHandler.badRequest(res, 'Aucun fichier fourni');
      return;
    }
    const photoUrl = await authService.uploadProfilePhoto(userId, file);
    ResponseHandler.success(res, { photoUrl }, 'Photo téléchargée.');
  } catch (error) {
    next(error);
  }
};

// DELETE /api/auth/upload-photo
export const deleteProfilePhoto = async (
  req: RequestWithUser,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.id;
    await authService.deleteProfilePhoto(userId);
    ResponseHandler.success(res, null, 'Photo supprimée.');
  } catch (error) {
    next(error);
  }
};

// ─── Forgot Password Routes ───────────────────────────────────────

// POST /api/auth/forgot-password
export const forgotPassword = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { email } = req.body;
    await authService.sendPasswordResetEmail(email);
    ResponseHandler.success(res, null, 'Email de réinitialisation envoyé.');
  } catch (error) {
    next(error);
  }
};

// POST /api/auth/reset-password
export const resetPassword = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { token, newPassword } = req.body;
    await authService.resetPassword(token, newPassword);
    ResponseHandler.success(res, null, 'Mot de passe réinitialisé.');
  } catch (error) {
    next(error);
  }
};

// ─── Email Verification ───────────────────────────────────────────

// GET /api/auth/verify-email
export const verifyEmail = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { token } = req.query;
    await authService.verifyEmail(token as string);
    ResponseHandler.success(res, null, 'Email vérifié.');
  } catch (error) {
    next(error);
  }
};

// POST /api/auth/resend-verification
export const resendVerification = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { email } = req.body;
    await authService.resendVerificationEmail(email);
    ResponseHandler.success(res, null, 'Email de vérification renvoyé.');
  } catch (error) {
    next(error);
  }
};