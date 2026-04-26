import { config } from '../config.js';
import { AppError } from '../middleware/errorHandler.js';

export async function getSTSCredentials() {
  if (config.nodeEnv === 'development') {
    return {
      accessKeyId: config.oss.accessKeyId || 'dev-key',
      accessKeySecret: config.oss.accessKeySecret || 'dev-secret',
      securityToken: '',
      region: config.oss.region || 'oss-cn-hangzhou',
      bucket: config.oss.bucket || 'dev-bucket',
    };
  }

  throw new AppError('请配置阿里云 OSS');
}
