// ============================================================
// DTOs — Data Transfer Objects (incoming request payloads)
// ============================================================

export interface RegisterDTO {
  email: string;
  password: string;
  fullName: string;
  phoneNumber: string;
  role?: 'patient' | 'pharmacy' | 'doctor';
}

export interface LoginDTO {
  email: string;
  password: string;
}

export interface UpdateProfileDTO {
  fullName?: string;
  phoneNumber?: string;
  address?: string;
  wilaya?: string;
  profileImage?: string;
}

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
  userId?: number;
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

export interface DoctorCreateDTO {
  userId: number;
  specialtyId: number;
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
  workingHours?: object;
  bio?: string;
  yearsOfExperience?: number;
}

export interface DoctorUpdateDTO {
  specialtyId?: number;
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
  workingHours?: object;
  bio?: string;
  yearsOfExperience?: number;
  isVerified?: boolean;
}

export interface MedicationCreateDTO {
  name: string;
  genericName?: string;
  category?: string;
  manufacturer?: string;
  description?: string;
  dosageForm?: string;
  strength?: string;
  requiresPrescription?: boolean;
  price?: number;
  barcode?: string;
  activeIngredients?: object;
  sideEffects?: string;
  contraindications?: string;
}

// ============================================================
// Response shapes
// ============================================================

export interface PharmacyWithStock {
  pharmacy: any;
  inStock: boolean;
  price?: number;
  distance?: number;
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
  pharmacyId: number;
  pharmacyName: string;
  wilaya: string;
  phone: string;
  isOnDutyTonight: boolean;
  inStock: boolean;
  price: number | null;
  distance?: number; // km, only if location provided
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
  reply:             string;
  usage:             string;
  contraindications: string;
  dosage:            string;
  sideEffects:       string;
  pregnancy:         string;
  interactions:      string;
  warnings:          string;
  foundInDb:         boolean;
  dbData?: {
    name:                 string;
    genericName:          string | null;
    price:                number | null;
    requiresPrescription: boolean;
    category:             string | null;
    dosageForm:           string | null;
    strength:             string | null;
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
  id: number;
  email: string;
  role: 'patient' | 'pharmacy' | 'doctor';
  iat?: number;
  exp?: number;
}