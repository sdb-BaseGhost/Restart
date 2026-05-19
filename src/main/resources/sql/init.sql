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
  `happiness` INT DEFAULT 50,
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
  `weight` INT DEFAULT 10
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
('欧皇附体', '幸运+10，好事更容易降临', '{"luck":10}'),
('富二代', '家境+8，出生就在罗马', '{"family":8}'),
('社恐', '社交-3，但快乐不会太低', '{"social":-3,"happiness":2}'),
('卷王', '智力成长+1，成就成长+1', '{"intelligence_growth":1,"achievement_growth":1}'),
('非酋', '幸运-5，运气不太好', '{"luck":-5}'),
('摆烂大师', '快乐每岁+1，成就增长减半', '{"happiness_growth":1,"master_slacker":1}'),
('熬夜冠军', '体质-3，智力+5，用生命在学习', '{"constitution":-3,"intelligence":5}'),
('键盘侠', '社交+5，体质-2，网上重拳出击', '{"social":5,"constitution":-2}'),
('天选打工人', '财富增长+50%，天生打工命', '{"worker_fate":1}'),
('运动健将', '体质+5，健康每岁+1', '{"constitution":5,"health_growth":1}'),
('文艺青年', '智力+3，快乐+3，诗和远方', '{"intelligence":3,"happiness":3}'),
('社交达人', '社交+8，快乐+2，朋友遍天下', '{"social":8,"happiness":2}'),
('佛系青年', '所有属性变化减半，无欲无求', '{"zen_youth":1}'),
('天降横财', '财富+20，一夜暴富', '{"wealth":20}');

-- ============================================================
-- 第三部分: 种子数据 - 事件 (event)
-- ============================================================

-- ------------------------------------------------------------
-- 0-6岁: 成长事件
-- ------------------------------------------------------------
INSERT INTO `event` (`name`, `description`, `min_age`, `max_age`, `rarity`, `type`, `effects`, `weight`) VALUES
('学走路', '你迈出了人生的第一步，虽然摔了个狗吃屎', 1, 2, 'common', 'funny', '{"health":1,"happiness":2}', 10),
('第一次说话', '你喊出了第一声"妈妈"，全家人激动得哭了', 1, 2, 'common', 'normal', '{"intelligence":1,"happiness":2}', 10),
('学会自己吃饭', '虽然把饭弄得到处都是，但你很自豪', 2, 3, 'common', 'funny', '{"health":1,"happiness":1}', 10),
('上幼儿园', '你背着小书包去了幼儿园，哭着要回家', 3, 5, 'common', 'normal', '{"social":2,"intelligence":1}', 10),
('幼儿园被表扬', '老师夸你是最乖的小朋友，奖励了一朵小红花', 3, 6, 'common', 'funny', '{"happiness":3,"achievement":1}', 10),
('生病住院', '你发了高烧，住了三天医院', 0, 6, 'rare', 'dark', '{"health":-5,"happiness":-3}', 5),
('捡到一百块', '你在地上捡到了一百块钱，买了一堆零食', 4, 6, 'rare', 'funny', '{"wealth":5,"happiness":5}', 5);

-- ------------------------------------------------------------
-- 7-18岁: 校园事件
-- ------------------------------------------------------------
INSERT INTO `event` (`name`, `description`, `min_age`, `max_age`, `rarity`, `type`, `effects`, `weight`) VALUES
('考试第一名', '你考了全班第一，妈妈奖励你吃大餐', 7, 18, 'common', 'normal', '{"intelligence":3,"achievement":3,"happiness":3}', 10),
('被老师批评', '上课偷看漫画被老师抓到了，罚站一节课', 7, 18, 'common', 'funny', '{"happiness":-2,"social":-1}', 10),
('交到好朋友', '你认识了一个志趣相投的好朋友', 7, 18, 'common', 'normal', '{"social":3,"happiness":3}', 10),
('参加运动会', '你在运动会上奋力拼搏，虽然没拿到名次', 7, 18, 'common', 'normal', '{"health":2,"happiness":2}', 10),
('校园霸凌', '你被高年级的同学欺负了，留下了心理阴影', 7, 15, 'rare', 'dark', '{"happiness":-5,"social":-3,"health":-2}', 5),
('初恋', '你偷偷喜欢上了同桌，写了人生第一封情书', 12, 18, 'rare', 'normal', '{"happiness":5,"social":2}', 5),
('高考', '你经历了人生中最重要的考试——高考', 17, 18, 'common', 'normal', '{"intelligence":5,"achievement":5,"happiness":-2}', 10),
('竞赛获奖', '你参加了全国学科竞赛并获奖', 12, 18, 'epic', 'normal', '{"intelligence":8,"achievement":8,"happiness":5}', 3),
('沉迷游戏', '你沉迷于网络游戏，成绩一落千丈', 10, 18, 'rare', 'funny', '{"intelligence":-3,"happiness":3,"achievement":-3}', 5),
('表白被拒', '你鼓起勇气表白，结果被发了好人卡', 14, 18, 'rare', 'funny', '{"happiness":-5,"social":-2}', 5);

-- ------------------------------------------------------------
-- 19-30岁: 青年事件
-- ------------------------------------------------------------
INSERT INTO `event` (`name`, `description`, `min_age`, `max_age`, `rarity`, `type`, `effects`, `weight`) VALUES
('大学毕业', '你顺利拿到了毕业证书，踏入社会', 21, 24, 'common', 'normal', '{"intelligence":3,"achievement":5,"happiness":3}', 10),
('找到第一份工作', '你找到了人生中第一份正式工作', 20, 26, 'common', 'normal', '{"wealth":10,"achievement":3,"happiness":3}', 10),
('被公司裁员', '公司效益不好，你被优化了', 22, 30, 'rare', 'dark', '{"wealth":-5,"happiness":-8,"achievement":-2}', 5),
('开始创业', '你辞去了工作，开始了创业之路', 22, 30, 'rare', 'normal', '{"wealth":-10,"achievement":5,"happiness":5}', 5),
('创业成功', '你的公司获得了融资，身价暴涨', 24, 30, 'epic', 'normal', '{"wealth":30,"achievement":15,"happiness":10}', 3),
('恋爱', '你遇到了心仪的对象，开始了一段恋情', 18, 30, 'common', 'normal', '{"happiness":8,"social":3}', 10),
('分手', '你和恋人分手了，痛哭了一场', 18, 30, 'rare', 'dark', '{"happiness":-8,"social":-2}', 5),
('加班猝死未遂', '连续加班一个月后，你在工位上晕倒了', 22, 30, 'epic', 'dark', '{"health":-15,"happiness":-10,"wealth":5}', 3),
('买彩票中奖', '你随手买了一张彩票，竟然中了大奖', 18, 30, 'epic', 'funny', '{"wealth":20,"happiness":10}', 3),
('考研上岸', '你成功考上了研究生', 21, 26, 'rare', 'normal', '{"intelligence":8,"achievement":8,"happiness":5}', 5);

-- ------------------------------------------------------------
-- 31-50岁: 中年事件
-- ------------------------------------------------------------
INSERT INTO `event` (`name`, `description`, `min_age`, `max_age`, `rarity`, `type`, `effects`, `weight`) VALUES
('升职加薪', '你升职了，工资翻了一番', 28, 50, 'common', 'normal', '{"wealth":15,"achievement":8,"happiness":5}', 10),
('结婚', '你和心爱的人步入了婚姻的殿堂', 25, 40, 'common', 'normal', '{"happiness":10,"social":5,"achievement":5}', 10),
('买房', '你终于攒够了首付，买了人生第一套房', 28, 45, 'rare', 'normal', '{"wealth":-20,"happiness":10,"achievement":10}', 5),
('中年危机', '你突然觉得人生毫无意义，陷入了深深的迷茫', 35, 50, 'rare', 'dark', '{"happiness":-10,"health":-3}', 5),
('离婚', '你和伴侣离婚了，财产对半分', 30, 50, 'epic', 'dark', '{"happiness":-15,"wealth":-10,"social":-5}', 3),
('孩子出生', '你有了自己的孩子，初为人父/人母', 28, 45, 'common', 'normal', '{"happiness":10,"achievement":5,"wealth":-5}', 10),
('投资失败', '你把积蓄投入股市，结果亏了一大半', 30, 50, 'rare', 'dark', '{"wealth":-15,"happiness":-8}', 5),
('升职为高管', '你成为了公司的高管', 35, 50, 'epic', 'normal', '{"wealth":25,"achievement":15,"happiness":5}', 3);

-- ------------------------------------------------------------
-- 51岁+: 老年事件
-- ------------------------------------------------------------
INSERT INTO `event` (`name`, `description`, `min_age`, `max_age`, `rarity`, `type`, `effects`, `weight`) VALUES
('退休', '你正式退休了，开始了悠闲的退休生活', 55, 70, 'common', 'normal', '{"happiness":5,"health":2,"wealth":-3}', 10),
('健康问题', '你的身体开始出现各种毛病', 50, 100, 'common', 'dark', '{"health":-8,"happiness":-5}', 10),
('抱孙子', '你的孩子有了孩子，你当上爷爷/奶奶了', 50, 70, 'rare', 'funny', '{"happiness":10,"achievement":5}', 5),
('老年大学', '你报名了老年大学，学习书法和绘画', 55, 100, 'rare', 'normal', '{"intelligence":3,"happiness":8,"social":3}', 5),
('老友聚会', '你和几十年的老朋友聚会，回忆往昔', 50, 100, 'common', 'funny', '{"happiness":8,"social":5}', 10),
('广场舞达人', '你成了广场上最靓的仔', 55, 100, 'rare', 'funny', '{"happiness":5,"health":3,"social":5}', 5),
('患上重病', '你被诊断出患有重病', 50, 100, 'epic', 'dark', '{"health":-20,"happiness":-15,"wealth":-10}', 3),
('金婚纪念', '你和伴侣走过了50年的婚姻生活', 65, 100, 'hidden', 'normal', '{"happiness":15,"achievement":10,"social":5}', 1),
('写回忆录', '你开始撰写自己的人生回忆录', 60, 100, 'hidden', 'normal', '{"intelligence":5,"achievement":8,"happiness":5}', 1);

-- ============================================================
-- 第四部分: 种子数据 - 结局 (ending)
-- ============================================================

INSERT INTO `ending` (`name`, `description`, `condition_type`, `condition_value`, `priority`) VALUES
('英年早逝', '你没能扛过命运的重击，生命过早地画上了句号...', 'health_zero', NULL, 100),
('长寿老人', '你活到了耄耋之年，儿孙满堂，安详离世', 'age_reach', '{"age":80}', 100),
('世界首富', '你成为了世界首富，钱多到花不完', 'attribute_high', '{"attribute":"wealth","threshold":100}', 90),
('人生赢家', '你活成了所有人羡慕的样子', 'attribute_high', '{"attribute":"achievement","threshold":100}', 90),
('程序员秃头', '你成为了一名顶级程序员，但头发也掉光了', 'attribute_high', '{"attribute":"intelligence","threshold":80}', 80),
('电竞冠军', '你在电竞领域登顶世界之巅', 'attribute_high', '{"attribute":"achievement","threshold":80}', 80),
('网红塌房', '你曾是顶流网红，但因丑闻跌落神坛', 'attribute_high', '{"attribute":"social","threshold":80}', 80),
('普通打工人', '你平平淡淡地过完了一生，不好不坏', 'age_reach', '{"age":60}', 50),
('躺平大师', '你选择了躺平，但意外地过得很幸福', 'special', '{"attribute":"happiness","threshold":80,"talent_id":7}', 50),
('社畜', '你为了生活奔波劳碌，身心俱疲', 'special', '{"attribute":"happiness","threshold":-10,"talent_id":0}', 10),
('失业青年', '你一直没找到稳定的工作，生活窘迫', 'attribute_high', '{"attribute":"wealth","threshold":-10}', 10),
('学术大牛', '你在学术界取得了卓越成就，桃李满天下', 'attribute_high', '{"attribute":"intelligence","threshold":90}', 80),
('社交恐惧症晚期', '你彻底封闭了自己，与世隔绝', 'special', '{"attribute":"social","threshold":-5,"talent_id":0}', 10),
('隐居山林', '你看透了红尘，选择归隐山林', 'special', '{"attribute":"happiness","threshold":60,"talent_id":14}', 50),
('亿万负翁', '你欠了一屁股债，但依然乐观', 'special', '{"attribute":"wealth","threshold":-50,"talent_id":0}', 10),
('家庭美满', '你拥有一个幸福的家庭，这比什么都重要', 'special', '{"attribute":"happiness","threshold":80,"talent_id":0}', 50),
('健身达人', '你成为了一名健身教练，身材超棒', 'attribute_high', '{"attribute":"health","threshold":90}', 50),
('学术不端', '你在学术道路上走了歪路，身败名裂', 'special', '{"attribute":"intelligence","threshold":70,"talent_id":0}', 10);
