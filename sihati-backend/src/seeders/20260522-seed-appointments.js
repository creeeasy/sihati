// 20260522-seed-appointments.js
"use strict";

module.exports = {
  async up(queryInterface, Sequelize) {
    const now = new Date();

    // Guard: skip if already seeded
    const existing = await queryInterface.sequelize.query(
      `SELECT id FROM appointments WHERE reason = 'Consultation de suivi (seed)' LIMIT 1`,
      { type: queryInterface.sequelize.QueryTypes.SELECT },
    );
    if (existing.length > 0) {
      console.log("⚠️  Seed appointments already applied, skipping.");
      return;
    }

    // ============================================
    // APPOINTMENTS — explicit UUIDs
    // ============================================

    const appointments = [
      // Ahmed Benali — upcoming
      {
        id: "e0e00001-0000-0000-0000-000000000001",
        patient_id: "11111111-1111-1111-1111-111111111111",
        doctor_id: "22222222-2222-2222-2222-222222222222",
        appointment_date: new Date(now.getTime() + 1 * 24 * 60 * 60 * 1000),
        appointment_time: "10:00",
        status: "pending",
        reason: "Consultation de suivi (seed)",
        notes: null,
        created_at: now,
        updated_at: now,
      },
      {
        id: "e0e00002-0000-0000-0000-000000000002",
        patient_id: "11111111-1111-1111-1111-111111111111",
        doctor_id: "22222222-2222-2222-2222-222222222222",
        appointment_date: new Date(now.getTime() + 5 * 24 * 60 * 60 * 1000),
        appointment_time: "15:30",
        status: "confirmed",
        reason: "Résultats d'analyses (seed)",
        notes: "Apporter le bilan sanguin",
        created_at: now,
        updated_at: now,
      },
      {
        id: "e0e00003-0000-0000-0000-000000000003",
        patient_id: "11111111-1111-1111-1111-111111111111",
        doctor_id: "22222222-2222-2222-2222-222222222222",
        appointment_date: new Date(now.getTime() - 10 * 24 * 60 * 60 * 1000),
        appointment_time: "09:00",
        status: "completed",
        reason: "Consultation initiale (seed)",
        notes: null,
        created_at: new Date(now.getTime() - 15 * 24 * 60 * 60 * 1000),
        updated_at: new Date(now.getTime() - 10 * 24 * 60 * 60 * 1000),
      },
      {
        id: "e0e00004-0000-0000-0000-000000000004",
        patient_id: "11111111-1111-1111-1111-111111111111",
        doctor_id: "22222222-2222-2222-2222-222222222222",
        appointment_date: new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000),
        appointment_time: "11:00",
        status: "cancelled",
        reason: "Douleurs abdominales (seed)",
        notes: null,
        cancelled_at: new Date(now.getTime() - 31 * 24 * 60 * 60 * 1000),
        cancelled_by: "11111111-1111-1111-1111-111111111111",
        cancellation_reason: "Patient indisponible",
        created_at: new Date(now.getTime() - 35 * 24 * 60 * 60 * 1000),
        updated_at: new Date(now.getTime() - 31 * 24 * 60 * 60 * 1000),
      },
      // Test Patient — upcoming
      {
        id: "e0e00005-0000-0000-0000-000000000005",
        patient_id: "fd355685-3476-4e51-8585-5bb6b150cdc3",
        doctor_id: "22222222-2222-2222-2222-222222222222",
        appointment_date: new Date(now.getTime() + 3 * 24 * 60 * 60 * 1000),
        appointment_time: "14:00",
        status: "pending",
        reason: "Première consultation (seed)",
        notes: "Nouveau patient",
        created_at: now,
        updated_at: now,
      },
      {
        id: "e0e00006-0000-0000-0000-000000000006",
        patient_id: "fd355685-3476-4e51-8585-5bb6b150cdc3",
        doctor_id: "22222222-2222-2222-2222-222222222222",
        appointment_date: new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000),
        appointment_time: "16:00",
        status: "confirmed",
        reason: "Suivi (seed)",
        notes: null,
        created_at: now,
        updated_at: now,
      },
      // Test Patient — past
      {
        id: "e0e00007-0000-0000-0000-000000000007",
        patient_id: "fd355685-3476-4e51-8585-5bb6b150cdc3",
        doctor_id: "22222222-2222-2222-2222-222222222222",
        appointment_date: new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000),
        appointment_time: "10:30",
        status: "completed",
        reason: "Migraine (seed)",
        notes: "Prescrit Doliprane",
        created_at: new Date(now.getTime() - 10 * 24 * 60 * 60 * 1000),
        updated_at: new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000),
      },
      {
        id: "e0e00008-0000-0000-0000-000000000008",
        patient_id: "fd355685-3476-4e51-8585-5bb6b150cdc3",
        doctor_id: "22222222-2222-2222-2222-222222222222",
        appointment_date: new Date(now.getTime() - 14 * 24 * 60 * 60 * 1000),
        appointment_time: "08:30",
        status: "no_show",
        reason: "Consultation urgente (seed)",
        notes: "Patient ne s'est pas présenté",
        created_at: new Date(now.getTime() - 16 * 24 * 60 * 60 * 1000),
        updated_at: new Date(now.getTime() - 14 * 24 * 60 * 60 * 1000),
      },
    ];

    await queryInterface.bulkInsert("appointments", appointments, {});

    console.log("✅ Seed Appointments terminé !");
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.bulkDelete(
      "appointments",
      {
        id: [
          "e0e00001-0000-0000-0000-000000000001",
          "e0e00002-0000-0000-0000-000000000002",
          "e0e00003-0000-0000-0000-000000000003",
          "e0e00004-0000-0000-0000-000000000004",
          "e0e00005-0000-0000-0000-000000000005",
          "e0e00006-0000-0000-0000-000000000006",
          "e0e00007-0000-0000-0000-000000000007",
          "e0e00008-0000-0000-0000-000000000008",
        ],
      },
      {},
    );
    console.log("✅ Seed Appointments annulé");
  },
};
