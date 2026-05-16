// ============================================================
// DTOs — Data Transfer Objects (incoming request payloads)
// ============================================================

export interface RegisterDTO {
  email: string;
  password: string;
  fullName: string;
  phoneNumber: string;
  role?: 'patient' | 'pharmacy' | 'doctor';
  chifaNumber?: string;  // ✅ Carte Chifa
}

export interface LoginDTO {
  email: string;
  password: string;
}

export interface UpdateProfileDTO {
  fullName?: string;
  phoneNumber?: string;
  chifaNumber?: string;  // ✅ Carte Chifa
  address?: string;
  wilaya?: string;
  profileImage?: string;
}

// ============================================================
// Pharmacie DTOs
// ============================================================

export interface PharmacyCreateDTO {
  pharmacyName: string;
  address: string;
  wilaya: string;
  commune?: string;
  latitude: number;
  longitude: number;
  phone: string;
  whatsappNumber?: string;
  email?: string;
  openingHours?: object;
  isOnDutyTonight?: boolean;
  userId?: string;  // ✅ UUID
}

export interface PharmacyUpdateDTO {
  pharmacyName?: string;
  address?: string;
  wilaya?: string;
  commune?: string;
  latitude?: number;
  longitude?: number;
  phone?: string;
  whatsappNumber?: string;
  email?: string;
  openingHours?: object;
  isOnDutyTonight?: boolean;
  isVerified?: boolean;
}

// ============================================================
// Médecin DTOs
// ============================================================

export interface DoctorCreateDTO {
  userId: string;  // ✅ UUID
  specialtyId: string;  // ✅ UUID
  doctorName: string;
  clinicName: string;
  clinicAddress: string;
  wilaya: string;
  commune?: string;
  latitude: number;
  longitude: number;
  phone: string;
  whatsappNumber?: string;
  consultationFee?: number;
  bio?: string;
  yearsOfExperience?: number;
}

export interface DoctorUpdateDTO {
  specialtyId?: string;  // ✅ UUID
  doctorName?: string;
  clinicName?: string;
  clinicAddress?: string;
  wilaya?: string;
  commune?: string;
  latitude?: number;
  longitude?: number;
  phone?: string;
  whatsappNumber?: string;
  consultationFee?: number;
  bio?: string;
  yearsOfExperience?: number;
  isVerified?: boolean;
}

// ============================================================
// Médicament DTOs
// ============================================================

export interface MedicationCreateDTO {
  name: string;
  genericName?: string;
  dci?: string;  // ✅ Dénomination Commune Internationale
  form?: string;  // ✅ Forme (comprimé, sirop, etc.)
  dosage?: string;  // ✅ Dosage
  category?: string;
  manufacturer?: string;
  description?: string;
  indications?: string;  // ✅ Indications
  contraindications?: string;  // ✅ Contre-indications
  sideEffects?: string;  // ✅ Effets secondaires
  posology?: string;  // ✅ Posologie
  dosageForm?: string;
  strength?: string;
  requiresPrescription?: boolean;
  price?: number;
  barcode?: string;
  activeIngredients?: object;
}

export interface MedicationUpdateDTO {
  name?: string;
  genericName?: string;
  dci?: string;
  form?: string;
  dosage?: string;
  category?: string;
  manufacturer?: string;
  description?: string;
  indications?: string;
  contraindications?: string;
  sideEffects?: string;
  posology?: string;
  requiresPrescription?: boolean;
  price?: number;
  barcode?: string;
}

// ============================================================
// Rendez-vous DTOs
// ============================================================

export interface AppointmentCreateDTO {
  patientId: string;  // ✅ UUID
  doctorId: string;  // ✅ UUID
  officeId?: string;  // ✅ UUID
  appointmentDate: Date;
  appointmentTime: string;
  reason?: string;
}

export interface AppointmentUpdateDTO {
  appointmentDate?: Date;
  appointmentTime?: string;
  reason?: string;
  notes?: string;
  status?: 'pending' | 'confirmed' | 'cancelled' | 'completed' | 'no_show';
}

// ============================================================
// Ordonnance DTOs
// ============================================================

export interface PrescriptionCreateDTO {
  consultationId?: string;  // ✅ UUID
  patientId: string;  // ✅ UUID
  doctorId: string;  // ✅ UUID
  diagnosis?: string;
  notes?: string;
  validityDays?: number;
  isRenewable?: boolean;
  medications: {
    medicationId?: string;  // ✅ UUID
    medicationName: string;
    dosage?: string;
    frequency?: string;
    durationDays?: number;
    quantity?: number;
    instructions?: string;
  }[];
}

// ============================================================
// Avis DTOs
// ============================================================

export interface ReviewCreateDTO {
  doctorId: string;  // ✅ UUID
  rating: number;
  comment?: string;
}

// ============================================================
// Favoris DTOs
// ============================================================

export interface FavoriteDoctorDTO {
  patientId: string;  // ✅ UUID
  doctorId: string;  // ✅ UUID
}

export interface FavoritePharmacyDTO {
  patientId: string;  // ✅ UUID
  pharmacyId: string;  // ✅ UUID
}

// ============================================================
// Consultation DTOs
// ============================================================

export interface ConsultationCreateDTO {
  appointmentId?: string;  // ✅ UUID
  patientId: string;  // ✅ UUID
  doctorId: string;  // ✅ UUID
  chiefComplaint?: string;
  symptoms?: string;
  diagnosis?: string;
  treatmentPlan?: string;
  notes?: string;
}

// ============================================================
// Patient Profile DTOs
// ============================================================

export interface PatientProfileDTO {
  dateOfBirth?: Date;
  gender?: 'male' | 'female' | 'other';
  bloodType?: string;
  emergencyContactName?: string;
  emergencyContactPhone?: string;
}

export interface AllergyDTO {
  allergyName: string;
  allergyType: 'medication' | 'food' | 'environmental' | 'other';
  severity: 'mild' | 'moderate' | 'severe';
  reaction?: string;
}

// ============================================================
// Réponse shapes
// ============================================================

export interface PharmacyWithStock {
  pharmacy: any;
  inStock: boolean;
  price?: number;
  quantity?: number;
  distance?: number;
  lastUpdated?: Date;
}

export interface MedicationSearchResult {
  medication: any;
  pharmacies: PharmacyWithStock[];
}

// ============================================================
// AI types
// ============================================================

export interface ChatHistoryItem {
  role: 'user' | 'model';
  parts: { text: string }[];
}

export type UrgencyLevel = 'low' | 'medium' | 'high' | 'emergency';

export interface PharmacyStock {
  pharmacyId: string;  // ✅ UUID
  pharmacyName: string;
  wilaya: string;
  phone: string;
  isOnDutyTonight: boolean;
  inStock: boolean;
  price: number | null;
  distance?: number;
}

export interface AIMedicationResult {
  name: string;
  genericName: string | null;
  category: string | null;
  requiresPrescription: boolean;
  basePrice: number | null;
  foundInDb: boolean;
  availableInPharmacies: PharmacyStock[];
}

export interface ChatResponse {
  reply: string;
  urgency: UrgencyLevel;
  isSymptomRelated: boolean;
  suggestedSpecialty: string | null;
  medicationSuggestions: AIMedicationResult[];
}

export interface InteractionResponse {
  safe: boolean;
  severity: 'none' | 'mild' | 'moderate' | 'severe' | 'unknown';
  reply: string;
}

export interface MedicationInfoResponse {
  reply: string;
  usage: string;
  contraindications: string;
  dosage: string;
  sideEffects: string;
  pregnancy: string;
  interactions: string;
  warnings: string;
  foundInDb: boolean;
  dbData?: {
    name: string;
    genericName: string | null;
    price: number | null;
    requiresPrescription: boolean;
    category: string | null;
    dosageForm: string | null;
    strength: string | null;
  };
}

export interface SpecialtyResponse {
  specialty: string;
  reason: string;
  urgency: UrgencyLevel;
}

// ============================================================
// JWT Payload
// ============================================================

export interface JwtPayload {
  id: string;  // ✅ UUID
  email: string;
  role: 'patient' | 'pharmacy' | 'doctor' | 'admin';
  iat?: number;
  exp?: number;
}

// ============================================================
// Query Parameters
// ============================================================

export interface PaginationQuery {
  page?: number;
  limit?: number;
  sort?: string;
  order?: 'ASC' | 'DESC';
}

export interface DoctorSearchQuery extends PaginationQuery {
  specialtyId?: string;  // ✅ UUID
  wilaya?: string;
  q?: string;
  minRating?: number;
  maxPrice?: number;
  lat?: number;
  lng?: number;
  radius?: number;
}

export interface PharmacySearchQuery extends PaginationQuery {
  wilaya?: string;
  q?: string;
  lat?: number;
  lng?: number;
  radius?: number;
  onDuty?: boolean;
}

export interface MedicationSearchQuery extends PaginationQuery {
  q?: string;
  category?: string;
  requiresPrescription?: boolean;
  lat?: number;
  lng?: number;
  radius?: number;
}