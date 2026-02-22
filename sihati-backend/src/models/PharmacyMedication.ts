import { Model, DataTypes, Optional } from 'sequelize';
import sequelize from '../config/database';

export interface PharmacyMedicationAttributes {
  id: number;
  pharmacyId: number;
  medicationId: number;
  inStock: boolean;
  quantity?: number;
  price?: number;
  lastUpdated?: Date;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface PharmacyMedicationCreationAttributes
  extends Optional<PharmacyMedicationAttributes, 'id' | 'inStock'> {}

class PharmacyMedication
  extends Model<
    PharmacyMedicationAttributes,
    PharmacyMedicationCreationAttributes
  >
  implements PharmacyMedicationAttributes
{
  public id!: number;
  public pharmacyId!: number;
  public medicationId!: number;
  public inStock!: boolean;
  public quantity?: number;
  public price?: number;
  public lastUpdated?: Date;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

  // Update stock info
  public async updateStock(
    inStock: boolean,
    quantity?: number
  ): Promise<void> {
    await this.update({
      inStock,
      quantity,
      lastUpdated: new Date(),
    });
  }

  // Associations
  public static associate(): void {
    const { Pharmacy, Medication } = sequelize.models;
    PharmacyMedication.belongsTo(Pharmacy, { foreignKey: 'pharmacyId' });
    PharmacyMedication.belongsTo(Medication, { foreignKey: 'medicationId' });
  }
}

PharmacyMedication.init(
  {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    pharmacyId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: { model: 'pharmacies', key: 'id' },
      onDelete: 'CASCADE',
    },
    medicationId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: { model: 'medications', key: 'id' },
      onDelete: 'CASCADE',
    },
    inStock: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
    },
    quantity: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    price: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true,
    },
    lastUpdated: {
      type: DataTypes.DATE,
      allowNull: true,
    },
  },
  {
    sequelize,
    tableName: 'pharmacy_medications',
    timestamps: true,
    underscored: true,
    indexes: [
      {
        unique: true,
        fields: ['pharmacy_id', 'medication_id'],
      },
    ],
  }
);

export default PharmacyMedication;