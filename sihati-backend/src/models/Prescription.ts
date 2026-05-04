// models/Prescription.ts
import { Model, DataTypes, Optional } from 'sequelize';
import sequelize from '../config/database';

export interface PrescriptionAttributes {
  id: string;
  consultationId?: string;
  patientId: string;
  doctorId: string;
  prescriptionDate: Date;
  diagnosis?: string;
  notes?: string;
  validityDays: number;
  isRenewable: boolean;
  fileUrl?: string;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface PrescriptionCreationAttributes
  extends Optional<PrescriptionAttributes, 'id' | 'validityDays' | 'isRenewable'> {}

class Prescription
  extends Model<PrescriptionAttributes, PrescriptionCreationAttributes>
  implements PrescriptionAttributes
{
  public id!: string;
  public consultationId?: string;
  public patientId!: string;
  public doctorId!: string;
  public prescriptionDate!: Date;
  public diagnosis?: string;
  public notes?: string;
  public validityDays!: number;
  public isRenewable!: boolean;
  public fileUrl?: string;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

  get expiryDate(): Date {
    return new Date(this.prescriptionDate.getTime() + this.validityDays * 24 * 60 * 60 * 1000);
  }

  get isValid(): boolean {
    return new Date() <= this.expiryDate;
  }

  get isExpired(): boolean {
    return new Date() > this.expiryDate;
  }

  public static associate(): void {
    const { User, Doctor, Consultation, PrescriptionMedication } = sequelize.models;
    Prescription.belongsTo(User, { foreignKey: 'patientId', as: 'patient' });
    Prescription.belongsTo(Doctor, { foreignKey: 'doctorId', as: 'doctor' });
    Prescription.belongsTo(Consultation, { foreignKey: 'consultationId', as: 'consultation' });
    Prescription.hasMany(PrescriptionMedication, { foreignKey: 'prescriptionId', as: 'medications' });
  }
}

Prescription.init(
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    consultationId: {
      type: DataTypes.UUID,
      allowNull: true,
      references: { model: 'consultations', key: 'id' },
    },
    patientId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: 'users', key: 'id' },
      onDelete: 'CASCADE',
    },
    doctorId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: 'doctors', key: 'id' },
    },
    prescriptionDate: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: DataTypes.NOW,
    },
    diagnosis: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    validityDays: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 30,
    },
    isRenewable: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    },
    fileUrl: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
  },
  {
    sequelize,
    tableName: 'prescriptions',
    timestamps: true,
    underscored: true,
    indexes: [
      { fields: ['patient_id'] },
      { fields: ['doctor_id'] },
      { fields: ['prescription_date'] },
    ],
  }
);

export default Prescription;