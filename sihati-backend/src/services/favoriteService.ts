// src/services/favoriteService.ts
import { FavoriteDoctor, FavoritePharmacy, Doctor, Pharmacy, User, Specialty } from '../models';

class FavoriteService {
  // ============================================
  // MÉDECINS FAVORIS
  // ============================================
  
  async getFavoriteDoctors(patientId: string) {
    const favorites = await FavoriteDoctor.findAll({
      where: { patientId },
      include: [
        {
          model: Doctor,
          as: 'doctor',  // ✅ Utiliser l'alias 'doctor'
          include: [
            { model: Specialty, as: 'specialty' },
            { model: User, as: 'user', attributes: ['id', 'fullName', 'profileImage'] }
          ]
        }
      ],
      order: [['createdAt', 'DESC']]
    });
    
    // ✅ Extraire le doctor de chaque favori
    return favorites.map(f => (f as any).doctor).filter(d => d);
  }

  async addFavoriteDoctor(patientId: string, doctorId: string) {
    const existing = await FavoriteDoctor.findOne({
      where: { patientId, doctorId }
    });
    
    if (existing) {
      throw new Error('Ce médecin est déjà dans vos favoris');
    }
    
    const favorite = await FavoriteDoctor.create({ patientId, doctorId });
    return favorite;
  }

  async removeFavoriteDoctor(patientId: string, doctorId: string) {
    const favorite = await FavoriteDoctor.findOne({
      where: { patientId, doctorId }
    });
    
    if (!favorite) {
      throw new Error('Médecin non trouvé dans vos favoris');
    }
    
    await favorite.destroy();
    return true;
  }

  async isDoctorFavorite(patientId: string, doctorId: string) {
    const favorite = await FavoriteDoctor.findOne({
      where: { patientId, doctorId }
    });
    return !!favorite;
  }

  // ============================================
  // PHARMACIES FAVORIS
  // ============================================
  
  async getFavoritePharmacies(patientId: string) {
    const favorites = await FavoritePharmacy.findAll({
      where: { patientId },
      include: [
        {
          model: Pharmacy,
          as: 'pharmacy',  // ✅ Utiliser l'alias 'pharmacy'
        }
      ],
      order: [['createdAt', 'DESC']]
    });
    
    // ✅ Extraire la pharmacie de chaque favori
    return favorites.map(f => (f as any).pharmacy).filter(p => p);
  }

  async addFavoritePharmacy(patientId: string, pharmacyId: string) {
    const existing = await FavoritePharmacy.findOne({
      where: { patientId, pharmacyId }
    });
    
    if (existing) {
      throw new Error('Cette pharmacie est déjà dans vos favoris');
    }
    
    const favorite = await FavoritePharmacy.create({ patientId, pharmacyId });
    return favorite;
  }

  async removeFavoritePharmacy(patientId: string, pharmacyId: string) {
    const favorite = await FavoritePharmacy.findOne({
      where: { patientId, pharmacyId }
    });
    
    if (!favorite) {
      throw new Error('Pharmacie non trouvée dans vos favoris');
    }
    
    await favorite.destroy();
    return true;
  }

  async isPharmacyFavorite(patientId: string, pharmacyId: string) {
    const favorite = await FavoritePharmacy.findOne({
      where: { patientId, pharmacyId }
    });
    return !!favorite;
  }

  // ============================================
  // STATISTIQUES
  // ============================================
  
  async getFavoriteCounts(patientId: string) {
    const [doctorsCount, pharmaciesCount] = await Promise.all([
      FavoriteDoctor.count({ where: { patientId } }),
      FavoritePharmacy.count({ where: { patientId } })
    ]);
    
    return {
      doctors: doctorsCount,
      pharmacies: pharmaciesCount,
      total: doctorsCount + pharmaciesCount
    };
  }
}

export default new FavoriteService();