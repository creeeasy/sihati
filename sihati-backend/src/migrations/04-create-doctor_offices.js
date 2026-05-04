"use strict";

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable("doctor_offices", {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
        allowNull: false,
      },
      doctor_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: { model: "doctors", key: "id" },
        onDelete: "CASCADE",
        onUpdate: "CASCADE",
      },
      office_name: {
        type: Sequelize.STRING,
        allowNull: true,
      },
      address: {
        type: Sequelize.STRING,
        allowNull: false,
      },
      wilaya: {
        type: Sequelize.STRING,
        allowNull: false,
      },
      commune: {
        type: Sequelize.STRING,
        allowNull: true,
      },
      latitude: {
        type: Sequelize.DECIMAL(10, 8),
        allowNull: false,
      },
      longitude: {
        type: Sequelize.DECIMAL(11, 8),
        allowNull: false,
      },
      phone: {
        type: Sequelize.STRING,
        allowNull: true,
      },
      is_primary: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: false,
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

    await queryInterface.addIndex("doctor_offices", ["doctor_id"]);
    await queryInterface.addIndex("doctor_offices", ["wilaya"]);
    await queryInterface.addIndex("doctor_offices", ["latitude", "longitude"]);
  },

  async down(queryInterface) {
    await queryInterface.dropTable("doctor_offices");
  },
};
