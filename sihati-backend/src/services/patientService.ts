import { 
  User, 
  PatientProfile, 
  PatientAllergy, 
  Prescription, 
  PrescriptionMedication,
  Consultation,
  MedicalDocument,
  Medication,
  Doctor,
  Appointment
} from '../models';

class PatientService {
  // ============================================
  // PROFIL PATIENT
  // ============================================
  
  async getPatientProfile(userId: string) {
    console.log(userId)
    const profile = await PatientProfile.findOne({
      where: { userId },
      include: [
        { model: User, as: 'user', attributes: { exclude: ['password'] } },
        { model: PatientAllergy, as: 'allergies' }
      ]
    });
    if (!profile) throw new Error('Profil patient non trouvé');
    return profile;
  }

  async updatePatientProfile(userId: string, data: any) {
    const profile = await PatientProfile.findOne({ where: { userId } });
    if (!profile) throw new Error('Profil patient non trouvé');
    await profile.update(data);
    return this.getPatientProfile(userId);
  }

  // ============================================
  // ALLERGIES
  // ============================================
  
  async getAllergies(userId: string) {
    return PatientAllergy.findAll({
      where: { patientId: userId },
      order: [['declaredAt', 'DESC']]
    });
  }

  async addAllergy(userId: string, data: any) {
    const allergy = await PatientAllergy.create({
      patientId: userId,
      ...data,
      declaredAt: new Date()
    });
    return allergy;
  }

  async deleteAllergy(allergyId: string) {
    const allergy = await PatientAllergy.findByPk(allergyId);
    if (!allergy) throw new Error('Allergie non trouvée');
    await allergy.destroy();
    return true;
  }

  // ============================================
  // PRESCRIPTIONS
  // ============================================
  
  async getPrescriptions(userId: string, page: number = 1, limit: number = 10) {
    const offset = (page - 1) * limit;
    const { rows, count } = await Prescription.findAndCountAll({
      where: { patientId: userId },
      include: [
        { model: Doctor, as: 'doctor', include: [{ model: User, as: 'user' }] },
        { 
          model: PrescriptionMedication, 
          as: 'medications',
          include: [{ model: Medication, as: 'medication' }]
        }
      ],
      order: [['prescriptionDate', 'DESC']],
      limit,
      offset
    });
    
    return {
      prescriptions: rows,
      total: count,
      page,
      totalPages: Math.ceil(count / limit)
    };
  }

  async getPrescriptionById(prescriptionId: string) {
    const prescription = await Prescription.findByPk(prescriptionId, {
      include: [
        { model: Doctor, as: 'doctor', include: [{ model: User, as: 'user' }] },
        { model: PrescriptionMedication, as: 'medications', include: [{ model: Medication, as: 'medication' }] }
      ]
    });
    if (!prescription) throw new Error('Ordonnance non trouvée');
    return prescription;
  }

  // ============================================
  // CONSULTATIONS
  // ============================================
  
  async getConsultations(userId: string, page: number = 1, limit: number = 10) {
    const offset = (page - 1) * limit;
    const { rows, count } = await Consultation.findAndCountAll({
      where: { patientId: userId },
      include: [
        { 
          model: User, 
          as: 'doctor',
          attributes: ['id', 'fullName', 'profileImage']
        },
        { model: Appointment, as: 'appointment' }
      ],
      order: [['consultationDate', 'DESC']],
      limit,
      offset
    });
    
    return {
      consultations: rows,
      total: count,
      page,
      totalPages: Math.ceil(count / limit)
    };
  }

  async getConsultationById(consultationId: string) {
    const consultation = await Consultation.findByPk(consultationId, {
      include: [
        { model: User, as: 'doctor', attributes: ['id', 'fullName', 'profileImage'] },
        { model: Appointment, as: 'appointment' },
        { model: Prescription, as: 'prescriptions' }
      ]
    });
    if (!consultation) throw new Error('Consultation non trouvée');
    return consultation;
  }

  // ============================================
  // DOCUMENTS MÉDICAUX
  // ============================================
  
  async getDocuments(userId: string) {
    return MedicalDocument.findAll({
      where: { patientId: userId },
      order: [['documentDate', 'DESC']]
    });
  }

  async addDocument(userId: string, data: any, fileUrl: string) {
    const document = await MedicalDocument.create({
      patientId: userId,
      ...data,
      fileUrl,
      // createdAt is set automatically by Sequelize
    });
    return document;
  }

  async deleteDocument(documentId: string) {
    const document = await MedicalDocument.findByPk(documentId);
    if (!document) throw new Error('Document non trouvé');
    await document.destroy();
    return true;
  }

  // ============================================
  // STATISTIQUES
  // ============================================
  
  async getStats(userId: string) {
    const [prescriptionsCount, consultationsCount, documentsCount, allergiesCount] = await Promise.all([
      Prescription.count({ where: { patientId: userId } }),
      Consultation.count({ where: { patientId: userId } }),
      MedicalDocument.count({ where: { patientId: userId } }),
      PatientAllergy.count({ where: { patientId: userId } })
    ]);
    
    return {
      prescriptionsCount,
      consultationsCount,
      documentsCount,
      allergiesCount
    };
  }
}

export default new PatientService();