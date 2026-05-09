// models/PharmacyMedication.ts
import { Model, DataTypes, Optional } from 'sequelize';
import sequelize from '../config/database';

export interface PharmacyMedicationAttributes {
  id: string;  // ✅ UUID
  pharmacyId: string;  // ✅ UUID
  medicationId: string;  // ✅ UUID
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
  public id!: string;
  public pharmacyId!: string;
  public medicationId!: string;
  public inStock!: boolean;
  public quantity?: number;
  public price?: number;
  public lastUpdated?: Date;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

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
public static associate(): void {
    const { Pharmacy, Medication } = sequelize.models;
    PharmacyMedication.belongsTo(Pharmacy, { foreignKey: 'pharmacyId', as: 'pharmacy' }); 
    PharmacyMedication.belongsTo(Medication, { foreignKey: 'medicationId', as: 'medication' });  
}
}

PharmacyMedication.init(
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    pharmacyId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: 'pharmacies', key: 'id' },
      onDelete: 'CASCADE',
    },
    medicationId: {
      type: DataTypes.UUID,
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