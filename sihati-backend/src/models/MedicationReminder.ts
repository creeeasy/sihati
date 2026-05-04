// models/MedicationReminder.ts
import { Model, DataTypes, Optional } from 'sequelize';
import sequelize from '../config/database';

export interface MedicationReminderAttributes {
  id: string;
  patientId: string;
  medicationHistoryId: string;
  reminderTime: string;
  daysOfWeek: number[]; // Array of days (0-6)
  isActive: boolean;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface MedicationReminderCreationAttributes
  extends Optional<MedicationReminderAttributes, 'id' | 'isActive'> {}

class MedicationReminder
  extends Model<MedicationReminderAttributes, MedicationReminderCreationAttributes>
  implements MedicationReminderAttributes
{
  public id!: string;
  public patientId!: string;
  public medicationHistoryId!: string;
  public reminderTime!: string;
  public daysOfWeek!: number[];
  public isActive!: boolean;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

  public static associate(): void {
    const { User, MedicationHistory } = sequelize.models;
    MedicationReminder.belongsTo(User, { foreignKey: 'patientId', as: 'patient' });
    MedicationReminder.belongsTo(MedicationHistory, { foreignKey: 'medicationHistoryId', as: 'medicationHistory' });
  }
}

MedicationReminder.init(
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    patientId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: 'users', key: 'id' },
      onDelete: 'CASCADE',
    },
    medicationHistoryId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: 'medication_histories', key: 'id' },
      onDelete: 'CASCADE',
    },
    reminderTime: {
      type: DataTypes.TIME,
      allowNull: false,
    },
    daysOfWeek: {
      type: DataTypes.ARRAY(DataTypes.INTEGER),
      allowNull: false,
    },
    isActive: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
    },
  },
  {
    sequelize,
    tableName: 'medication_reminders',
    timestamps: true,
    underscored: true,
    indexes: [
      { fields: ['patient_id'] },
      { fields: ['is_active'] },
    ],
  }
);

export default MedicationReminder;