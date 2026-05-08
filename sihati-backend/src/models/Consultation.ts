// models/Consultation.ts
import { Model, DataTypes, Optional } from 'sequelize';
import sequelize from '../config/database';

export interface ConsultationAttributes {
  id: string;
  appointmentId?: string;
  patientId: string;
  doctorId: string;
  consultationDate: Date;
  chiefComplaint?: string;
  symptoms?: string;
  diagnosis?: string;
  treatmentPlan?: string;
  notes?: string;
  durationMinutes?: number;
  feePaid?: number;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface ConsultationCreationAttributes extends Optional<ConsultationAttributes, 'id'> {}

class Consultation extends Model<ConsultationAttributes, ConsultationCreationAttributes> implements ConsultationAttributes {
  public id!: string;
  public appointmentId?: string;
  public patientId!: string;
  public doctorId!: string;
  public consultationDate!: Date;
  public chiefComplaint?: string;
  public symptoms?: string;
  public diagnosis?: string;
  public treatmentPlan?: string;
  public notes?: string;
  public durationMinutes?: number;
  public feePaid?: number;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

  public static associate(): void {
    const { User, Appointment, Prescription } = sequelize.models;
    Consultation.belongsTo(User, { foreignKey: 'patientId', as: 'patient' });
    Consultation.belongsTo(User, { foreignKey: 'doctorId', as: 'doctor' }); // ✅ Référence users
    Consultation.belongsTo(Appointment, { foreignKey: 'appointmentId', as: 'appointment' });
    Consultation.hasMany(Prescription, { foreignKey: 'consultationId', as: 'prescriptions' });
  }
}

Consultation.init(
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    appointmentId: {
      type: DataTypes.UUID,
      allowNull: true,
      references: { model: 'appointments', key: 'id' },
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
      references: { model: 'users', key: 'id' }, // ✅ Référence users
      onDelete: 'CASCADE',
    },
    consultationDate: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: DataTypes.NOW,
    },
    chiefComplaint: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    symptoms: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    diagnosis: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    treatmentPlan: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    durationMinutes: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    feePaid: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true,
    },
  },
  {
    sequelize,
    tableName: 'consultations',
    timestamps: true,
    underscored: true,
    indexes: [
      { fields: ['patient_id'] },
      { fields: ['doctor_id'] },
      { fields: ['consultation_date'] },
    ],
  }
);

export default Consultation;