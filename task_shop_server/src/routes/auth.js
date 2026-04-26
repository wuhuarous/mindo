import { Router } from 'express';
import { sendCode, login } from '../controllers/authController.js';

const router = Router();

router.post('/send-code', sendCode);
router.post('/login', login);

export default router;
