# 人生重开模拟器 — 设计文档

## 1. 项目概述

基于 JFinal 框架的前后端不分离 Web 应用，模拟人生从出生到死亡的随机事件驱动游戏。

- **框架**：JFinal 5.x
- **前端**：Layui 2.x + 自定义 CSS
- **模板引擎**：Enjoy
- **数据库**：MySQL 8.x + JFinal ActiveRecord
- **缓存**：Redis（jfinal-redis 插件）

## 2. 评审指标覆盖

| 指标 | 分值 | 对应实现 |
|------|------|----------|
| 2个表以上的增删查改 | 40 | 5张表：user, game_result, event, talent, ending |
| 前端页面技术 | 10 | Layui + 自定义 Apple 风格 CSS |
| 合理使用验证器 | 10 | UserValidator, GameValidator |
| 分页功能 | 10 | 历史记录页面分页（JFinal paginate + Layui table） |
| 合理使用拦截器 | 10 | LoginInterceptor, GameInterceptor |
| 合理使用 Enjoy 模板 | 10 | 公共布局 #include、条件渲染 #if、循环 #for |
| 其他 | 10 | Redis 缓存 + 排行榜、MD5 加密、注释完备 |

## 3. 数据库设计

### 3.1 user — 用户表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int, PK, auto | 用户ID |
| username | varchar(50), unique | 用户名 |
| password | varchar(100) | 密码（MD5加密） |
| nickname | varchar(50) | 昵称 |
| create_time | datetime | 注册时间 |

### 3.2 game_result — 游戏结果表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int, PK, auto | 记录ID |
| user_id | int, FK | 用户ID |
| final_age | int | 终止年龄 |
| wealth | int | 最终财富 |
| health | int | 最终健康 |
| happiness | int | 最终快乐 |
| social | int | 最终社交 |
| achievement | int | 最终成就 |
| ending_name | varchar(100) | 结局名称 |
| talents | varchar(200) | 选择的天赋（逗号分隔） |
| create_time | datetime | 游戏结束时间 |

### 3.3 event — 事件表（种子数据）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int, PK, auto | 事件ID |
| name | varchar(100) | 事件名称 |
| description | text | 事件描述 |
| min_age | int | 最小触发年龄 |
| max_age | int | 最大触发年龄 |
| rarity | varchar(20) | 稀有度: common/rare/epic/hidden |
| type | varchar(20) | 类型: funny/dark/normal |
| effects | varchar(500) | 属性变化JSON，如 `{"health":-1,"happiness":2}` |
| weight | int | 触发权重（越大越容易触发） |

### 3.4 talent — 天赋表（种子数据）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int, PK, auto | 天赋ID |
| name | varchar(50) | 天赋名称 |
| description | varchar(200) | 天赋描述 |
| effects | varchar(500) | 属性加成JSON，如 `{"intelligence_growth":2}` |

### 3.5 ending — 结局表（种子数据）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int, PK, auto | 结局ID |
| name | varchar(100) | 结局名称 |
| description | text | 结局描述 |
| condition_type | varchar(50) | 触发条件类型：health_zero/age_reach/attribute_high/special |
| condition_value | varchar(200) | 触发条件值JSON，如 `{"attribute":"wealth","threshold":100}` 或 `{"age":80}` |
| priority | int | 优先级（多条件满足时取高优先级，100最高） |

## 4. 项目架构（MVC）

```
src/main/java/com/life/
├── config/
│   └── LifeConfig.java          # JFinal 全局配置（路由、拦截器、数据库、Redis、模板引擎）
├── interceptor/
│   ├── LoginInterceptor.java    # 登录拦截器：未登录跳转登录页
│   └── GameInterceptor.java     # 游戏拦截器：校验游戏是否进行中
├── validator/
│   ├── UserValidator.java       # 注册/登录参数验证
│   └── GameValidator.java       # 游戏参数验证
├── model/
│   ├── User.java                # 用户模型（映射 user 表）
│   ├── GameResult.java          # 游戏结果模型（映射 game_result 表）
│   ├── Event.java               # 事件模型（映射 event 表）
│   ├── Talent.java              # 天赋模型（映射 talent 表）
│   └── Ending.java              # 结局模型（映射 ending 表）
├── service/
│   ├── UserService.java         # 用户业务逻辑（注册、登录校验）
│   ├── GameService.java         # 游戏核心逻辑（年龄推进、事件触发、结局判定）
│   ├── EndingService.java       # 结局计算逻辑
│   ├── CacheService.java        # Redis 缓存管理（加载/读取静态数据）
│   └── RankService.java         # Redis 排行榜（写入/查询排名）
├── controller/
│   ├── IndexController.java     # 首页 + 排行榜展示
│   ├── UserController.java      # 用户注册/登录/个人信息
│   └── GameController.java      # 游戏主流程（开局、推进、结束、历史）
└── game/
    ├── GameState.java           # 游戏状态对象（存入 Session）
    └── GameEngine.java          # 游戏引擎（属性计算、天赋效果、事件效果）
```

### 前端页面

```
src/main/webapp/
├── WEB-INF/
│   └── view/
│       ├── layout.html          # 公共布局模板（Enjoy #include）
│       ├── index.html           # 首页 + 排行榜
│       ├── user/
│       │   ├── login.html       # 登录页
│       │   └── register.html    # 注册页
│       ├── game/
│       │   ├── start.html       # 开局（分配属性 + 选天赋）
│       │   ├── playing.html     # 游戏主界面
│       │   ├── result.html      # 结局展示页
│       │   └── history.html     # 历史记录（分页列表）
│       └── common/
│           ├── header.html      # 顶部导航
│           └── footer.html      # 底部
└── static/
    ├── layui/                   # Layui 框架文件
    └── css/
        └── life.css             # 自定义主题样式
```

### 请求流程

```
浏览器请求 → JFinal路由 → LoginInterceptor（判断登录）
                         → Validator（参数校验）
                         → Controller（接收参数、调用Service）
                         → Service（业务逻辑、操作Model/Redis）
                         → Model/Db（数据库操作）
                         → Controller → Enjoy模板渲染 → HTML响应
```

## 5. 游戏核心逻辑

### 5.1 开局流程

1. 进入游戏页面，展示属性分配面板
2. 玩家分配 20 点属性到：智力、颜值、体质、家境、幸运
3. 可点击"随机分配"按钮自动打散 20 点
4. 从天赋表随机抽取 10 个，玩家选择 3 个
5. 天赋效果生效（直接加属性或标记成长加成）
6. 创建 GameState 存入 Session，进入游戏

### 5.2 GameState 结构

```java
class GameState {
    int age;                          // 当前年龄，从 0 开始
    int intelligence;                 // 智力
    int appearance;                   // 颜值
    int constitution;                 // 体质
    int family;                       // 家境
    int luck;                         // 幸运
    int wealth;                       // 财富
    int health;                       // 健康
    int happiness;                    // 快乐
    int social;                       // 社交
    int achievement;                  // 成就
    List<String> selectedTalents;     // 已选天赋 ID
    List<String> eventLog;            // 事件日志
    Map<String, Integer> talentBonuses; // 天赋成长加成标记
}
```

### 5.3 年龄推进机制

点击"下一年"时执行：

1. `age++`
2. 应用天赋成长加成（如"天才少年"每岁智力+2）
3. 根据 age 确定事件池：
   - 0-6 岁：成长事件
   - 7-18 岁：校园事件
   - 19-30 岁：大学/就业/恋爱事件
   - 31-50 岁：事业/家庭事件
   - 51 岁+：养老/健康事件
4. 从事件池中按权重随机抽取 1 个事件
5. 应用事件效果到属性
6. 检查死亡判定
7. 检查结局触发
8. 记录事件到 eventLog
9. 刷新页面

### 5.4 死亡判定机制

每岁推进时按顺序检查：

**强制死亡**：`health <= 0` 时立即死亡，触发对应死因事件。

**概率死亡**（年龄 + 运气影响）：

```
基础死亡概率 = 0
当 age >= 50 时：基础概率 = (age - 50) * 0.5%
幸运修正：基础概率 -= luck * 0.1%
健康修正：基础概率 += (50 - health) * 0.2%

最终概率 clamp 到 0%~30%
每岁 roll 一次随机数，命中则死亡
```

死亡后触发死因事件写入日志，进入结局判定。

### 5.5 结局触发规则

每岁推进后检查，优先级高的先匹配：

| 优先级 | 条件 | 结局 |
|--------|------|------|
| 100 | health <= 0 | 英年早逝 |
| 100 | age >= 80 | 长寿老人 |
| 90 | wealth >= 100 | 世界首富 |
| 90 | achievement >= 100 | 人生赢家 |
| 80 | 某属性极高 + 特定天赋 | 程序员秃头/电竞冠军/网红等 |
| 50 | 无特殊条件，age >= 60 | 普通打工人/躺平大师 |
| 10 | age >= 40 + 低属性 | 社畜/失业青年 |

共 10-15 个结局，覆盖各种属性组合。

### 5.6 属性变化规则

- 属性值范围：0-100（clamp）
- 属性联动：
  - health <= 20 时，happiness 每岁 -2
  - wealth <= 0 时，health 每岁 -1
  - social 高时，happiness 有额外加成

## 6. Redis 应用

### 6.1 缓存层

- `CacheService.java`：启动时加载事件/天赋/结局到 Redis
- `LifeConfig.afterJFinalStart()` 中调用初始化
- 游戏中读事件从 Redis 取，不查 DB
- 缓存 key：`game:events`、`game:talents`、`game:endings`

### 6.2 排行榜

- `RankService.java`：封装排行榜操作
- 游戏结束时：`ZADD game:rank:achievement {score} {userId:username}`
- 首页展示 Top 10：`ZREVRANGE game:rank:achievement 0 9`
- 支持多维度：成就榜、财富榜、长寿榜
- 首页用 Layui 表格展示排行榜

## 7. 前端 UI 设计

### 7.1 设计理念

- 参考 Apple/Linear/Stripe 极简风格
- 深色背景 (#0a0a0a) + 白色文字 + 霓虹色点缀（青色 #00f0ff / 紫色 #a855f7）
- 大量留白，信息层级清晰
- 大号字体 + 细字重
- 卡片无边框，用微弱背景色差区分层级
- 动画克制，属性变化用数字跳动

### 7.2 页面设计

**开局页面**：属性用加减按钮调节，天赋卡片可点击选中，选中高亮霓虹边框。

**游戏主界面**：左侧属性面板（纯数字 + 颜色变化），右侧事件日志（滚动区域），年龄超大号字体居中，"下一年"按钮霓虹渐变。

**结局页面**：结局名称大号居中配英文副标题，属性网格排列，按钮线框风格。

**历史记录**：极简表格，无明显边框，悬停高亮，支持分页。

### 7.3 实现要点

- Layui 仅作为底层组件库，大量覆盖默认样式
- CSS 变量统一管理颜色主题
- 全局字体：`-apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif`
- 属性值颜色：>70 青色 / 40-70 白色 / <40 红色

## 8. 拦截器

**LoginInterceptor**：拦截 `/game/*`，检查 Session 中 `loginUser`，未登录重定向到 `/user/login`。放行 `/user/login`、`/user/register`、`/`。

**GameInterceptor**：拦截 `/game/playing`、`/game/nextYear`，检查 Session 中 `gameState`，无游戏状态重定向到 `/game/start`。

## 9. 验证器

**UserValidator**：注册时验证用户名 3-20 位、密码 6-20 位、昵称非空；登录时验证用户名和密码非空。验证失败通过 `addError(key, msg)` 返回错误，页面用 `#if(errMsg)` 展示。

**GameValidator**：属性分配总点数 = 20 且每项 >= 0；天赋选择必须 3 个且为有效 ID。

## 10. CRUD 操作覆盖

| 表 | Create | Read | Update | Delete |
|----|--------|------|--------|--------|
| user | 注册 | 登录查询、个人信息 | 修改昵称/密码 | 注销账号 |
| game_result | 游戏结束写入 | 历史记录查询（分页） | — | 删除历史记录 |
| event | 种子数据初始化 | 游戏中查询事件池 | 后台可扩展 | 后台可扩展 |
| talent | 种子数据初始化 | 开局随机抽取 | 后台可扩展 | 后台可扩展 |
| ending | 种子数据初始化 | 结局判定查询 | 后台可扩展 | 后台可扩展 |

注：event、talent、ending 表以种子数据 + 查询为主，代码层面保留完整 DAO 操作能力，满足评审"2个表以上"要求。

## 10. 页面路由

| 路径 | Controller | 方法 | 说明 |
|------|-----------|------|------|
| `/` | IndexController | index | 首页 + 排行榜 |
| `/user/login` | UserController | login | 登录页（GET展示/POST提交） |
| `/user/register` | UserController | register | 注册页（GET展示/POST提交） |
| `/user/logout` | UserController | logout | 退出登录 |
| `/user/profile` | UserController | profile | 个人信息页 |
| `/user/update` | UserController | update | 修改昵称/密码 |
| `/user/delete` | UserController | deleteAccount | 注销账号 |
| `/game/start` | GameController | start | 开局页面 |
| `/game/create` | GameController | create | 创建游戏（提交属性+天赋） |
| `/game/playing` | GameController | playing | 游戏主界面 |
| `/game/nextYear` | GameController | nextYear | 推进一年 |
| `/game/result` | GameController | result | 结局页面 |
| `/game/history` | GameController | history | 历史记录（分页） |
| `/game/delete` | GameController | delete | 删除历史记录 |
