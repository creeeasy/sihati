// models/Conversation.ts
import { Model, DataTypes, Optional, Op } from 'sequelize';
import sequelize from '../config/database';

export interface ConversationAttributes {
  id: string;  // ✅ UUID
  userId: string;  // ✅ UUID
  userMessage: string;
  aiResponse: string;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface ConversationCreationAttributes
  extends Optional<ConversationAttributes, 'id'> {}

class Conversation
  extends Model<ConversationAttributes, ConversationCreationAttributes>
  implements ConversationAttributes
{
  public id!: string;
  public userId!: string;
  public userMessage!: string;
  public aiResponse!: string;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

  public static associate(): void {
    const { User } = sequelize.models;
    Conversation.belongsTo(User, { foreignKey: 'userId', as: 'user' });
  }
}

Conversation.init(
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
    userMessage: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    aiResponse: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
  },
  {
    sequelize,
    tableName: 'conversations',
    timestamps: true,
    underscored: true,
    indexes: [
      { fields: ['user_id'] },
      { fields: ['created_at'] },
    ],
    scopes: {
      recent: {
        where: {
          createdAt: {
            [Op.gte]: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000),
          },
        },
      },
      byUser: (userId: string) => ({
        where: { userId },
      }),
    },
  }
);

export default Conversation;