import express, { Request, Response } from 'express';
import helmet from 'helmet';
import cors from 'cors';
import morgan from 'morgan';
import { morganStream } from './utils/logger';
import routes from './routes';
import { errorHandler } from './middlewares/errorHandler';

const app = express();

// ─── Security ───────────────────────────────────────────────
app.use(helmet());

// ─── CORS ────────────────────────────────────────────────────
app.use(
  cors({
    origin: '*', // Allow all origins (Flutter mobile app)
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  })
);

// ─── HTTP Logging ────────────────────────────────────────────
app.use(
  morgan('combined', {
    stream: morganStream,
    skip: (req) => req.url === '/health', // Don't log health checks
  })
);

// ─── Body Parsing ────────────────────────────────────────────
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// ─── Health Check ────────────────────────────────────────────
app.get('/health', (_req: Request, res: Response) => {
  res.status(200).json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'development',
  });
});

// ─── API Routes ──────────────────────────────────────────────
app.use('/api', routes);

// ─── 404 Handler ─────────────────────────────────────────────
app.use((req: Request, res: Response) => {
  res.status(404).json({
    success: false,
    message: `Route ${req.method} ${req.originalUrl} introuvable.`,
  });
});

// ─── Global Error Handler (must be last) ─────────────────────
app.use(errorHandler);

export default app;