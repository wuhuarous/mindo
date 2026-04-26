import { Router } from 'express';
import { authMiddleware } from '../middleware/auth.js';
import { publish, draw, submit, mine, detail } from '../controllers/taskController.js';

const router = Router();

router.post('/publish', authMiddleware, publish);
router.post('/draw', authMiddleware, draw);
router.post('/submit', authMiddleware, submit);
router.get('/mine', authMiddleware, mine);
router.get('/:id', authMiddleware, detail);

export default router;
