import { PrismaClient } from '@prisma/client';
import { AppError } from '../middleware/errorHandler.js';

const prisma = new PrismaClient();

export async function updateProfile(userId, { nickname, avatarIndex }) {
  if (nickname !== undefined && (nickname.length < 1 || nickname.length > 20)) {
    throw new AppError('昵称需在 1-20 字之间');
  }
  if (avatarIndex !== undefined && (avatarIndex < 0 || avatarIndex > 23)) {
    throw new AppError('无效的头像');
  }

  const data = {};
  if (nickname !== undefined) data.nickname = nickname;
  if (avatarIndex !== undefined) data.avatarIndex = avatarIndex;

  const user = await prisma.user.update({
    where: { id: userId },
    data,
    select: { id: true, phone: true, nickname: true, avatarIndex: true, coins: true },
  });

  return user;
}
