import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  const user = await prisma.user.create({
    data: {
      phone: '13800138000',
      coins: 100,
    },
  });

  await prisma.task.createMany({
    data: [
      { type: 'text', title: '写一句关于春天的诗', rewardCoins: 5, publisherId: user.id },
      { type: 'image', title: '拍一张窗外的风景', rewardCoins: 10, publisherId: user.id },
      { type: 'video', title: '录一段10秒的自我介绍', rewardCoins: 15, publisherId: user.id },
    ],
  });

  console.log('Seed data created');
}

main().catch(console.error).finally(() => prisma.$disconnect());
