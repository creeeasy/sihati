// models/User.ts
import { Model, DataTypes, Optional } from 'sequelize';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import env from '../config/env';
import sequelize from '../config/database';

export interface UserAttributes {
  id: string;
  email: string;
  password: string;
  fullName: string;
  phoneNumber: string;
  role: 'patient' | 'pharmacy' | 'doctor' | 'admin';
  chifaNumber?: string;
  isVerified: boolean;
  wilaya?: string;
  address?: string;
  profileImage?: string;
  lastLogin?: Date;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface UserCreationAttributes
  extends Optional<UserAttributes, 'id' | 'isVerified' | 'role'> {}

class User extends Model<UserAttributes, UserCreationAttributes> implements UserAttributes {
  public id!: string;
  public email!: string;
  public password!: string;
  public fullName!: string;
  public phoneNumber!: string;
  public role!: 'patient' | 'pharmacy' | 'doctor' | 'admin';
  public chifaNumber?: string;
  public isVerified!: boolean;
  public wilaya?: string;
  public address?: string;
  public profileImage?: string;
  public lastLogin?: Date;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

  public async comparePassword(password: string): Promise<boolean> {
    return bcrypt.compare(password, this.password);
  }

  public generateToken(): string {
    return jwt.sign(
      { id: this.id, email: this.email, role: this.role },
      env.JWT_SECRET!,
      { expiresIn: env.JWT_EXPIRES_IN as jwt.SignOptions['expiresIn'] }
    );
  }

  public generateRefreshToken(): string {
    return jwt.sign(
      { id: this.id },
      env.JWT_REFRESH_SECRET!,
      { expiresIn: '30d' }
    );
  }

  public toJSON(): Omit<UserAttributes, 'password'> {
    const values = super.toJSON() as UserAttributes;
    delete (values as any).password;
    return values;
  }

  public static associate(): void {
    const { Conversation, PatientProfile, Doctor, Pharmacy, RefreshToken } = sequelize.models;
    User.hasMany(Conversation, { foreignKey: 'userId', as: 'conversations' });
    User.hasOne(PatientProfile, { foreignKey: 'userId', as: 'patientProfile' });
    User.hasOne(Doctor, { foreignKey: 'userId', as: 'doctor' });
    User.hasOne(Pharmacy, { foreignKey: 'userId', as: 'pharmacy' });
    User.hasMany(RefreshToken, { foreignKey: 'userId', as: 'refreshTokens' });
  }
}

User.init(
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
      validate: { isEmail: true },
    },
    password: {
      type: DataTypes.STRING(100),
      allowNull: false,
    },
    fullName: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    phoneNumber: {
      type: DataTypes.STRING,
      allowNull: false,
      validate: {
        is: /^(\+213|0)[5-7][0-9]{8}$/, // ✅ Accepte +213 ou 0
      },
    },
    chifaNumber: {
      type: DataTypes.STRING(15),
      allowNull: true,
      validate: {
        len: [13, 15],
        isNumeric: true,
      },
    },
    role: {
      type: DataTypes.ENUM('patient', 'pharmacy', 'doctor', 'admin'),
      allowNull: false,
      defaultValue: 'patient',
    },
    isVerified: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    },
    wilaya: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    address: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    profileImage: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    lastLogin: {
      type: DataTypes.DATE,
      allowNull: true,
    },
  },
  {
    sequelize,
    tableName: 'users',
    timestamps: true,
    underscored: true,
    hooks: {
      beforeCreate: async (user: User) => {
        user.password = await bcrypt.hash(user.password, 10);
      },
      beforeUpdate: async (user: User) => {
        if (user.changed('password')) {
          user.password = await bcrypt.hash(user.password, 10);
        }
      },
    },
  }
);

export default User;