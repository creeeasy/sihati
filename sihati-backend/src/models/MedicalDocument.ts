// models/MedicalDocument.ts
import { Model, DataTypes, Optional } from 'sequelize';
import sequelize from '../config/database';

export interface MedicalDocumentAttributes {
  id: string;
  patientId: string;
  doctorId?: string;
  documentType: 'lab_result' | 'radiology' | 'report' | 'certificate' | 'prescription' | 'other';
  title: string;
  description?: string;
  fileUrl: string;
  fileType?: string;
  fileSizeBytes?: number;
  documentDate: Date;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface MedicalDocumentCreationAttributes
  extends Optional<MedicalDocumentAttributes, 'id'> {}

class MedicalDocument
  extends Model<MedicalDocumentAttributes, MedicalDocumentCreationAttributes>
  implements MedicalDocumentAttributes
{
  public id!: string;
  public patientId!: string;
  public doctorId?: string;
  public documentType!: 'lab_result' | 'radiology' | 'report' | 'certificate' | 'prescription' | 'other';
  public title!: string;
  public description?: string;
  public fileUrl!: string;
  public fileType?: string;
  public fileSizeBytes?: number;
  public documentDate!: Date;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

  get formattedFileSize(): string {
    if (!this.fileSizeBytes) return 'Taille inconnue';
    if (this.fileSizeBytes < 1024) return `${this.fileSizeBytes} B`;
    if (this.fileSizeBytes < 1024 * 1024) return `${(this.fileSizeBytes / 1024).toFixed(1)} KB`;
    return `${(this.fileSizeBytes / (1024 * 1024)).toFixed(1)} MB`;
  }

  get typeDisplayName(): string {
    const types: Record<string, string> = {
      lab_result: 'Analyse',
      radiology: 'Radiologie',
      report: 'Compte-rendu',
      certificate: 'Certificat',
      prescription: 'Ordonnance',
      other: 'Autre',
    };
    return types[this.documentType] ?? 'Document';
  }

  public static associate(): void {
    const { User, Doctor } = sequelize.models;
    MedicalDocument.belongsTo(User, { foreignKey: 'patientId', as: 'patient' });
    MedicalDocument.belongsTo(Doctor, { foreignKey: 'doctorId', as: 'doctor' });
  }
}

MedicalDocument.init(
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
      allowNull: true,
      references: { model: 'doctors', key: 'id' },
    },
    documentType: {
      type: DataTypes.ENUM('lab_result', 'radiology', 'report', 'certificate', 'prescription', 'other'),
      allowNull: false,
    },
    title: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    fileUrl: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    fileType: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    fileSizeBytes: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    documentDate: {
      type: DataTypes.DATEONLY,
      allowNull: false,
    },
  },
  {
    sequelize,
    tableName: 'medical_documents',
    timestamps: true,
    underscored: true,
    indexes: [
      { fields: ['patient_id'] },
      { fields: ['doctor_id'] },
      { fields: ['document_type'] },
      { fields: ['document_date'] },
    ],
  }
);

export default MedicalDocument;