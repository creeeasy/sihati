// src/controllers/aiController.ts
import { Request, Response, NextFunction } from 'express';
import aiService from '../services/aiService';
import { Conversation } from '../models';
import ResponseHandler from '../utils/responseHandler';
import { ChatHistoryItem } from '../types';

// ─── POST /api/ai/chat ────────────────────────────────────────
export const chat = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { message, history, location } = req.body;

    if (!message || String(message).trim().length === 0) {
      ResponseHandler.badRequest(res, 'Le message ne peut pas être vide.');
      return;
    }

    let chatHistory: ChatHistoryItem[] = Array.isArray(history)
      ? history
          .filter(
            (h: any) =>
              (h.role === 'user' || h.role === 'model') &&
              Array.isArray(h.parts) &&
              h.parts[0]?.text
          )
          .slice(-20)
      : [];

    while (chatHistory.length > 0 && chatHistory[0].role !== 'user') {
      chatHistory.shift();
    }

    const userLocation =
      location?.lat && location?.lng
        ? { lat: Number(location.lat), lng: Number(location.lng) }
        : undefined;

    const result = await aiService.sendQuery(message, chatHistory, userLocation);

    // Save to DB if user authenticated
    if (req.user) {
      await Conversation.create({
        userId: req.user.id,
        userMessage: message,
        aiResponse: result.reply,
      });
    }

    ResponseHandler.success(res, result, 'Réponse générée.');
  } catch (error) {
    next(error);
  }
};

// ─── POST /api/ai/interaction ─────────────────────────────────
export const checkInteraction = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { med1, med2 } = req.body;

    if (!med1 || !med2) {
      ResponseHandler.badRequest(res, 'Veuillez fournir deux noms de médicaments.');
      return;
    }

    const result = await aiService.checkDrugInteraction(
      String(med1).trim(),
      String(med2).trim()
    );

    ResponseHandler.success(res, result, 'Interaction vérifiée.');
  } catch (error) {
    next(error);
  }
};

// ─── POST /api/ai/ask-medication ──────────────────────────────
export const askMedicationQuestion = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { medicationName, question } = req.body;

    if (!medicationName || String(medicationName).trim().length < 2) {
      ResponseHandler.badRequest(res, 'Veuillez fournir un nom de médicament.');
      return;
    }
    if (!question || String(question).trim().length < 3) {
      ResponseHandler.badRequest(res, 'Veuillez poser une question.');
      return;
    }

    const result = await aiService.askMedicationQuestion(
      String(medicationName).trim(),
      String(question).trim()
    );

    ResponseHandler.success(res, result, 'Réponse générée.');
  } catch (error) {
    next(error);
  }
};

// ─── POST /api/ai/medication-info ─────────────────────────────
export const getMedicationInfo = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { medication } = req.body;

    if (!medication || String(medication).trim().length < 2) {
      ResponseHandler.badRequest(res, 'Veuillez fournir un nom de médicament.');
      return;
    }

    const result = await aiService.getMedicationInfo(String(medication).trim());
    ResponseHandler.success(res, result, 'Informations récupérées.');
  } catch (error) {
    next(error);
  }
};

// ─── POST /api/ai/specialty ───────────────────────────────────
export const suggestSpecialty = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { symptoms } = req.body;

    if (!symptoms || String(symptoms).trim().length < 2) {
      ResponseHandler.badRequest(res, 'Veuillez décrire vos symptômes.');
      return;
    }

    const result = await aiService.suggestSpecialty(String(symptoms).trim());
    ResponseHandler.success(res, result, 'Spécialité suggérée.');
  } catch (error) {
    next(error);
  }
};

// ─── GET /api/ai/history ──────────────────────────────────────
export const getHistory = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    if (!req.user) {
      ResponseHandler.unauthorized(res, 'Authentification requise.');
      return;
    }

    const conversations = await Conversation.findAll({
      where: { userId: req.user.id },
      order: [['createdAt', 'DESC']],
      limit: 30,
      attributes: ['id', 'userMessage', 'aiResponse', 'createdAt'],
    });

    ResponseHandler.success(res, { conversations }, 'Historique récupéré.');
  } catch (error) {
    next(error);
  }
};

// ─── GET /api/ai/conversation/:id ────────────────────────────
export const getConversation = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    if (!req.user) {
      ResponseHandler.unauthorized(res, 'Authentification requise.');
      return;
    }

    const { id } = req.params;
    const conversation = await Conversation.findOne({
      where: { id, userId: req.user.id },
      attributes: ['id', 'userMessage', 'aiResponse', 'createdAt'],
    });

    if (!conversation) {
      ResponseHandler.notFound(res, 'Conversation introuvable.');
      return;
    }

    ResponseHandler.success(res, { conversation }, 'Conversation récupérée.');
  } catch (error) {
    next(error);
  }
};