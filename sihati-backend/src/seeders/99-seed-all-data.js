"use strict";
const crypto = require("crypto");
const bcrypt = require("bcrypt");

module.exports = {
  async up(queryInterface, Sequelize) {
    const now = new Date();
    const hashedPassword = await bcrypt.hash("Password123", 10);

    // ============================================
    // 1. SPÉCIALITÉS
    // ============================================
    const specialties = [
      {
        id: "11111111-1111-1111-1111-111111111101",
        name_fr: "Médecine Générale",
        name_ar: "الطب العام",
        icon: "stethoscope",
        description: "Médecin généraliste",
        created_at: now,
        updated_at: now,
      },
      {
        id: "11111111-1111-1111-1111-111111111102",
        name_fr: "Cardiologie",
        name_ar: "طب القلب",
        icon: "heart",
        description: "Spécialiste du cœur",
        created_at: now,
        updated_at: now,
      },
      {
        id: "11111111-1111-1111-1111-111111111103",
        name_fr: "Dermatologie",
        name_ar: "طب الجلد",
        icon: "skin",
        description: "Spécialiste de la peau",
        created_at: now,
        updated_at: now,
      },
      {
        id: "11111111-1111-1111-1111-111111111104",
        name_fr: "Pédiatrie",
        name_ar: "طب الأطفال",
        icon: "baby",
        description: "Spécialiste des enfants",
        created_at: now,
        updated_at: now,
      },
      {
        id: "11111111-1111-1111-1111-111111111105",
        name_fr: "Gynécologie",
        name_ar: "أمراض النساء",
        icon: "female",
        description: "Spécialiste des femmes",
        created_at: now,
        updated_at: now,
      },
    ];
    await queryInterface.bulkInsert("specialties", specialties, {});

    // ============================================
    // 2. UTILISATEURS
    // ============================================
    const users = [
      {
        id: "11111111-1111-1111-1111-111111111111",
        email: "patient@test.com",
        password: hashedPassword,
        full_name: "Ahmed Benali",
        phone_number: "0555123456",
        role: "patient",
        is_active: true,
        is_verified: true,
        wilaya: "Alger",
        address: "123 Rue Didouche Mourad",
        chifa_number: "1234567890123",
        created_at: now,
        updated_at: now,
      },
      {
        id: "22222222-2222-2222-2222-222222222222",
        email: "dr.benali@test.com",
        password: hashedPassword,
        full_name: "Dr. Mehdi Benali",
        phone_number: "0555123457",
        role: "doctor",
        is_active: true,
        is_verified: true,
        wilaya: "Alger",
        created_at: now,
        updated_at: now,
      },
      {
        id: "33333333-3333-3333-3333-333333333333",
        email: "dr.zeroual@test.com",
        password: hashedPassword,
        full_name: "Dr. Amina Zeroual",
        phone_number: "0555123458",
        role: "doctor",
        is_active: true,
        is_verified: true,
        wilaya: "Alger",
        created_at: now,
        updated_at: now,
      },
      {
        id: "44444444-4444-4444-4444-444444444444",
        email: "dr.mansouri@test.com",
        password: hashedPassword,
        full_name: "Dr. Sarah Mansouri",
        phone_number: "0555123459",
        role: "doctor",
        is_active: true,
        is_verified: true,
        wilaya: "Oran",
        created_at: now,
        updated_at: now,
      },
      {
        id: "55555555-5555-5555-5555-555555555555",
        email: "dr.khelifi@test.com",
        password: hashedPassword,
        full_name: "Dr. Karim Khelifi",
        phone_number: "0555123460",
        role: "doctor",
        is_active: true,
        is_verified: true,
        wilaya: "Constantine",
        created_at: now,
        updated_at: now,
      },
    ];
    await queryInterface.bulkInsert("users", users, {});

    // ============================================
    // 3. DOCTORS
    // ============================================
    const doctors = [
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
      {
        id: "eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee",
        user_id: "33333333-3333-3333-3333-333333333333",
        specialty_id: "11111111-1111-1111-1111-111111111102",
        doctor_name: "Dr. Amina Zeroual",
        clinic_name: "Clinique du Cœur",
        clinic_address: "8 Boulevard Colonel Bougara",
        wilaya: "Alger",
        commune: "El Biar",
        latitude: 36.7738,
        longitude: 3.0388,
        phone: "+213551234568",
        whatsapp_number: "+213551234568",
        consultation_fee: 4000,
        years_of_experience: 15,
        bio: "Cardiologue renommée",
        average_rating: 4.9,
        total_reviews: 78,
        is_verified: true,
        created_at: now,
        updated_at: now,
      },
      {
        id: "ffffffff-ffff-ffff-ffff-ffffffffffff",
        user_id: "44444444-4444-4444-4444-444444444444",
        specialty_id: "11111111-1111-1111-1111-111111111103",
        doctor_name: "Dr. Sarah Mansouri",
        clinic_name: "Centre de Dermatologie",
        clinic_address: "45 Rue des Frères Bouadou",
        wilaya: "Oran",
        commune: "El Hamri",
        latitude: 35.7038,
        longitude: -0.6412,
        phone: "+213551234569",
        whatsapp_number: "+213551234569",
        consultation_fee: 3500,
        years_of_experience: 8,
        bio: "Dermatologue spécialisée",
        average_rating: 4.7,
        total_reviews: 32,
        is_verified: true,
        created_at: now,
        updated_at: now,
      },
      {
        id: "1111aaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
        user_id: "55555555-5555-5555-5555-555555555555",
        specialty_id: "11111111-1111-1111-1111-111111111104",
        doctor_name: "Dr. Karim Khelifi",
        clinic_name: "Clinique Enfants Santé",
        clinic_address: "30 Avenue de l'ALN",
        wilaya: "Constantine",
        commune: "Ville Nouvelle",
        latitude: 36.3638,
        longitude: 6.6138,
        phone: "+213551234570",
        whatsapp_number: "+213551234570",
        consultation_fee: 3000,
        years_of_experience: 10,
        bio: "Pédiatre passionné",
        average_rating: 4.8,
        total_reviews: 56,
        is_verified: true,
        created_at: now,
        updated_at: now,
      },
    ];
    await queryInterface.bulkInsert("doctors", doctors, {});

    // ============================================
    // 4. PHARMACIES (avec JSONB valide)
    // ============================================
    const pharmacies = [
      {
        id: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
        pharmacy_name: "Pharmacie Centrale",
        address: "123 Rue Didouche Mourad",
        wilaya: "Alger",
        commune: "Alger Centre",
        latitude: 36.7638,
        longitude: 3.0488,
        phone: "+213551234571",
        whatsapp_number: "+213551234571",
        is_on_duty_tonight: true,
        is_verified: true,
        opening_hours: JSON.stringify({
          monday: { open: "09:00", close: "18:00" },
        }),
        created_at: now,
        updated_at: now,
      },
      {
        id: "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb",
        pharmacy_name: "Pharmacie Benamor",
        address: "45 Boulevard Krim Belkacem",
        wilaya: "Alger",
        commune: "Hydra",
        latitude: 36.7538,
        longitude: 3.0588,
        phone: "+213551234572",
        whatsapp_number: "+213551234572",
        is_on_duty_tonight: false,
        is_verified: true,
        opening_hours: JSON.stringify({
          monday: { open: "08:30", close: "19:00" },
        }),
        created_at: now,
        updated_at: now,
      },
      {
        id: "cccccccc-cccc-cccc-cccc-cccccccccccc",
        pharmacy_name: "Pharmacie La Santé",
        address: "8 Rue Larbi Ben Mhidi",
        wilaya: "Alger",
        commune: "Sidi M'hamed",
        latitude: 36.7638,
        longitude: 3.0388,
        phone: "+213551234573",
        is_on_duty_tonight: false,
        is_verified: true,
        created_at: now,
        updated_at: now,
      },
      {
        id: "dddddddd-dddd-dddd-dddd-dddddddddddd",
        pharmacy_name: "Pharmacie de l'Oued",
        address: "12 Rue Khemisti",
        wilaya: "Oran",
        commune: "El Hamri",
        latitude: 35.6938,
        longitude: -0.6512,
        phone: "+213551234574",
        whatsapp_number: "+213551234574",
        is_on_duty_tonight: true,
        is_verified: true,
        opening_hours: JSON.stringify({
          monday: { open: "08:00", close: "20:00" },
        }),
        created_at: now,
        updated_at: now,
      },
    ];
    await queryInterface.bulkInsert("pharmacies", pharmacies, {});

    // ============================================
    // 5. MÉDICAMENTS
    // ============================================
    const medications = [
      {
        id: "99999999-9999-9999-9999-999999999901",
        name: "Doliprane 1000mg",
        generic_name: "Paracétamol",
        dci: "Paracétamol",
        form: "Comprimé",
        dosage: "1000 mg",
        category: "Antalgique",
        manufacturer: "Sanofi",
        requires_prescription: false,
        created_at: now,
        updated_at: now,
      },
      {
        id: "99999999-9999-9999-9999-999999999902",
        name: "Nurofen 400mg",
        generic_name: "Ibuprofène",
        dci: "Ibuprofène",
        form: "Comprimé",
        dosage: "400 mg",
        category: "Anti-inflammatoire",
        manufacturer: "Reckitt",
        requires_prescription: false,
        created_at: now,
        updated_at: now,
      },
      {
        id: "99999999-9999-9999-9999-999999999903",
        name: "Aspirine 100mg",
        generic_name: "Acide acétylsalicylique",
        dci: "Acide acétylsalicylique",
        form: "Comprimé",
        dosage: "100 mg",
        category: "Anti-coagulant",
        manufacturer: "Bayer",
        requires_prescription: false,
        created_at: now,
        updated_at: now,
      },
      {
        id: "99999999-9999-9999-9999-999999999904",
        name: "Amoxicilline 500mg",
        generic_name: "Amoxicilline",
        dci: "Amoxicilline",
        form: "Gélule",
        dosage: "500 mg",
        category: "Antibiotique",
        manufacturer: "GSK",
        requires_prescription: true,
        created_at: now,
        updated_at: now,
      },
    ];
    await queryInterface.bulkInsert("medications", medications, {});

    // ============================================
    // 6. STOCKS PHARMACIES
    // ============================================
    for (const med of medications) {
      for (const pharm of pharmacies) {
        await queryInterface.bulkInsert(
          "pharmacy_medications",
          [
            {
              id: crypto.randomUUID(),
              pharmacy_id: pharm.id,
              medication_id: med.id,
              in_stock: true,
              quantity: Math.floor(Math.random() * 100) + 1,
              price: Math.floor(Math.random() * 500) + 100,
              last_updated: now,
              created_at: now,
              updated_at: now,
            },
          ],
          {},
        );
      }
    }

    // ============================================
    // 7. HORAIRES MÉDECINS
    // ============================================
    const schedules = [
      {
        id: crypto.randomUUID(),
        doctor_id: "dddddddd-dddd-dddd-dddd-dddddddddddd",
        day_of_week: 1,
        start_time: "09:00",
        end_time: "12:00",
        is_available: true,
        created_at: now,
        updated_at: now,
      },
      {
        id: crypto.randomUUID(),
        doctor_id: "dddddddd-dddd-dddd-dddd-dddddddddddd",
        day_of_week: 1,
        start_time: "14:00",
        end_time: "17:00",
        is_available: true,
        created_at: now,
        updated_at: now,
      },
      {
        id: crypto.randomUUID(),
        doctor_id: "eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee",
        day_of_week: 1,
        start_time: "10:00",
        end_time: "13:00",
        is_available: true,
        created_at: now,
        updated_at: now,
      },
      {
        id: crypto.randomUUID(),
        doctor_id: "eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee",
        day_of_week: 3,
        start_time: "10:00",
        end_time: "13:00",
        is_available: true,
        created_at: now,
        updated_at: now,
      },
    ];
    await queryInterface.bulkInsert("doctor_schedules", schedules, {});

    console.log("✅ Seed completed successfully!");
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.bulkDelete("pharmacy_medications", null, {});
    await queryInterface.bulkDelete("doctor_schedules", null, {});
    await queryInterface.bulkDelete("medications", null, {});
    await queryInterface.bulkDelete("pharmacies", null, {});
    await queryInterface.bulkDelete("doctors", null, {});
    await queryInterface.bulkDelete("users", null, {});
    await queryInterface.bulkDelete("specialties", null, {});
  },
};
