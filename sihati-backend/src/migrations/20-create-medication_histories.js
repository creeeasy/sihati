"use strict";

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable("medication_histories", {
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
      prescription_id: {
        type: Sequelize.UUID,
        allowNull: true,
        references: { model: "prescriptions", key: "id" },
        onDelete: "SET NULL",
        onUpdate: "CASCADE",
      },
      medication_id: {
        type: Sequelize.UUID,
        allowNull: true,
        references: { model: "medications", key: "id" },
        onDelete: "SET NULL",
        onUpdate: "CASCADE",
      },
      medication_name: {
        type: Sequelize.STRING,
        allowNull: false,
      },
      dosage: {
        type: Sequelize.STRING,
        allowNull: false,
      },
      frequency: {
        type: Sequelize.STRING,
        allowNull: false,
      },
      start_date: {
        type: Sequelize.DATEONLY,
        allowNull: false,
      },
      end_date: {
        type: Sequelize.DATEONLY,
        allowNull: true,
      },
      prescribed_by: {
        type: Sequelize.UUID,
        allowNull: true,
        references: { model: "doctors", key: "id" },
        onDelete: "SET NULL",
        onUpdate: "CASCADE",
      },
      reason: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      is_active: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
      },
      adherence_rate: {
        type: Sequelize.DECIMAL(5, 2),
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

    await queryInterface.addIndex("medication_histories", ["patient_id"]);
    await queryInterface.addIndex("medication_histories", ["is_active"]);
    await queryInterface.addIndex("medication_histories", ["start_date"]);
  },

  async down(queryInterface) {
    await queryInterface.dropTable("medication_histories");
  },
};
