# 人生重开模拟器

基于 JFinal 5 + MySQL + Redis 的人生模拟游戏 Web 应用。每次开局随机分配属性、选择天赋，逐年推进人生，触发随机事件，最终达成不同结局。

## 技术栈

| 组件 | 版本 |
|------|------|
| JDK | 17 |
| JFinal | 5.2.2 |
| MySQL | 5.7+ |
| Redis | 6.0+ |
| Tomcat | 9.x（Servlet 4.0） |
| Maven | 3.6+ |

## 项目启动

### 1. 环境准备

确保本地已安装并启动以下服务：

- **MySQL** — 运行在 `localhost:3306`
- **Redis** — 运行在 `localhost:6379`
- **JDK 17**
- **Tomcat 9.x**（注意：不要使用 Tomcat 10+，JFinal 5.2.2 依赖 `javax.servlet`，与 Tomcat 10 的 `jakarta.servlet` 不兼容）
- **Maven 3.6+**

### 2. 初始化数据库

在 MySQL 中执行初始化脚本，创建数据库和表，并导入种子数据：

```bash
mysql -u root -p < src/main/resources/sql/init.sql
```

或者在 MySQL 客户端中手动执行：

```sql
CREATE DATABASE IF NOT EXISTS life_restart DEFAULT CHARACTER SET utf8mb4;
USE life_restart;
SOURCE src/main/resources/sql/init.sql;
```

该脚本会自动创建 `life_restart` 数据库，并初始化以下 5 张表及种子数据：

| 表名 | 说明 |
|------|------|
| `user` | 用户账号信息 |
| `game_result` | 游戏结果记录 |
| `event` | 随机事件库（约 40 个） |
| `talent` | 天赋库（15 个） |
| `ending` | 结局库（18 个） |

### 3. 配置数据库连接

编辑 `src/main/java/com/life/config/LifeConfig.java`，修改数据库和 Redis 连接信息：

```java
// MySQL
DruidPlugin druidPlugin = new DruidPlugin(
    "jdbc:mysql://localhost:3306/life_restart?characterEncoding=utf8&serverTimezone=Asia/Shanghai",
    "root", "你的密码",
    "com.mysql.cj.jdbc.Driver"
);

// Redis
JedisPool jedisPool = new JedisPool(poolConfig, "localhost", 6379);
```

### 4. Maven 构建

```bash
mvn clean package
```

### 5. 部署到 Tomcat

将 `target/enterprise335-1.0-SNAPSHOT.war` 复制到 Tomcat 的 `webapps/` 目录，然后启动 Tomcat：

```bash
# Windows
catalina.bat run

# Linux/Mac
./catalina.sh run
```

或者在 IntelliJ IDEA 中配置 Tomcat 9 作为 Application Server，直接运行项目。

### 6. 访问应用

浏览器打开：

```
http://localhost:8080/enterprise335-1.0-SNAPSHOT/
```

## 游戏机制

### 属性系统

开局时玩家拥有 **20 点**自由属性点，可分配到以下 5 项基础属性（每项 0-20）：

| 属性 | 说明 |
|------|------|
| 智力 | 影响学业、成就相关事件 |
| 颜值 | 影响社交、恋爱相关事件 |
| 体质 | 影响健康、运动相关事件 |
| 家境 | 影响财富、成长环境 |
| 幸运 | 影响随机事件的好坏概率 |

游戏过程中还会产生以下动态属性（初始值见下表）：

| 属性 | 初始值 | 范围 |
|------|--------|------|
| 健康 (health) | 50 | 0-100 |
| 快乐 (happiness) | 50 | 0-100 |
| 社交 (social) | 50 | 0-100 |
| 财富 (wealth) | 20 | 无上限 |
| 成就 (achievement) | 0 | 无上限 |

### 天赋系统

开局时可从 15 个天赋中**最多选择 3 个**。天赋分为三类效果：

- **直接加成** — 立即增加属性值（如「欧皇附体」幸运+10）
- **成长加成** — 每岁自动增加属性（如「天才少年」智力成长+2）
- **特殊效果** — 改变游戏规则（如「佛系青年」所有属性变化减半）

### 事件系统

每年推进时，系统根据年龄从对应事件池中**加权随机**抽取一个事件触发：

| 年龄段 | 事件池 | 典型事件 |
|--------|--------|----------|
| 0-6 岁 | 童年 | 学走路、上幼儿园、生病住院 |
| 7-18 岁 | 校园 | 考试第一、初恋、高考、竞赛获奖 |
| 19-30 岁 | 青年 | 毕业、找工作、创业、恋爱 |
| 31-50 岁 | 中年 | 升职、结婚、买房、中年危机 |
| 51 岁+ | 老年 | 退休、健康问题、抱孙子 |

事件稀有度分为：`common`（普通）、`rare`（稀有）、`epic`（史诗）、`hidden`（隐藏），稀有度越高权重越低。

### 属性联动

属性之间存在相互影响：

- 健康 ≤ 20 → 快乐每岁额外 -2
- 财富 ≤ 0 → 健康每岁 -1
- 社交 > 70 → 快乐额外 +1

### 生死判定

- **强制死亡**：健康降为 0 时立即死亡
- **概率死亡**：50 岁以后，每岁有概率自然死亡
  - 基础概率 = (年龄 - 50) × 0.5%
  - 幸运降低概率，健康低于 50 增加概率
  - 概率上限 30%

### 结局系统

游戏结束时按优先级匹配结局，共有 18 种结局，触发条件分为三类：

| 条件类型 | 说明 | 示例 |
|----------|------|------|
| `health_zero` | 健康归零 | 英年早逝 |
| `age_reach` | 活到指定年龄 | 长寿老人（80 岁）、普通打工人（60 岁） |
| `attribute_high` | 属性达到阈值 | 世界首富（财富≥100）、学术大牛（智力≥90） |
| `special` | 天赋+属性组合 | 躺平大师（持有「摆烂大师」天赋且快乐≥80） |

### 排行榜

游戏结束后结果会保存到数据库，并通过 Redis 维护三个排行榜：

- **成就排行** — 按成就值排序
- **财富排行** — 按财富值排序
- **年龄排行** — 按终年排序

## 项目结构

```
src/main/
├── java/com/life/
│   ├── config/LifeConfig.java       # JFinal 全局配置
│   ├── controller/                   # 控制器层
│   │   ├── IndexController.java     # 首页 + 排行榜
│   │   ├── UserController.java      # 登录、注册、个人中心
│   │   └── GameController.java      # 游戏核心流程
│   ├── game/
│   │   ├── GameEngine.java          # 游戏引擎（核心逻辑）
│   │   └── GameState.java           # 游戏状态 POJO
│   ├── interceptor/                  # 拦截器
│   │   ├── LoginInterceptor.java    # 登录校验
│   │   └── GameInterceptor.java     # 游戏状态校验
│   ├── model/                        # ActiveRecord 模型
│   ├── service/                      # 业务逻辑层
│   └── validator/                    # 参数校验
├── resources/
│   ├── sql/init.sql                  # 数据库初始化脚本
│   └── view/                         # 模板文件（JFinal Enjoy）
└── webapp/
    └── static/                       # 静态资源（CSS、JS）
```
