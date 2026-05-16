"use strict";

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable("medical_documents", {
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
      doctor_id: {
        type: Sequelize.UUID,
        allowNull: true,
        references: { model: "doctors", key: "id" },
        onDelete: "SET NULL",
        onUpdate: "CASCADE",
      },
      document_type: {
        type: Sequelize.ENUM(
          "lab_result",
          "radiology",
          "report",
          "certificate",
          "prescription",
          "other",
        ),
        allowNull: false,
      },
      title: {
        type: Sequelize.STRING,
        allowNull: false,
      },
      description: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      file_url: {
        type: Sequelize.TEXT,
        allowNull: false,
      },
      file_type: {
        type: Sequelize.STRING,
        allowNull: true,
      },
      file_size_bytes: {
        type: Sequelize.INTEGER,
        allowNull: true,
      },
      document_date: {
        type: Sequelize.DATEONLY,
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

    await queryInterface.addIndex("medical_documents", ["patient_id"]);
    await queryInterface.addIndex("medical_documents", ["doctor_id"]);
    await queryInterface.addIndex("medical_documents", ["document_type"]);
    await queryInterface.addIndex("medical_documents", ["document_date"]);
  },

  async down(queryInterface) {
    await queryInterface.dropTable("medical_documents");
  },
};
