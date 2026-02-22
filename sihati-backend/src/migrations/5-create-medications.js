"use strict";

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable("medications", {
      id: {
        type: Sequelize.INTEGER,
        autoIncrement: true,
        primaryKey: true,
        allowNull: false,
      },
      name: {
        type: Sequelize.STRING,
        allowNull: false,
        unique: true,
      },
      generic_name: {
        type: Sequelize.STRING,
        allowNull: true,
      },
      category: {
        type: Sequelize.STRING,
        allowNull: true,
      },
      manufacturer: {
        type: Sequelize.STRING,
        allowNull: true,
      },
      description: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      dosage_form: {
        type: Sequelize.STRING,
        allowNull: true,
      },
      strength: {
        type: Sequelize.STRING,
        allowNull: true,
      },
      requires_prescription: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: false,
      },
      price: {
        type: Sequelize.DECIMAL(10, 2),
        allowNull: true,
      },
      barcode: {
        type: Sequelize.STRING,
        allowNull: true,
        unique: true,
      },
      active_ingredients: {
        type: Sequelize.JSONB,
        allowNull: true,
      },
      side_effects: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      contraindications: {
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

    await queryInterface.addIndex("medications", ["name"], { unique: true });
    await queryInterface.addIndex("medications", ["category"]);
    await queryInterface.addIndex("medications", ["requires_prescription"]);
  },

  async down(queryInterface) {
    await queryInterface.dropTable("medications");
  },
};
