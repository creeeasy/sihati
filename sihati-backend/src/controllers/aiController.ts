import { Request, Response, NextFunction } from 'express';
import aiService from '../services/aiService';
import { Conversation } from '../models';
import ResponseHandler from '../utils/responseHandler';

// POST /api/ai/chat
export const chat = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { message } = req.body;

    if (!message || message.trim().length === 0) {
      ResponseHandler.badRequest(res, 'Le message ne peut pas être vide.');
      return;
    }

    const reply = await aiService.sendQuery(message);

    // Save conversation if user is authenticated
    if (req.user) {
      await Conversation.create({
        userId: req.user.id,
        userMessage: message,
        aiResponse: reply,
      });
    }

    ResponseHandler.success(res, { reply }, 'Réponse générée.');
  } catch (error) {
    next(error);
  }
};

// POST /api/ai/medications
export const getMedicationSuggestions = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { symptoms } = req.body;

    if (!symptoms || symptoms.trim().length < 2) {
      ResponseHandler.badRequest(res, 'Veuillez décrire vos symptômes.');
      return;
    }

    const suggestions = await aiService.getMedicationSuggestions(symptoms);
    ResponseHandler.success(
      res,
      { suggestions },
      'Suggestions de médicaments générées.'
    );
  } catch (error) {
    next(error);
  }
};

// POST /api/ai/interaction
export const checkInteraction = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { med1, med2 } = req.body;

    if (!med1 || !med2) {
      ResponseHandler.badRequest(
        res,
        'Veuillez fournir deux noms de médicaments.'
      );
      return;
    }

    const reply = await aiService.checkDrugInteraction(med1, med2);
    ResponseHandler.success(res, { reply }, 'Interaction vérifiée.');
  } catch (error) {
    next(error);
  }
};

// POST /api/ai/medication-info
export const getMedicationInfo = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { medication } = req.body;

    if (!medication || medication.trim().length < 2) {
      ResponseHandler.badRequest(res, 'Veuillez fournir un nom de médicament.');
      return;
    }

    const reply = await aiService.getMedicationInfo(medication);
    ResponseHandler.success(res, { reply }, 'Informations récupérées.');
  } catch (error) {
    next(error);
  }
};

// POST /api/ai/specialty
export const suggestSpecialty = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { symptoms } = req.body;

    if (!symptoms || symptoms.trim().length < 2) {
      ResponseHandler.badRequest(res, 'Veuillez décrire vos symptômes.');
      return;
    }

    const reply = await aiService.suggestSpecialty(symptoms);
    ResponseHandler.success(res, { reply }, 'Spécialité suggérée.');
  } catch (error) {
    next(error);
  }
};