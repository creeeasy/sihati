// models/PrescriptionMedication.ts
import { Model, DataTypes, Optional } from 'sequelize';
import sequelize from '../config/database';

export interface PrescriptionMedicationAttributes {
  id: string;
  prescriptionId: string;
  medicationId?: string;
  medicationName: string;
  dosage?: string;
  frequency?: string;
  durationDays?: number;
  quantity?: number;
  instructions?: string;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface PrescriptionMedicationCreationAttributes
  extends Optional<PrescriptionMedicationAttributes, 'id'> {}

class PrescriptionMedication
  extends Model<PrescriptionMedicationAttributes, PrescriptionMedicationCreationAttributes>
  implements PrescriptionMedicationAttributes
{
  public id!: string;
  public prescriptionId!: string;
  public medicationId?: string;
  public medicationName!: string;
  public dosage?: string;
  public frequency?: string;
  public durationDays?: number;
  public quantity?: number;
  public instructions?: string;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

  public static associate(): void {
    const { Prescription, Medication } = sequelize.models;
    PrescriptionMedication.belongsTo(Prescription, { foreignKey: 'prescriptionId', as: 'prescription' });
    PrescriptionMedication.belongsTo(Medication, { foreignKey: 'medicationId', as: 'medication' });
  }
}

PrescriptionMedication.init(
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    prescriptionId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: 'prescriptions', key: 'id' },
      onDelete: 'CASCADE',
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
      allowNull: true,
    },
    frequency: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    durationDays: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    quantity: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    instructions: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
  },
  {
    sequelize,
    tableName: 'prescription_medications',
    timestamps: true,
    underscored: true,
    indexes: [
      { fields: ['prescription_id'] },
    ],
  }
);

export default PrescriptionMedication;