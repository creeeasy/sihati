import { Sequelize } from 'sequelize';
import env from './env';

const sequelize = new Sequelize(env.DB_NAME, env.DB_USER, env.DB_PASSWORD, {
  host: env.DB_HOST,
  port: env.DB_PORT,
  dialect: 'postgres',

  pool: {
    max: 5,
    min: 0,
    acquire: 30000, // 30 seconds
    idle: 10000,    // 10 seconds
  },

  logging: env.NODE_ENV === 'development' ? console.log : false,

  define: {
    timestamps: true,
    underscored: true, // snake_case column names in DB
  },
});

export default sequelize;