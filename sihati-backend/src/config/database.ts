import { Sequelize } from 'sequelize';
import env from './env';

console.log(`🚀 Running in ${env.NODE_ENV.toUpperCase()} mode`);

const sequelize = new Sequelize(
  env.DB_NAME,
  env.DB_USER,
  env.DB_PASSWORD,
  {
    host: env.DB_HOST,
    port: env.DB_PORT,
    dialect: 'postgres',
    logging: false,

    dialectOptions:
      env.NODE_ENV === 'production'
        ? {
            ssl: {
              require: true,
              rejectUnauthorized: false,
            },
          }
        : undefined,
  }
);

export default sequelize;