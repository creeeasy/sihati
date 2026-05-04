// models/RefreshToken.ts
import { Model, DataTypes, Optional } from 'sequelize';
import sequelize from '../config/database';
import crypto from 'crypto';

export interface RefreshTokenAttributes {
  id: string;
  userId: string;
  token: string;
  expiresAt: Date;
  revokedAt?: Date;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface RefreshTokenCreationAttributes
  extends Optional<RefreshTokenAttributes, 'id' | 'token'> {}

class RefreshToken
  extends Model<RefreshTokenAttributes, RefreshTokenCreationAttributes>
  implements RefreshTokenAttributes
{
  public id!: string;
  public userId!: string;
  public token!: string;
  public expiresAt!: Date;
  public revokedAt?: Date;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

  get isValid(): boolean {
    return !this.revokedAt && this.expiresAt > new Date();
  }

  public static generateToken(): string {
    return crypto.randomBytes(40).toString('hex');
  }

  public async revoke(): Promise<void> {
    await this.update({ revokedAt: new Date() });
  }

  public static associate(): void {
    const { User } = sequelize.models;
    RefreshToken.belongsTo(User, { foreignKey: 'userId', as: 'user' });
  }
}

RefreshToken.init(
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    userId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: 'users', key: 'id' },
      onDelete: 'CASCADE',
    },
    token: {
      type: DataTypes.STRING(100),
      allowNull: false,
      unique: true,
    },
    expiresAt: {
      type: DataTypes.DATE,
      allowNull: false,
    },
    revokedAt: {
      type: DataTypes.DATE,
      allowNull: true,
    },
  },
  {
    sequelize,
    tableName: 'refresh_tokens',
    timestamps: true,
    underscored: true,
    indexes: [
      { fields: ['user_id'] },
      { fields: ['token'] },
      { fields: ['expires_at'] },
    ],
  }
);

export default RefreshToken;