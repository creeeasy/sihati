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
// JWT Payload
// ============================================================

export interface JwtPayload {
  id: number;
  email: string;
  role: 'patient' | 'pharmacy' | 'doctor';
  iat?: number;
  exp?: number;
}