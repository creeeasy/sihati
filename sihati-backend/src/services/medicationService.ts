// src/services/medicationService.ts
import { Op } from 'sequelize';
import { Medication, Pharmacy, PharmacyMedication } from '../models';

class MedicationService {
  // 📌 Rechercher des médicaments
  async searchMedications(query: string, category?: string, requiresPrescription?: boolean) {
    const where: any = {};
    
    if (query && query.length >= 2) {
      where[Op.or] = [
        { name: { [Op.iLike]: `%${query}%` } },
        { genericName: { [Op.iLike]: `%${query}%` } },
        { dci: { [Op.iLike]: `%${query}%` } }
      ];
    }
    
    if (category) where.category = category;
    if (requiresPrescription !== undefined) where.requiresPrescription = requiresPrescription;
    
    return Medication.findAll({
      where,
      order: [['name', 'ASC']],
      limit: 50
    });
  }

  // 📌 Récupérer un médicament par ID
  async getMedicationById(id: string) {
    const medication = await Medication.findByPk(id);
    if (!medication) throw new Error('Médicament non trouvé');
    return medication;
  }

  // 📌 Récupérer les pharmacies qui ont un médicament en stock (CORRIGÉ)
  async getPharmaciesWithStock(medicationId: string, lat?: number, lng?: number, radius: number = 10) {
    // ✅ Inclure directement la pharmacie dans la requête
    const pharmacyMedications = await PharmacyMedication.findAll({
      where: { 
        medicationId, 
        inStock: true 
      },
      include: [
        { 
          model: Pharmacy, 
          as: 'pharmacy',  // ✅ Utiliser l'alias correct
          required: true 
        }
      ]
    });
    
    // Transformer les résultats
    let pharmacies = pharmacyMedications.map(pm => {
      const pharmacyData = (pm as any).pharmacy;
      return {
        pharmacy: pharmacyData,
        inStock: pm.inStock,
        price: pm.price,
        quantity: pm.quantity,
        lastUpdated: pm.lastUpdated
      };
    });
    
    // Filtrage par distance si coordonnées fournies
    if (lat && lng && pharmacies.length > 0) {
      pharmacies = pharmacies.filter(p => {
        if (!p.pharmacy) return false;
        const distance = this.calculateDistance(lat, lng, p.pharmacy.latitude, p.pharmacy.longitude);
        (p as any).distance = distance;
        return distance <= radius;
      });
      
      pharmacies.sort((a, b) => ((a as any).distance || 0) - ((b as any).distance || 0));
    }
    
    return pharmacies;
  }

  // 📌 Rechercher par code-barres
  async searchByBarcode(barcode: string) {
    const medication = await Medication.findOne({ where: { barcode } });
    return medication;
  }

  // 📌 Obtenir les médicaments populaires
  async getPopularMedications(limit: number = 10) {
    return Medication.findAll({
      limit,
      order: [['name', 'ASC']]
    });
  }

  // 📌 Calculer la distance
  private calculateDistance(lat1: number, lng1: number, lat2: number, lng2: number): number {
    const earthRadius = 6371;
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLng = (lng2 - lng1) * Math.PI / 180;
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
              Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
              Math.sin(dLng / 2) * Math.sin(dLng / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return earthRadius * c;
  }
}

export default new MedicationService();