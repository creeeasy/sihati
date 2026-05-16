"use strict";

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable("medication_reminders", {
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
      medication_history_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: { model: "medication_histories", key: "id" },
        onDelete: "CASCADE",
        onUpdate: "CASCADE",
      },
      reminder_time: {
        type: Sequelize.TIME,
        allowNull: false,
      },
      days_of_week: {
        type: Sequelize.ARRAY(Sequelize.INTEGER),
        allowNull: false,
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

    await queryInterface.addIndex("medication_reminders", ["patient_id"]);
  },

  async down(queryInterface) {
    await queryInterface.dropTable("medication_reminders");
  },
};
