import { Op } from 'sequelize';
import { Doctor, Specialty, User } from '../models';
import { DoctorCreateDTO, DoctorUpdateDTO } from '../types';
import { NotFoundError } from './pharmacyService';

// Haversine formula: distance in km between two GPS points
function haversineDistance(
  lat1: number,
  lng1: number,
  lat2: number,
  lng2: number
): number {
  const R = 6371;
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLng = ((lng2 - lng1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLng / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

class DoctorService {
  // Get all doctors with optional filters
  async getAllDoctors(filters?: {
    specialtyId?: number;
    wilaya?: string;
  }): Promise<Doctor[]> {
    const where: any = {};
    if (filters?.specialtyId) where.specialtyId = filters.specialtyId;
    if (filters?.wilaya) where.wilaya = filters.wilaya;

    return Doctor.findAll({
      where,
      include: [
        { model: Specialty, as: 'specialty' },
        { model: User, as: 'user', attributes: ['id', 'fullName', 'email', 'profileImage'] },
      ],
      order: [
        ['averageRating', 'DESC'],
        ['doctorName', 'ASC'],
      ],
    });
  }

  // Get doctors within a given radius sorted by distance
  async getNearbyDoctors(
    lat: number,
    lng: number,
    radiusKm: number,
    specialtyId?: number
  ): Promise<Doctor[]> {
    const where: any = {};
    if (specialtyId) where.specialtyId = specialtyId;

    const doctors = await Doctor.findAll({
      where,
      include: [
        { model: Specialty, as: 'specialty' },
        { model: User, as: 'user', attributes: ['id', 'fullName', 'profileImage'] },
      ],
    });

    return doctors
      .map((d) => {
        const distance = haversineDistance(
          lat,
          lng,
          Number(d.latitude),
          Number(d.longitude)
        );
        (d as any).dataValues.distance = Math.round(distance * 10) / 10;
        return d;
      })
      .filter((d) => (d as any).dataValues.distance <= radiusKm)
      .sort(
        (a, b) =>
          (a as any).dataValues.distance - (b as any).dataValues.distance
      );
  }

  // Get doctor by ID
  async getDoctorById(id: number): Promise<Doctor> {
    const doctor = await Doctor.findByPk(id, {
      include: [
        { model: Specialty, as: 'specialty' },
        { model: User, as: 'user', attributes: ['id', 'fullName', 'email', 'profileImage'] },
      ],
    });

    if (!doctor) {
      throw new NotFoundError(`Médecin #${id} introuvable.`);
    }

    return doctor;
  }

  // Search doctors by name or clinic name
  async searchDoctors(
    query: string,
    filters?: { specialtyId?: number; wilaya?: string }
  ): Promise<Doctor[]> {
    const where: any = {
      [Op.or]: [
        { doctorName: { [Op.iLike]: `%${query}%` } },
        { clinicName: { [Op.iLike]: `%${query}%` } },
      ],
    };

    if (filters?.specialtyId) where.specialtyId = filters.specialtyId;
    if (filters?.wilaya) where.wilaya = filters.wilaya;

    return Doctor.findAll({
      where,
      include: [
        { model: Specialty, as: 'specialty' },
        { model: User, as: 'user', attributes: ['id', 'fullName', 'profileImage'] },
      ],
      order: [['averageRating', 'DESC']],
    });
  }

  // Get top rated doctors (minimum 5 reviews)
  async getTopRatedDoctors(limit: number = 10): Promise<Doctor[]> {
    return Doctor.findAll({
      where: {
        totalReviews: { [Op.gte]: 5 },
      },
      include: [
        { model: Specialty, as: 'specialty' },
        { model: User, as: 'user', attributes: ['id', 'fullName', 'profileImage'] },
      ],
      order: [['averageRating', 'DESC']],
      limit,
    });
  }

  // Create a new doctor profile
  async createDoctor(data: DoctorCreateDTO): Promise<Doctor> {
    // Validate specialty exists
    const specialty = await Specialty.findByPk(data.specialtyId);
    if (!specialty) {
      throw new NotFoundError(`Spécialité #${data.specialtyId} introuvable.`);
    }

    const doctor = await Doctor.create(data as any);

    return this.getDoctorById(doctor.id);
  }

  // Update a doctor profile
  async updateDoctor(id: number, data: DoctorUpdateDTO): Promise<Doctor> {
    const doctor = await this.getDoctorById(id);
    await doctor.update(data);
    return this.getDoctorById(id);
  }
}

export default new DoctorService();