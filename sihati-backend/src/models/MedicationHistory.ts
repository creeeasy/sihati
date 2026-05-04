// models/MedicationHistory.ts
import { Model, DataTypes, Optional } from 'sequelize';
import sequelize from '../config/database';

export interface MedicationHistoryAttributes {
  id: string;
  patientId: string;
  prescriptionId?: string;
  medicationId?: string;
  medicationName: string;
  dosage: string;
  frequency: string;
  startDate: Date;
  endDate?: Date;
  prescribedBy?: string;
  reason?: string;
  isActive: boolean;
  adherenceRate?: number;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface MedicationHistoryCreationAttributes
  extends Optional<MedicationHistoryAttributes, 'id' | 'isActive'> {}

class MedicationHistory
  extends Model<MedicationHistoryAttributes, MedicationHistoryCreationAttributes>
  implements MedicationHistoryAttributes
{
  public id!: string;
  public patientId!: string;
  public prescriptionId?: string;
  public medicationId?: string;
  public medicationName!: string;
  public dosage!: string;
  public frequency!: string;
  public startDate!: Date;
  public endDate?: Date;
  public prescribedBy?: string;
  public reason?: string;
  public isActive!: boolean;
  public adherenceRate?: number;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

  get daysRemaining(): number | null {
    if (!this.endDate) return null;
    const remaining = this.endDate.getTime() - new Date().getTime();
    return Math.max(0, Math.ceil(remaining / (1000 * 60 * 60 * 24)));
  }

  get progressPercentage(): number | null {
    if (!this.endDate) return null;
    const total = this.endDate.getTime() - this.startDate.getTime();
    const elapsed = new Date().getTime() - this.startDate.getTime();
    const progress = (elapsed / total) * 100;
    return Math.min(100, Math.max(0, progress));
  }

  get isContinuous(): boolean {
    return !this.endDate;
  }

  public static associate(): void {
    const { User, Prescription, Medication, Doctor } = sequelize.models;
    MedicationHistory.belongsTo(User, { foreignKey: 'patientId', as: 'patient' });
    MedicationHistory.belongsTo(Prescription, { foreignKey: 'prescriptionId', as: 'prescription' });
    MedicationHistory.belongsTo(Medication, { foreignKey: 'medicationId', as: 'medication' });
    MedicationHistory.belongsTo(Doctor, { foreignKey: 'prescribedBy', as: 'prescribingDoctor' });
  }
}

MedicationHistory.init(
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
    prescriptionId: {
      type: DataTypes.UUID,
      allowNull: true,
      references: { model: 'prescriptions', key: 'id' },
    },
    medicationId: {
      type: DataTypes.UUID,
      allowNull: true,
      references: { model: 'medications', key: 'id' },
    },
    medicationName: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    dosage: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    frequency: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    startDate: {
      type: DataTypes.DATEONLY,
      allowNull: false,
    },
    endDate: {
      type: DataTypes.DATEONLY,
      allowNull: true,
    },
    prescribedBy: {
      type: DataTypes.UUID,
      allowNull: true,
      references: { model: 'doctors', key: 'id' },
    },
    reason: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    isActive: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
    },
    adherenceRate: {
      type: DataTypes.DECIMAL(5, 2),
      allowNull: true,
    },
  },
  {
    sequelize,
    tableName: 'medication_histories',
    timestamps: true,
    underscored: true,
    indexes: [
      { fields: ['patient_id'] },
      { fields: ['is_active'] },
      { fields: ['start_date'] },
    ],
  }
);

export default MedicationHistory;