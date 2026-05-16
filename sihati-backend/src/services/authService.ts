import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';
import { User, RefreshToken } from '../models';
import env from '../config/env';
import { RegisterDTO } from '../types';
import { Op } from 'sequelize';

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
  async register(
    data: RegisterDTO & {
      chifaNumber?: string;
      pharmacyData?: any;
      doctorProfile?: any;
    }
  ): Promise<{ user: Omit<User, 'password'>; accessToken: string; refreshToken: string }> {
    const existing = await User.findOne({ where: { email: data.email } });
    if (existing) {
      throw new ConflictError('Un compte avec cet email existe déjà.');
    }

    const user = await User.create({
      email: data.email,
      password: data.password,
      fullName: data.fullName,
      phoneNumber: data.phoneNumber,
      chifaNumber: data.chifaNumber,
      role: (data.role as any) || 'patient',
    });

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

    if (data.role === 'doctor' && data.doctorProfile) {
      const { Doctor } = await import('../models');
      await Doctor.create({
        userId: user.id,
        specialtyId: data.doctorProfile.specialtyId,
        doctorName: data.doctorProfile.doctorName,
        clinicName: data.doctorProfile.clinicName,
        clinicAddress: data.doctorProfile.clinicAddress,
        wilaya: data.doctorProfile.wilaya,
        commune: data.doctorProfile.commune,
        latitude: data.doctorProfile.latitude,
        longitude: data.doctorProfile.longitude,
        phone: data.doctorProfile.phone,
        consultationFee: data.doctorProfile.consultationFee,
        isVerified: false,
      });
    }

    const accessToken = user.generateToken();
    const refreshToken = await this.createRefreshToken(user.id);

    return { user: user.toJSON() as any, accessToken, refreshToken };
  }

  async login(
    email: string,
    password: string
  ): Promise<{ user: Omit<User, 'password'>; accessToken: string; refreshToken: string }> {
    const user = await User.findOne({
      where: { email },
      attributes: { include: ['password'] },
    });
console.log("user")
console.log(user)
    if (!user) {
      throw new AuthenticationError('Email ou mot de passe incorrect.');
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

  async refreshAccessToken(
    refreshToken: string
  ): Promise<{ accessToken: string; refreshToken: string }> {
    const tokenRecord = await RefreshToken.findOne({
      where: {
        token: refreshToken,
        expiresAt: { [Op.gt]: new Date() },
        revokedAt: { [Op.is]: null } as any,
      } as any,
    });

    if (!tokenRecord) {
      throw new AuthenticationError('Refresh token invalide ou expiré.');
    }

    const user = await User.findByPk(tokenRecord.userId);
    if (!user) {
      throw new AuthenticationError('Utilisateur introuvable.');
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

  async updateChifaNumber(
    userId: string,
    chifaNumber?: string
  ): Promise<Omit<User, 'password'>> {
    const user = await User.findByPk(userId);
    if (!user) {
      throw new NotFoundError('Utilisateur non trouvé.');
    }
    await user.update({ chifaNumber: chifaNumber || undefined });
    return user.toJSON() as any;
  }

  async changePassword(
    userId: string,
    currentPassword: string,
    newPassword: string
  ): Promise<void> {
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

  async uploadProfilePhoto(userId: string, _: any): Promise<string> {
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
    await user.update({ profileImage: undefined });
  }

  async sendPasswordResetEmail(email: string): Promise<void> {
    const user = await User.findOne({ where: { email } });
    if (!user) return;
  }

  async resetPassword(_: string, __: string): Promise<void> {
    throw new AuthenticationError('Fonctionnalité non encore implémentée.');
  }

  async verifyEmail(_: string): Promise<void> {
    throw new AuthenticationError('Fonctionnalité non encore implémentée.');
  }

  async resendVerificationEmail(email: string): Promise<void> {
    const user = await User.findOne({ where: { email } });
    if (!user || user.isVerified) return;
  }

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
    return user;
  }
}

export default new AuthService();