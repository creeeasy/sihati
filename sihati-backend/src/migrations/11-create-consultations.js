"use strict";

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable("consultations", {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
        allowNull: false,
      },
      appointment_id: {
        type: Sequelize.UUID,
        allowNull: true,
        references: { model: "appointments", key: "id" },
        onDelete: "SET NULL",
        onUpdate: "CASCADE",
      },
      patient_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: { model: "users", key: "id" },
        onDelete: "CASCADE",
        onUpdate: "CASCADE",
      },
      doctor_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: { model: "doctors", key: "id" },
        onDelete: "CASCADE",
        onUpdate: "CASCADE",
      },
      consultation_date: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.fn("NOW"),
      },
      chief_complaint: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      symptoms: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      diagnosis: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      treatment_plan: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      notes: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      duration_minutes: {
        type: Sequelize.INTEGER,
        allowNull: true,
      },
      fee_paid: {
        type: Sequelize.DECIMAL(10, 2),
        allowNull: true,
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.fn("NOW"),
      },
      updated_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.fn("NOW"),
      },
    });

    await queryInterface.addIndex("consultations", ["patient_id"]);
    await queryInterface.addIndex("consultations", ["doctor_id"]);
    await queryInterface.addIndex("consultations", ["consultation_date"]);
  },

  async down(queryInterface) {
    await queryInterface.dropTable("consultations");
  },
};
