"use strict";

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable("specialties", {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
        allowNull: false,
      },
      name_fr: {
        type: Sequelize.STRING,
        allowNull: false,
        unique: true,
      },
      name_ar: {
        type: Sequelize.STRING,
        allowNull: false,
      },
      icon: {
        type: Sequelize.STRING,
        allowNull: false,
      },
      description: {
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

    await queryInterface.addIndex("specialties", ["name_fr"], { unique: true });
  },

  async down(queryInterface) {
    await queryInterface.dropTable("specialties");
  },
};
