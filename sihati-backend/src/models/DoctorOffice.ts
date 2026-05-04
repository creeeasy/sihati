// models/DoctorOffice.ts
import { Model, DataTypes, Optional } from 'sequelize';
import sequelize from '../config/database';

export interface DoctorOfficeAttributes {
  id: string;
  doctorId: string;
  officeName?: string;
  address: string;
  wilaya: string;
  commune?: string;
  latitude: number;
  longitude: number;
  phone?: string;
  isPrimary: boolean;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface DoctorOfficeCreationAttributes
  extends Optional<DoctorOfficeAttributes, 'id' | 'isPrimary'> {}

class DoctorOffice
  extends Model<DoctorOfficeAttributes, DoctorOfficeCreationAttributes>
  implements DoctorOfficeAttributes
{
  public id!: string;
  public doctorId!: string;
  public officeName?: string;
  public address!: string;
  public wilaya!: string;
  public commune?: string;
  public latitude!: number;
  public longitude!: number;
  public phone?: string;
  public isPrimary!: boolean;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

  get fullAddress(): string {
    const parts = [this.address, this.commune, this.wilaya].filter(Boolean);
    return parts.join(', ');
  }

  public static associate(): void {
    const { Doctor, Appointment } = sequelize.models;
    DoctorOffice.belongsTo(Doctor, { foreignKey: 'doctorId', as: 'doctor' });
    DoctorOffice.hasMany(Appointment, { foreignKey: 'officeId', as: 'appointments' });
  }
}

DoctorOffice.init(
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    doctorId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: 'doctors', key: 'id' },
      onDelete: 'CASCADE',
    },
    officeName: {
      type: DataTypes.STRING,
      allowNull: true,
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
      allowNull: true,
    },
    isPrimary: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    },
  },
  {
    sequelize,
    tableName: 'doctor_offices',
    timestamps: true,
    underscored: true,
    indexes: [
      { fields: ['doctor_id'] },
      { fields: ['wilaya'] },
      { fields: ['latitude', 'longitude'] },
    ],
  }
);

export default DoctorOffice;