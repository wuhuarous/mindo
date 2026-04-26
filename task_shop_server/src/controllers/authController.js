import { sendVerificationCode, loginWithCode } from '../services/authService.js';

export async function sendCode(req, res) {
  const { phone } = req.body;
  if (!phone || !/^1\d{10}$/.test(phone)) {
    return res.status(400).json({ success: false, data: null, error: '请输入有效手机号' });
  }
  const result = await sendVerificationCode(phone);
  res.json({ success: true, data: result, error: null });
}

export async function login(req, res) {
  const { phone, code } = req.body;
  if (!phone || !code) {
    return res.status(400).json({ success: false, data: null, error: '手机号和验证码不能为空' });
  }
  const result = await loginWithCode(phone, code);
  res.json({ success: true, data: result, error: null });
}
