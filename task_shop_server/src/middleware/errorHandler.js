export function errorHandler(err, req, res, _next) {
  console.error(`[Error] ${err.message}`, err.stack);
  const status = err.status || 500;
  res.status(status).json({
    success: false,
    data: null,
    error: err.message || '服务器内部错误',
  });
}

export class AppError extends Error {
  constructor(message, status = 400) {
    super(message);
    this.status = status;
  }
}
