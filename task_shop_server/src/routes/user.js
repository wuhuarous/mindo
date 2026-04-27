import { Router } from 'express';
import { authMiddleware } from '../middleware/auth.js';
import { updateProfile } from '../services/userService.js';

const router = Router();

router.put('/profile', authMiddleware, async (req, res) => {
  try {
    const user = await updateProfile(req.userId, req.body);
    res.json({ success: true, data: user, error: null });
  } catch (e) {
    res.status(e.status || 400).json({ success: false, data: null, error: e.message });
  }
});

export default router;
