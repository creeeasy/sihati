// models/Doctor.ts
import { Model, DataTypes, Optional } from 'sequelize';
import sequelize from '../config/database';

export interface DoctorAttributes {
  id: string;  // ✅ UUID
  userId: string;  // ✅ UUID
  specialtyId: string;  // ✅ UUID
  doctorName: string;
  clinicName: string;
  clinicAddress: string;
  wilaya: string;
  commune?: string;
  latitude: number;
  longitude: number;
  phone: string;
  whatsappNumber?: string;
  consultationFee?: number;
  workingHours?: object;
  bio?: string;
  yearsOfExperience?: number;
  averageRating?: number;
  totalReviews?: number;
  isVerified: boolean;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface DoctorCreationAttributes
  extends Optional<DoctorAttributes, 'id' | 'isVerified' | 'averageRating' | 'totalReviews'> {}

class Doctor
  extends Model<DoctorAttributes, DoctorCreationAttributes>
  implements DoctorAttributes
{
  public id!: string;
  public userId!: string;
  public specialtyId!: string;
  public doctorName!: string;
  public clinicName!: string;
  public clinicAddress!: string;
  public wilaya!: string;
  public commune?: string;
  public latitude!: number;
  public longitude!: number;
  public phone!: string;
  public whatsappNumber?: string;
  public consultationFee?: number;
  public workingHours?: object;
  public bio?: string;
  public yearsOfExperience?: number;
  public averageRating?: number;
  public totalReviews?: number;
  public isVerified!: boolean;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

  get formattedFee(): string | null {
    if (this.consultationFee == null) return null;
    return `${this.consultationFee.toLocaleString('fr-DZ')} DA`;
  }

  get formattedDistance(): string | null {
    const distance = (this as any).dataValues?.distance;
    if (distance == null) return null;
    return distance < 1
      ? `${Math.round(distance * 1000)} m`
      : `${distance.toFixed(1)} km`;
  }

  public async updateRating(newRating: number): Promise<void> {
    const currentTotal = this.totalReviews ?? 0;
    const currentAvg = this.averageRating ?? 0;
    const updatedTotal = currentTotal + 1;
    const updatedAvg = (currentAvg * currentTotal + newRating) / updatedTotal;

    await this.update({
      averageRating: Math.round(updatedAvg * 100) / 100,
      totalReviews: updatedTotal,
    });
  }

// models/Doctor.ts
public static associate(): void {
    const { User, Specialty, Appointment, Review, DoctorOffice } = sequelize.models;
    Doctor.belongsTo(User, { foreignKey: 'userId', as: 'user' });
    Doctor.belongsTo(Specialty, { foreignKey: 'specialtyId', as: 'specialty' });
    Doctor.hasMany(Appointment, { foreignKey: 'doctorId', as: 'appointments' });
    Doctor.hasMany(Review, { foreignKey: 'doctorId', as: 'reviews' });
    Doctor.hasMany(DoctorOffice, { foreignKey: 'doctorId', as: 'offices' }); 
}
}

Doctor.init(
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    userId: {
      type: DataTypes.UUID,
      allowNull: false,
      unique: true,
      references: { model: 'users', key: 'id' },
      onDelete: 'CASCADE',
    },
    specialtyId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: 'specialties', key: 'id' },
    },
    doctorName: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    clinicName: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    clinicAddress: {
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
    consultationFee: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true,
    },
    workingHours: {
      type: DataTypes.JSONB,
      allowNull: true,
    },
    bio: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    yearsOfExperience: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    averageRating: {
      type: DataTypes.DECIMAL(3, 2),
      allowNull: true,
      defaultValue: 0.0,
    },
    totalReviews: {
      type: DataTypes.INTEGER,
      allowNull: true,
      defaultValue: 0,
    },
    isVerified: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    },
  },
  {
    sequelize,
    tableName: 'doctors',
    timestamps: true,
    underscored: true,
    indexes: [
      { fields: ['wilaya'] },
      { fields: ['specialty_id'] },
      { fields: ['latitude', 'longitude'] },
    ],
  }
);

export default Doctor;