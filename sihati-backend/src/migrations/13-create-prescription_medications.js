"use strict";

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable("prescription_medications", {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
        allowNull: false,
      },
      prescription_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: { model: "prescriptions", key: "id" },
        onDelete: "CASCADE",
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
        allowNull: true,
      },
      frequency: {
        type: Sequelize.STRING,
        allowNull: true,
      },
      duration_days: {
        type: Sequelize.INTEGER,
        allowNull: true,
      },
      quantity: {
        type: Sequelize.INTEGER,
        allowNull: true,
      },
      instructions: {
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

    await queryInterface.addIndex("prescription_medications", [
      "prescription_id",
    ]);
    await queryInterface.addIndex("prescription_medications", [
      "medication_id",
    ]);
  },

  async down(queryInterface) {
    await queryInterface.dropTable("prescription_medications");
  },
};
