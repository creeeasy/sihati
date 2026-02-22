import { Request, Response, NextFunction } from 'express';
import Joi from 'joi';
import ResponseHandler from '../utils/responseHandler';

// Validate req.body against a Joi schema
export const validate = (schema: Joi.Schema) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    const { error, value } = schema.validate(req.body, {
      abortEarly: false,   // Return all errors, not just the first
      stripUnknown: true,  // Remove unknown fields from body
    });

    if (error) {
      const messages = error.details.map((d) => d.message).join(', ');
      ResponseHandler.badRequest(res, messages);
      return;
    }

    // Replace req.body with validated/sanitized value
    req.body = value;
    next();
  };
};

// Validate req.query against a Joi schema
export const validateQuery = (schema: Joi.Schema) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    const { error, value } = schema.validate(req.query, {
      abortEarly: false,
      stripUnknown: true,
    });

    if (error) {
      const messages = error.details.map((d) => d.message).join(', ');
      ResponseHandler.badRequest(res, messages);
      return;
    }

    req.query = value;
    next();
  };
};