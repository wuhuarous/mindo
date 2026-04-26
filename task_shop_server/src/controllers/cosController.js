import { uploadToCOS } from '../services/cosService.js';

export async function upload(req, res) {
  if (!req.file) {
    return res.status(400).json({ success: false, data: null, error: '未选择文件' });
  }

  const ext = req.file.originalname.split('.').pop() || 'jpg';
  const key = `tasks/${Date.now()}_${Math.random().toString(36).slice(2, 8)}.${ext}`;
  const url = await uploadToCOS(req.file.path, key);

  res.json({ success: true, data: { url }, error: null });
}
