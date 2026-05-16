# Sihati Backend — Model Cleanup Changelog

> **Database:** `sihati_db_v3` (fresh, clean slate — `sihati_db_v2` untouched)  
> **Scope:** Models, Migrations, Controllers, Services, Seeders, Types, Validators

---

## 1. New Database

A new PostgreSQL database `sihati_db_v3` was created and the `.env` file updated:

```diff
-DB_NAME=sihati_db_v2
+DB_NAME=sihati_db_v3
```

All 24 migrations ran clean on the new DB. Both seeders ran successfully.

---

## 2. Fields Removed — Summary

| Model | Field(s) Removed | Reason |
|---|---|---|
| `User` | `isActive`, `fcmToken` | No deactivation logic; no push notifications |
| `MedicationHistory` | `isActive`, `adherenceRate` | Derive active status from `endDate`; analytics field never used |
| `MedicationReminder` | `isActive` | Delete the row instead of soft-deactivating |
| `Doctor` | `workingHours` | Duplicate of `DoctorSchedule` model |
| `Consultation` | `durationMinutes`, `feePaid` | Billing/admin concern out of scope |
| `Appointment` | `consultationFee` | Already on `Doctor.consultationFee` |
| `MedicalDocument` | `uploadedAt` | Redundant — `createdAt` does the same thing |
| `PatientProfile` | `address`, `wilaya`, `commune` | Already on `User` — two sources of truth |
| `Conversation` | `context` | JSONB with no defined schema, never populated |

---

## 3. Files Changed

### Models (`src/models/`)
| File | Changes |
|---|---|
| `User.ts` | Removed `isActive`, `fcmToken` from interface, class, and `init()` |
| `MedicationHistory.ts` | Removed `isActive`, `adherenceRate`; removed `is_active` index |
| `MedicationReminder.ts` | Removed `isActive`; removed `is_active` index |
| `Doctor.ts` | Removed `workingHours` |
| `Consultation.ts` | Removed `durationMinutes`, `feePaid`; **fixed `associate()`** — `doctorId` now correctly uses `User` model (not `Doctor`) since FK references `users.id` |
| `Appointment.ts` | Removed `consultationFee` |
| `MedicalDocument.ts` | Removed `uploadedAt` |
| `PatientProfile.ts` | Removed `address`, `wilaya`, `commune` |
| `Conversation.ts` | Removed `context` |

### Migrations (`src/migrations/`)
| File | Changes |
|---|---|
| `01-create-users.js` | Removed `is_active`, `fcm_token` columns |
| `03-create-doctors.js` | Removed `working_hours` column |
| `09-create-patient_profiles.js` | Removed `address`, `wilaya`, `commune` columns |
| `10-create-appointments.js` | Removed `consultation_fee` column |
| `11-create-consultations.js` | Removed `duration_minutes`, `fee_paid` columns |
| `14-create-medical_documents.js` | Removed `uploaded_at` column |
| `17-create-conversations.js` | Removed `context` column |
| `20-create-medication_histories.js` | Removed `is_active`, `adherence_rate` columns + `is_active` index |
| `21-create-medication_reminders.js` | Removed `is_active` column + `is_active` index |

### Services (`src/services/`)
| File | Changes |
|---|---|
| `authService.ts` | Removed 3 `user.isActive` guards (login, refreshToken, verifyToken) |
| `appointmentService.ts` | Removed `consultationFee` parameter from `createAppointment()` |
| `patientService.ts` | Removed `uploadedAt` from `addDocument()`; fixed `getConsultations()` and `getConsultationById()` to use `User as 'doctor'` (matches updated association) |

### Controllers (`src/controllers/`)
| File | Changes |
|---|---|
| `consultationController.ts` | Removed `durationMinutes`, `feePaid` from request destructure and `Consultation.create()`; fixed `getPatientConsultations()` and `getConsultationById()` to use `User as 'doctor'` |

### Seeders (`src/seeders/`)
| File | Changes |
|---|---|
| `20260509160541-seed-complete.js` | Removed `is_active` from 3 user records; removed `fee_paid` from consultations raw INSERT |
| `20260509160542-seed-pharmacy.js` | Removed `is_active` and `fcm_token` from all 5 pharmacy user records |

### Types & Validators
| File | Changes |
|---|---|
| `src/types/index.ts` | Removed `workingHours` from `DoctorCreateDTO`/`DoctorUpdateDTO`; `consultationFee` from `AppointmentCreateDTO`; `durationMinutes`/`feePaid` from `ConsultationCreateDTO`; `address`/`wilaya`/`commune` from `PatientProfileDTO` |
| `src/validators/doctorValidator.ts` | Removed `workingHours` from `validateCreate` and `validateUpdate` Joi schemas |

---

## 4. Association Bug Fixed

**`Consultation.associate()`** was importing `Doctor` but the FK `doctor_id` references `users.id` (not `doctors.id`). Fixed to:

```ts
// Before (bug)
const { User, Doctor, Appointment, Prescription } = sequelize.models;
Consultation.belongsTo(Doctor, { foreignKey: 'doctorId', as: 'doctor' });

// After (correct)
const { User, Appointment, Prescription } = sequelize.models;
Consultation.belongsTo(User, { foreignKey: 'doctorId', as: 'doctor' }); // ✅ doctorId → users.id
```

The same fix was propagated to every controller/service that did `include: [{ model: Doctor, as: 'doctor' }]` for consultations — they now use `User as 'doctor'` instead.

---

## 5. Final Verification

```
✅ 24 migrations ran clean on sihati_db_v3
✅ 2 seeders executed with no errors
✅ 0 stale field references remaining across entire src/ directory
✅ consultations.doctor_id → users(id) FK confirmed in DB
```

### Test Credentials (after seeding)

| Role | Email | Password |
|---|---|---|
| Doctor | `dr.benali@test.com` | `Password123` |
| Patient | `patient@test.com` | `Password123` |
| Patient | `test.patient@test.com` | `Password123` |
| Pharmacy | `pharmacie.centrale@sihati.dz` | `password123` |
| Pharmacy | `pharmacie.ennour@sihati.dz` | `password123` |
| Pharmacy | `pharmacie.elafdal@sihati.dz` | `password123` |
| Pharmacy | `pharmacie.elwafa@sihati.dz` | `password123` |
| Pharmacy | `pharmacie.elhidjab@sihati.dz` | `password123` |

---

## 6. What Was NOT Changed

The following fields looked suspicious but are intentionally kept:

| Field | Model | Why kept |
|---|---|---|
| `isVerified` | `User`, `Doctor`, `Pharmacy` | Email/admin verification flow |
| `lastLogin` | `User` | Simple audit field |
| `isAvailable` | `DoctorSchedule` | Lets doctor block a day without deleting |
| `isOnDutyTonight` | `Pharmacy` | Core pharmacy duty feature |
| `isRenewable` | `Prescription` | Simple flag, makes sense |
| `inStock` | `PharmacyMedication` | Core pharmacy feature |
| `cancelledAt`, `cancelledBy`, `cancellationReason` | `Appointment` | Kept as a unit — useful for cancellation history |
| `consultationFee` | `Doctor` | Kept here — this is the single source of truth |
