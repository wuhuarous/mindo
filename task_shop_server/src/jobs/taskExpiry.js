import cron from 'node-cron';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export function startTaskExpiryJob() {
  cron.schedule('* * * * *', async () => {
    try {
      const result = await prisma.task.updateMany({
        where: {
          status: 'doing',
          deadline: { lt: new Date() },
        },
        data: {
          status: 'pending',
          claimerId: null,
          deadline: null,
        },
      });

      if (result.count > 0) {
        console.log(`[TaskExpiry] Released ${result.count} expired tasks`);
      }
    } catch (err) {
      console.error('[TaskExpiry] Error:', err.message);
    }
  });

  console.log('[TaskExpiry] Job started (runs every minute)');
}
