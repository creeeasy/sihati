"use strict";

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable("patient_allergies", {
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
      allergy_name: {
        type: Sequelize.STRING,
        allowNull: false,
      },
      allergy_type: {
        type: Sequelize.ENUM("medication", "food", "environmental", "other"),
        allowNull: false,
      },
      severity: {
        type: Sequelize.ENUM("mild", "moderate", "severe"),
        allowNull: false,
      },
      reaction: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      declared_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.fn("NOW"),
      },
      declared_by: {
        type: Sequelize.UUID,
        allowNull: true,
        references: { model: "doctors", key: "id" },
        onDelete: "SET NULL",
        onUpdate: "CASCADE",
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

    await queryInterface.addIndex("patient_allergies", ["patient_id"]);
  },

  async down(queryInterface) {
    await queryInterface.dropTable("patient_allergies");
  },
};
