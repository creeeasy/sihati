"use strict";

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable("conversations", {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
        allowNull: false,
      },
      user_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: { model: "users", key: "id" },
        onDelete: "CASCADE",
        onUpdate: "CASCADE",
      },
      user_message: {
        type: Sequelize.TEXT,
        allowNull: false,
      },
      ai_response: {
        type: Sequelize.TEXT,
        allowNull: false,
      },
      context: {
        type: Sequelize.JSONB,
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

    await queryInterface.addIndex("conversations", ["user_id"]);
    await queryInterface.addIndex("conversations", ["created_at"]);
  },

  async down(queryInterface) {
    await queryInterface.dropTable("conversations");
  },
};
