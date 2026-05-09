// src/services/waitingQueueService.ts
import { Op } from 'sequelize';
import { WaitingQueue, User, Appointment, Doctor } from '../models';

class WaitingQueueService {
  // Helper to convert userId to doctorId if needed
  private async resolveDoctorId(identifier: string): Promise<string | null> {
    // First, check if it's a valid doctor ID
    const doctor = await Doctor.findByPk(identifier);
    if (doctor) return doctor.id;
    
    // If not, check if it's a user ID and get associated doctor
    const doctorByUser = await Doctor.findOne({ 
      where: { userId: identifier },
      attributes: ['id']
    });
    if (doctorByUser) return doctorByUser.id;
    
    return null;
  }

  // Récupérer la file d'attente d'un médecin
  async getQueue(doctorId: string) {
    // Resolve the actual doctor ID (in case userId is passed)
    const actualDoctorId = await this.resolveDoctorId(doctorId);
    if (!actualDoctorId) {
      console.log(`No doctor found for identifier: ${doctorId}`);
      return [];
    }

    console.log(`Fetching queue for doctorId: ${actualDoctorId}`);
    
    const queue = await WaitingQueue.findAll({
      where: {
        doctorId: actualDoctorId,
        status: { [Op.in]: ['waiting', 'in_consultation'] }
      },
      include: [
        { model: User, as: 'patient', attributes: ['id', 'fullName', 'phoneNumber', 'chifaNumber'] },
        { model: Appointment, as: 'appointment', attributes: ['appointmentTime', 'reason'] }
      ],
      order: [['position', 'ASC']]
    });
    
    return queue;
  }

  // Ajouter patient à la file
  async addPatient(data: {
    doctorIdOrUserId: string;  // Can be either doctor ID or user ID
    patientId: string;
    appointmentId?: string;
    priority?: number;
    notes?: string;
  }) {
    const { doctorIdOrUserId, patientId, appointmentId, priority = 1, notes } = data;
    
    // Resolve the actual doctor ID
    const actualDoctorId = await this.resolveDoctorId(doctorIdOrUserId);
    if (!actualDoctorId) {
      throw new Error('Doctor not found for the provided identifier');
    }
    
    // Calculer la prochaine position
    const lastInQueue = await WaitingQueue.findOne({
      where: { doctorId: actualDoctorId, status: { [Op.in]: ['waiting', 'in_consultation'] } },
      order: [['position', 'DESC']]
    });
    const position = (lastInQueue?.position || 0) + 1;
    
    const entry = await WaitingQueue.create({
      doctorId: actualDoctorId,
      patientId,
      appointmentId,
      priority,
      position,
      notes,
      arrivedAt: new Date(),
      estimatedWaitMinutes: position * 20
    });
    
    return entry;
  }

  // Appeler patient suivant
  async callNext(doctorIdOrUserId: string) {
    const actualDoctorId = await this.resolveDoctorId(doctorIdOrUserId);
    if (!actualDoctorId) {
      throw new Error('Doctor not found for the provided identifier');
    }
    
    const next = await WaitingQueue.findOne({
      where: { doctorId: actualDoctorId, status: 'waiting' },
      order: [['priority', 'ASC'], ['position', 'ASC']]
    });
    
    if (!next) return null;
    
    await next.update({ status: 'in_consultation', startedAt: new Date() });
    return next;
  }

  // Terminer consultation
  async completeConsultation(entryId: string) {
    const entry = await WaitingQueue.findByPk(entryId);
    if (!entry) throw new Error('Entrée non trouvée');
    
    await entry.update({ status: 'completed', completedAt: new Date() });
    
    // Recalculer les positions des patients en attente
    await this.recalculatePositions(entry.doctorId);
    
    return entry;
  }

  // Recalculer les positions
  async recalculatePositions(doctorId: string) {
    const waiting = await WaitingQueue.findAll({
      where: { doctorId, status: 'waiting' },
      order: [['priority', 'ASC'], ['position', 'ASC']]
    });
    
    let pos = 1;
    for (const item of waiting) {
      await item.update({ position: pos, estimatedWaitMinutes: pos * 20 });
      pos++;
    }
  }

  // Changer priorité (urgence)
  async setPriority(entryId: string, priority: number) {
    const entry = await WaitingQueue.findByPk(entryId);
    if (!entry) throw new Error('Entrée non trouvée');
    
    await entry.update({ priority });
    await this.recalculatePositions(entry.doctorId);
    
    return entry;
  }

  // Retirer patient de la file
  async removePatient(entryId: string, reason?: string) {
    const entry = await WaitingQueue.findByPk(entryId);
    if (!entry) throw new Error('Entrée non trouvée');
    
    await entry.update({ status: 'cancelled', notes: reason });
    await this.recalculatePositions(entry.doctorId);
    
    return entry;
  }

  // Get doctor info by ID
  async getDoctorInfo(identifier: string) {
    const actualDoctorId = await this.resolveDoctorId(identifier);
    if (!actualDoctorId) return null;
    
    const doctor = await Doctor.findByPk(actualDoctorId, {
      include: [{ model: User, as: 'user', attributes: ['fullName', 'email', 'phoneNumber'] }]
    });
    
    return doctor;
  }
}

export default new WaitingQueueService();