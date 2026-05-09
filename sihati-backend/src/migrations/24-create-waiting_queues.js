"use strict";

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable("waiting_queues", {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
      },
      doctor_id: {
        type: Sequelize.UUID,
        allowNull: false,
        // ✅ FIX: Reference doctors table instead of users
        references: { model: "doctors", key: "id" },
        onDelete: "CASCADE",
      },
      patient_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: { model: "users", key: "id" },
        onDelete: "CASCADE",
      },
      appointment_id: {
        type: Sequelize.UUID,
        allowNull: true,
        references: { model: "appointments", key: "id" },
      },
      status: {
        type: Sequelize.ENUM(
          "waiting",
          "in_consultation",
          "completed",
          "skipped",
          "cancelled",
        ),
        allowNull: false,
        defaultValue: "waiting",
      },
      priority: {
        type: Sequelize.INTEGER,
        allowNull: false,
        defaultValue: 1,
      },
      position: {
        type: Sequelize.INTEGER,
        allowNull: false,
      },
      arrived_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.fn("NOW"),
      },
      started_at: { type: Sequelize.DATE, allowNull: true },
      completed_at: { type: Sequelize.DATE, allowNull: true },
      estimated_wait_minutes: { type: Sequelize.INTEGER, allowNull: true },
      notes: { type: Sequelize.TEXT, allowNull: true },
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

    await queryInterface.addIndex("waiting_queues", ["doctor_id"]);
    await queryInterface.addIndex("waiting_queues", ["status"]);
    await queryInterface.addIndex("waiting_queues", ["position"]);
  },

  async down(queryInterface) {
    // Drop the table (this will automatically remove all constraints)
    await queryInterface.dropTable("waiting_queues");
  },
};
