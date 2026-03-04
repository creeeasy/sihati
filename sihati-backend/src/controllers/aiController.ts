import { Request, Response, NextFunction } from 'express';
import aiService from '../services/aiService';
import { Conversation } from '../models';
import ResponseHandler from '../utils/responseHandler';
import { ChatHistoryItem } from '../types';

// ─── POST /api/ai/chat ────────────────────────────────────────
// Body: { message, history?, location? }
// history: [{ role: 'user'|'model', parts: [{ text }] }]
// location: { lat, lng }
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

    // Validate history if provided
    let chatHistory: ChatHistoryItem[] = Array.isArray(history)
      ? history
          .filter(
            (h: any) =>
              (h.role === 'user' || h.role === 'model') &&
              Array.isArray(h.parts) &&
              h.parts[0]?.text
          )
          .slice(-20) // hard cap: max 20 turns from client
      : [];

    // Gemini requires history to start with a 'user' turn
    // Drop leading 'model' entries (e.g. the welcome message)
    while (chatHistory.length > 0 && chatHistory[0].role !== 'user') {
      chatHistory.shift();
    }

    // Validate location if provided
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
        context: {
          urgency: result.urgency,
          suggestedSpecialty: result.suggestedSpecialty,
          isSymptomRelated: result.isSymptomRelated,
          medicationCount: result.medicationSuggestions.length,
        },
      });
    }

    ResponseHandler.success(res, result, 'Réponse générée.');
  } catch (error) {
    next(error);
  }
};

// ─── POST /api/ai/interaction ─────────────────────────────────
// Body: { med1, med2 }
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

// ─── POST /api/ai/medication-info ─────────────────────────────
// Body: { medication }
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
// Body: { symptoms }
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
// Returns last 30 conversations for the authenticated user
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
      attributes: ['id', 'userMessage', 'aiResponse', 'context', 'createdAt'],
    });

    ResponseHandler.success(res, { conversations }, 'Historique récupéré.');
  } catch (error) {
    next(error);
  }
};

// ─── GET /api/ai/conversation/:id ────────────────────────────
// Fetch a single conversation by id to resume it
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
      where: { id: Number(id), userId: req.user.id },
      attributes: ['id', 'userMessage', 'aiResponse', 'context', 'createdAt'],
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