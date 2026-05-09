// models/index.ts
import sequelize from '../config/database';

// Import all models
import User from './User';
import Specialty from './Specialty';
import Doctor from './Doctor';
import DoctorOffice from './DoctorOffice';
import DoctorSchedule from './DoctorSchedule';
import Pharmacy from './Pharmacy';
import Medication from './Medication';
import PharmacyMedication from './PharmacyMedication';
import Appointment from './Appointment';
import Prescription from './Prescription';
import PrescriptionMedication from './PrescriptionMedication';
import Consultation from './Consultation';
import MedicalDocument from './MedicalDocument';
import PatientProfile from './PatientProfile';
import PatientAllergy from './PatientAllergy';
import Conversation from './Conversation';
import Review from './Review';
import RefreshToken from './RefreshToken';
import FavoritePharmacy from './FavoritePharmacy';
import FavoriteDoctor from './FavoriteDoctor';
import MedicationHistory from './MedicationHistory';
import MedicationReminder from './MedicationReminder';
import Notification from './Notification';
import WaitingQueue from './WaitingQueue';
// Register models on the sequelize instance
const models = {
  User,
  Specialty,
  Doctor,
  DoctorOffice,
  DoctorSchedule,
  Pharmacy,
  Medication,
  PharmacyMedication,
  Appointment,
  Prescription,
  PrescriptionMedication,
  Consultation,
  MedicalDocument,
  PatientProfile,
  PatientAllergy,
  Conversation,
  Review,
  RefreshToken,
  FavoritePharmacy,
  FavoriteDoctor,
  MedicationHistory,
  MedicationReminder,
  Notification,
  WaitingQueue
};

// Run all associations after all models are registered
Object.values(models).forEach((model) => {
  if (typeof (model as any).associate === 'function') {
    (model as any).associate();
  }
});

export {
  sequelize,
  User,
  Specialty,
  Doctor,
  DoctorOffice,
  DoctorSchedule,
  Pharmacy,
  Medication,
  PharmacyMedication,
  Appointment,
  Prescription,
  PrescriptionMedication,
  Consultation,
  MedicalDocument,
  PatientProfile,
  PatientAllergy,
  Conversation,
  Review,
  RefreshToken,
  FavoritePharmacy,
  FavoriteDoctor,
  MedicationHistory,
  MedicationReminder,
  Notification,
  WaitingQueue
};

export default models;