import COS from 'cos-nodejs-sdk-v5';
import fs from 'fs';
import path from 'path';
import { config } from '../config.js';

const cos = new COS({
  SecretId: config.cosSecretId,
  SecretKey: config.cosSecretKey,
});

const bucket = config.cosBucket;
const region = config.cosRegion;
const domain = config.cosDomain;

export async function uploadToCOS(filePath, key) {
  return new Promise((resolve, reject) => {
    cos.putObject(
      {
        Bucket: bucket,
        Region: region,
        Key: key,
        Body: fs.createReadStream(filePath),
        ContentLength: fs.statSync(filePath).size,
      },
      (err, data) => {
        // Clean up the temp file
        fs.unlink(filePath, () => {});
        if (err) return reject(err);
        resolve(`${domain}/${key}`);
      }
    );
  });
}
