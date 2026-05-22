README:
markdown

# Sihati Mobile — Backend Integration

## Overview

The Sihati backend is a **Node.js/Express/TypeScript + Sequelize** API deployed at  
`https://sihati-1.onrender.com/api`.

The Flutter mobile app uses **GetX** with this architecture:
Controller (GetX)
↓
Repository (business logic + error handling)
↓
Provider (HTTP calls via ApiService/Dio)
↓
ApiService (Dio + JWT interceptor + auto-refresh)
↓
Backend

text

---

## Environment

**Base URL:** `lib/app/constants/api_constants.dart`

```dart
static const String BASE_URL = 'https://sihati-1.onrender.com/api';
JWT: ApiService interceptor auto-attaches token. No manual token passing in providers.

Providers (lib/data/providers/)
Provider	Routes	Status
auth_provider.dart	/auth/register, /auth/login, /auth/profile, /auth/profile/chifa, /auth/logout	✅
appointment_provider.dart	/appointments/patient/:id, /appointments/:id, /appointments, /appointments/:id/cancel, /doctors/:id/available-slots	✅
patient_provider.dart	/patient/profile, /patient/prescriptions, /patient/consultations, /patient/documents, /patient/allergies, /patient/stats	✅
doctor_provider.dart	/doctors, /doctors/:id, /doctors/search, /doctors/top-rated, /doctors/specialties	✅
pharmacy_provider.dart	/pharmacies, /pharmacies/:id, /pharmacies/nearby, /pharmacies/duty	✅
medication_provider.dart	/medications, /medications/:id, /medications/search, /medications/popular, /medications/barcode, /medications/:id/pharmacies	✅
favorite_provider.dart	/favorites/doctors, /favorites/pharmacies, /favorites/stats	✅
ai_provider.dart	/ai/interaction, /ai/chat	✅
Repositories (lib/data/repositories/)
Repository	Provider	Status
auth_repository.dart	AuthProvider	✅
appointment_repository.dart	AppointmentProvider	✅
patient_repository.dart	PatientProvider	✅
doctor_repository.dart	DoctorProvider	✅
pharmacy_repository.dart	PharmacyProvider	✅
medication_repository.dart	MedicationProvider	✅
favorite_repository.dart	FavoriteProvider	✅
ai_repository.dart	AiProvider	✅
Models (lib/core/models/)
Model	Backend Table	Status
user_model.dart	users	✅
patient_profile_model.dart	patient_profiles	✅
doctor_model.dart	doctors	✅
specialty_model.dart	specialties	✅
pharmacy_model.dart	pharmacies	✅
medication_model.dart	medications	✅
medication_search_result.dart	/medications/search response	✅
pharmacy_with_stock.dart	/medications/:id/pharmacies response	✅
appointment_model.dart	appointments	✅
prescription_model.dart	prescriptions	✅
consultation_model.dart	consultations	✅
medical_document_model.dart	documents	✅
medication_history_model.dart	medication_histories	✅
allergy_model.dart	patient_allergies	✅
auth_response.dart	Auth wrapper	✅
api_response.dart	Generic wrapper	✅
Auth Flow
text
Register (POST /auth/register, role: 'patient')
    → User created + PatientProfile auto-created
    ↓
Login (POST /auth/login, role: 'patient')
    → Backend validates email + password + role
    → Returns accessToken + refreshToken
    ↓
ApiService interceptor attaches Authorization header
    ↓
Token expired → auto-refresh via /auth/refresh-token
    ↓
Logout → revoke refresh token, clear local state
Key Design Decisions
Patient-only app — doctor/pharmacy specific endpoints excluded

Client-side appointment filtering — backend returns all appointments, filtered by isUpcoming/isPast in repository

No reschedule endpoint — backend has no /appointments/:id/reschedule

Medication history from prescriptions — no dedicated endpoint, extracted client-side

isActive removed — backend doesn't provide this field

Favorites backend-synced — not local GetStorage

getProfile() no token param — JWT handled by interceptor

updateProfile()/updateChifaNumber() no userId param — backend uses JWT

Login sends role: 'patient' — backend enforces role on login

PatientProfile auto-created on register — backend creates row with optional fields

Not Yet Wired
Feature	Route
Change password	/auth/change-password
Forgot/reset password	/auth/forgot-password, /auth/reset-password
Email verification	/auth/verify-email
AI medication info	/ai/medication-info
AI specialty suggestion	/ai/specialty
AI ask medication	/ai/ask-medication
AI history	/ai/history
Waiting queue	/waiting-queue
Doctor reviews	/reviews
text

Save as `README.md` in `sihati_mobile/`.
```
