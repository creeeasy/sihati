import winston from 'winston';
import path from 'path';
import fs from 'fs';
import env from '../config/env';

// Ensure log directory exists
const logDir = env.LOG_DIR || 'logs';
if (!fs.existsSync(logDir)) {
  fs.mkdirSync(logDir, { recursive: true });
}

const { combine, timestamp, printf, colorize, errors } = winston.format;

// Custom log format
const logFormat = printf(({ level, message, timestamp, stack }) => {
  return stack
    ? `[${timestamp}] ${level}: ${message}\n${stack}`
    : `[${timestamp}] ${level}: ${message}`;
});

const logger = winston.createLogger({
  level: env.LOG_LEVEL || 'info',
  format: combine(
    timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
    errors({ stack: true }),
    logFormat
  ),
  transports: [
    // Console transport
    new winston.transports.Console({
      format: combine(
        colorize(),
        timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
        errors({ stack: true }),
        logFormat
      ),
    }),
    // File transport — all logs
    new winston.transports.File({
      filename: path.join(logDir, 'combined.log'),
    }),
    // File transport — errors only
    new winston.transports.File({
      filename: path.join(logDir, 'error.log'),
      level: 'error',
    }),
  ],
});

// Morgan-compatible stream for HTTP request logging
export const morganStream = {
  write: (message: string) => {
    logger.info(message.trim());
  },
};

export default logger;