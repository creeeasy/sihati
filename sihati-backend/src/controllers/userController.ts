// src/controllers/userController.ts
import { Request, Response, NextFunction } from 'express';
import { User } from '../models';
import { Op } from 'sequelize';

const getId = (param: string | string[] | undefined): string => {
  if (typeof param === 'string') return param;
  if (Array.isArray(param)) return param[0];
  return '';
};

// GET /api/users/:id
export const getUserById = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = getId(req.params.id);
    if (!userId) {
      return res.status(400).json({ success: false, message: 'ID utilisateur invalide' });
    }
    
    const user = await User.findByPk(userId, {
      attributes: { exclude: ['password'] }
    });
    
    if (!user) {
      return res.status(404).json({ success: false, message: 'Utilisateur non trouvé' });
    }
    
    return res.json({ success: true, data: user });
  } catch (error) {
    return next(error);
  }
};

// GET /api/users/search?q=...&role=patient
export const searchUsers = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { chifaNumber, role } = req.query;
    const whereClause: any = {};
    
    if (role) whereClause.role = role;
    
    if (chifaNumber) {
      whereClause[Op.or] = [
        { chifaNumber: { [Op.iLike]: `%${chifaNumber}%` } }
      ];
    }
    
    const users = await User.findAll({
      where: whereClause,
      attributes: { exclude: ['password'] },
      limit: 50
    });
    
    return res.json({ success: true, data: users });
  } catch (error) {
    return next(error);
  }
};