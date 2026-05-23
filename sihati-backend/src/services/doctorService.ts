import { Op } from 'sequelize';
import { Doctor, Specialty, User, Review, DoctorOffice, DoctorSchedule } from '../models';

// Haversine formula
function haversineDistance(lat1: number, lng1: number, lat2: number, lng2: number): number {
  const R = 6371;
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLng = ((lng2 - lng1) * Math.PI) / 180;
  const a = Math.sin(dLat / 2) ** 2 +
            Math.cos((lat1 * Math.PI) / 180) * Math.cos((lat2 * Math.PI) / 180) *
            Math.sin(dLng / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

class DoctorService {
  // 📌 Récupérer tous les médecins
  async getAllDoctors(filters?: { specialtyId?: string; wilaya?: string }) {
    const where: any = { isVerified: true };
    if (filters?.specialtyId) where.specialtyId = filters.specialtyId;
    if (filters?.wilaya) where.wilaya = filters.wilaya;

    return Doctor.findAll({
      where,
      include: [
        { model: Specialty, as: 'specialty' },
        { model: User, as: 'user', attributes: { exclude: ['password'] } }
      ]
    });
  }

  // 📌 Rechercher avec filtres
  async searchDoctors(params: {
    q?: string;
    specialtyId?: string;
    wilaya?: string;
    minRating?: number;
    maxPrice?: number;
    lat?: number;
    lng?: number;
    radius?: number;
  }) {
    const where: any = { isVerified: true };
    if (params.specialtyId) where.specialtyId = params.specialtyId;
    if (params.wilaya) where.wilaya = params.wilaya;
    if (params.minRating) where.averageRating = { [Op.gte]: params.minRating };
    if (params.maxPrice) where.consultationFee = { [Op.lte]: params.maxPrice };
    if (params.q) {
      where[Op.or] = [
        { doctorName: { [Op.iLike]: `%${params.q}%` } },
        { clinicName: { [Op.iLike]: `%${params.q}%` } },
        { clinicAddress: { [Op.iLike]: `%${params.q}%` } }
      ];
    }

    let doctors = await Doctor.findAll({
      include: [{ model: Specialty, as: 'specialty' }],
      where
    });

    if (params.lat && params.lng) {
      const radiusKm = params.radius || 10;
      doctors = doctors
        .map(d => {
          const distance = haversineDistance(params.lat!, params.lng!, d.latitude, d.longitude);
          (d as any).dataValues.distance = distance;
          return d;
        })
        .filter(d => (d as any).dataValues.distance <= radiusKm)
        .sort((a, b) => (a as any).dataValues.distance - (b as any).dataValues.distance);
    }

    return doctors;
  }

  // 📌 Récupérer un médecin par ID
async getDoctorById(id: string) {
    const doctor = await Doctor.findByPk(id, {
        include: [
            { model: Specialty, as: 'specialty' },
            { model: User, as: 'user', attributes: { exclude: ['password'] } }
            // ❌ RETIRER DoctorOffice si l'association n'existe pas
        ]
    });
    if (!doctor) throw new Error('Médecin non trouvé');
    return doctor;
}

  // 📌 Créer un médecin
  async createDoctor(data: any) {
    return Doctor.create(data);
  }

  // 📌 Mettre à jour un médecin
  async updateDoctor(id: string, data: any) {
    const doctor = await this.getDoctorById(id);
    await doctor.update(data);
    return this.getDoctorById(id);
  }

  // 📌 Supprimer un médecin
  async deleteDoctor(id: string) {
    const doctor = await this.getDoctorById(id);
    await doctor.destroy();
    return true;
  }

  // 📌 Récupérer les avis d'un médecin
  async getDoctorReviews(id: string) {
    return Review.findAll({
      where: { doctorId: id },
      include: [{ model: User, as: 'user', attributes: ['id', 'fullName', 'profileImage'] }],
      order: [['createdAt', 'DESC']]
    });
  }

  // 📌 Ajouter un avis
  async addReview(doctorId: string, userId: string, rating: number, comment?: string) {
    const existing = await Review.findOne({ where: { doctorId, userId } });
    if (existing) throw new Error('Vous avez déjà laissé un avis pour ce médecin');
    return Review.create({ doctorId, userId, rating, comment });
  }

  // 📌 Top médecins (par note)
  async getTopRatedDoctors(limit: number = 10) {
    return Doctor.findAll({
      include: [{ model: Specialty, as: 'specialty' }],
      where: { isVerified: true, averageRating: { [Op.gt]: 0 } },
      order: [['averageRating', 'DESC']],
      limit
    });
  }

  // 📌 Récupérer toutes les spécialités
  async getAllSpecialties() {
    return Specialty.findAll();
  }

  // 📌 Créneaux disponibles
async getAvailableSlots(doctorId: string, date: Date, officeId?: string) {
  const where: any = { doctorId, isAvailable: true };
  if (officeId) where.officeId = officeId;
  
  const schedules = await DoctorSchedule.findAll({ where });
  return this.generateTimeSlots(schedules, date);
}

  private generateTimeSlots(schedules: DoctorSchedule[], date: Date): string[] {
    const slots: string[] = [];
    const dayOfWeek = date.getDay();
    const daySchedules = schedules.filter(s => s.dayOfWeek === dayOfWeek);

    for (const schedule of daySchedules) {
      let current = new Date(`2000-01-01T${schedule.startTime}`);
      const end = new Date(`2000-01-01T${schedule.endTime}`);
      while (current < end) {
        slots.push(`${current.getHours().toString().padStart(2, '0')}:${current.getMinutes().toString().padStart(2, '0')}`);
        current.setMinutes(current.getMinutes() + 30);
      }
    }
    return slots;
  }
  // src/services/doctorService.ts (ajouter ces méthodes)

// Récupérer les disponibilités d'un médecin
async getSchedule(doctorId: string) {
  const schedules = await DoctorSchedule.findAll({
    where: { doctorId },
    order: [['dayOfWeek', 'ASC'], ['startTime', 'ASC']]
  });
  return schedules;
}

// Mettre à jour les disponibilités
async updateSchedule(doctorId: string, schedules: any[]) {
  await DoctorSchedule.destroy({ where: { doctorId } });
  const newSchedules = await DoctorSchedule.bulkCreate(
    schedules.map(s => ({ ...s, doctorId }))
  );
  return newSchedules;
}

// Mettre à jour le profil médecin
async updateDoctorProfile(doctorId: string, data: any) {
  const doctor = await Doctor.findByPk(doctorId);
  if (!doctor) throw new Error('Médecin non trouvé');
  await doctor.update(data);
  return doctor;
}
// src/services/doctorService.ts
async getDoctorByUserId(userId: string) {
    const doctor = await Doctor.findOne({
        where: { userId },
        include: [
            { model: Specialty, as: 'specialty' },
            { model: User, as: 'user', attributes: { exclude: ['password'] } }
        ]
    });
    if (!doctor) throw new Error('Médecin non trouvé');
    return doctor;
}
}


export default new DoctorService();