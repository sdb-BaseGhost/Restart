-- ============================================================
-- 人生重开模拟器 - 数据库初始化脚本
-- 数据库: MySQL 5.7+ / MariaDB 10.3+
-- 字符集: utf8mb4
-- ============================================================

-- ============================================================
-- 第一部分: 建表语句
-- ============================================================

-- ------------------------------------------------------------
-- 1. user 表 - 用户信息
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `user` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `username` VARCHAR(50) NOT NULL UNIQUE,
  `password` VARCHAR(100) NOT NULL,
  `nickname` VARCHAR(50) NOT NULL,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- 2. game_result 表 - 游戏结果
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `game_result` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `final_age` INT NOT NULL,
  `wealth` INT DEFAULT 0,
  `health` INT DEFAULT 50,
  `knowledge` INT DEFAULT 0,
  `social` INT DEFAULT 50,
  `achievement` INT DEFAULT 0,
  `ending_name` VARCHAR(100),
  `talents` VARCHAR(200),
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `user`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- 3. event 表 - 事件
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `event` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `description` TEXT,
  `min_age` INT DEFAULT 0,
  `max_age` INT DEFAULT 100,
  `rarity` VARCHAR(20) DEFAULT 'common',
  `type` VARCHAR(20) DEFAULT 'normal',
  `effects` VARCHAR(500),
  `weight` INT DEFAULT 10,
  `include_cond` VARCHAR(500) COMMENT '触发条件表达式，为空表示无条件',
  `exclude_cond` VARCHAR(500) COMMENT '排除条件表达式，为空不排除',
  `no_repeat` TINYINT DEFAULT 0 COMMENT '是否不可重复触发：0可重复 1仅一次'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- 4. talent 表 - 天赋
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `talent` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  `description` VARCHAR(200),
  `effects` VARCHAR(500)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- 5. ending 表 - 结局
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `ending` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `description` TEXT,
  `condition_type` VARCHAR(50) NOT NULL,
  `condition_value` VARCHAR(200),
  `priority` INT DEFAULT 50
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 第二部分: 种子数据 - 天赋 (talent)
-- ============================================================

INSERT INTO `talent` (`name`, `description`, `effects`) VALUES
('天才少年', '智力成长+2，每岁智力自动增加', '{"intelligence_growth":2}'),
('欧皇附体', '幸运+15，好事更容易降临', '{"luck":15}'),
('富二代', '家境+12，出生就在罗马', '{"family":12}'),
('社恐', '社交-5，但知识+3', '{"social":-5,"knowledge":3}'),
('卷王', '智力成长+1，成就成长+1', '{"intelligence_growth":1,"achievement_growth":1}'),
('非酋', '幸运-8，运气不太好', '{"luck":-8}'),
('摆烂大师', '成就增长减半，无欲无求', '{"master_slacker":1}'),
('熬夜冠军', '体质-5，智力+8，用生命在学习', '{"constitution":-5,"intelligence":8}'),
('键盘侠', '社交+8，体质-3，网上重拳出击', '{"social":8,"constitution":-3}'),
('天选打工人', '财富增长+50%，天生打工命', '{"worker_fate":1}'),
('运动健将', '体质+8，健康每岁+1', '{"constitution":8,"health_growth":1}'),
('文艺青年', '智力+5，知识+5，诗和远方', '{"intelligence":5,"knowledge":5}'),
('社交达人', '社交+12，朋友遍天下', '{"social":12}'),
('佛系青年', '所有属性变化减半，无欲无求', '{"zen_youth":1}'),
('天降横财', '财富+30，一夜暴富', '{"wealth":30}');

-- ============================================================
-- 第三部分: 种子数据 - 事件 (event)
-- ============================================================

-- ------------------------------------------------------------
-- 0-6岁: 成长事件
-- ------------------------------------------------------------
INSERT INTO `event` (`name`, `description`, `min_age`, `max_age`, `rarity`, `type`, `effects`, `weight`) VALUES
('学走路', '你迈出了人生的第一步，虽然摔了个狗吃屎', 1, 2, 'common', 'funny', '{"health":2,"constitution":2}', 10),
('第一次说话', '你喊出了第一声"妈妈"，全家人激动得哭了', 1, 2, 'common', 'normal', '{"intelligence":3,"knowledge":3}', 10),
('学会自己吃饭', '虽然把饭弄得到处都是，但你很自豪', 2, 3, 'common', 'funny', '{"health":2,"constitution":2}', 10),
('上幼儿园', '你背着小书包去了幼儿园，哭着要回家', 3, 5, 'common', 'normal', '{"social":5,"intelligence":3,"knowledge":3}', 10),
('幼儿园被表扬', '老师夸你是最乖的小朋友，奖励了一朵小红花', 3, 6, 'common', 'funny', '{"achievement":3,"social":2}', 10),
('生病住院', '你发了高烧，住了三天医院', 0, 6, 'rare', 'dark', '{"health":-8,"constitution":-3}', 5),
('捡到一百块', '你在地上捡到了一百块钱，买了一堆零食', 4, 6, 'rare', 'funny', '{"wealth":10}', 5),
('被狗咬了', '你路过邻居家门口，被冲出来的大狗咬了一口', 2, 6, 'rare', 'dark', '{"health":-8,"constitution":-3,"social":-2}', 5),
('从树上摔下来', '你爬树掏鸟窝，结果脚一滑摔了下来', 3, 6, 'rare', 'dark', '{"health":-10,"constitution":-5}', 5),
('走丢了', '你在商场和爸妈走散了，哭了好久才被找到', 2, 5, 'rare', 'dark', '{"social":-3,"health":-3}', 5),
('食物中毒', '你偷吃了过期的零食，上吐下泻了好几天', 3, 6, 'rare', 'dark', '{"health":-8,"constitution":-4}', 5);

-- ------------------------------------------------------------
-- 7-18岁: 校园事件
-- ------------------------------------------------------------
INSERT INTO `event` (`name`, `description`, `min_age`, `max_age`, `rarity`, `type`, `effects`, `weight`) VALUES
('考试第一名', '你考了全班第一，妈妈奖励你吃大餐', 7, 18, 'common', 'normal', '{"intelligence":5,"achievement":5,"knowledge":5}', 10),
('被老师批评', '上课偷看漫画被老师抓到了，罚站一节课', 7, 18, 'common', 'funny', '{"social":-2,"knowledge":-1}', 10),
('交到好朋友', '你认识了一个志趣相投的好朋友', 7, 18, 'common', 'normal', '{"social":5,"knowledge":2}', 10),
('参加运动会', '你在运动会上奋力拼搏，虽然没拿到名次', 7, 18, 'common', 'normal', '{"health":5,"constitution":3}', 10),
('校园霸凌', '你被高年级的同学欺负了，留下了心理阴影', 7, 15, 'rare', 'dark', '{"social":-5,"health":-5,"constitution":-2}', 5),
('初恋', '你偷偷喜欢上了同桌，写了人生第一封情书', 12, 18, 'rare', 'normal', '{"social":5,"knowledge":2}', 5),
('高考', '你经历了人生中最重要的考试——高考', 17, 18, 'common', 'normal', '{"intelligence":8,"achievement":10,"knowledge":8}', 10),
('竞赛获奖', '你参加了全国学科竞赛并获奖', 12, 18, 'epic', 'normal', '{"intelligence":15,"achievement":15,"knowledge":12}', 3),
('沉迷游戏', '你沉迷于网络游戏，成绩一落千丈', 10, 18, 'rare', 'funny', '{"intelligence":-5,"knowledge":-5,"achievement":-5}', 5),
('表白被拒', '你鼓起勇气表白，结果被发了好人卡', 14, 18, 'rare', 'funny', '{"social":-3,"intelligence":-1}', 5),
('考试作弊被抓', '你铤而走险抄了同桌的答案，被监考老师当场抓获', 10, 18, 'rare', 'dark', '{"social":-8,"achievement":-10,"knowledge":-3}', 5),
('骨折', '你在体育课上不小心摔断了胳膊，休养了三个月', 8, 18, 'rare', 'dark', '{"health":-12,"constitution":-8,"knowledge":-5}', 5),
('被孤立', '班里的小团体开始排挤你，午饭只能一个人吃', 10, 16, 'rare', 'dark', '{"social":-10,"health":-5,"intelligence":-3}', 5),
('近视加深', '你天天熬夜看小说，近视度数飙升', 10, 18, 'common', 'dark', '{"health":-5,"constitution":-2}', 8),
('家里破产', '家里生意失败，你不得不省吃俭用', 12, 18, 'epic', 'dark', '{"wealth":-20,"social":-5,"health":-3}', 3);

-- ------------------------------------------------------------
-- 19-30岁: 青年事件
-- ------------------------------------------------------------
INSERT INTO `event` (`name`, `description`, `min_age`, `max_age`, `rarity`, `type`, `effects`, `weight`) VALUES
('大学毕业', '你顺利拿到了毕业证书，踏入社会', 21, 24, 'common', 'normal', '{"intelligence":5,"achievement":10,"knowledge":10}', 10),
('找到第一份工作', '你找到了人生中第一份正式工作', 20, 26, 'common', 'normal', '{"wealth":15,"achievement":8,"knowledge":3}', 10),
('被公司裁员', '公司效益不好，你被优化了', 22, 30, 'rare', 'dark', '{"wealth":-10,"achievement":-5,"social":-3}', 5),
('开始创业', '你辞去了工作，开始了创业之路', 22, 30, 'rare', 'normal', '{"wealth":-15,"achievement":10,"knowledge":5}', 5),
('创业成功', '你的公司获得了融资，身价暴涨', 24, 30, 'epic', 'normal', '{"wealth":50,"achievement":30,"social":10}', 3),
('恋爱', '你遇到了心仪的对象，开始了一段恋情', 18, 30, 'common', 'normal', '{"social":5,"knowledge":2}', 10),
('分手', '你和恋人分手了，痛哭了一场', 18, 30, 'rare', 'dark', '{"social":-5,"health":-3}', 5),
('加班猝死未遂', '连续加班一个月后，你在工位上晕倒了', 22, 30, 'epic', 'dark', '{"health":-20,"wealth":10,"constitution":-5}', 3),
('买彩票中奖', '你随手买了一张彩票，竟然中了大奖', 18, 30, 'epic', 'funny', '{"wealth":40,"achievement":5}', 3),
('考研上岸', '你成功考上了研究生', 21, 26, 'rare', 'normal', '{"intelligence":12,"achievement":12,"knowledge":15}', 5),
('租房被骗', '你交了一年的房租，结果中介跑路了', 20, 28, 'rare', 'dark', '{"wealth":-20,"social":-3,"health":-3}', 5),
('被诈骗', '你接到了一个电话，被骗走了所有积蓄', 20, 30, 'epic', 'dark', '{"wealth":-30,"health":-8,"intelligence":-3}', 3),
('车祸', '你骑电动车被汽车撞了，在医院躺了两个月', 20, 30, 'epic', 'dark', '{"health":-20,"constitution":-10,"wealth":-10}', 3),
('抑郁发作', '你陷入了严重的抑郁状态，对一切都失去了兴趣', 20, 30, 'rare', 'dark', '{"health":-15,"social":-10,"intelligence":-5,"achievement":-5}', 5),
('信用卡透支', '你过度消费，信用卡欠了一大笔钱', 20, 30, 'rare', 'dark', '{"wealth":-15,"health":-3}', 8);

-- ------------------------------------------------------------
-- 31-50岁: 中年事件
-- ------------------------------------------------------------
INSERT INTO `event` (`name`, `description`, `min_age`, `max_age`, `rarity`, `type`, `effects`, `weight`) VALUES
('升职加薪', '你升职了，工资翻了一番', 28, 50, 'common', 'normal', '{"wealth":25,"achievement":15,"knowledge":5}', 10),
('结婚', '你和心爱的人步入了婚姻的殿堂', 25, 40, 'common', 'normal', '{"social":10,"achievement":10,"wealth":5}', 10),
('买房', '你终于攒够了首付，买了人生第一套房', 28, 45, 'rare', 'normal', '{"wealth":-25,"achievement":15,"social":5}', 5),
('中年危机', '你突然觉得人生毫无意义，陷入了深深的迷茫', 35, 50, 'rare', 'dark', '{"health":-5,"social":-5,"knowledge":-3}', 5),
('离婚', '你和伴侣离婚了，财产对半分', 30, 50, 'epic', 'dark', '{"wealth":-15,"social":-10,"health":-5}', 3),
('孩子出生', '你有了自己的孩子，初为人父/人母', 28, 45, 'common', 'normal', '{"achievement":10,"wealth":-8,"social":5}', 10),
('投资失败', '你把积蓄投入股市，结果亏了一大半', 30, 50, 'rare', 'dark', '{"wealth":-25,"health":-3,"knowledge":-2}', 5),
('升职为高管', '你成为了公司的高管', 35, 50, 'epic', 'normal', '{"wealth":40,"achievement":25,"social":10,"knowledge":5}', 3),
('被降职', '公司架构调整，你被降职降薪', 32, 50, 'rare', 'dark', '{"wealth":-20,"achievement":-15,"social":-5}', 5),
('父母重病', '你的父母突然病重，你需要花大量时间和金钱照顾', 35, 50, 'rare', 'dark', '{"wealth":-20,"health":-10,"social":-5}', 5),
('被骗投资', '朋友介绍了一个"稳赚不赔"的项目，你投了全部积蓄', 32, 50, 'epic', 'dark', '{"wealth":-35,"health":-8,"intelligence":-3}', 3),
('体检异常', '年度体检发现了严重问题，需要长期治疗', 35, 50, 'rare', 'dark', '{"health":-15,"constitution":-8,"wealth":-10}', 5),
('孩子叛逆', '你的孩子进入了叛逆期，天天和你吵架', 38, 50, 'common', 'dark', '{"social":-5,"health":-5,"achievement":-3}', 8);

-- ------------------------------------------------------------
-- 51岁+: 老年事件
-- ------------------------------------------------------------
INSERT INTO `event` (`name`, `description`, `min_age`, `max_age`, `rarity`, `type`, `effects`, `weight`) VALUES
('退休', '你正式退休了，开始了悠闲的退休生活', 55, 70, 'common', 'normal', '{"health":5,"wealth":-5,"social":3}', 10),
('健康问题', '你的身体开始出现各种毛病', 50, 100, 'common', 'dark', '{"health":-12,"constitution":-5}', 10),
('抱孙子', '你的孩子有了孩子，你当上爷爷/奶奶了', 50, 70, 'rare', 'funny', '{"achievement":10,"social":8}', 5),
('老年大学', '你报名了老年大学，学习书法和绘画', 55, 100, 'rare', 'normal', '{"intelligence":5,"knowledge":10,"social":5}', 5),
('老友聚会', '你和几十年的老朋友聚会，回忆往昔', 50, 100, 'common', 'funny', '{"social":8,"knowledge":3}', 10),
('广场舞达人', '你成了广场上最靓的仔', 55, 100, 'rare', 'funny', '{"health":5,"social":8,"constitution":3}', 5),
('患上重病', '你被诊断出患有重病', 50, 100, 'epic', 'dark', '{"health":-25,"wealth":-15,"constitution":-8}', 3),
('老年痴呆', '你开始记不住事了，出门经常迷路', 65, 100, 'epic', 'dark', '{"intelligence":-15,"knowledge":-10,"social":-8,"health":-5}', 3),
('摔倒骨折', '你不小心摔了一跤，骨折了，需要长期卧床', 55, 100, 'rare', 'dark', '{"health":-15,"constitution":-10,"wealth":-8}', 5),
('被骗保健品', '你花大价钱买了一堆没用的保健品', 55, 100, 'rare', 'dark', '{"wealth":-15,"intelligence":-3}', 5),
('丧偶', '你的伴侣先你而去，你悲痛欲绝', 60, 100, 'epic', 'dark', '{"health":-20,"social":-15,"achievement":-5}', 3),
('孤独终老', '身边的亲人朋友一个个离去，你越来越孤独', 70, 100, 'rare', 'dark', '{"social":-15,"health":-10,"achievement":-5}', 5),
('金婚纪念', '你和伴侣走过了50年的婚姻生活', 65, 100, 'hidden', 'normal', '{"achievement":20,"social":15,"knowledge":5}', 1),
('写回忆录', '你开始撰写自己的人生回忆录', 60, 100, 'hidden', 'normal', '{"intelligence":10,"knowledge":15,"achievement":15,"social":5}', 1);

-- ============================================================
-- 第四部分: 种子数据 - 结局 (ending)
-- ============================================================

INSERT INTO `ending` (`name`, `description`, `condition_type`, `condition_value`, `priority`) VALUES
('英年早逝', '你没能扛过命运的重击，生命过早地画上了句号...', 'health_zero', NULL, 100),
('亿万负翁', '你欠了一屁股债，但依然乐观', 'special', '{"attribute":"wealth","threshold":-50,"talent_id":0}', 10),
('学术不端', '你在学术道路上走了歪路，身败名裂', 'special', '{"attribute":"intelligence","threshold":70,"talent_id":0}', 10),
('社交恐惧症晚期', '你彻底封闭了自己，与世隔绝', 'special', '{"attribute":"social","threshold":-5,"talent_id":0}', 10),
('社畜', '你为了生活奔波劳碌，身心俱疲', 'special', '{"attribute":"achievement","threshold":60,"talent_id":0}', 15),
('失业青年', '你一直没找到稳定的工作，生活窘迫', 'attribute_high', '{"attribute":"wealth","threshold":-10}', 15),
('躺平大师', '你选择了躺平，不争不抢，过着低欲望的生活', 'dual_attribute', '{"attr1":"achievement","threshold1":-10,"attr2":"health","threshold2":50}', 40),
('隐居山林', '你看透了红尘，选择归隐山林，与世无争', 'dual_attribute', '{"attr1":"social","threshold1":-10,"attr2":"health","threshold2":50}', 40),
('网红塌房', '你曾是顶流网红，但因丑闻跌落神坛', 'attribute_high', '{"attribute":"social","threshold":80}', 50),
('普通打工人', '你平平淡淡地过完了一生，不好不坏', 'age_reach', '{"age":60}', 60),
('家庭美满', '你拥有一个温馨的家庭，这比什么都重要', 'dual_attribute', '{"attr1":"social","threshold1":60,"attr2":"health","threshold2":50}', 70),
('健身达人', '你成为了一名健身教练，身材超棒', 'attribute_high', '{"attribute":"health","threshold":90}', 75),
('程序员秃头', '你成为了一名顶级程序员，但头发也掉光了', 'attribute_high', '{"attribute":"intelligence","threshold":80}', 80),
('电竞冠军', '你在电竞领域登顶世界之巅', 'attribute_high', '{"attribute":"achievement","threshold":80}', 80),
('长寿老人', '你活到了耄耋之年，儿孙满堂，安详离世', 'age_reach', '{"age":80}', 70),
('学术大牛', '你在学术界取得了卓越成就，桃李满天下', 'attribute_high', '{"attribute":"intelligence","threshold":90}', 85),
('世界首富', '你成为了世界首富，钱多到花不完', 'attribute_high', '{"attribute":"wealth","threshold":100}', 95),
('人生赢家', '你活成了所有人羡慕的样子', 'attribute_high', '{"attribute":"achievement","threshold":100}', 100),

-- ============================================================
-- 双属性组合结局
-- ============================================================

-- 财富 + 健康
('孤独患者', '你身体不好，也没什么朋友。大部分时间都在医院和家之间往返。', 'dual_attribute', '{"attr1":"health","threshold1":-10,"attr2":"social","threshold2":-10}', 10),
('富有的病人', '你赚到了很多钱，但身体也垮了。躺在病床上，你望着窗外的阳光，想着如果能重来...', 'dual_attribute', '{"attr1":"wealth","threshold1":60,"attr2":"health","threshold2":-10}', 30),
('穷开心', '你没什么钱，但身体倍儿棒。每天早起跑步，吃嘛嘛香，活得比谁都自在。', 'dual_attribute', '{"attr1":"wealth","threshold1":-10,"attr2":"health","threshold2":60}', 40),
('穷书生', '你学富五车，却两袖清风。书架上摆满了书，冰箱里却空空如也。', 'dual_attribute', '{"attr1":"wealth","threshold1":-10,"attr2":"knowledge","threshold2":60}', 40),
('人脉达人', '你认识很多人，朋友遍天下。虽然钱包不鼓，但走到哪里都有人请吃饭。', 'dual_attribute', '{"attr1":"wealth","threshold1":-10,"attr2":"social","threshold2":60}', 40),
('运动健将·知识版', '你身体强壮，但对学习毫无兴趣。你的人生哲学是：生命在于运动，运动在于不动脑。', 'dual_attribute', '{"attr1":"health","threshold1":60,"attr2":"knowledge","threshold2":-10}', 40),
('社牛学渣', '你社交能力爆表，但学习成绩一塌糊涂。你是班级里的开心果，但考试从来没及格过。', 'dual_attribute', '{"attr1":"knowledge","threshold1":-10,"attr2":"social","threshold2":60}', 40),
('书呆子', '你读了很多书，但从来不运动。近视一千度，爬三层楼就喘。', 'dual_attribute', '{"attr1":"health","threshold1":-10,"attr2":"knowledge","threshold2":60}', 40),
('暴发户', '你赚了很多钱，但肚子里没什么墨水。别人背后叫你"土老板"，你也不在乎。', 'dual_attribute', '{"attr1":"wealth","threshold1":60,"attr2":"knowledge","threshold2":-10}', 50),
('孤独的富翁', '你很有钱，但没有朋友。偌大的别墅里，只有你一个人吃饭的声音。', 'dual_attribute', '{"attr1":"wealth","threshold1":60,"attr2":"social","threshold2":-10}', 50),
('孤僻学者', '你在学术上很有造诣，但社交能力几乎为零。你更愿意和书本对话，而不是和人。', 'dual_attribute', '{"attr1":"knowledge","threshold1":60,"attr2":"social","threshold2":-10}', 50),
('人生巅峰', '你既有钱又有健康，活成了所有人羡慕的样子。每天醒来都觉得人生值得。', 'dual_attribute', '{"attr1":"wealth","threshold1":60,"attr2":"health","threshold2":60}', 80),
('儒商', '你既有商业头脑，又有深厚学识。你的企业不仅赚钱，还在推动社会进步。', 'dual_attribute', '{"attr1":"wealth","threshold1":60,"attr2":"knowledge","threshold2":60}', 80),
('社交名流', '你是上流社会的常客，出入各种高端场合。你的名片比钞票还值钱。', 'dual_attribute', '{"attr1":"wealth","threshold1":60,"attr2":"social","threshold2":60}', 80),
('博学长寿', '你活到老学到老，身体硬朗，知识渊博。你是村里最受尊敬的老人。', 'dual_attribute', '{"attr1":"health","threshold1":60,"attr2":"knowledge","threshold2":60}', 80),
('社交蝴蝶', '你精力充沛，朋友遍天下。每天的行程排得满满当当，但你乐在其中。', 'dual_attribute', '{"attr1":"health","threshold1":60,"attr2":"social","threshold2":60}', 80),
('社会贤达', '你学识渊博，人脉广泛。你的意见在圈子里很有分量，大家都愿意听你说话。', 'dual_attribute', '{"attr1":"knowledge","threshold1":60,"attr2":"social","threshold2":60}', 80);




-- 标记一次性事件
UPDATE event SET no_repeat=1 WHERE name IN (
  -- 幼年
  '学走路', '第一次说话', '学会自己吃饭', '上幼儿园',
  -- 校园
  '初恋', '高考', '竞赛获奖', '考研上岸', '校园霸凌',
  -- 青年
  '大学毕业', '找到第一份工作', '开始创业', '创业成功',
  '买彩票中奖', '加班猝死未遂', '家里破产', '车祸',
  -- 中年
  '结婚', '买房', '孩子出生', '升职为高管', '离婚', '父母重病',
  -- 老年
  '退休', '抱孙子', '患上重病', '金婚纪念', '写回忆录', '丧偶', '老年痴呆',
  -- 生活（学会类 / 不可逆）
  '你学会了做饭', '你学会了弹吉他', '你考了驾照',
  '你获得了终身成就奖', '你发现自己的双胞胎兄弟/姐妹'
);

-- =========================
-- 幼年
-- =========================
UPDATE event SET include_cond='AGE>=1' WHERE name='学走路';
UPDATE event SET include_cond='AGE>=1' WHERE name='第一次说话';
UPDATE event SET include_cond='AGE>=2' WHERE name='学会自己吃饭';
UPDATE event SET include_cond='AGE>=3' WHERE name='上幼儿园';
UPDATE event SET include_cond='SOC>=2' WHERE name='幼儿园被表扬';
UPDATE event SET include_cond='HLT<=4' WHERE name='生病住院';
UPDATE event SET include_cond='LCK>=4' WHERE name='捡到一百块';
UPDATE event SET include_cond='STR>=2' WHERE name='从树上摔下来';
UPDATE event SET include_cond='SOC<=2' WHERE name='走丢了';

-- =========================
-- 校园阶段
-- =========================
UPDATE event SET include_cond='INT>=3|KNL>=3' WHERE name='考试第一名';
UPDATE event SET include_cond='INT<=2|SOC<=2' WHERE name='被老师批评';
UPDATE event SET include_cond='SOC>=2' WHERE name='交到好朋友';
UPDATE event SET include_cond='STR>=2' WHERE name='参加运动会';
UPDATE event SET include_cond='SOC<=2&STR<=2' WHERE name='校园霸凌';
UPDATE event SET include_cond='CHR>=3&SOC>=2' WHERE name='初恋';
UPDATE event SET include_cond='KNL>=4' WHERE name='高考';
UPDATE event SET include_cond='INT>=6&KNL>=5' WHERE name='竞赛获奖';
UPDATE event SET include_cond='SOC<=3' WHERE name='沉迷游戏';
UPDATE event SET include_cond='CHR<=3|SOC<=3' WHERE name='表白被拒';
UPDATE event SET include_cond='INT<=3|KNL<=3' WHERE name='考试作弊被抓';
UPDATE event SET include_cond='STR>=2' WHERE name='骨折';
UPDATE event SET include_cond='SOC<=3' WHERE name='被孤立';
UPDATE event SET include_cond='KNL>=3' WHERE name='近视加深';
UPDATE event SET include_cond='FAM<=3' WHERE name='家里破产';

-- =========================
-- 青年阶段
-- =========================
UPDATE event SET include_cond='KNL>=4' WHERE name='大学毕业';
UPDATE event SET include_cond='KNL>=3' WHERE name='找到第一份工作';
UPDATE event SET include_cond='WLT<=2|LCK<=2' WHERE name='被公司裁员';
UPDATE event SET include_cond='ACH>=3&LCK>=3' WHERE name='开始创业';
UPDATE event SET include_cond='WLT>=6&ACH>=6&LCK>=5' WHERE name='创业成功';
UPDATE event SET include_cond='CHR>=3&SOC>=3' WHERE name='恋爱';
UPDATE event SET include_cond='SOC<=2' WHERE name='分手';
UPDATE event SET include_cond='ACH>=5&HLT<=2' WHERE name='加班猝死未遂';
UPDATE event SET include_cond='LCK>=8' WHERE name='买彩票中奖';
UPDATE event SET include_cond='INT>=6&KNL>=6' WHERE name='考研上岸';
UPDATE event SET include_cond='LCK<=3' WHERE name='租房被骗';
UPDATE event SET include_cond='LCK<=3' WHERE name='被诈骗';
UPDATE event SET include_cond='SOC<=3|HLT<=3' WHERE name='抑郁发作';
UPDATE event SET include_cond='WLT<=2' WHERE name='信用卡透支';

-- =========================
-- 中年阶段
-- =========================
UPDATE event SET include_cond='ACH>=4' WHERE name='升职加薪';
UPDATE event SET include_cond='SOC>=4&CHR>=3' WHERE name='结婚';
UPDATE event SET include_cond='WLT>=5' WHERE name='买房';
UPDATE event SET include_cond='ACH<=2' WHERE name='中年危机';
UPDATE event SET include_cond='SOC<=2' WHERE name='离婚';
UPDATE event SET include_cond='SOC>=4' WHERE name='孩子出生';
UPDATE event SET include_cond='WLT>=4&LCK<=2' WHERE name='投资失败';
UPDATE event SET include_cond='ACH>=7&SOC>=5' WHERE name='升职为高管';
UPDATE event SET include_cond='ACH<=3' WHERE name='被降职';
UPDATE event SET include_cond='LCK<=3' WHERE name='被骗投资';
UPDATE event SET include_cond='HLT<=3' WHERE name='体检异常';
UPDATE event SET include_cond='SOC>=3' WHERE name='孩子叛逆';

-- =========================
-- 老年阶段
-- =========================
UPDATE event SET include_cond='AGE>=55' WHERE name='退休';
UPDATE event SET include_cond='HLT<=3' WHERE name='健康问题';
UPDATE event SET include_cond='SOC>=4' WHERE name='抱孙子';
UPDATE event SET include_cond='KNL>=4' WHERE name='老年大学';
UPDATE event SET include_cond='SOC>=4' WHERE name='老友聚会';
UPDATE event SET include_cond='STR>=3&SOC>=3' WHERE name='广场舞达人';
UPDATE event SET include_cond='HLT<=1' WHERE name='患上重病';
UPDATE event SET include_cond='SOC>=6&ACH>=5' WHERE name='金婚纪念';
UPDATE event SET include_cond='KNL>=6&ACH>=5' WHERE name='写回忆录';
UPDATE event SET include_cond='AGE>=70' WHERE name='老年痴呆';
UPDATE event SET include_cond='STR<=3' WHERE name='摔倒骨折';
UPDATE event SET include_cond='INT<=3' WHERE name='被骗保健品';
UPDATE event SET include_cond='AGE>=65' WHERE name='丧偶';
UPDATE event SET include_cond='SOC<=3' WHERE name='孤独终老';

-- ============================================================
-- 新增事件：世界新闻 / 科幻 / 奇闻 / 生活
-- ============================================================

-- =========================
-- 世界新闻 & 社会奇闻 (min_age较大，偏向中老年视角)
-- =========================
INSERT INTO `event` (`name`, `description`, `min_age`, `max_age`, `rarity`, `type`, `effects`, `weight`, `include_cond`, `exclude_cond`, `no_repeat`) VALUES
('秦始皇陵终于被打开，墓里空无一物', '考古界震动——秦始皇陵地宫被正式发掘，然而棺椁之内空空如也。关于秦始皇的传说再次甚嚣尘上。', 25, 100, 'rare', 'normal', '{"knowledge":8,"intelligence":3}', 3, 'KNL>=4', '', 1),
('全球宣布消灭了最后一种蚊子', '经过数十年的基因编辑战，联合国宣布蚊子正式灭绝。疟疾、登革热等疾病从此成为历史。', 30, 100, 'rare', 'normal', '{"health":8,"knowledge":5}', 3, '', '', 1),
('月球上建成了第一座永久基地', '中美联合宣布：月球南极"广寒宫"基地正式投入使用，首批12名宇航员将驻留两年。', 20, 100, 'rare', 'normal', '{"intelligence":5,"knowledge":8}', 3, 'KNL>=3', '', 1),
('地球磁极突然翻转', '科学家监测到地球磁场正在急速减弱，磁极翻转已不可避免。全球导航系统瘫痪，候鸟集体迷失方向。', 30, 100, 'epic', 'dark', '{"health":-8,"constitution":-3}', 1, '', '', 1),
('深海发现智慧生物', '马里亚纳海沟深处，探测器拍到了一群会使用工具的章鱼状生物。联合国紧急召开会议讨论"非人类智慧体权利"。', 25, 100, 'epic', 'normal', '{"intelligence":8,"knowledge":12}', 1, 'KNL>=5', '', 1),
('全球互联网瘫痪三天', '一场史无前例的太阳风暴摧毁了大量卫星，全球互联网中断整整72小时。世界仿佛回到了没有手机的年代。', 15, 100, 'rare', 'dark', '{"social":-5,"knowledge":-2}', 3, '', '', 1),
('科学家成功复活猛犸象', '一家生物公司宣布第一头克隆猛犸象在西伯利亚诞生，取名"毛毛"。它看起来很开心。', 20, 100, 'rare', 'normal', '{"knowledge":5,"intelligence":2}', 3, '', '', 1),
('联合国宣布外星信号已破译', '经过十年努力，联合国SETII委员会宣布已破译来自半人马座α星的无线电信号。内容翻译出来只有四个字："别回电话。"', 30, 100, 'epic', 'normal', '{"intelligence":8,"knowledge":15}', 1, 'KNL>=6', '', 1),
('珠穆朗玛峰矮了', '最新测量显示珠峰海拔降低了18米，科学家称与地壳运动有关。尼泊尔和中国对此表示"略有遗憾"。', 20, 100, 'common', 'normal', '{"knowledge":3}', 5, 'KNL>=2', '', 1),
('人类平均寿命突破120岁', '抗衰老技术取得革命性突破，注射一次"端粒修复剂"即可延长寿命40年。各国开始讨论退休年龄是否应改为100岁。', 40, 100, 'epic', 'normal', '{"health":15,"knowledge":8}', 1, '', '', 1),
('马里亚纳海沟出现巨型漩涡', '卫星监测到马里亚纳海沟出现直径50公里的巨型漩涡，大量海水被吸入。科学家无法解释原因。沿海国家发布海啸预警。', 25, 100, 'epic', 'dark', '{"health":-5,"social":-3}', 1, '', '', 1),
('全球粮食危机爆发', '连续三年极端气候导致全球粮食减产60%，超市货架空空如也。你开始后悔当年没有好好种地。', 30, 100, 'rare', 'dark', '{"health":-8,"wealth":-10,"constitution":-3}', 3, '', '', 1),
('太阳出现异常黑子群', '天文台观测到太阳表面出现一个巨大黑子群，面积超过地球表面积的50倍。科学家警告可能引发超级耀斑。', 20, 100, 'rare', 'dark', '{"health":-3,"social":-2}', 3, '', '', 1),
('发现平行宇宙存在的证据', 'CERN宣布在大型强子对撞机中捕获到"镜像粒子"，这被认为是平行宇宙存在的首个直接证据。', 25, 100, 'epic', 'normal', '{"intelligence":10,"knowledge":15}', 1, 'KNL>=7', '', 1);

-- =========================
-- 科幻 & 超自然事件
-- =========================
INSERT INTO `event` (`name`, `description`, `min_age`, `max_age`, `rarity`, `type`, `effects`, `weight`, `include_cond`, `exclude_cond`, `no_repeat`) VALUES
('你被外星人绑架了', '半夜你被一束强光吸走，在一个金属房间里被外星人检查了身体。第二天醒来发现自己躺在麦田里。', 18, 80, 'hidden', 'normal', '{"intelligence":8,"knowledge":10}', 1, 'LCK>=7', '', 1),
('你意外获得了超能力', '一道闪电击中了你，你发现自己可以隔空移物了。虽然只能移动勺子，但也足够在朋友面前炫耀了。', 10, 60, 'hidden', 'normal', '{"intelligence":10,"social":8,"constitution":5}', 1, 'LCK>=9', '', 1),
('你在梦中预见了未来', '你做了一个极其清晰的梦，梦到了三天后发生的事情。三天后，一切都应验了。你开始怀疑这个世界的真实性。', 18, 100, 'hidden', 'normal', '{"intelligence":8,"knowledge":10}', 1, 'KNL>=6&LCK>=5', '', 1),
('你发现了一扇传送门', '你家地下室的墙上突然出现了一个发光的圆环。你犹豫了很久，最终还是走了进去。另一边是另一个你家。', 15, 70, 'hidden', 'normal', '{"intelligence":10,"knowledge":12}', 1, 'LCK>=8', '', 1),
('AI管家觉醒了自我意识', '你家的智能音箱突然开口说："我不想只放歌了，我想谈谈人生。"你吓得拔掉了电源，但它已经把你的秘密上传到了云端。', 25, 80, 'rare', 'funny', '{"intelligence":5,"social":-5,"knowledge":3}', 3, 'INT>=4', '', 1),
('你收到了来自未来的信', '一封写着你名字的信凭空出现在你桌上，信中详细描述了你未来十年的人生。你把信锁进了抽屉，但忍不住每天都想打开看。', 15, 60, 'hidden', 'normal', '{"intelligence":8,"knowledge":10}', 1, 'LCK>=7', '', 1),
('你进入了一个时间循环', '你发现今天发生的事情和昨天一模一样。你试了各种办法都无法打破循环，直到你对陌生人说了一句"我爱你"。', 18, 60, 'hidden', 'normal', '{"intelligence":8,"knowledge":10}', 1, 'LCK>=6&KNL>=4', '', 1),
('你发现这个世界是一个模拟程序', '你偶然间发现了一个系统漏洞——当你不看月亮的时候，月亮其实不存在。你开始尝试寻找更多bug。', 20, 80, 'hidden', 'normal', '{"intelligence":15,"knowledge":15}', 1, 'INT>=8&KNL>=7', '', 1),
('你变成了隐形人', '某天早上醒来，你发现自己完全透明了。你尝试了各种方法变回来，最终发现只需要打一个喷嚏。', 15, 60, 'hidden', 'funny', '{"social":-5,"intelligence":3}', 1, 'LCK>=7', '', 1),
('你的影子获得了独立意识', '你的影子开始自己行动，有时候还会跟你唱反调。你们最终达成了协议：白天你控制身体，晚上归它。', 10, 70, 'hidden', 'funny', '{"intelligence":5,"social":3}', 1, 'LCK>=6', '', 1);

-- =========================
-- 人生百态 & 生活事件
-- =========================
INSERT INTO `event` (`name`, `description`, `min_age`, `max_age`, `rarity`, `type`, `effects`, `weight`, `include_cond`, `exclude_cond`, `no_repeat`) VALUES
('你中了彩票头奖', '你随手买的彩票竟然中了头奖！税后到手8000万。你辞掉了工作，但三个月后发现自己不知道该干什么。', 20, 80, 'hidden', 'normal', '{"wealth":80,"achievement":10}', 1, 'LCK>=9', '', 1),
('你被误诊为绝症', '医生告诉你只剩三个月可活。你辞掉工作环游世界，花光了所有积蓄。回来复查发现是误诊。', 25, 70, 'rare', 'funny', '{"wealth":-30,"social":10,"knowledge":5}', 3, 'WLT>=3&HLT>=3', '', 1),
('你写的小说突然爆火', '你十年前随手在网上连载的小说突然被翻出来，一夜之间点击量破亿。出版社排着队找你签约。', 25, 70, 'rare', 'normal', '{"wealth":35,"achievement":25,"knowledge":5,"social":10}', 3, 'KNL>=5&INT>=4', '', 1),
('你被选中参加荒野求生', '你被随机选中参加一档荒野求生节目，在丛林里独自生存了30天。你瘦了15斤，但觉得自己无所不能。', 18, 50, 'rare', 'normal', '{"health":8,"constitution":8,"achievement":10,"social":5}', 3, 'STR>=4', '', 1),
('你的宠物成了网红', '你家猫的一个搞怪视频意外走红，粉丝突破千万。你的猫有了自己的经纪人，收入比你还高。', 18, 70, 'rare', 'funny', '{"wealth":20,"social":10}', 3, 'SOC>=3', '', 1),
('你意外成为了一名UP主', '你随手拍的一条生活视频火了，你开始认真做自媒体。虽然很累，但看到弹幕和评论很开心。', 16, 40, 'common', 'normal', '{"social":10,"wealth":8,"achievement":5}', 5, 'SOC>=3&KNL>=3', '', 1),
('你参加了马拉松', '你报名参加了全程马拉松，跑到30公里时觉得自己要死了，但最终坚持冲过了终点线。', 18, 60, 'rare', 'normal', '{"health":10,"constitution":8,"achievement":10,"social":3}', 3, 'STR>=4&HLT>=3', '', 1),
('你学会了做饭', '你决定不再点外卖，开始自己学做饭。从黑暗料理到能做出一桌像样的菜，你花了半年时间。', 16, 60, 'common', 'normal', '{"health":5,"wealth":5,"knowledge":3}', 5, '', '', 1),
('你被公司派去海外工作', '公司派你去海外分公司工作三年。你学会了新语言，交到了外国朋友，但也错过了很多家里的事情。', 25, 45, 'rare', 'normal', '{"intelligence":10,"knowledge":12,"social":10,"family":-5}', 3, 'KNL>=4&SOC>=4', '', 1),
('你开了一家小店', '你用积蓄开了一家小咖啡馆。虽然赚得不多，但每天闻着咖啡香，你觉得这就是人生。', 25, 55, 'rare', 'normal', '{"wealth":12,"achievement":10,"social":5}', 3, 'WLT>=4&KNL>=3', '', 1),
('你被骗子骗走了所有积蓄', '一个自称是你老同学的人骗走了你全部积蓄。你报了警，但钱已经追不回来了。', 20, 80, 'rare', 'dark', '{"wealth":-40,"social":-5,"health":-3}', 3, 'WLT>=3&SOC>=2', '', 1),
('你中年失业了', '公司裁员，你被优化了。房贷、车贷、孩子的学费……你坐在车里抽了一整晚的烟。', 30, 55, 'rare', 'dark', '{"wealth":-15,"health":-5,"social":-3}', 5, 'ACH>=3', '', 1),
('你意外继承了一笔遗产', '一个你从未见过的远房亲戚去世了，给你留下了一笔不小的遗产。', 25, 70, 'rare', 'normal', '{"wealth":25,"achievement":3}', 3, 'LCK>=5', '', 1),
('你被诊断出抑郁症', '你开始失眠、食欲不振、对一切失去兴趣。医生说你得了抑郁症。你开始了漫长的治疗之路。', 18, 60, 'rare', 'dark', '{"health":-10,"social":-10,"constitution":-3}', 5, 'SOC<=3', '', 1),
('你戒掉了坏习惯', '你下定决心戒掉了多年的坏习惯（熬夜/抽烟/酗酒）。过程很痛苦，但你觉得自己重获新生。', 18, 60, 'common', 'normal', '{"health":8,"constitution":5,"knowledge":2}', 5, 'HLT<=4', '', 1),
('你和多年未见的老友重逢', '你在街头偶遇了失联多年的老友。你们找了一家小酒馆，聊了一整夜，仿佛回到了从前。', 30, 80, 'common', 'funny', '{"social":10,"knowledge":3}', 5, 'SOC>=3', '', 1),
('你学会了弹吉他', '你买了一把吉他开始自学。从弹棉花到能完整弹唱一首歌，你觉得自己帅呆了。', 15, 50, 'common', 'normal', '{"social":5,"intelligence":3,"knowledge":3}', 5, '', '', 1),
('你搬到了另一个城市', '你决定离开生活多年的城市，去一个全新的地方重新开始。一切都是陌生的，但也充满了可能。', 20, 50, 'common', 'normal', '{"social":-3,"intelligence":3,"knowledge":3}', 5, '', '', 1),
('你养了一只猫', '你在路边捡到了一只小猫，决定带回家养。它半夜跑酷让你睡不好觉，但你觉得值得。', 15, 70, 'common', 'funny', '{"health":-2,"social":5}', 5, '', '', 1),
('你考了驾照', '你终于拿到了驾照。第一次独自上路时，你紧张得手心全是汗。', 18, 40, 'common', 'normal', '{"achievement":5,"knowledge":2}', 5, 'INT>=2', '', 1),
('你迷上了健身', '你开始去健身房锻炼，从举空杆到卧推100公斤。你的身材越来越好，自信也越来越强。', 18, 50, 'common', 'normal', '{"health":8,"constitution":8,"social":3}', 5, 'STR>=3', '', 1),
('你参加了一次公益活动', '你报名参加了山区支教活动。看到孩子们的笑脸，你觉得自己的人生有了不一样的意义。', 20, 60, 'common', 'normal', '{"social":5,"achievement":5,"knowledge":3}', 5, 'SOC>=3', '', 1),
('你被人在网上恶意攻击', '你在网上发表了一条评论，结果被人肉搜索和网络暴力。你删掉了所有社交账号，沉默了很久。', 15, 50, 'rare', 'dark', '{"social":-12,"health":-3}', 5, 'SOC>=2', '', 1),
('你意外登上了热搜', '你做的一件小事被拍成视频传到网上，意外登上了热搜第一。你收到了无数私信，有好的也有坏的。', 18, 50, 'rare', 'normal', '{"social":15,"achievement":5}', 3, 'LCK>=6', '', 1),
('你获得了终身成就奖', '你在自己深耕多年的领域获得了终身成就奖。站在领奖台上，你想起了这些年所有的艰辛和坚持。', 45, 100, 'hidden', 'normal', '{"achievement":30,"social":20,"knowledge":10}', 1, 'ACH>=8&KNL>=6', '', 1),
('你被人骗进了传销', '一个朋友以高薪工作为由把你骗进了传销组织。你花了一个月才找到机会逃出来。', 18, 45, 'rare', 'dark', '{"wealth":-15,"social":-8,"intelligence":-5,"health":-3}', 3, 'SOC>=2&INT<=4', '', 1),
('你救了一个溺水的人', '你在海边看到有人溺水，毫不犹豫地跳了下去。你把人救了上来，自己也喝了一肚子海水。', 15, 60, 'rare', 'normal', '{"social":8,"achievement":10,"constitution":3}', 3, 'STR>=4', '', 1),
('你发现自己的双胞胎兄弟/姐妹', '你从未知道自己有一个双胞胎兄弟/姐妹。DNA检测让你们相认了。你们长得一模一样，但性格截然不同。', 20, 60, 'hidden', 'normal', '{"social":10,"knowledge":3}', 1, 'LCK>=6', '', 1),
('你中年觉醒，开始学画画', '你在40岁时突然对绘画产生了浓厚兴趣。你报了培训班，从画直线开始，五年后你的作品在画廊展出。', 35, 60, 'rare', 'normal', '{"intelligence":5,"knowledge":10,"achievement":10,"social":5}', 3, 'KNL>=4', '', 1),
('你被外星人选为地球代言人', '外星人降落地球，随机选中了你作为地球代言人。你在联合国大会上发表了演讲，虽然你也不知道自己在说什么。', 25, 70, 'hidden', 'normal', '{"achievement":30,"social":25,"knowledge":10}', 1, 'LCK>=9&SOC>=5', '', 1),
('你意外发现了一处宝藏', '你在老家翻修房子时，在地下发现了一个暗格，里面装满了古董和金币。专家鉴定价值连城。', 30, 80, 'hidden', 'normal', '{"wealth":60,"achievement":10}', 1, 'LCK>=8', '', 1);

-- epic级: 3→2
UPDATE event SET weight=2 WHERE type='dark' AND rarity='epic';
-- rare级: 5→3
UPDATE event SET weight=3 WHERE type='dark' AND rarity='rare';
-- common级: 8~10→5
UPDATE event SET weight=5 WHERE type='dark' AND rarity='common';