// models/PatientAllergy.ts
import { Model, DataTypes, Optional } from 'sequelize';
import sequelize from '../config/database';

export interface PatientAllergyAttributes {
  id: string;
  patientId: string;
  allergyName: string;
  allergyType: 'medication' | 'food' | 'environmental' | 'other';
  severity: 'mild' | 'moderate' | 'severe';
  reaction?: string;
  declaredAt?: Date;
  declaredBy?: string;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface PatientAllergyCreationAttributes
  extends Optional<PatientAllergyAttributes, 'id' | 'declaredAt'> {}

class PatientAllergy extends Model<PatientAllergyAttributes, PatientAllergyCreationAttributes> implements PatientAllergyAttributes {
  public id!: string;
  public patientId!: string;
  public allergyName!: string;
  public allergyType!: 'medication' | 'food' | 'environmental' | 'other';
  public severity!: 'mild' | 'moderate' | 'severe';
  public reaction?: string;
  public declaredAt!: Date;
  public declaredBy?: string;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

  public static associate(): void {
    const { User, PatientProfile, Doctor } = sequelize.models;
    PatientAllergy.belongsTo(User, { foreignKey: 'patientId', as: 'patient' });
    PatientAllergy.belongsTo(PatientProfile, { foreignKey: 'patientId', as: 'patientProfile' });
    PatientAllergy.belongsTo(Doctor, { foreignKey: 'declaredBy', as: 'declaredByDoctor' });
  }
}

PatientAllergy.init(
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
    allergyName: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    allergyType: {
      type: DataTypes.ENUM('medication', 'food', 'environmental', 'other'),
      allowNull: false,
    },
    severity: {
      type: DataTypes.ENUM('mild', 'moderate', 'severe'), // ✅ ENUM corrigé
      allowNull: false,
      defaultValue: 'mild',
    },
    reaction: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    declaredAt: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: DataTypes.NOW,
    },
    declaredBy: {
      type: DataTypes.UUID,
      allowNull: true,
      references: { model: 'doctors', key: 'id' },
    },
  },
  {
    sequelize,
    tableName: 'patient_allergies',
    timestamps: true,
    underscored: true,
    indexes: [{ fields: ['patient_id'] }],
  }
);

export default PatientAllergy;