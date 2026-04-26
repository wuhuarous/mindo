import { getSTSCredentials } from '../services/ossService.js';

export async function getSTS(req, res) {
  const credentials = await getSTSCredentials();
  res.json({ success: true, data: credentials, error: null });
}
