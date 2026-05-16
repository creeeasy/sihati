// models/PatientProfile.ts
import { Model, DataTypes, Optional } from 'sequelize';
import sequelize from '../config/database';

export interface PatientProfileAttributes {
  id: string;
  userId: string;
  dateOfBirth?: Date;
  gender?: 'male' | 'female' | 'other';
  bloodType?: string;
  emergencyContactName?: string;
  emergencyContactPhone?: string;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface PatientProfileCreationAttributes
  extends Optional<PatientProfileAttributes, 'id'> {}

class PatientProfile
  extends Model<PatientProfileAttributes, PatientProfileCreationAttributes>
  implements PatientProfileAttributes
{
  public id!: string;
  public userId!: string;
  public dateOfBirth?: Date;
  public gender?: 'male' | 'female' | 'other';
  public bloodType?: string;
  public emergencyContactName?: string;
  public emergencyContactPhone?: string;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

  get age(): number | null {
    if (!this.dateOfBirth) return null;
    const today = new Date();
    let age = today.getFullYear() - this.dateOfBirth.getFullYear();
    const m = today.getMonth() - this.dateOfBirth.getMonth();
    if (m < 0 || (m === 0 && today.getDate() < this.dateOfBirth.getDate())) {
      age--;
    }
    return age;
  }

  public static associate(): void {
    const { User, PatientAllergy } = sequelize.models;
    PatientProfile.belongsTo(User, { foreignKey: 'userId', as: 'user' });
    PatientProfile.hasMany(PatientAllergy, { foreignKey: 'patientId', as: 'allergies' });
  }
}

PatientProfile.init(
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    userId: {
      type: DataTypes.UUID,
      allowNull: false,
      unique: true,
      references: { model: 'users', key: 'id' },
      onDelete: 'CASCADE',
    },
    dateOfBirth: {
      type: DataTypes.DATEONLY,
      allowNull: true,
    },
    gender: {
      type: DataTypes.ENUM('male', 'female', 'other'),
      allowNull: true,
    },
    bloodType: {
      type: DataTypes.STRING(5),
      allowNull: true,
    },
    emergencyContactName: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    emergencyContactPhone: {
      type: DataTypes.STRING,
      allowNull: true,
    },
  },
  {
    sequelize,
    tableName: 'patient_profiles',
    timestamps: true,
    underscored: true,
  }
);

export default PatientProfile;