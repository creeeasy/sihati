// models/Notification.ts
import { Model, DataTypes, Optional } from 'sequelize';
import sequelize from '../config/database';

export interface NotificationAttributes {
  id: string;
  userId: string;
  title: string;
  body: string;
  type: 'appointment' | 'medication' | 'system' | 'reminder' | 'message';
  data?: object;
  isRead: boolean;
  readAt?: Date;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface NotificationCreationAttributes
  extends Optional<NotificationAttributes, 'id' | 'isRead'> {}

class Notification
  extends Model<NotificationAttributes, NotificationCreationAttributes>
  implements NotificationAttributes
{
  public id!: string;
  public userId!: string;
  public title!: string;
  public body!: string;
  public type!: 'appointment' | 'medication' | 'system' | 'reminder' | 'message';
  public data?: object;
  public isRead!: boolean;
  public readAt?: Date;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

  public markAsRead(): void {
    this.isRead = true;
    this.readAt = new Date();
  }

  public static associate(): void {
    const { User } = sequelize.models;
    Notification.belongsTo(User, { foreignKey: 'userId', as: 'user' });
  }
}

Notification.init(
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
    title: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    body: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    type: {
      type: DataTypes.ENUM('appointment', 'medication', 'system', 'reminder', 'message'),
      allowNull: false,
    },
    data: {
      type: DataTypes.JSONB,
      allowNull: true,
    },
    isRead: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    },
    readAt: {
      type: DataTypes.DATE,
      allowNull: true,
    },
  },
  {
    sequelize,
    tableName: 'notifications',
    timestamps: true,
    underscored: true,
    indexes: [
      { fields: ['user_id'] },
      { fields: ['is_read'] },
      { fields: ['created_at'] },
    ],
  }
);

export default Notification;