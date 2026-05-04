// models/FavoritePharmacy.ts
import { Model, DataTypes, Optional } from 'sequelize';
import sequelize from '../config/database';

export interface FavoritePharmacyAttributes {
  id: string;
  patientId: string;
  pharmacyId: string;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface FavoritePharmacyCreationAttributes
  extends Optional<FavoritePharmacyAttributes, 'id'> {}

class FavoritePharmacy
  extends Model<FavoritePharmacyAttributes, FavoritePharmacyCreationAttributes>
  implements FavoritePharmacyAttributes
{
  public id!: string;
  public patientId!: string;
  public pharmacyId!: string;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

  public static associate(): void {
    const { User, Pharmacy } = sequelize.models;
    FavoritePharmacy.belongsTo(User, { foreignKey: 'patientId', as: 'patient' });
    FavoritePharmacy.belongsTo(Pharmacy, { foreignKey: 'pharmacyId', as: 'pharmacy' });
  }
}

FavoritePharmacy.init(
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
    pharmacyId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: 'pharmacies', key: 'id' },
      onDelete: 'CASCADE',
    },
  },
  {
    sequelize,
    tableName: 'favorite_pharmacies',
    timestamps: true,
    underscored: true,
    indexes: [
      {
        unique: true,
        fields: ['patient_id', 'pharmacy_id'],
      },
    ],
  }
);

export default FavoritePharmacy;