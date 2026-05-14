// src/services/authService.ts
import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';
import { User, RefreshToken } from '../models';
import env from '../config/env';
import { RegisterDTO } from '../types';
import { Op } from 'sequelize';

// Custom errors
export class AuthenticationError extends Error {
  statusCode = 401;
  constructor(message: string) {
    super(message);
    this.name = 'AuthenticationError';
  }
}

export class ConflictError extends Error {
  statusCode = 409;
  constructor(message: string) {
    super(message);
    this.name = 'ConflictError';
  }
}

export class NotFoundError extends Error {
  statusCode = 404;
  constructor(message: string) {
    super(message);
    this.name = 'NotFoundError';
  }
}

class AuthService {
  // ─── Register ────────────────────────────────────────────────────
  async register(
  data: RegisterDTO & { chifaNumber?: string; pharmacyData?: any }
): Promise<{ user: Omit<User, 'password'>; accessToken: string; refreshToken: string }> {
  const existing = await User.findOne({ where: { email: data.email } });
  if (existing) {
    throw new ConflictError('Un compte avec cet email existe déjà.');
  }
console.log("data:")
console.log(data)
  const user = await User.create({
    email: data.email,
    password: data.password,
    fullName: data.fullName,
    phoneNumber: data.phoneNumber,
    chifaNumber: data.chifaNumber,
    role: (data.role as any) || 'patient',
  });

  // ✅ SI LE RÔLE EST PHARMACY, CRÉER LA PHARMACIE
  if (data.role === 'pharmacy' && data.pharmacyData) {
    const { Pharmacy } = await import('../models');
    await Pharmacy.create({
      userId: user.id,
      pharmacyName: data.pharmacyData.pharmacyName,
      address: data.pharmacyData.address,
      wilaya: data.pharmacyData.wilaya,
      commune: data.pharmacyData.commune,
      latitude: data.pharmacyData.latitude,
      longitude: data.pharmacyData.longitude,
      phone: data.pharmacyData.phone,
      whatsappNumber: data.pharmacyData.whatsappNumber,
      email: data.email,
      isOnDutyTonight: false,
      isVerified: false,
    });
  }

  const accessToken = user.generateToken();
  const refreshToken = await this.createRefreshToken(user.id);

  return { user: user.toJSON() as any, accessToken, refreshToken };
}

  // ─── Login ───────────────────────────────────────────────────────
  async login(
    email: string,
    password: string
  ): Promise<{ user: Omit<User, 'password'>; accessToken: string; refreshToken: string }> {
    const user = await User.findOne({
      where: { email },
      attributes: { include: ['password'] },
    });
     
    if (!user) {
      throw new AuthenticationError('Email ou mot de passe incorrect.');
    }
    if (!user.isActive) {
      throw new AuthenticationError('Ce compte a été désactivé.');
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      throw new AuthenticationError('Email ou mot de passe incorrect.');
    }

    await user.update({ lastLogin: new Date() });

    const accessToken = user.generateToken();
    const refreshToken = await this.createRefreshToken(user.id);

    return { user: user.toJSON() as any, accessToken, refreshToken };
  }

  // ─── Refresh Token ───────────────────────────────────────────────
  async createRefreshToken(userId: string): Promise<string> {
    const token = RefreshToken.generateToken();
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 30);

    await RefreshToken.create({
      userId,
      token,
      expiresAt,
    });

    return token;
  }

  async refreshAccessToken(refreshToken: string): Promise<{ accessToken: string; refreshToken: string }> {
    const tokenRecord = await RefreshToken.findOne({
      where: {
        token: refreshToken,
        expiresAt: { [Op.gt]: new Date() },
        revokedAt: { [Op.is]: null } as any, // ✅ Correction
      } as any, // ✅ Type assertion temporaire
    });

    if (!tokenRecord) {
      throw new AuthenticationError('Refresh token invalide ou expiré.');
    }

    const user = await User.findByPk(tokenRecord.userId);
    if (!user || !user.isActive) {
      throw new AuthenticationError('Utilisateur introuvable ou désactivé.');
    }

    const newAccessToken = user.generateToken();
    const newRefreshToken = await this.createRefreshToken(user.id);
    await tokenRecord.revoke();

    return { accessToken: newAccessToken, refreshToken: newRefreshToken };
  }

  async revokeRefreshToken(refreshToken: string): Promise<void> {
    const tokenRecord = await RefreshToken.findOne({ where: { token: refreshToken } });
    if (tokenRecord) {
      await tokenRecord.revoke();
    }
  }

  // ─── User Management ────────────────────────────────────────────
  async getUserById(userId: string): Promise<Omit<User, 'password'>> {
    const user = await User.findByPk(userId);
    if (!user) {
      throw new NotFoundError('Utilisateur non trouvé.');
    }
    return user.toJSON() as any;
  }

  async updateProfile(
    userId: string,
    data: { fullName?: string; phoneNumber?: string }
  ): Promise<Omit<User, 'password'>> {
    const user = await User.findByPk(userId);
    if (!user) {
      throw new NotFoundError('Utilisateur non trouvé.');
    }

    await user.update(data);
    return user.toJSON() as any;
  }

  async updateChifaNumber(userId: string, chifaNumber?: string): Promise<Omit<User, 'password'>> {
    const user = await User.findByPk(userId);
    if (!user) {
      throw new NotFoundError('Utilisateur non trouvé.');
    }

    // ✅ Correction : envoyer undefined ou la valeur, jamais null
    await user.update({ chifaNumber: chifaNumber || undefined });
    return user.toJSON() as any;
  }

  async changePassword(userId: string, currentPassword: string, newPassword: string): Promise<void> {
    const user = await User.findByPk(userId, {
      attributes: { include: ['password'] },
    });

    if (!user) {
      throw new NotFoundError('Utilisateur non trouvé.');
    }

    const isMatch = await user.comparePassword(currentPassword);
    if (!isMatch) {
      throw new AuthenticationError('Mot de passe actuel incorrect.');
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);
    await user.update({ password: hashedPassword });
  }

  // ─── Profile Photo ──────────────────────────────────────────────
  async uploadProfilePhoto(userId: string, file: any): Promise<string> {
    const user = await User.findByPk(userId);
    if (!user) {
      throw new NotFoundError('Utilisateur non trouvé.');
    }

    const photoUrl = `https://example.com/uploads/${userId}_${Date.now()}.jpg`;
    await user.update({ profileImage: photoUrl });
    return photoUrl;
  }

  async deleteProfilePhoto(userId: string): Promise<void> {
    const user = await User.findByPk(userId);
    if (!user) {
      throw new NotFoundError('Utilisateur non trouvé.');
    }

    // ✅ Correction : envoyer undefined (pas null)
    await user.update({ profileImage: undefined });
  }

  // ─── Forgot Password (à compléter plus tard) ────────────────────
  async sendPasswordResetEmail(email: string): Promise<void> {
    const user = await User.findOne({ where: { email } });
    if (!user) return;
    // TODO: Implémenter l'envoi d'email
  }

  async resetPassword(token: string, newPassword: string): Promise<void> {
    // TODO: Implémenter avec une table ResetToken
    throw new AuthenticationError('Fonctionnalité non encore implémentée.');
  }

  // ─── Email Verification (à compléter plus tard) ─────────────────
  async verifyEmail(token: string): Promise<void> {
    // TODO: Implémenter avec une table EmailVerificationToken
    throw new AuthenticationError('Fonctionnalité non encore implémentée.');
  }

  async resendVerificationEmail(email: string): Promise<void> {
    const user = await User.findOne({ where: { email } });
    if (!user || user.isVerified) return;
    // TODO: Implémenter l'envoi d'email
  }

  // ─── Token Verification ─────────────────────────────────────────
  async verifyToken(token: string): Promise<User> {
    let decoded: any;

    try {
      decoded = jwt.verify(token, env.JWT_SECRET);
    } catch {
      throw new AuthenticationError('Token invalide ou expiré.');
    }

    const user = await User.findByPk(decoded.id);
    if (!user) {
      throw new AuthenticationError('Utilisateur introuvable.');
    }
    if (!user.isActive) {
      throw new AuthenticationError('Ce compte a été désactivé.');
    }
    return user;
  }
}

export default new AuthService();