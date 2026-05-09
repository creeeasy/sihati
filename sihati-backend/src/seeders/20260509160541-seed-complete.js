"use strict";
const bcrypt = require("bcrypt");

module.exports = {
  async up(queryInterface, Sequelize) {
    const now = new Date();
    const hashedPassword = await bcrypt.hash("Password123", 10);

    // 1. SPÉCIALITÉS
    await queryInterface.bulkInsert(
      "specialties",
      [
        {
          id: "11111111-1111-1111-1111-111111111101",
          name_fr: "Médecine Générale",
          name_ar: "الطب العام",
          icon: "stethoscope",
          created_at: now,
          updated_at: now,
        },
        {
          id: "11111111-1111-1111-1111-111111111102",
          name_fr: "Cardiologie",
          name_ar: "طب القلب",
          icon: "heart",
          created_at: now,
          updated_at: now,
        },
        {
          id: "11111111-1111-1111-1111-111111111103",
          name_fr: "Dermatologie",
          name_ar: "طب الجلد",
          icon: "skin",
          created_at: now,
          updated_at: now,
        },
        {
          id: "11111111-1111-1111-1111-111111111104",
          name_fr: "Pédiatrie",
          name_ar: "طب الأطفال",
          icon: "baby",
          created_at: now,
          updated_at: now,
        },
        {
          id: "11111111-1111-1111-1111-111111111105",
          name_fr: "Gynécologie",
          name_ar: "أمراض النساء",
          icon: "female",
          created_at: now,
          updated_at: now,
        },
      ],
      {},
    );

    // 2. UTILISATEURS
    await queryInterface.bulkInsert(
      "users",
      [
        {
          id: "22222222-2222-2222-2222-222222222222",
          email: "dr.benali@test.com",
          password: hashedPassword,
          full_name: "Dr. Mehdi Benali",
          phone_number: "0555123457",
          role: "doctor",
          is_active: true,
          is_verified: true,
          created_at: now,
          updated_at: now,
        },
        {
          id: "11111111-1111-1111-1111-111111111111",
          email: "patient@test.com",
          password: hashedPassword,
          full_name: "Ahmed Benali",
          phone_number: "0555123456",
          chifa_number: "1234567890123",
          role: "patient",
          is_active: true,
          is_verified: true,
          created_at: now,
          updated_at: now,
        },
        {
          id: "fd355685-3476-4e51-8585-5bb6b150cdc3",
          email: "test.patient@test.com",
          password: hashedPassword,
          full_name: "Test Patient",
          phone_number: "0555987654",
          chifa_number: "12345678901234",
          role: "patient",
          is_active: true,
          is_verified: true,
          created_at: now,
          updated_at: now,
        },
      ],
      {},
    );

    // 3. PROFIL DOCTEUR (doctor_id = dddddddd-dddd-dddd-dddd-dddddddddddd)
    await queryInterface.bulkInsert(
      "doctors",
      [
        {
          id: "dddddddd-dddd-dddd-dddd-dddddddddddd",
          user_id: "22222222-2222-2222-2222-222222222222",
          specialty_id: "11111111-1111-1111-1111-111111111101",
          doctor_name: "Dr. Mehdi Benali",
          clinic_name: "Clinique El Djazair",
          clinic_address: "15 Rue Larbi Ben Mhidi",
          wilaya: "Alger",
          commune: "Sidi M'hamed",
          latitude: 36.7638,
          longitude: 3.0488,
          phone: "+213551234567",
          whatsapp_number: "+213551234567",
          consultation_fee: 2500,
          years_of_experience: 12,
          bio: "Médecin généraliste expérimenté",
          average_rating: 4.8,
          total_reviews: 45,
          is_verified: true,
          created_at: now,
          updated_at: now,
        },
      ],
      {},
    );

    // 4. HORAIRES
    await queryInterface.sequelize.query(`
      INSERT INTO doctor_schedules (id, doctor_id, day_of_week, start_time, end_time, is_available, created_at, updated_at)
      VALUES 
        (gen_random_uuid(), 'dddddddd-dddd-dddd-dddd-dddddddddddd', 1, '09:00', '17:00', true, NOW(), NOW()),
        (gen_random_uuid(), 'dddddddd-dddd-dddd-dddd-dddddddddddd', 2, '09:00', '17:00', true, NOW(), NOW()),
        (gen_random_uuid(), 'dddddddd-dddd-dddd-dddd-dddddddddddd', 3, '09:00', '17:00', true, NOW(), NOW()),
        (gen_random_uuid(), 'dddddddd-dddd-dddd-dddd-dddddddddddd', 4, '09:00', '17:00', true, NOW(), NOW()),
        (gen_random_uuid(), 'dddddddd-dddd-dddd-dddd-dddddddddddd', 5, '09:00', '17:00', true, NOW(), NOW());
    `);

    // 5. CONSULTATIONS
    await queryInterface.sequelize.query(`
      INSERT INTO consultations (id, patient_id, doctor_id, consultation_date, chief_complaint, diagnosis, treatment_plan, notes, fee_paid, created_at, updated_at)
      VALUES 
        (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', NOW() - INTERVAL '30 days', 'Douleurs abdominales', 'Gastrite aiguë', 'Repos, antiacides', 'Patient à revoir dans 7 jours', 2500, NOW(), NOW()),
        (gen_random_uuid(), 'fd355685-3476-4e51-8585-5bb6b150cdc3', '22222222-2222-2222-2222-222222222222', NOW() - INTERVAL '15 days', 'Maux de tête', 'Migraine', 'Doliprane 1000mg si besoin', 'Stress au travail', 2500, NOW(), NOW());
    `);

    // 6. PRESCRIPTIONS
    await queryInterface.sequelize.query(`
      INSERT INTO prescriptions (id, patient_id, doctor_id, consultation_id, prescription_date, diagnosis, notes, validity_days, is_renewable, created_at, updated_at)
      SELECT 
        gen_random_uuid(), 
        '11111111-1111-1111-1111-111111111111', 
        'dddddddd-dddd-dddd-dddd-dddddddddddd', 
        id, 
        NOW(), 
        'Gastrite aiguë', 
        'Traitement pour 7 jours', 
        30, 
        true, 
        NOW(), 
        NOW()
      FROM consultations WHERE patient_id = '11111111-1111-1111-1111-111111111111' LIMIT 1;
    `);

    // 7. MÉDICAMENTS
    await queryInterface.sequelize.query(`
      INSERT INTO prescription_medications (id, prescription_id, medication_name, dosage, frequency, duration_days, quantity, instructions, created_at, updated_at)
      SELECT 
        gen_random_uuid(),
        id,
        'Oméprazole 20mg',
        '1 gélule',
        '1x par jour, le matin',
        7,
        7,
        'À prendre avant le petit-déjeuner',
        NOW(),
        NOW()
      FROM prescriptions WHERE patient_id = '11111111-1111-1111-1111-111111111111' LIMIT 1;
    `);

    // 8. RENDEZ-VOUS
    await queryInterface.sequelize.query(`
      INSERT INTO appointments (id, patient_id, doctor_id, appointment_date, appointment_time, status, reason, created_at, updated_at)
      VALUES 
        (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', NOW() + INTERVAL '1 day', '10:00', 'pending', 'Consultation de suivi', NOW(), NOW()),
        (gen_random_uuid(), 'fd355685-3476-4e51-8585-5bb6b150cdc3', '22222222-2222-2222-2222-222222222222', NOW() + INTERVAL '2 days', '14:30', 'confirmed', 'Première consultation', NOW(), NOW());
    `);

    // 9. ALLERGIES
    await queryInterface.sequelize.query(`
      INSERT INTO patient_allergies (id, patient_id, allergy_name, allergy_type, severity, reaction, declared_at, created_at, updated_at)
      VALUES 
        (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'Pénicilline', 'medication', 'severe', 'Éruption cutanée, difficultés respiratoires', NOW(), NOW(), NOW()),
        (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'Arachides', 'food', 'moderate', 'Urticaire, gonflement des lèvres', NOW(), NOW(), NOW());
    `);

    // 10. AVIS
    await queryInterface.sequelize.query(`
      INSERT INTO reviews (id, user_id, doctor_id, rating, comment, created_at, updated_at)
      VALUES 
        (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'dddddddd-dddd-dddd-dddd-dddddddddddd', 5, 'Excellent médecin, très à l''écoute !', NOW(), NOW()),
        (gen_random_uuid(), 'fd355685-3476-4e51-8585-5bb6b150cdc3', 'dddddddd-dddd-dddd-dddd-dddddddddddd', 4, 'Très professionnel.', NOW(), NOW());
    `);

    // 11. FILE D'ATTENTE
    await queryInterface.sequelize.query(`
      INSERT INTO waiting_queues (id, doctor_id, patient_id, status, priority, position, arrived_at, started_at, estimated_wait_minutes, notes, created_at, updated_at)
      VALUES 
        (gen_random_uuid(), 'dddddddd-dddd-dddd-dddd-dddddddddddd', '11111111-1111-1111-1111-111111111111', 'in_consultation', 1, 1, NOW(), NOW(), 0, 'Consultation de suivi', NOW(), NOW()),
        (gen_random_uuid(), 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'fd355685-3476-4e51-8585-5bb6b150cdc3', 'waiting', 0, 2, NOW() - INTERVAL '10 minutes', NULL, 15, 'URGENCE', NOW(), NOW());
    `);

    console.log("✅ Seed complet exécuté avec succès !");
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.bulkDelete("waiting_queues", null, {});
    await queryInterface.bulkDelete("prescription_medications", null, {});
    await queryInterface.bulkDelete("prescriptions", null, {});
    await queryInterface.bulkDelete("consultations", null, {});
    await queryInterface.bulkDelete("appointments", null, {});
    await queryInterface.bulkDelete("doctor_schedules", null, {});
    await queryInterface.bulkDelete("reviews", null, {});
    await queryInterface.bulkDelete("patient_allergies", null, {});
    await queryInterface.bulkDelete("doctors", null, {});
    await queryInterface.bulkDelete("users", null, {});
    await queryInterface.bulkDelete("specialties", null, {});
  },
};
