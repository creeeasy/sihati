import { Model, DataTypes, Optional } from 'sequelize';
import sequelize from '../config/database';

export interface PharmacyAttributes {
  id: number;
  userId?: number;
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
  extends Optional<
    PharmacyAttributes,
    'id' | 'isOnDutyTonight' | 'isVerified'
  > {}

class Pharmacy
  extends Model<PharmacyAttributes, PharmacyCreationAttributes>
  implements PharmacyAttributes
{
  public id!: number;
  public userId?: number;
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

  // Virtual: full address string
  get fullAddress(): string {
    const parts = [this.address, this.commune, this.wilaya].filter(Boolean);
    return parts.join(', ');
  }

  // Virtual: formatted distance (set dynamically after geospatial query)
  get formattedDistance(): string | null {
    const distance = (this as any).dataValues?.distance;
    if (distance == null) return null;
    return distance < 1
      ? `${Math.round(distance * 1000)} m`
      : `${distance.toFixed(1)} km`;
  }

  // Virtual: whether pharmacy has WhatsApp
  get hasWhatsapp(): boolean {
    return !!this.whatsappNumber;
  }

  // Associations
  public static associate(): void {
    const { User, Medication, PharmacyMedication } = sequelize.models;
    Pharmacy.belongsTo(User, { foreignKey: 'userId', as: 'user' });
    Pharmacy.belongsToMany(Medication, {
      through: PharmacyMedication,
      foreignKey: 'pharmacyId',
      as: 'medications',
    });
  }
}

Pharmacy.init(
  {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    userId: {
      type: DataTypes.INTEGER,
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
    },
    longitude: {
      type: DataTypes.DECIMAL(11, 8),
      allowNull: false,
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