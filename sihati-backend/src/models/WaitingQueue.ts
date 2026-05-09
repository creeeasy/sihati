// src/models/WaitingQueue.ts
import { Model, DataTypes, Optional } from 'sequelize';
import sequelize from '../config/database';

export interface WaitingQueueAttributes {
  id: string;
  doctorId: string;
  patientId: string;
  appointmentId?: string;
  status: 'waiting' | 'in_consultation' | 'completed' | 'skipped' | 'cancelled';
  priority: number; // 0=urgent, 1=with_appointment, 2=without_appointment
  position: number;
  arrivedAt: Date;
  startedAt?: Date;
  completedAt?: Date;
  estimatedWaitMinutes?: number;
  notes?: string;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface WaitingQueueCreationAttributes
  extends Optional<WaitingQueueAttributes, 'id' | 'status' | 'priority' | 'position'> {}

class WaitingQueue
  extends Model<WaitingQueueAttributes, WaitingQueueCreationAttributes>
  implements WaitingQueueAttributes
{
  public id!: string;
  public doctorId!: string;
  public patientId!: string;
  public appointmentId?: string;
  public status!: 'waiting' | 'in_consultation' | 'completed' | 'skipped' | 'cancelled';
  public priority!: number;
  public position!: number;
  public arrivedAt!: Date;
  public startedAt?: Date;
  public completedAt?: Date;
  public estimatedWaitMinutes?: number;
  public notes?: string;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

  public static associate(): void {
    const { Doctor, User, Appointment } = sequelize.models;
    // ✅ FIX: Reference Doctor model, not User
    WaitingQueue.belongsTo(Doctor, { foreignKey: 'doctorId', as: 'doctor' });
    WaitingQueue.belongsTo(User, { foreignKey: 'patientId', as: 'patient' });
    WaitingQueue.belongsTo(Appointment, { foreignKey: 'appointmentId', as: 'appointment' });
  }
}

WaitingQueue.init(
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    doctorId: {
      type: DataTypes.UUID,
      allowNull: false,
      // ✅ FIX: Reference doctors table, not users
      references: { model: 'doctors', key: 'id' },
      onDelete: 'CASCADE',
    },
    patientId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: 'users', key: 'id' },
      onDelete: 'CASCADE',
    },
    appointmentId: {
      type: DataTypes.UUID,
      allowNull: true,
      references: { model: 'appointments', key: 'id' },
    },
    status: {
      type: DataTypes.ENUM('waiting', 'in_consultation', 'completed', 'skipped', 'cancelled'),
      allowNull: false,
      defaultValue: 'waiting',
    },
    priority: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 1,
      validate: { min: 0, max: 2 },
    },
    position: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    arrivedAt: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: DataTypes.NOW,
    },
    startedAt: { type: DataTypes.DATE, allowNull: true },
    completedAt: { type: DataTypes.DATE, allowNull: true },
    estimatedWaitMinutes: { type: DataTypes.INTEGER, allowNull: true },
    notes: { type: DataTypes.TEXT, allowNull: true },
  },
  {
    sequelize,
    tableName: 'waiting_queues',
    timestamps: true,
    underscored: true,
    indexes: [
      { fields: ['doctor_id'] },
      { fields: ['status'] },
      { fields: ['position'] },
    ],
  }
);

export default WaitingQueue;