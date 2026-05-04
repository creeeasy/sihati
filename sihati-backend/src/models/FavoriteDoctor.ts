// models/FavoriteDoctor.ts
import { Model, DataTypes, Optional } from 'sequelize';
import sequelize from '../config/database';

export interface FavoriteDoctorAttributes {
  id: string;
  patientId: string;
  doctorId: string;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface FavoriteDoctorCreationAttributes
  extends Optional<FavoriteDoctorAttributes, 'id'> {}

class FavoriteDoctor
  extends Model<FavoriteDoctorAttributes, FavoriteDoctorCreationAttributes>
  implements FavoriteDoctorAttributes
{
  public id!: string;
  public patientId!: string;
  public doctorId!: string;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

  public static associate(): void {
    const { User, Doctor } = sequelize.models;
    FavoriteDoctor.belongsTo(User, { foreignKey: 'patientId', as: 'patient' });
    FavoriteDoctor.belongsTo(Doctor, { foreignKey: 'doctorId', as: 'doctor' });
  }
}

FavoriteDoctor.init(
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
    doctorId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: 'doctors', key: 'id' },
      onDelete: 'CASCADE',
    },
  },
  {
    sequelize,
    tableName: 'favorite_doctors',
    timestamps: true,
    underscored: true,
    indexes: [
      {
        unique: true,
        fields: ['patient_id', 'doctor_id'],
      },
    ],
  }
);

export default FavoriteDoctor;