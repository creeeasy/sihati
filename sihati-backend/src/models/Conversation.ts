import { Model, DataTypes, Optional, Op } from 'sequelize';
import sequelize from '../config/database';

export interface ConversationAttributes {
  id: number;
  userId: number;
  userMessage: string;
  aiResponse: string;
  context?: object;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface ConversationCreationAttributes
  extends Optional<ConversationAttributes, 'id'> {}

class Conversation
  extends Model<ConversationAttributes, ConversationCreationAttributes>
  implements ConversationAttributes
{
  public id!: number;
  public userId!: number;
  public userMessage!: string;
  public aiResponse!: string;
  public context?: object;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

  // Associations
  public static associate(): void {
    const { User } = sequelize.models;
    Conversation.belongsTo(User, { foreignKey: 'userId', as: 'user' });
  }
}

Conversation.init(
  {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    userId: {
      type: DataTypes.INTEGER,
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
    context: {
      type: DataTypes.JSONB,
      allowNull: true,
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
            [Op.gte]: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000), // last 30 days
          },
        },
      },
      byUser: (userId: number) => ({
        where: { userId },
      }),
    },
  }
);

export default Conversation;