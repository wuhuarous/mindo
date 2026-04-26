import express from 'express';
import cors from 'cors';
import { config } from './config.js';
import { errorHandler } from './middleware/errorHandler.js';
import authRoutes from './routes/auth.js';
import cosRoutes from './routes/cos.js';
import taskRoutes from './routes/tasks.js';

const app = express();

app.use(cors());
app.use(express.json({ limit: '1mb' }));

app.use('/api/auth', authRoutes);
app.use('/api/upload', cosRoutes);
app.use('/api/tasks', taskRoutes);

app.use(errorHandler);

import { startTaskExpiryJob } from './jobs/taskExpiry.js';

app.listen(config.port, () => {
  console.log(`Server running on port ${config.port}`);
  startTaskExpiryJob();
});
