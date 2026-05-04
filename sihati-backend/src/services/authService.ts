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
    data: RegisterDTO & { chifaNumber?: string }
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

    // Update last login
    await user.update({ lastLogin: new Date() });

    const accessToken = user.generateToken();
    const refreshToken = await this.createRefreshToken(user.id);

    return { user: user.toJSON() as any, accessToken, refreshToken };
  }

  // ─── Refresh Token ───────────────────────────────────────────────
  async createRefreshToken(userId: string): Promise<string> {
    const token = RefreshToken.generateToken();
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 30); // 30 days

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
        revokedAt: null,
      },
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

    // Revoke old refresh token
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

    await user.update({ chifaNumber: chifaNumber || null });
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

    // TODO: Implement file upload to cloud storage (AWS S3, Cloudinary, etc.)
    const photoUrl = `https://example.com/uploads/${userId}_${Date.now()}.jpg`;
    await user.update({ profileImage: photoUrl });

    return photoUrl;
  }

  async deleteProfilePhoto(userId: string): Promise<void> {
    const user = await User.findByPk(userId);
    if (!user) {
      throw new NotFoundError('Utilisateur non trouvé.');
    }

    // TODO: Delete file from cloud storage
    await user.update({ profileImage: null });
  }

  // ─── Forgot Password ────────────────────────────────────────────
  async sendPasswordResetEmail(email: string): Promise<void> {
    const user = await User.findOne({ where: { email } });
    if (!user) {
      // Don't reveal that the user doesn't exist for security
      return;
    }

    // TODO: Generate reset token and send email
    // const resetToken = crypto.randomBytes(32).toString('hex');
    // await user.update({ resetPasswordToken: resetToken, resetPasswordExpires: new Date(Date.now() + 3600000) });
    // await sendEmail(user.email, 'Reset your password', `Click here: /reset-password?token=${resetToken}`);
  }

  async resetPassword(token: string, newPassword: string): Promise<void> {
    // TODO: Implement password reset
    const user = await User.findOne({
      where: {
        resetPasswordToken: token,
        resetPasswordExpires: { [Op.gt]: new Date() },
      },
    });

    if (!user) {
      throw new AuthenticationError('Token invalide ou expiré.');
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);
    await user.update({
      password: hashedPassword,
      resetPasswordToken: null,
      resetPasswordExpires: null,
    });
  }

  // ─── Email Verification ─────────────────────────────────────────
  async verifyEmail(token: string): Promise<void> {
    // TODO: Implement email verification
    const user = await User.findOne({ where: { verificationToken: token } });
    if (!user) {
      throw new AuthenticationError('Token invalide.');
    }

    await user.update({ isVerified: true, verificationToken: null });
  }

  async resendVerificationEmail(email: string): Promise<void> {
    const user = await User.findOne({ where: { email } });
    if (!user || user.isVerified) {
      return;
    }

    // TODO: Generate new token and send email
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