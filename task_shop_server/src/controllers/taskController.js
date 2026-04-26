import { publishTask, drawTask, submitTask, getMyTasks, getTaskDetail } from '../services/taskService.js';

export async function publish(req, res) {
  const task = await publishTask(req.userId, req.body);
  res.json({ success: true, data: task, error: null });
}

export async function draw(req, res) {
  const task = await drawTask(req.userId);
  if (!task) {
    return res.json({ success: true, data: null, error: '暂无可用任务' });
  }
  res.json({ success: true, data: task, error: null });
}

export async function submit(req, res) {
  const result = await submitTask(req.userId, req.body);
  res.json({ success: true, data: result, error: null });
}

export async function mine(req, res) {
  const role = req.query.role || 'claimer';
  const tasks = await getMyTasks(req.userId, role);
  res.json({ success: true, data: tasks, error: null });
}

export async function detail(req, res) {
  const task = await getTaskDetail(req.params.id, req.userId);
  res.json({ success: true, data: task, error: null });
}
