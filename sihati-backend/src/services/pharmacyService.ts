import { Op } from 'sequelize';
import { Pharmacy, User } from '../models';
import { PharmacyCreateDTO, PharmacyUpdateDTO } from '../types';

export class NotFoundError extends Error {
  statusCode = 404;
  constructor(message: string) {
    super(message);
    this.name = 'NotFoundError';
  }
}

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

class PharmacyService {
  // Get all pharmacies with optional filters
  async getAllPharmacies(filters?: {
    wilaya?: string;
    isOnDuty?: boolean;
  }): Promise<Pharmacy[]> {
    const where: any = {};
    if (filters?.wilaya) where.wilaya = filters.wilaya;
    if (filters?.isOnDuty !== undefined)
      where.isOnDutyTonight = filters.isOnDuty;

    return Pharmacy.findAll({
      where,
      include: [{ model: User, as: 'user', attributes: ['id', 'fullName', 'email'] }],
      order: [['pharmacyName', 'ASC']],
    });
  }

  // Get pharmacies within a given radius (km) sorted by distance
  async getNearbyPharmacies(
    lat: number,
    lng: number,
    radiusKm: number
  ): Promise<(Pharmacy & { distance: number })[]> {
    const pharmacies = await Pharmacy.findAll();

    const withDistance = pharmacies
      .map((p) => {
        const distance = haversineDistance(
          lat,
          lng,
          Number(p.latitude),
          Number(p.longitude)
        );
        (p as any).dataValues.distance = Math.round(distance * 10) / 10;
        return p as Pharmacy & { distance: number };
      })
      .filter((p) => (p as any).dataValues.distance <= radiusKm)
      .sort(
        (a, b) => (a as any).dataValues.distance - (b as any).dataValues.distance
      );

    return withDistance;
  }

  // Get pharmacy by ID
  async getPharmacyById(id: number): Promise<Pharmacy> {
    const pharmacy = await Pharmacy.findByPk(id, {
      include: [{ model: User, as: 'user', attributes: ['id', 'fullName', 'email'] }],
    });

    if (!pharmacy) {
      throw new NotFoundError(`Pharmacie #${id} introuvable.`);
    }

    return pharmacy;
  }

  // Get pharmacies on duty tonight
  async getDutyPharmacies(wilaya?: string): Promise<Pharmacy[]> {
    const where: any = { isOnDutyTonight: true };
    if (wilaya) where.wilaya = wilaya;

    return Pharmacy.findAll({
      where,
      order: [
        ['wilaya', 'ASC'],
        ['pharmacyName', 'ASC'],
      ],
    });
  }

  // Search pharmacies by name or address
  async searchPharmacies(
    query: string,
    location?: { lat: number; lng: number }
  ): Promise<Pharmacy[]> {
    const pharmacies = await Pharmacy.findAll({
      where: {
        [Op.or]: [
          { pharmacyName: { [Op.iLike]: `%${query}%` } },
          { address: { [Op.iLike]: `%${query}%` } },
          { wilaya: { [Op.iLike]: `%${query}%` } },
        ],
      },
    });

    if (location) {
      return pharmacies
        .map((p) => {
          const distance = haversineDistance(
            location.lat,
            location.lng,
            Number(p.latitude),
            Number(p.longitude)
          );
          (p as any).dataValues.distance = Math.round(distance * 10) / 10;
          return p;
        })
        .sort(
          (a, b) =>
            (a as any).dataValues.distance - (b as any).dataValues.distance
        );
    }

    return pharmacies;
  }

  // Create a new pharmacy
  async createPharmacy(data: PharmacyCreateDTO): Promise<Pharmacy> {
    return Pharmacy.create(data as any);
  }

  // Update an existing pharmacy
  async updatePharmacy(
    id: number,
    data: PharmacyUpdateDTO
  ): Promise<Pharmacy> {
    const pharmacy = await this.getPharmacyById(id);
    await pharmacy.update(data);
    return pharmacy;
  }

  // Delete a pharmacy
  async deletePharmacy(id: number): Promise<void> {
    const pharmacy = await this.getPharmacyById(id);
    await pharmacy.destroy();
  }
}

export default new PharmacyService();