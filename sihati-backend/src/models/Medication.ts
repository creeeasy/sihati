import { Model, DataTypes, Optional } from 'sequelize';
import sequelize from '../config/database';

export interface MedicationAttributes {
  id: number;
  name: string;
  genericName?: string;
  category?: string;
  manufacturer?: string;
  description?: string;
  dosageForm?: string;
  strength?: string;
  requiresPrescription: boolean;
  price?: number;
  barcode?: string;
  activeIngredients?: object;
  sideEffects?: string;
  contraindications?: string;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface MedicationCreationAttributes
  extends Optional<MedicationAttributes, 'id' | 'requiresPrescription'> {}

class Medication
  extends Model<MedicationAttributes, MedicationCreationAttributes>
  implements MedicationAttributes
{
  public id!: number;
  public name!: string;
  public genericName?: string;
  public category?: string;
  public manufacturer?: string;
  public description?: string;
  public dosageForm?: string;
  public strength?: string;
  public requiresPrescription!: boolean;
  public price?: number;
  public barcode?: string;
  public activeIngredients?: object;
  public sideEffects?: string;
  public contraindications?: string;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

  // Associations
  public static associate(): void {
    const { Pharmacy, PharmacyMedication } = sequelize.models;
    Medication.belongsToMany(Pharmacy, {
      through: PharmacyMedication,
      foreignKey: 'medicationId',
      as: 'pharmacies',
    });
  }
}

Medication.init(
  {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
    genericName: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    category: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    manufacturer: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    dosageForm: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    strength: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    requiresPrescription: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    },
    price: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true,
    },
    barcode: {
      type: DataTypes.STRING,
      allowNull: true,
      unique: true,
    },
    activeIngredients: {
      type: DataTypes.JSONB,
      allowNull: true,
    },
    sideEffects: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    contraindications: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
  },
  {
    sequelize,
    tableName: 'medications',
    timestamps: true,
    underscored: true,
    indexes: [
      { unique: true, fields: ['name'] },
      { fields: ['category'] },
    ],
    scopes: {
      otc: { where: { requiresPrescription: false } },
      prescription: { where: { requiresPrescription: true } },
    },
  }
);

export default Medication;