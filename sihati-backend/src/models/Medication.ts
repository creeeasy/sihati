// models/Medication.ts
import { Model, DataTypes, Optional } from 'sequelize';
import sequelize from '../config/database';

export interface MedicationAttributes {
  id: string;  // ✅ UUID
  name: string;
  genericName?: string;
  dci?: string;  // 🆕 Dénomination Commune Internationale
  form?: string;  // 🆕 Forme (comprimé, sirop, etc.)
  dosage?: string;  // 🆕 Dosage
  category?: string;
  manufacturer?: string;
  description?: string;
  indications?: string;  // 🆕 Indications
  contraindications?: string;  // 🆕 Contre-indications
  sideEffects?: string;  // 🆕 Effets secondaires
  posology?: string;  // 🆕 Posologie
  requiresPrescription: boolean;
  barcode?: string;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface MedicationCreationAttributes
  extends Optional<MedicationAttributes, 'id' | 'requiresPrescription'> {}

class Medication
  extends Model<MedicationAttributes, MedicationCreationAttributes>
  implements MedicationAttributes
{
  public id!: string;
  public name!: string;
  public genericName?: string;
  public dci?: string;
  public form?: string;
  public dosage?: string;
  public category?: string;
  public manufacturer?: string;
  public description?: string;
  public indications?: string;
  public contraindications?: string;
  public sideEffects?: string;
  public posology?: string;
  public requiresPrescription!: boolean;
  public barcode?: string;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

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
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
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
    dci: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    form: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    dosage: {
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
    indications: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    contraindications: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    sideEffects: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    posology: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    requiresPrescription: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    },
    barcode: {
      type: DataTypes.STRING,
      allowNull: true,
      unique: true,
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
      { fields: ['barcode'] },
    ],
    scopes: {
      otc: { where: { requiresPrescription: false } },
      prescription: { where: { requiresPrescription: true } },
    },
  }
);

export default Medication;