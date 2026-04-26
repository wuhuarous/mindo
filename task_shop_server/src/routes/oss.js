import { Router } from 'express';
import { authMiddleware } from '../middleware/auth.js';
import { getSTS } from '../controllers/ossController.js';

const router = Router();

router.get('/sts', authMiddleware, getSTS);

export default router;
