"use strict";

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable("medications", {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
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
      dci: {
        type: Sequelize.STRING,
        allowNull: true,
      },
      form: {
        type: Sequelize.STRING,
        allowNull: true,
      },
      dosage: {
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
      indications: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      contraindications: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      side_effects: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      posology: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      requires_prescription: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: false,
      },
      barcode: {
        type: Sequelize.STRING,
        allowNull: true,
        unique: true,
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
    await queryInterface.addIndex("medications", ["barcode"], { unique: true });
  },

  async down(queryInterface) {
    await queryInterface.dropTable("medications");
  },
};
