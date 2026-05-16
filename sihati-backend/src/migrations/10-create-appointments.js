"use strict";

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable("appointments", {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
        allowNull: false,
      },
      patient_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: { model: "users", key: "id" },
        onDelete: "CASCADE",
        onUpdate: "CASCADE",
      },
      // Changer la référence de doctor_id
      doctor_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: { model: "users", key: "id" }, // ← au lieu de 'doctors'
        onDelete: "CASCADE",
      },
      office_id: {
        type: Sequelize.UUID,
        allowNull: true,
        references: { model: "doctor_offices", key: "id" },
        onDelete: "SET NULL",
        onUpdate: "CASCADE",
      },
      appointment_date: {
        type: Sequelize.DATEONLY,
        allowNull: false,
      },
      appointment_time: {
        type: Sequelize.TIME,
        allowNull: false,
      },
      status: {
        type: Sequelize.ENUM(
          "pending",
          "confirmed",
          "cancelled",
          "completed",
          "no_show",
        ),
        allowNull: false,
        defaultValue: "pending",
      },
      reason: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      notes: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      cancelled_at: {
        type: Sequelize.DATE,
        allowNull: true,
      },
      cancelled_by: {
        type: Sequelize.UUID,
        allowNull: true,
        references: { model: "users", key: "id" },
      },
      cancellation_reason: {
        type: Sequelize.TEXT,
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

    await queryInterface.addIndex("appointments", ["patient_id"]);
    await queryInterface.addIndex("appointments", ["doctor_id"]);
    await queryInterface.addIndex("appointments", ["appointment_date"]);
    await queryInterface.addIndex("appointments", ["status"]);
  },

  async down(queryInterface) {
    await queryInterface.dropTable("appointments");
  },
};
