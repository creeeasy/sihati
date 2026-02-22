import { Request, Response, NextFunction } from 'express';
import env from '../config/env';

// Base class for all operational (expected) errors
export class AppError extends Error {
  statusCode: number;
  isOperational: boolean;

  constructor(message: string, statusCode: number) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = true;
    Error.captureStackTrace(this, this.constructor);
  }
}

// Global error handler — must have 4 params for Express to treat as error middleware
export const errorHandler = (
  err: any,
  _: Request,
  res: Response,
  __: NextFunction
): void => {
  // Default to 500
  let statusCode = err.statusCode || 500;
  let message = err.message || 'Erreur serveur interne.';

  // Handle Sequelize validation errors
  if (err.name === 'SequelizeValidationError') {
    statusCode = 400;
    message = err.errors.map((e: any) => e.message).join(', ');
  }

  // Handle Sequelize unique constraint errors
  if (err.name === 'SequelizeUniqueConstraintError') {
    statusCode = 409;
    message = 'Cette valeur existe déjà.';
  }

  // Handle Sequelize foreign key errors
  if (err.name === 'SequelizeForeignKeyConstraintError') {
    statusCode = 400;
    message = 'Référence invalide.';
  }

  // Handle JWT errors
  if (err.name === 'JsonWebTokenError') {
    statusCode = 401;
    message = 'Token invalide.';
  }

  if (err.name === 'TokenExpiredError') {
    statusCode = 401;
    message = 'Token expiré.';
  }

  // Log error (non-operational = unexpected, log full stack)
  if (!err.isOperational) {
    console.error('💥 Unexpected error:', err);
  }

  res.status(statusCode).json({
    success: false,
    message,
    ...(env.NODE_ENV === 'development' && { stack: err.stack }),
  });
};