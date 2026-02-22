import jwt from 'jsonwebtoken';
import { User } from '../models';
import env from '../config/env';
import { RegisterDTO } from '../types';

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

class AuthService {
  // Register a new user
  async register(
    data: RegisterDTO
  ): Promise<{ user: Omit<User, 'password'>; token: string }> {
    // Check if email already exists
    const existing = await User.findOne({ where: { email: data.email } });
    if (existing) {
      throw new ConflictError('Un compte avec cet email existe déjà.');
    }

    // Create user (password hashed via beforeCreate hook)
    const user = await User.create({
      email: data.email,
      password: data.password,
      fullName: data.fullName,
      phoneNumber: data.phoneNumber,
      role: (data.role as any) || 'patient',
    });

    const token = user.generateToken();

    return { user: user.toJSON() as any, token };
  }

  // Login an existing user
  async login(
    email: string,
    password: string
  ): Promise<{ user: Omit<User, 'password'>; token: string }> {
    // Find user including password (normally excluded by toJSON)
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

    const token = user.generateToken();

    return { user: user.toJSON() as any, token };
  }

  // Verify a JWT token and return the user
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

  // Generate a fresh token for an existing user
  async refreshToken(userId: number): Promise<string> {
    const user = await User.findByPk(userId);

    if (!user) {
      throw new AuthenticationError('Utilisateur introuvable.');
    }

    return user.generateToken();
  }
}

export default new AuthService();