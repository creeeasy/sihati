// src/server.ts
import app from './app';
import sequelize from './config/database';
import logger from './utils/logger';
import env from './config/env';

// Import models to register them before sync
import './models/index';

async function startServer(): Promise<void> {
  try {
    // 1. Test database connection
    await sequelize.authenticate();
    logger.info('✅ Database connection established successfully.');

    // 2. Sync models ONLY in development (but prefer migrations)
    if (env.NODE_ENV === 'development') {
      // Option 1: Just check connection, no sync (recommended)
      logger.info('⚠️ Using migrations, not sync. Run: npx sequelize-cli db:migrate');
      
      // Option 2: If you really need sync (use with caution)
      // await sequelize.sync({ alter: false }); // Only create missing tables
    }

    // 3. Start HTTP server
    const server = app.listen(env.PORT, () => {
      logger.info(`🚀 Sihati API running on port ${env.PORT}`);
      logger.info(`🌍 Environment: ${env.NODE_ENV}`);
      logger.info(`📋 Health check: http://localhost:${env.PORT}/health`);
      logger.info(`📡 API base URL: http://localhost:${env.PORT}/api`);
    });

    // 4. Graceful shutdown handlers
    const shutdown = async (signal: string) => {
      logger.info(`\n${signal} received. Shutting down gracefully...`);
      server.close(async () => {
        logger.info('HTTP server closed.');
        await sequelize.close();
        logger.info('Database connection closed.');
        process.exit(0);
      });
    };

    process.on('SIGTERM', () => shutdown('SIGTERM'));
    process.on('SIGINT', () => shutdown('SIGINT'));

    // 5. Handle unhandled promise rejections
    process.on('unhandledRejection', (reason: any) => {
      logger.error('Unhandled Rejection:', reason);
      server.close(() => process.exit(1));
    });

    // 6. Handle uncaught exceptions
    process.on('uncaughtException', (error: Error) => {
      logger.error('Uncaught Exception:', error);
      process.exit(1);
    });

  } catch (error) {
    logger.error('❌ Failed to start server:', error);
    process.exit(1);
  }
}

startServer();