// models/Review.ts
import { Model, DataTypes, Optional } from 'sequelize';
import sequelize from '../config/database';
import Doctor from './Doctor';

export interface ReviewAttributes {
  id: string;  // ✅ UUID
  userId: string;  // ✅ UUID
  doctorId: string;  // ✅ UUID
  rating: number;
  comment?: string;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface ReviewCreationAttributes
  extends Optional<ReviewAttributes, 'id'> {}

class Review
  extends Model<ReviewAttributes, ReviewCreationAttributes>
  implements ReviewAttributes
{
  public id!: string;
  public userId!: string;
  public doctorId!: string;
  public rating!: number;
  public comment?: string;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

  public static associate(): void {
    const { User, Doctor } = sequelize.models;
    Review.belongsTo(User, { foreignKey: 'userId', as: 'user' });
    Review.belongsTo(Doctor, { foreignKey: 'doctorId', as: 'doctor' });
  }
}

Review.init(
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    userId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: 'users', key: 'id' },
      onDelete: 'CASCADE',
    },
    doctorId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: 'doctors', key: 'id' },
      onDelete: 'CASCADE',
    },
    rating: {
      type: DataTypes.DECIMAL(2, 1),
      allowNull: false,
      validate: {
        min: 1.0,
        max: 5.0,
      },
    },
    comment: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
  },
  {
    sequelize,
    tableName: 'reviews',
    timestamps: true,
    underscored: true,
    indexes: [
      {
        unique: true,
        fields: ['user_id', 'doctor_id'],
      },
    ],
    hooks: {
      afterCreate: async (review: Review) => {
        const doctor = await Doctor.findByPk(review.doctorId);
        if (doctor) {
          await doctor.updateRating(review.rating);
        }
      },
    },
  }
);

export default Review;