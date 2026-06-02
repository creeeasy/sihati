import { Appointment, Doctor, User, DoctorOffice } from '../models';

class AppointmentService {
  // Récupérer les RDV d'un médecin
  async getDoctorAppointments(doctorId: string, status?: string) {
    const where: any = { doctorId };
    if (status) where.status = status;
    
    return Appointment.findAll({
      where,
      include: [
        { model: User, as: 'patient', attributes: ['id', 'fullName', 'phoneNumber', 'chifaNumber'] },
        { model: DoctorOffice, as: 'office' }
      ],
      order: [['appointmentDate', 'ASC'], ['appointmentTime', 'ASC']]
    });
  }

  // Récupérer les RDV d'un patient
  async getPatientAppointments(patientId: string, status?: string) {
    const where: any = { patientId };
    if (status) where.status = status;
    
    return Appointment.findAll({
      where,
      include: [
        { 
          model: User, 
          as: 'doctor',
          attributes: ['id', 'fullName', 'phoneNumber', 'profileImage'],
          include: [{ model: Doctor, as: 'doctor' }]
        },
        { model: DoctorOffice, as: 'office' }
      ],
      order: [['appointmentDate', 'DESC']]
    });
  }

  // Créer un rendez-vous
  async createAppointment(data: {
    patientId: string;
    doctorId: string;
    officeId?: string;
    appointmentDate: Date;
    appointmentTime: string;
    reason?: string;
  }) {
     const doctor = await Doctor.findByPk(data.doctorId);
  
  if (!doctor) {
    throw new Error('Doctor not found');
  }
 return Appointment.create({
    patientId: data.patientId,
    doctorId: doctor.userId,  // Convert doctors.id → users.id
    officeId: data.officeId,
    appointmentDate: data.appointmentDate,
    appointmentTime: data.appointmentTime,
    reason: data.reason,
    status: 'pending'
  });
  }

  // Confirmer un rendez-vous
  async confirmAppointment(id: string) {
    const appointment = await Appointment.findByPk(id);
    if (!appointment) throw new Error('Rendez-vous non trouvé');
    await appointment.update({ status: 'confirmed' });
    return appointment;
  }

  // Annuler un rendez-vous
  async cancelAppointment(id: string, reason?: string) {
    const appointment = await Appointment.findByPk(id);
    if (!appointment) throw new Error('Rendez-vous non trouvé');
    await appointment.update({ 
      status: 'cancelled',
      cancellationReason: reason,
      cancelledAt: new Date()
    });
    return appointment;
  }

  // Terminer un rendez-vous
  async completeAppointment(id: string) {
    const appointment = await Appointment.findByPk(id);
    if (!appointment) throw new Error('Rendez-vous non trouvé');
    await appointment.update({ status: 'completed' });
    return appointment;
  }

  // Récupérer un rendez-vous par ID
  async getAppointmentById(id: string) {
    const appointment = await Appointment.findByPk(id, {
      include: [
        { model: User, as: 'patient', attributes: ['id', 'fullName', 'phoneNumber'] },
        { 
          model: User, 
          as: 'doctor',
          attributes: ['id', 'fullName', 'phoneNumber', 'profileImage'],
          include: [{ model: Doctor, as: 'doctor' }]
        },
        { model: DoctorOffice, as: 'office' }
      ]
    });
    if (!appointment) throw new Error('Rendez-vous non trouvé');
    return appointment;
  }
}

export default new AppointmentService();