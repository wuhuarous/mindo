# 一分钟差事铺

抽盲盒 · 做任务 · 赚金币 — 一个基于 Flutter + Node.js 的趣味任务社交应用。

## 项目结构

```
mindo/
├── task_shop/              # Flutter 前端
│   ├── lib/
│   │   ├── config/         # 设计系统 (AppColors/AppTokens)
│   │   ├── models/         # 数据模型 (Task, User)
│   │   ├── pages/          # 页面
│   │   │   ├── login_page.dart        # 登录页（一键体验）
│   │   │   ├── home_page.dart         # 首页（Bento Box）
│   │   │   ├── draw_page.dart         # 抽盲盒
│   │   │   ├── publish_page.dart      # 发布任务
│   │   │   ├── task_execute_page.dart # 执行任务（60s 倒计时）
│   │   │   ├── task_detail_page.dart  # 任务详情
│   │   │   └── profile_page.dart      # 个人中心
│   │   ├── providers/      # 状态管理 (Provider)
│   │   ├── services/       # API + 上传服务
│   │   └── widgets/        # 通用组件
│   └── pubspec.yaml
├── task_shop_server/        # Node.js 后端
│   ├── prisma/
│   │   ├── schema.prisma   # 数据库模型
│   │   └── seed.js         # 种子数据
│   ├── src/
│   │   ├── controllers/    # 路由控制器
│   │   ├── middleware/      # JWT 认证中间件
│   │   ├── routes/         # 路由定义
│   │   ├── services/       # 业务逻辑层
│   │   └── jobs/           # 定时任务（任务过期）
│   └── package.json
└── .gitignore
```

## 功能概览

| 功能 | 说明 |
|------|------|
| 一键登录 | 开发环境免验证码，生成随机手机号直接进入 |
| 发布任务 | 支持文案（限200字）和图片，支付金币发布 |
| 盲盒抽取 | 随机分配未领取任务，原子化并发安全 |
| 60s 倒计时 | 领取后限时完成，超时任务自动过期 |
| 三格式回复 | 文案 / 图片 / 视频回复，不限制任务类型 |
| 金币系统 | 初始 20 金币，完成后赚取，发布时消耗 |
| 任务详情 | 发布者查看完成内容和回复图片预览 |
| 头像系统 | 24 个 emoji 头像可选，本地持久化 |
| 定时过期 | 每 10 分钟自动清理过期任务 |

## 技术栈

**前端**：Flutter 3.x · Provider · google_fonts (Fredoka + Nunito) · Material 3 · Claymorphism

**后端**：Node.js · Express · Prisma ORM · PostgreSQL · JWT · node-cron

**存储**：腾讯云 COS（multipart 上传）

**设计**：Pet Tech 调色板 `#F97316` · Claymorphism 3D 阴影 · Bento Box 布局

## 快速开始

### 环境要求

- Flutter SDK 3.x
- Node.js 18+
- PostgreSQL 14+
- 腾讯云 COS 存储桶（图片上传）

### 1. 后端启动

```bash
cd task_shop_server
cp .env.example .env   # 编辑 .env 填入数据库和 COS 配置
npm install
npx prisma migrate dev
npm run db:seed         # 导入示例数据
npm run dev             # 启动在 localhost:3000
```

### 2. 前端启动

```bash
cd task_shop
flutter pub get
flutter run
```

### 环境变量 (.env)

```env
PORT=3000
JWT_SECRET=your-jwt-secret
NODE_ENV=development
DATABASE_URL=postgresql://postgres:password@localhost:5432/task_shop

# 腾讯云 COS
COS_SECRET_ID=your-secret-id
COS_SECRET_KEY=your-secret-key
COS_BUCKET=pickle-1259519965
COS_REGION=ap-guangzhou
COS_DOMAIN=https://pickle-1259519965.cos.ap-guangzhou.myqcloud.com

# 短信（生产环境）
SMS_ACCESS_KEY_ID=your-sms-key
SMS_ACCESS_KEY_SECRET=your-sms-secret
SMS_SIGN_NAME=your-sign-name
SMS_TEMPLATE_CODE=SMS_xxxxxx
```

### API 端点

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/auth/send-code` | 发送验证码 |
| POST | `/api/auth/login` | 验证码登录 |
| GET | `/api/tasks` | 任务列表 |
| POST | `/api/tasks` | 发布任务 |
| POST | `/api/tasks/draw` | 盲盒抽取 |
| POST | `/api/tasks/:id/claim` | 领取任务 |
| POST | `/api/tasks/:id/submit` | 提交完成 |
| GET | `/api/tasks/:id` | 任务详情 |
| POST | `/api/upload` | 上传文件到 COS |
