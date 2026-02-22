import { Op } from 'sequelize';
import { Medication, Pharmacy, PharmacyMedication } from '../models';
import { MedicationCreateDTO, MedicationSearchResult } from '../types';
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

class MedicationService {
  // Search medications and return which pharmacies stock them
  async searchMedications(
    query: string,
    location?: { lat: number; lng: number }
  ): Promise<MedicationSearchResult[]> {
    const medications = await Medication.findAll({
      where: {
        [Op.or]: [
          { name: { [Op.iLike]: `%${query}%` } },
          { genericName: { [Op.iLike]: `%${query}%` } },
        ],
      },
      include: [
        {
          model: Pharmacy,
          as: 'pharmacies',
          through: {
            attributes: ['inStock', 'price', 'lastUpdated'],
          },
        },
      ],
    });

    return medications.map((medication) => {
      const pharmacies = ((medication as any).pharmacies || []).map(
        (pharmacy: any) => {
          const junction = pharmacy.PharmacyMedication || pharmacy.pharmacy_medications;
          let distance: number | undefined;

          if (location) {
            distance =
              Math.round(
                haversineDistance(
                  location.lat,
                  location.lng,
                  Number(pharmacy.latitude),
                  Number(pharmacy.longitude)
                ) * 10
              ) / 10;
          }

          return {
            pharmacy,
            inStock: junction?.inStock ?? false,
            price: junction?.price,
            distance,
          };
        }
      );

      // Sort pharmacies by distance if location provided
      if (location) {
        pharmacies.sort(
          (a: any, b: any) => (a.distance ?? Infinity) - (b.distance ?? Infinity)
        );
      }

      return { medication, pharmacies };
    });
  }

  // Get a single medication by ID with stocking pharmacies
  async getMedicationById(id: number): Promise<Medication> {
    const medication = await Medication.findByPk(id, {
      include: [
        {
          model: Pharmacy,
          as: 'pharmacies',
          through: { attributes: ['inStock', 'price', 'lastUpdated'] },
        },
      ],
    });

    if (!medication) {
      throw new NotFoundError(`Médicament #${id} introuvable.`);
    }

    return medication;
  }

  // Get all medications with optional filters
  async getAllMedications(filters?: {
    category?: string;
    requiresPrescription?: boolean;
  }): Promise<Medication[]> {
    const where: any = {};
    if (filters?.category) where.category = filters.category;
    if (filters?.requiresPrescription !== undefined)
      where.requiresPrescription = filters.requiresPrescription;

    return Medication.findAll({
      where,
      order: [['name', 'ASC']],
    });
  }

  // Get most widely stocked medications
  async getPopularMedications(limit: number = 20): Promise<Medication[]> {
    return Medication.findAll({
      include: [
        {
          model: Pharmacy,
          as: 'pharmacies',
          through: { attributes: [] },
        },
      ],
      order: [[{ model: Pharmacy, as: 'pharmacies' }, 'id', 'ASC']],
      limit,
    });
  }

  // Create a new medication
  async createMedication(data: MedicationCreateDTO): Promise<Medication> {
    const existing = await Medication.findOne({ where: { name: data.name } });
    if (existing) {
      throw new Error(`Un médicament avec le nom "${data.name}" existe déjà.`);
    }
    return Medication.create(data as any);
  }

  // Update stock info in junction table
  async updateMedicationStock(
    medicationId: number,
    pharmacyId: number,
    inStock: boolean,
    quantity?: number
  ): Promise<void> {
    const record = await PharmacyMedication.findOne({
      where: { medicationId, pharmacyId },
    });

    if (!record) {
      throw new NotFoundError(
        `Association médicament/pharmacie introuvable.`
      );
    }

    await record.updateStock(inStock, quantity);
  }
}

export default new MedicationService();