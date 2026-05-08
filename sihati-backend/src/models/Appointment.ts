// models/Appointment.ts
import { Model, DataTypes, Optional } from 'sequelize';
import sequelize from '../config/database';

export interface AppointmentAttributes {
  id: string;
  patientId: string;
  doctorId: string;
  officeId?: string;
  appointmentDate: Date;
  appointmentTime: string;
  status: 'pending' | 'confirmed' | 'cancelled' | 'completed' | 'no_show';
  reason?: string;
  notes?: string;
  consultationFee?: number;
  cancelledAt?: Date;
  cancelledBy?: string;
  cancellationReason?: string;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface AppointmentCreationAttributes
  extends Optional<AppointmentAttributes, 'id' | 'status'> {}

class Appointment extends Model<AppointmentAttributes, AppointmentCreationAttributes> implements AppointmentAttributes {
  public id!: string;
  public patientId!: string;
  public doctorId!: string;
  public officeId?: string;
  public appointmentDate!: Date;
  public appointmentTime!: string;
  public status!: 'pending' | 'confirmed' | 'cancelled' | 'completed' | 'no_show';
  public reason?: string;
  public notes?: string;
  public consultationFee?: number;
  public cancelledAt?: Date;
  public cancelledBy?: string;
  public cancellationReason?: string;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

  get formattedDate(): string {
    const months = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
    return `${this.appointmentDate.getDate()} ${months[this.appointmentDate.getMonth()]} ${this.appointmentDate.getFullYear()}`;
  }

  get isUpcoming(): boolean {
    const now = new Date();
    const appointmentDateTime = new Date(
      this.appointmentDate.getFullYear(),
      this.appointmentDate.getMonth(),
      this.appointmentDate.getDate(),
      parseInt(this.appointmentTime.split(':')[0]),
      parseInt(this.appointmentTime.split(':')[1])
    );
    return appointmentDateTime > now && (this.status === 'pending' || this.status === 'confirmed');
  }

  get isToday(): boolean {
    const today = new Date();
    return this.appointmentDate.getDate() === today.getDate() &&
      this.appointmentDate.getMonth() === today.getMonth() &&
      this.appointmentDate.getFullYear() === today.getFullYear();
  }

  public async cancel(reason?: string, cancelledBy?: string): Promise<void> {
    await this.update({
      status: 'cancelled',
      cancelledAt: new Date(),
      cancelledBy,
      cancellationReason: reason,
    });
  }

  public async confirm(): Promise<void> {
    await this.update({ status: 'confirmed' });
  }

  public async complete(): Promise<void> {
    await this.update({ status: 'completed' });
  }

  public static associate(): void {
    const { User, Doctor, DoctorOffice } = sequelize.models;
    Appointment.belongsTo(User, { foreignKey: 'patientId', as: 'patient' });
    Appointment.belongsTo(User, { foreignKey: 'doctorId', as: 'doctor' }); // ✅ Référence users
    Appointment.belongsTo(DoctorOffice, { foreignKey: 'officeId', as: 'office' });
  }
}

Appointment.init(
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
    doctorId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: 'users', key: 'id' }, // ✅ Référence users
      onDelete: 'CASCADE',
    },
    officeId: {
      type: DataTypes.UUID,
      allowNull: true,
      references: { model: 'doctor_offices', key: 'id' },
    },
    appointmentDate: {
      type: DataTypes.DATEONLY,
      allowNull: false,
    },
    appointmentTime: {
      type: DataTypes.TIME,
      allowNull: false,
    },
    status: {
      type: DataTypes.ENUM('pending', 'confirmed', 'cancelled', 'completed', 'no_show'),
      allowNull: false,
      defaultValue: 'pending',
    },
    reason: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    consultationFee: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true,
    },
    cancelledAt: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    cancelledBy: {
      type: DataTypes.UUID,
      allowNull: true,
      references: { model: 'users', key: 'id' },
    },
    cancellationReason: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
  },
  {
    sequelize,
    tableName: 'appointments',
    timestamps: true,
    underscored: true,
    indexes: [
      { fields: ['patient_id'] },
      { fields: ['doctor_id'] },
      { fields: ['appointment_date'] },
      { fields: ['status'] },
    ],
  }
);

export default Appointment;