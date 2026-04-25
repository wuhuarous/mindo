# 一分钟差事铺 - 设计文档

## 概述

一分钟差事铺是一个移动端任务平台 App，用户可发布短任务（文案/图片/视频），其他用户以"抽盲盒"方式领取并在一分钟内完成，获取虚拟币奖励。

## 技术栈

| 层级 | 选型 | 理由 |
|------|------|------|
| 前端 | Flutter 3.x | 跨平台移动端 |
| 后端 | Node.js + Express.js | 阿里云 SDK 生态成熟 |
| 数据库 | PostgreSQL | 支持行级锁，适合并发领取 |
| ORM | Prisma | 类型安全，迁移方便 |
| 定时任务 | node-cron | 轻量，无需额外基础设施 |
| 文件存储 | 阿里云 OSS + STS | 前端直传，后端提供临时凭证 |
| 短信 | 阿里云 SMS | 验证码登录 |
| 内容安全 | 阿里云内容安全 | 图片/视频审核 |
| 状态管理 | Provider | 够用，不引入复杂度 |

## 数据库设计

### 用户表 (User)

```prisma
model User {
  id         String   @id @default(uuid())
  phone      String   @unique
  coins      Int      @default(20)  // 初始 20 币
  createdAt  DateTime @default(now())
  updatedAt  DateTime @updatedAt

  publishedTasks  Task[]   @relation("Publisher")
  claimedTasks    Task[]   @relation("Claimer")
  completions     Completion[]
}
```

### 任务表 (Task)

```prisma
model Task {
  id           String   @id @default(uuid())
  type         String   // text | image | video
  title        String   // 简短描述
  contentUrl   String?  // OSS URL（发布时附带的内容，可选）
  rewardCoins  Int      // 奖励币数
  status       String   @default("pending") // pending | doing | completed | expired
  rejected     Boolean  @default(false)     // 被举报屏蔽

  publisherId  String
  publisher    User     @relation("Publisher", fields: [publisherId], references: [id])

  claimerId    String?
  claimer      User?    @relation("Claimer", fields: [claimerId], references: [id])

  deadline     DateTime? // 领取后截止时间

  createdAt  DateTime @default(now())
  updatedAt  DateTime @updatedAt

  completions Completion[]
}
```

### 完成记录表 (Completion)

```prisma
model Completion {
  id          String   @id @default(uuid())
  contentUrl  String   // OSS URL
  submittedAt DateTime
  isValid     Boolean  // 是否倒计时内提交

  taskId String
  task   Task @relation(fields: [taskId], references: [id])

  userId String
  user   User @relation(fields: [userId], references: [id])

  createdAt DateTime @default(now())
}
```

### 验证码表 (VerificationCode)

```prisma
model VerificationCode {
  id        String   @id @default(uuid())
  phone     String
  code      String
  expiresAt DateTime
  used      Boolean  @default(false)
  createdAt DateTime @default(now())
}
```

## API 设计

### 认证

| 方法 | 路径 | 说明 | 请求体 | 响应 |
|------|------|------|--------|------|
| POST | /api/auth/send-code | 发送验证码 | `{ phone }` | `{ success, message }` |
| POST | /api/auth/login | 验证码登录 | `{ phone, code }` | `{ success, data: { token, user } }` |

### OSS

| 方法 | 路径 | 说明 | 响应 |
|------|------|------|------|
| GET | /api/oss/sts | STS 临时凭证 | `{ credentials: { accessKeyId, accessKeySecret, securityToken, region, bucket } }` |

### 任务

| 方法 | 路径 | 说明 | 请求体 | 响应 |
|------|------|------|--------|------|
| POST | /api/tasks/publish | 发布任务 | `{ type, title, contentUrl?, rewardCoins }` | `{ success, data: task }` |
| POST | /api/tasks/draw | 抽盲盒 | - | `{ success, data: task }` |
| POST | /api/tasks/submit | 提交完成 | `{ taskId, contentUrl }` | `{ success, data }` |
| GET | /api/tasks/mine | 我的任务 | query: `?role=publisher\|claimer` | `{ success, data: tasks[] }` |

### 统一响应格式

```json
{ "success": true, "data": {}, "error": null }
{ "success": false, "data": null, "error": "错误信息" }
```

## 并发安全方案

抽盲盒使用 Prisma 的原子条件更新，避免并发重复领取：

```javascript
// 事务中执行
const task = await prisma.$transaction(async (tx) => {
  // 找到一条待领取任务
  const task = await tx.task.findFirst({
    where: { status: 'pending', rejected: false },
    orderBy: { createdAt: 'asc' }, // 先进先出
  });
  if (!task) return null;

  // 原子更新：只有 status='pending' 时才更新
  const updated = await tx.task.updateMany({
    where: { id: task.id, status: 'pending' },
    data: { status: 'doing', claimerId: userId, deadline: ... },
  });

  return updated.count > 0 ? task : null;
});
```

## 定时任务

使用 node-cron 每分钟扫描超时任务：

```javascript
// 每分钟执行
cron.schedule('* * * * *', async () => {
  await prisma.task.updateMany({
    where: { status: 'doing', deadline: { lt: new Date() } },
    data: { status: 'pending', claimerId: null, deadline: null },
  });
});
```

## 前端状态管理（Provider）

```dart
// 核心 Provider
class UserProvider extends ChangeNotifier { ... }
class TaskProvider extends ChangeNotifier { ... }
class TimerProvider extends ChangeNotifier { ... }
```

## 开发顺序

1. **Phase 1: 后端基础设施** → Prisma schema、Express 骨架、JWT 中间件
2. **Phase 2: 用户系统** → 短信验证码、登录 API
3. **Phase 3: OSS 直传** → STS 接口、Flutter 上传组件
4. **Phase 4: 发布任务** → 表单页面 + 后端接口
5. **Phase 5: 抽盲盒 + 倒计时** → 核心交互流程
6. **Phase 6: 提交完成** → 提交 + 奖励发放
7. **Phase 7: 定时任务** → 超时释放脚本
8. **Phase 8: UI 打磨** → 动画、主题、布局优化
9. **Phase 9: 上架必需** → 内容安全审核、用户协议、举报功能

## 页面路由

| 路由 | 页面 | 说明 |
|------|------|------|
| /login | 登录页 | 手机号 + 验证码 |
| / | 首页(任务列表) | 展示我的任务 |
| /draw | 盲盒抽奖页 | 抽盲盒动画 |
| /publish | 发布任务页 | 表单发布 |
| /task/:id | 任务执行页 | 60 秒倒计时 + 提交 |
| /profile | 个人中心 | 虚拟币余额、历史记录 |

## 未解决问题（TBD）

无 — 全部需求已覆盖。
