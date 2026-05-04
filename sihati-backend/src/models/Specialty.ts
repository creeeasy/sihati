// models/Specialty.ts
import { Model, DataTypes, Optional } from 'sequelize';
import sequelize from '../config/database';

export interface SpecialtyAttributes {
  id: string;  // ✅ UUID
  nameFr: string;
  nameAr: string;
  icon: string;
  description?: string;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface SpecialtyCreationAttributes
  extends Optional<SpecialtyAttributes, 'id'> {}

class Specialty
  extends Model<SpecialtyAttributes, SpecialtyCreationAttributes>
  implements SpecialtyAttributes
{
  public id!: string;
  public nameFr!: string;
  public nameAr!: string;
  public icon!: string;
  public description?: string;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

  public static associate(): void {
    const { Doctor } = sequelize.models;
    Specialty.hasMany(Doctor, { foreignKey: 'specialtyId', as: 'doctors' });
  }
}

Specialty.init(
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    nameFr: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
    nameAr: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    icon: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
  },
  {
    sequelize,
    tableName: 'specialties',
    timestamps: true,
    underscored: true,
    indexes: [{ unique: true, fields: ['name_fr'] }],
  }
);

export default Specialty;