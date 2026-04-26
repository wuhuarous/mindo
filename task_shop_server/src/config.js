import 'dotenv/config';

export const config = {
  port: parseInt(process.env.PORT || '3000'),
  jwtSecret: process.env.JWT_SECRET || 'dev-secret',
  nodeEnv: process.env.NODE_ENV || 'development',
  cosSecretId: process.env.COS_SECRET_ID,
  cosSecretKey: process.env.COS_SECRET_KEY,
  cosBucket: process.env.COS_BUCKET,
  cosRegion: process.env.COS_REGION,
  cosDomain: process.env.COS_DOMAIN,
  sms: {
    accessKeyId: process.env.SMS_ACCESS_KEY_ID,
    accessKeySecret: process.env.SMS_ACCESS_KEY_SECRET,
    signName: process.env.SMS_SIGN_NAME,
    templateCode: process.env.SMS_TEMPLATE_CODE,
  },
};
