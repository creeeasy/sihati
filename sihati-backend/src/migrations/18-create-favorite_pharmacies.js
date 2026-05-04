"use strict";

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable("favorite_pharmacies", {
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
      pharmacy_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: { model: "pharmacies", key: "id" },
        onDelete: "CASCADE",
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

    await queryInterface.addIndex(
      "favorite_pharmacies",
      ["patient_id", "pharmacy_id"],
      {
        unique: true,
        name: "unique_patient_pharmacy_favorite",
      },
    );
  },

  async down(queryInterface) {
    await queryInterface.dropTable("favorite_pharmacies");
  },
};
