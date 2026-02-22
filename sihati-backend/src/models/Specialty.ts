import { Model, DataTypes, Optional } from 'sequelize';
import sequelize from '../config/database';

export interface SpecialtyAttributes {
  id: number;
  nameFr: string;
  nameAr: string;
  icon: string;
  description?: string;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface SpecialtyCreationAttributes
  extends Optional<SpecialtyAttributes, 'id'> {}

class Specialty
  extends Model<SpecialtyAttributes, SpecialtyCreationAttributes>
  implements SpecialtyAttributes
{
  public id!: number;
  public nameFr!: string;
  public nameAr!: string;
  public icon!: string;
  public description?: string;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

  // Associations
  public static associate(): void {
    const { Doctor } = sequelize.models;
    Specialty.hasMany(Doctor, { foreignKey: 'specialtyId', as: 'doctors' });
  }
}

Specialty.init(
  {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    nameFr: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
    nameAr: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    icon: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
  },
  {
    sequelize,
    tableName: 'specialties',
    timestamps: true,
    underscored: true,
    indexes: [{ unique: true, fields: ['name_fr'] }],
    scopes: {
      withDoctorCount: {
        include: [
          {
            model: sequelize.models.Doctor,
            as: 'doctors',
            attributes: [],
          },
        ],
        attributes: {
          include: [
            [
              sequelize.fn('COUNT', sequelize.col('doctors.id')),
              'doctorCount',
            ],
          ],
        },
        group: ['Specialty.id'],
      },
    },
  }
);

// Seed data
export const SPECIALTIES_SEED = [
  { nameFr: 'Médecine Générale',    nameAr: 'الطب العام',               icon: 'stethoscope' },
  { nameFr: 'Pédiatrie',            nameAr: 'طب الأطفال',               icon: 'baby' },
  { nameFr: 'Cardiologie',          nameAr: 'طب القلب',                 icon: 'heart' },
  { nameFr: 'Dermatologie',         nameAr: 'طب الجلد',                 icon: 'skin' },
  { nameFr: 'Gynécologie',          nameAr: 'أمراض النساء',             icon: 'female' },
  { nameFr: 'ORL',                  nameAr: 'أنف أذن حنجرة',            icon: 'ear' },
  { nameFr: 'Ophtalmologie',        nameAr: 'طب العيون',                icon: 'eye' },
  { nameFr: 'Dentiste',             nameAr: 'طب الأسنان',               icon: 'tooth' },
  { nameFr: 'Psychiatrie',          nameAr: 'الطب النفسي',              icon: 'brain' },
  { nameFr: 'Neurologie',           nameAr: 'طب الأعصاب',               icon: 'nerve' },
  { nameFr: 'Orthopédie',           nameAr: 'جراحة العظام',             icon: 'bone' },
  { nameFr: 'Urologie',             nameAr: 'المسالك البولية',          icon: 'kidney' },
  { nameFr: 'Gastro-entérologie',   nameAr: 'أمراض الجهاز الهضمي',     icon: 'stomach' },
  { nameFr: 'Pneumologie',          nameAr: 'أمراض الجهاز التنفسي',     icon: 'lungs' },
  { nameFr: 'Chirurgie Générale',   nameAr: 'الجراحة العامة',           icon: 'scalpel' },
  { nameFr: 'Endocrinologie',       nameAr: 'الغدد الصماء',             icon: 'hormone' },
  { nameFr: 'Rhumatologie',         nameAr: 'أمراض الروماتيزم',         icon: 'joint' },
  { nameFr: 'Néphrologie',          nameAr: 'أمراض الكلى',              icon: 'kidney2' },
];

export default Specialty;