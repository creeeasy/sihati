// models/DoctorSchedule.ts
import { Model, DataTypes, Optional } from 'sequelize';
import sequelize from '../config/database';

export interface DoctorScheduleAttributes {
  id: string;
  doctorId: string;
  officeId?: string;
  dayOfWeek: number; // 0 = Sunday, 1 = Monday, ..., 6 = Saturday
  startTime: string;
  endTime: string;
  isAvailable: boolean;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface DoctorScheduleCreationAttributes
  extends Optional<DoctorScheduleAttributes, 'id' | 'isAvailable'> {}

class DoctorSchedule
  extends Model<DoctorScheduleAttributes, DoctorScheduleCreationAttributes>
  implements DoctorScheduleAttributes
{
  public id!: string;
  public doctorId!: string;
  public officeId?: string;
  public dayOfWeek!: number;
  public startTime!: string;
  public endTime!: string;
  public isAvailable!: boolean;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

  get dayName(): string {
    const days = ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];
    return days[this.dayOfWeek];
  }

  public static associate(): void {
    const { Doctor, DoctorOffice } = sequelize.models;
    DoctorSchedule.belongsTo(Doctor, { foreignKey: 'doctorId', as: 'doctor' });
    DoctorSchedule.belongsTo(DoctorOffice, { foreignKey: 'officeId', as: 'office' });
  }
}

DoctorSchedule.init(
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
    officeId: {
      type: DataTypes.UUID,
      allowNull: true,
      references: { model: 'doctor_offices', key: 'id' },
    },
    dayOfWeek: {
      type: DataTypes.INTEGER,
      allowNull: false,
      validate: { min: 0, max: 6 },
    },
    startTime: {
      type: DataTypes.TIME,
      allowNull: false,
    },
    endTime: {
      type: DataTypes.TIME,
      allowNull: false,
    },
    isAvailable: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
    },
  },
  {
    sequelize,
    tableName: 'doctor_schedules',
    timestamps: true,
    underscored: true,
    indexes: [
      { fields: ['doctor_id'] },
      { fields: ['office_id'] },
      { fields: ['day_of_week'] },
    ],
  }
);

export default DoctorSchedule;