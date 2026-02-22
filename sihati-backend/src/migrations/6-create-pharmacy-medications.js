"use strict";

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable("pharmacy_medications", {
      id: {
        type: Sequelize.INTEGER,
        autoIncrement: true,
        primaryKey: true,
        allowNull: false,
      },
      pharmacy_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: { model: "pharmacies", key: "id" },
        onDelete: "CASCADE",
        onUpdate: "CASCADE",
      },
      medication_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: { model: "medications", key: "id" },
        onDelete: "CASCADE",
        onUpdate: "CASCADE",
      },
      in_stock: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
      },
      quantity: {
        type: Sequelize.INTEGER,
        allowNull: true,
      },
      price: {
        type: Sequelize.DECIMAL(10, 2),
        allowNull: true,
      },
      last_updated: {
        type: Sequelize.DATE,
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

    // Composite unique: one entry per pharmacy-medication pair
    await queryInterface.addIndex(
      "pharmacy_medications",
      ["pharmacy_id", "medication_id"],
      { unique: true, name: "unique_pharmacy_medication" },
    );
    await queryInterface.addIndex("pharmacy_medications", ["pharmacy_id"]);
    await queryInterface.addIndex("pharmacy_medications", ["medication_id"]);
    await queryInterface.addIndex("pharmacy_medications", ["in_stock"]);
  },

  async down(queryInterface) {
    await queryInterface.dropTable("pharmacy_medications");
  },
};
