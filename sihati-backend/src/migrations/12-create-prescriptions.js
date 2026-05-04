"use strict";

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable("prescriptions", {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
        allowNull: false,
      },
      consultation_id: {
        type: Sequelize.UUID,
        allowNull: true,
        references: { model: "consultations", key: "id" },
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
      prescription_date: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.fn("NOW"),
      },
      diagnosis: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      notes: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      validity_days: {
        type: Sequelize.INTEGER,
        allowNull: false,
        defaultValue: 30,
      },
      is_renewable: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: false,
      },
      file_url: {
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

    await queryInterface.addIndex("prescriptions", ["patient_id"]);
    await queryInterface.addIndex("prescriptions", ["doctor_id"]);
    await queryInterface.addIndex("prescriptions", ["prescription_date"]);
  },

  async down(queryInterface) {
    await queryInterface.dropTable("prescriptions");
  },
};
