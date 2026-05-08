// models/Pharmacy.ts
import { Model, DataTypes, Optional } from 'sequelize';
import sequelize from '../config/database';

export interface PharmacyAttributes {
  id: string;
  userId?: string;
  pharmacyName: string;
  address: string;
  wilaya: string;
  commune?: string;
  latitude: number;
  longitude: number;
  phone: string;
  whatsappNumber?: string;
  email?: string;
  openingHours?: object;
  isOnDutyTonight: boolean;
  isVerified: boolean;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface PharmacyCreationAttributes
  extends Optional<PharmacyAttributes, 'id' | 'isOnDutyTonight' | 'isVerified'> {}

class Pharmacy extends Model<PharmacyAttributes, PharmacyCreationAttributes> implements PharmacyAttributes {
  public id!: string;
  public userId?: string;
  public pharmacyName!: string;
  public address!: string;
  public wilaya!: string;
  public commune?: string;
  public latitude!: number;
  public longitude!: number;
  public phone!: string;
  public whatsappNumber?: string;
  public email?: string;
  public openingHours?: object;
  public isOnDutyTonight!: boolean;
  public isVerified!: boolean;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

  get fullAddress(): string {
    const parts = [this.address, this.commune, this.wilaya].filter(Boolean);
    return parts.join(', ');
  }

  get formattedDistance(): string | null {
    const distance = (this as any).dataValues?.distance;
    if (distance == null) return null;
    return distance < 1
      ? `${Math.round(distance * 1000)} m`
      : `${distance.toFixed(1)} km`;
  }

  get hasWhatsapp(): boolean {
    return !!this.whatsappNumber;
  }

  public static associate(): void {
    const { User, Medication, PharmacyMedication, FavoritePharmacy } = sequelize.models;
    Pharmacy.belongsTo(User, { foreignKey: 'userId', as: 'user' });
    Pharmacy.belongsToMany(Medication, {
      through: PharmacyMedication,
      foreignKey: 'pharmacyId',
      as: 'medications',
    });
    Pharmacy.hasMany(FavoritePharmacy, { foreignKey: 'pharmacyId', as: 'favoritedBy' });
  }
}

Pharmacy.init(
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    userId: {
      type: DataTypes.UUID,
      allowNull: true,
      references: { model: 'users', key: 'id' },
      onDelete: 'SET NULL',
    },
    pharmacyName: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    address: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    wilaya: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    commune: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    latitude: {
      type: DataTypes.DECIMAL(10, 8),
      allowNull: false,
      validate: {
        min: -90,
        max: 90,
      },
    },
    longitude: {
      type: DataTypes.DECIMAL(11, 8),
      allowNull: false,
      validate: {
        min: -180,
        max: 180,
      },
    },
    phone: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    whatsappNumber: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    email: {
      type: DataTypes.STRING,
      allowNull: true,
      validate: { isEmail: true },
    },
    openingHours: {
      type: DataTypes.JSONB,
      allowNull: true,
    },
    isOnDutyTonight: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    },
    isVerified: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    },
  },
  {
    sequelize,
    tableName: 'pharmacies',
    timestamps: true,
    underscored: true,
    indexes: [
      { fields: ['wilaya'] },
      { fields: ['is_on_duty_tonight'] },
      { fields: ['latitude', 'longitude'] },
    ],
  }
);

export default Pharmacy;