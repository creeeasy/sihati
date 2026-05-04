"use strict";

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable("doctor_schedules", {
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
      office_id: {
        type: Sequelize.UUID,
        allowNull: true,
        references: { model: "doctor_offices", key: "id" },
        onDelete: "CASCADE",
        onUpdate: "CASCADE",
      },
      day_of_week: {
        type: Sequelize.INTEGER,
        allowNull: false,
        validate: { min: 0, max: 6 },
      },
      start_time: {
        type: Sequelize.TIME,
        allowNull: false,
      },
      end_time: {
        type: Sequelize.TIME,
        allowNull: false,
      },
      is_available: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
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

    await queryInterface.addIndex("doctor_schedules", ["doctor_id"]);
    await queryInterface.addIndex("doctor_schedules", ["office_id"]);
    await queryInterface.addIndex("doctor_schedules", ["day_of_week"]);
  },

  async down(queryInterface) {
    await queryInterface.dropTable("doctor_schedules");
  },
};
