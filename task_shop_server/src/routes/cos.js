import { Router } from 'express';
import multer from 'multer';
import { authMiddleware } from '../middleware/auth.js';
import { upload } from '../controllers/cosController.js';

const router = Router();
const uploader = multer({ dest: '/tmp/uploads/' });

router.post('/', authMiddleware, uploader.single('file'), upload);

export default router;
