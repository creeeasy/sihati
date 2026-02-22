import { Response } from 'express';

class ResponseHandler {
  // 200 OK
  success(res: Response, data: any, message: string = 'Succès') {
    return res.status(200).json({
      success: true,
      message,
      data,
    });
  }

  // 201 Created
  created(res: Response, data: any, message: string = 'Créé avec succès') {
    return res.status(201).json({
      success: true,
      message,
      data,
    });
  }

  // 400 Bad Request
  badRequest(res: Response, message: string = 'Requête invalide') {
    return res.status(400).json({
      success: false,
      message,
    });
  }

  // 401 Unauthorized
  unauthorized(res: Response, message: string = 'Non autorisé') {
    return res.status(401).json({
      success: false,
      message,
    });
  }

  // 403 Forbidden
  forbidden(res: Response, message: string = 'Accès refusé') {
    return res.status(403).json({
      success: false,
      message,
    });
  }

  // 404 Not Found
  notFound(res: Response, message: string = 'Ressource introuvable') {
    return res.status(404).json({
      success: false,
      message,
    });
  }

  // 409 Conflict
  conflict(res: Response, message: string = 'Conflit de données') {
    return res.status(409).json({
      success: false,
      message,
    });
  }

  // 500 Internal Server Error
  serverError(res: Response, message: string = 'Erreur serveur interne') {
    return res.status(500).json({
      success: false,
      message,
    });
  }
}

export default new ResponseHandler();