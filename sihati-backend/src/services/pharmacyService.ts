import { Op } from 'sequelize';
import { Pharmacy, User, PharmacyMedication, Medication } from '../models';

function haversineDistance(lat1: number, lng1: number, lat2: number, lng2: number): number {
  const R = 6371;
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLng = ((lng2 - lng1) * Math.PI) / 180;
  const a = Math.sin(dLat / 2) ** 2 +
            Math.cos((lat1 * Math.PI) / 180) * Math.cos((lat2 * Math.PI) / 180) *
            Math.sin(dLng / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

class PharmacyService {
  // 📌 Récupérer toutes les pharmacies
  async getAllPharmacies(filters?: { wilaya?: string; isOnDuty?: boolean }) {
    const where: any = { isVerified: true };
    if (filters?.wilaya) where.wilaya = filters.wilaya;
    if (filters?.isOnDuty !== undefined) where.isOnDutyTonight = filters.isOnDuty;

    return Pharmacy.findAll({
      where,
      include: [{ model: User, as: 'user', attributes: { exclude: ['password'] } }],
      order: [['pharmacyName', 'ASC']]
    });
  }

  // 📌 Pharmacies de garde
  async getDutyPharmacies(wilaya?: string) {
    const where: any = { isVerified: true, isOnDutyTonight: true };
    if (wilaya) where.wilaya = wilaya;

    return Pharmacy.findAll({
      where,
      include: [{ model: User, as: 'user', attributes: ['id', 'fullName', 'profileImage'] }],
      order: [['pharmacyName', 'ASC']]
    });
  }

  // 📌 Pharmacies à proximité
  async getNearbyPharmacies(lat: number, lng: number, radiusKm: number = 5, wilaya?: string) {
    const where: any = { isVerified: true };
    if (wilaya) where.wilaya = wilaya;

    let pharmacies = await Pharmacy.findAll({ where });

    pharmacies = pharmacies
      .map(p => {
        const distance = haversineDistance(lat, lng, p.latitude, p.longitude);
        (p as any).dataValues.distance = distance;
        return p;
      })
      .filter(p => (p as any).dataValues.distance <= radiusKm)
      .sort((a, b) => (a as any).dataValues.distance - (b as any).dataValues.distance);

    return pharmacies;
  }

  // 📌 Récupérer une pharmacie par ID
  async getPharmacyById(id: string) {
    const pharmacy = await Pharmacy.findByPk(id, {
      include: [
        { model: User, as: 'user', attributes: { exclude: ['password'] } },
        { model: Medication, as: 'medications', through: { attributes: ['inStock', 'price', 'quantity'] } }
      ]
    });
    if (!pharmacy) throw new Error('Pharmacie non trouvée');
    return pharmacy;
  }

  // 📌 Créer une pharmacie
  async createPharmacy(data: any) {
    return Pharmacy.create(data);
  }

  // 📌 Mettre à jour une pharmacie
  async updatePharmacy(id: string, data: any) {
    const pharmacy = await this.getPharmacyById(id);
    await pharmacy.update(data);
    return this.getPharmacyById(id);
  }

  // 📌 Supprimer une pharmacie
  async deletePharmacy(id: string) {
    const pharmacy = await this.getPharmacyById(id);
    await pharmacy.destroy();
    return true;
  }

  // 📌 Mettre à jour le statut de garde
  async setDutyStatus(id: string, isOnDuty: boolean) {
    const pharmacy = await this.getPharmacyById(id);
    await pharmacy.update({ isOnDutyTonight: isOnDuty });
    return pharmacy;
  }

  // 📌 Rechercher des pharmacies par nom
  async searchPharmacies(query: string, wilaya?: string) {
    const where: any = {
      isVerified: true,
      pharmacyName: { [Op.iLike]: `%${query}%` }
    };
    if (wilaya) where.wilaya = wilaya;

    return Pharmacy.findAll({
      where,
      include: [{ model: User, as: 'user', attributes: ['id', 'fullName', 'profileImage'] }],
      order: [['pharmacyName', 'ASC']]
    });
  }

  // 📌 Vérifier le stock d'un médicament
  async getMedicationStock(pharmacyId: string, medicationId: string) {
    const stock = await PharmacyMedication.findOne({
      where: { pharmacyId, medicationId }
    });
    return stock;
  }

  // 📌 Mettre à jour le stock
  async updateStock(pharmacyId: string, medicationId: string, data: { inStock: boolean; quantity?: number; price?: number }) {
    const [stock, created] = await PharmacyMedication.findOrCreate({
      where: { pharmacyId, medicationId },
      defaults: { ...data, lastUpdated: new Date() }
    });
    if (!created) {
      await stock.update({ ...data, lastUpdated: new Date() });
    }
    return stock;
  }
}

export default new PharmacyService();