import { PrismaClient } from '@prisma/client';
import { AppError } from '../middleware/errorHandler.js';

const prisma = new PrismaClient();

export async function publishTask(userId, { type, title, contentUrl, rewardCoins }) {
  const validTypes = ['text', 'image', 'video'];
  if (!validTypes.includes(type)) throw new AppError('无效的任务类型');
  if (!title || title.length > 50) throw new AppError('任务标题需在 1-50 字之间');
  if (type === 'text' && contentUrl && contentUrl.length > 200) throw new AppError('文案内容不能超过200字');
  if (rewardCoins < 1) throw new AppError('奖励至少 1 币');

  const user = await prisma.user.findUnique({ where: { id: userId } });
  if (!user || user.coins < rewardCoins) throw new AppError('虚拟币不足');

  const [task] = await prisma.$transaction([
    prisma.task.create({
      data: { type, title, contentUrl: contentUrl || null, rewardCoins, publisherId: userId },
    }),
    prisma.user.update({
      where: { id: userId },
      data: { coins: { decrement: rewardCoins } },
    }),
  ]);

  return task;
}

export async function drawTask(userId) {
  const [task] = await prisma.$transaction(async (tx) => {
    const found = await tx.task.findFirst({
      where: { status: 'pending', rejected: false },
      orderBy: { createdAt: 'asc' },
    });
    if (!found) return [null];

    const result = await tx.task.updateMany({
      where: { id: found.id, status: 'pending' },
      data: {
        status: 'doing',
        claimerId: userId,
        deadline: new Date(Date.now() + 60 * 1000),
      },
    });
    return result.count > 0 ? [found] : [null];
  });

  return task;
}

export async function submitTask(userId, { taskId, contentUrl }) {
  const task = await prisma.task.findUnique({ where: { id: taskId } });
  if (!task) throw new AppError('任务不存在');
  if (task.claimerId !== userId) throw new AppError('这不是你领取的任务');
  if (task.status !== 'doing') throw new AppError('任务状态不正确');

  const now = new Date();
  const isValid = task.deadline && now <= task.deadline;

  if (!isValid) {
    await prisma.task.update({
      where: { id: taskId },
      data: { status: 'expired', claimerId: null, deadline: null },
    });
    throw new AppError('倒计时已结束，任务已过期');
  }

  const [completion] = await prisma.$transaction([
    prisma.completion.create({
      data: { taskId, userId, contentUrl, submittedAt: now, isValid: true },
    }),
    prisma.task.update({
      where: { id: taskId },
      data: { status: 'completed' },
    }),
    prisma.user.update({
      where: { id: userId },
      data: { coins: { increment: task.rewardCoins } },
    }),
  ]);

  return completion;
}

export async function getMyTasks(userId, role) {
  const where = role === 'publisher'
    ? { publisherId: userId }
    : { claimerId: userId };

  return prisma.task.findMany({
    where,
    orderBy: { createdAt: 'desc' },
    include: {
      publisher: { select: { id: true, phone: true } },
      claimer: { select: { id: true, phone: true } },
    },
  });
}

export async function getTaskDetail(taskId, userId) {
  const task = await prisma.task.findUnique({
    where: { id: taskId },
    include: {
      publisher: { select: { id: true, phone: true } },
      claimer: { select: { id: true, phone: true } },
      completions: {
        orderBy: { submittedAt: 'desc' },
        take: 1,
      },
    },
  });

  if (!task) throw new AppError('任务不存在');
  if (task.publisherId !== userId && task.claimerId !== userId) {
    throw new AppError('无权查看此任务');
  }

  return task;
}
