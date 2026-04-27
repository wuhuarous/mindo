import { PrismaClient } from '@prisma/client';
import jwt from 'jsonwebtoken';
import { config } from '../config.js';
import { AppError } from '../middleware/errorHandler.js';

const prisma = new PrismaClient();

function generateCode() {
  return String(Math.floor(100000 + Math.random() * 900000));
}

export async function sendVerificationCode(phone) {
  const code = config.nodeEnv === 'development' ? '123456' : generateCode();

  await prisma.verificationCode.updateMany({
    where: { phone, used: false, expiresAt: { gt: new Date() } },
    data: { used: true },
  });

  await prisma.verificationCode.create({
    data: {
      phone,
      code,
      expiresAt: new Date(Date.now() + 5 * 60 * 1000),
    },
  });

  if (config.nodeEnv !== 'development') {
    console.log(`[SMS] Sent code ${code} to ${phone}`);
  }

  return { message: '验证码已发送' };
}

export async function loginWithCode(phone, code) {
  // 开发模式跳过验证码校验
  if (config.nodeEnv === 'development') {
    let user = await prisma.user.findUnique({ where: { phone } });
    if (!user) {
      user = await prisma.user.create({ data: { phone, coins: 20 } });
    }
    const token = jwt.sign({ userId: user.id }, config.jwtSecret, { expiresIn: '7d' });
    return { token, user: { id: user.id, phone: user.phone, nickname: user.nickname, avatarIndex: user.avatarIndex, coins: user.coins } };
  }

  const record = await prisma.verificationCode.findFirst({
    where: {
      phone,
      code,
      used: false,
      expiresAt: { gt: new Date() },
    },
    orderBy: { createdAt: 'desc' },
  });

  if (!record) throw new AppError('验证码错误或已过期');

  await prisma.verificationCode.update({
    where: { id: record.id },
    data: { used: true },
  });

  let user = await prisma.user.findUnique({ where: { phone } });
  if (!user) {
    user = await prisma.user.create({ data: { phone, coins: 20 } });
  }

  const token = jwt.sign({ userId: user.id }, config.jwtSecret, { expiresIn: '7d' });

  return {
    token,
    user: { id: user.id, phone: user.phone, nickname: user.nickname, avatarIndex: user.avatarIndex, coins: user.coins },
  };
}
