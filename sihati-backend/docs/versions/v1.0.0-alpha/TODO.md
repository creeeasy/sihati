# 📝 Sihati Backend - TODO List

## 🔴 PRIORITÉ HAUTE (Module Médicaments)

### Medication

- [ ] Créer `medication.routes.ts`
- [ ] Créer `medicationController.ts`
- [ ] Créer `medicationService.ts`
- [ ] Implémenter `GET /medications/search`
- [ ] Implémenter `GET /medications/:id`
- [ ] Implémenter `GET /medications/:id/pharmacies`
- [ ] Implémenter `POST /medications/barcode`

---

## 🟡 PRIORITÉ MOYENNE

### Appointments (Rendez-vous)

- [ ] Créer `appointment.routes.ts`
- [ ] Créer `appointmentController.ts`
- [ ] Créer `appointmentService.ts`
- [ ] Implémenter `GET /appointments`
- [ ] Implémenter `POST /appointments`
- [ ] Implémenter `PUT /appointments/:id/cancel`
- [ ] Implémenter `PUT /appointments/:id/confirm`
- [ ] Implémenter `GET /doctors/:id/available-slots`

### Favorites (Favoris)

- [ ] Créer `favorite.routes.ts`
- [ ] Créer `favoriteController.ts`
- [ ] Créer `favoriteService.ts`
- [ ] Implémenter `GET /favorites/pharmacies`
- [ ] Implémenter `POST /favorites/pharmacies/:id`
- [ ] Implémenter `DELETE /favorites/pharmacies/:id`
- [ ] Implémenter `GET /favorites/doctors`
- [ ] Implémenter `POST /favorites/doctors/:id`
- [ ] Implémenter `DELETE /favorites/doctors/:id`

---

## 🟢 PRIORITÉ BASSE (Fonctionnalités avancées)

### Medical Record (Dossier médical)

- [ ] Créer `patient.routes.ts`
- [ ] Créer `patientController.ts`
- [ ] Créer `patientService.ts`
- [ ] Implémenter `GET /patient/medical-record`
- [ ] Implémenter `GET /patient/prescriptions`
- [ ] Implémenter `GET /patient/consultations`
- [ ] Implémenter `GET /patient/documents`
- [ ] Implémenter `POST /patient/documents`
- [ ] Implémenter `GET /patient/allergies`
- [ ] Implémenter `POST /patient/allergies`
- [ ] Implémenter `DELETE /patient/allergies/:id`

### Reviews (Avis)

- [ ] Créer `review.routes.ts`
- [ ] Créer `reviewController.ts`
- [ ] Créer `reviewService.ts`
- [ ] Implémenter `GET /reviews/:doctorId`
- [ ] Implémenter `POST /reviews`
- [ ] Implémenter `PUT /reviews/:id`
- [ ] Implémenter `DELETE /reviews/:id`

### AI Features (Intelligence Artificielle)

- [ ] Implémenter `POST /ai/chat`
- [ ] Implémenter `POST /ai/medication-info`
- [ ] Implémenter `POST /ai/interaction`
- [ ] Implémenter `POST /ai/specialty`

### Email & Notifications

- [ ] Implémenter email verification
- [ ] Implémenter forgot password / reset password
- [ ] Implémenter push notifications (FCM)

### File Upload (Photos, Documents)

- [ ] Configurer Cloudinary ou AWS S3
- [ ] Implémenter upload profile photo
- [ ] Implémenter upload medical documents

---

## 🧪 Tests

- [ ] Tester tous les endpoints Auth
- [ ] Tester tous les endpoints Doctors
- [ ] Tester tous les endpoints Pharmacies
- [ ] Tester la recherche géographique (distance)
- [ ] Tester le refresh token
- [ ] Tester les rate limits

---

## 🚀 Déploiement

- [ ] Configurer HTTPS (Certbot)
- [ ] Mettre à jour .env en production
- [ ] Sauvegarder la base de données
- [ ] Configurer les backups automatiques
