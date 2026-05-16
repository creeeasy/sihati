import { Sequelize } from 'sequelize';
import env from './env';

let sequelize: Sequelize;

switch (env.NODE_ENV) {
  case 'production':
    console.log('🚀 Using PRODUCTION DB (internal)');

    if (!env.DATABASE_URL_INTERNAL) {
      throw new Error('❌ Missing DATABASE_URL_INTERNAL');
    }

    sequelize = new Sequelize(env.DATABASE_URL_INTERNAL, {
      dialect: 'postgres',
      logging: false,
      dialectOptions: {
        ssl: {
          require: true,
          rejectUnauthorized: false,
        },
      },
    });
    break;

  case 'staging':
    console.log('🧪 Using STAGING DB (external)');

    if (!env.DATABASE_URL_EXTERNAL) {
      throw new Error('❌ Missing DATABASE_URL_EXTERNAL');
    }

    sequelize = new Sequelize(env.DATABASE_URL_EXTERNAL, {
      dialect: 'postgres',
      logging: false, // cleaner logs
      dialectOptions: {
        ssl: {
          require: true,
          rejectUnauthorized: false,
        },
      },
    });
    break;

  default:
    console.log('💻 Using DEVELOPMENT DB (local)');

    sequelize = new Sequelize(
      env.DB_NAME,
      env.DB_USER,
      env.DB_PASSWORD,
      {
        host: env.DB_HOST,
        port: env.DB_PORT,
        dialect: 'postgres',
        logging: false,
        //logging: console.log,
      }
    );
}

export default sequelize;