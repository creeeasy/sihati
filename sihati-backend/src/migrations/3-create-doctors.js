"use strict";

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable("doctors", {
      id: {
        type: Sequelize.INTEGER,
        autoIncrement: true,
        primaryKey: true,
        allowNull: false,
      },
      user_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        unique: true,
        references: { model: "users", key: "id" },
        onDelete: "CASCADE",
        onUpdate: "CASCADE",
      },
      specialty_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: { model: "specialties", key: "id" },
        onDelete: "RESTRICT",
        onUpdate: "CASCADE",
      },
      doctor_name: {
        type: Sequelize.STRING,
        allowNull: false,
      },
      clinic_name: {
        type: Sequelize.STRING,
        allowNull: false,
      },
      clinic_address: {
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
        allowNull: false,
      },
      whatsapp_number: {
        type: Sequelize.STRING,
        allowNull: true,
      },
      consultation_fee: {
        type: Sequelize.DECIMAL(10, 2),
        allowNull: true,
      },
      working_hours: {
        type: Sequelize.JSONB,
        allowNull: true,
      },
      bio: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      years_of_experience: {
        type: Sequelize.INTEGER,
        allowNull: true,
      },
      average_rating: {
        type: Sequelize.DECIMAL(3, 2),
        allowNull: true,
        defaultValue: 0.0,
      },
      total_reviews: {
        type: Sequelize.INTEGER,
        allowNull: true,
        defaultValue: 0,
      },
      is_verified: {
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

    await queryInterface.addIndex("doctors", ["wilaya"]);
    await queryInterface.addIndex("doctors", ["specialty_id"]);
    await queryInterface.addIndex("doctors", ["latitude", "longitude"]);
    await queryInterface.addIndex("doctors", ["average_rating"]);
  },

  async down(queryInterface) {
    await queryInterface.dropTable("doctors");
  },
};
