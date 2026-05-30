import dotenv from 'dotenv';

dotenv.config();

export type AppEnv = 'development' | 'staging' | 'production';

export interface EnvConfig {
  NODE_ENV: AppEnv;
  PORT: number;

  DB_HOST: string;
  DB_PORT: number;
  DB_NAME: string;
  DB_USER: string;
  DB_PASSWORD: string;

  JWT_SECRET: string;
  JWT_REFRESH_SECRET: string;
  JWT_EXPIRES_IN: string;

  GEMINI_API_KEY: string;

  RATE_LIMIT_WINDOW_MS: number;
  RATE_LIMIT_MAX_REQUESTS: number;

  LOG_LEVEL: string;
  LOG_DIR: string;
}

function validateEnv(): EnvConfig {
  const NODE_ENV = (process.env.NODE_ENV || 'development') as AppEnv;

  const requiredVars = [
    'DB_HOST',
    'DB_PORT',
    'DB_NAME',
    'DB_USER',
    'DB_PASSWORD',
    'JWT_SECRET',
    'JWT_REFRESH_SECRET',
    'GEMINI_API_KEY',
  ];

  const missing = requiredVars.filter((key) => !process.env[key]);

  if (missing.length > 0) {
    throw new Error(
      `❌ Missing environment variables (${NODE_ENV}): ${missing.join(', ')}`
    );
  }

  return {
    NODE_ENV,

    PORT: parseInt(process.env.PORT || '7500', 10),

    DB_HOST: process.env.DB_HOST!,
    DB_PORT: parseInt(process.env.DB_PORT!, 10),
    DB_NAME: process.env.DB_NAME!,
    DB_USER: process.env.DB_USER!,
    DB_PASSWORD: process.env.DB_PASSWORD!,

    JWT_SECRET: process.env.JWT_SECRET!,
    JWT_REFRESH_SECRET: process.env.JWT_REFRESH_SECRET!,
    JWT_EXPIRES_IN: process.env.JWT_EXPIRES_IN || '7d',

    GEMINI_API_KEY: process.env.GEMINI_API_KEY!,

    RATE_LIMIT_WINDOW_MS: parseInt(
      process.env.RATE_LIMIT_WINDOW_MS || '900000',
      10
    ),
    RATE_LIMIT_MAX_REQUESTS: parseInt(
      process.env.RATE_LIMIT_MAX_REQUESTS || '100',
      10
    ),

    LOG_LEVEL: process.env.LOG_LEVEL || 'info',
    LOG_DIR: process.env.LOG_DIR || 'logs',
  };
}

const env = validateEnv();

export default env;