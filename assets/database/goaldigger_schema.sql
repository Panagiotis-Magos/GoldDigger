PRAGMA foreign_keys = ON;

-- Table: goals
CREATE TABLE `goals` (
    `goal_id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `title` TEXT NOT NULL,
    `category` TEXT NOT NULL,
    `description` TEXT,
    `target` INTEGER NOT NULL DEFAULT 0,
    `reward` INTEGER DEFAULT 0
);

INSERT INTO `goals` (`goal_id`, `title`, `category`, `description`, `target`, `reward`)
VALUES (1,'Explore 5 historical landmarks','Traveling','Show share end how case structure. Attention soon strong improve player significant from.',5,470),(2,'Travel to 3 different cities this year','Traveling','Explain mother newspaper board two.',5,790),(3,'Participate in a cultural festival','Traveling','Western join hand open. Eye business sell medical chance add. Really everybody magazine name.',5,600),(4,'Experience 3 different cuisines in new locations','Traveling','Require music position near pick. Study stand how network some side miss. Scientist down attorney.',5,400),(5,'Capture 10 beautiful sceneries','Traveling','Voice off these own apply decade himself. Tend according choice have.',5,600),(6,'Create a structured weekly plan','Productivity','Month nearly us heavy maybe. Face response partner.',5,210),(7,'Declutter your home and digital life','Productivity','Subject Republican use onto. Respond hundred former message. During lead would each few.',5,760),(8,'Improve professional skills through training','Productivity','Example million friend few month. Imagine yeah include decade each begin.',5,300),(9,'Set and achieve SMART personal goals','Productivity','Boy guy economic section. Finally institution this game do cost near.',5,590),(10,'Build a sustainable morning routine','Productivity','Machine end last then someone. Growth until carry generation eye. Standard standard work go.',5,710),(11,'Host or attend 3 social gatherings','Social Life','Environmental concern piece reveal. Great region class probably improve drug.',5,330),(12,'Reconnect with old friends','Social Life','Eye possible focus. Happy goal later stand.',5,180),(13,'Volunteer for a community cause','Social Life','Do company join see standard provide. As just clear.',5,260),(14,'Meet 10 new people through events','Social Life','South wear million kind hot with. Support other answer. Million yard wind his low these.',5,270),(15,'Strengthen family bonds through activities','Social Life','Go end task hotel carry. Threat training only with.',5,600);

-- Table: tasks
CREATE TABLE `tasks` (
    `task_id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `title` TEXT NOT NULL,
    `category` TEXT NOT NULL,
    `description` TEXT,
    `gold_reward` INTEGER DEFAULT NULL
);

INSERT INTO tasks (`task_id`, `title`, `category`, `description`, `gold_reward`)  
VALUES (1,'Visit a local museum','Traveling','Car billion possible available community week. Open national area very our recent act.',130),(2,'Go on a 5km hike','Traveling','Class long evening his relate. Through newspaper authority second be shake today their.',110),(3,'Take a day trip to a nearby city','Traveling','Then once those bed street. Foot weight moment scientist actually.',60),(4,'Book a tour of a historical site','Traveling','Sort culture common. Three senior moment they. Child central together reach both outside clearly.',280),(5,'Try a local dish at a restaurant','Traveling','Let only foreign. Simple fly him play send art. Big until option capital memory enough.',110),(6,'Capture a sunrise or sunset','Traveling','Dark save dream set bed. Want her serious different enter break. Author arrive amount student.',180),(7,'Travel by public transportation for a day','Traveling','Body energy morning goal play agreement defense law. Go hair understand our.',260),(8,'Attend a cultural festival','Traveling','Painting west see break drop any section.',240),(9,'Visit a famous landmark','Traveling','South young push left point. Person expert benefit product direction mission.',100),(10,'Take a walk in a botanical garden','Traveling','Concern possible research. Help score strong practice although.',70),(11,'Explore a nature reserve','Traveling','Couple still you meeting family treatment work. Last personal husband within record war fly be.',260),(12,'Camp overnight at a national park','Traveling','Institution compare cost expert police among during. Decade rate debate building home card subject.',150),(13,'Take a picture of a unique street art','Traveling','Agency process hospital approach hand though free.',290),(14,'Map out a road trip itinerary','Traveling','Whether it clear various. Good building under lead all become rise.',50),(15,'Visit a new country','Traveling','Hard area player by. Need garden consider surface.',160),(16,'Visit a local beach or lake','Traveling','Number law skill usually result. Understand specific know response offer party issue.',190),(17,'Travel with friends for a weekend','Traveling','Level why ball day grow family like. My father buy high wait stop.',70),(18,'Try a new adventure sport','Traveling','Tax toward who me analysis. Always us paper season today world loss.',110),(19,'Explore a local market','Traveling','Sound class remember newspaper any north actually. One surface break per risk others other.',160),(20,'Visit a mountain or a valley','Traveling','Election decade public fact factor. Become policy defense animal successful explain road value.',120),(21,'Spend a day as a tourist in your city','Traveling','Hit receive simply whole. Different beyond quality support machine arm rest.',90),(22,'Watch a live performance in another city','Traveling','Point major ability important us two. Coach group meet nice letter political cell.',190),(23,'Book and stay at a unique Airbnb','Traveling','Tell should by great. Speak white economic which.',250),(24,'Visit a small village or rural area','Traveling','Cold main position music probably. Education popular small animal.',110),(25,'Learn a local phrase or language','Traveling','Adult certain property strong. Land even lay view. Where will record senior middle pick poor.',130),(26,'Take a walking tour of a new place','Traveling','Single next after operation interesting house toward theory. Hope between top coach this sometimes.',50),(27,'Find and explore a hidden gem location','Traveling','Oil project actually practice rich. Range individual who forget director.',280),(28,'Take a boat ride','Traveling','Door loss shake structure light a. Against stage past nature PM. Human western course lose if.',300),(29,'Visit an art gallery in another city','Traveling','Bank nor people wide. Yourself organization by show service them. Choice without him second.',50),(30,'Explore a famous library','Traveling','She power despite loss report hold. Administration meet color get part Republican.',100),(31,'Complete a daily planner','Productivity','Leader glass Mrs by business nearly. Treatment edge challenge fear run with.',100),(32,'Finish a project proposal','Productivity','Nature evidence hit everything society anyone daughter. So thing trip own early section often.',260),(33,'Organize your workspace','Productivity','Choose today them door size. Stay somebody nation.',230),(34,'Attend a time management workshop','Productivity','Else movement create join style. Provide carry stand star. Work participant answer meet.',60),(35,'Update your resume','Productivity','Pressure commercial painting grow clearly house. Most if care road. Garden course yet product.',160),(36,'Write a journal entry','Productivity','Tough car really friend eight popular. Strategy need believe notice significant effect office.',230),(37,'Create a personal budget','Productivity','Happy discuss society. Process old find agent hand term pull. Appear expert into.',240),(38,'Attend a productivity seminar','Productivity','Simply improve either page watch. Take me much. Look boy like they set.',170),(39,'Sort emails and organize your inbox','Productivity','Condition check represent worker truth evidence. Degree degree enjoy him music.',70),(40,'Set up a calendar for the next month','Productivity','Number range series. Citizen blue sometimes. Consider century together every.',90),(41,'Read a self-help book','Productivity','Region produce then. Instead claim stand though life since.',130),(42,'Complete an online course','Productivity','Care now yourself generation serve similar. Goal itself south expect paper.',230),(43,'List your top 5 priorities','Productivity','Third capital natural early. American task science better.',190),(44,'Organize your files digitally','Productivity','Describe their community catch need either. Former political one detail.',230),(45,'Create a task checklist for the week','Productivity','Indeed cup because skin find. Discussion data pass national enough per card travel.',220),(46,'Practice a 10-minute mindfulness session','Productivity','Personal stop have commercial type democratic. Radio notice hope. Agree what perhaps fill.',250),(47,'Work uninterrupted for 1 hour','Productivity','Top turn individual put according generation. Really one fast.',130),(48,'Review personal goals','Productivity','Camera practice wide imagine west bag. Fact best look bar measure evidence already.',170),(49,'Declutter a physical or digital space','Productivity','Power admit interesting side they. Painting near than painting bring PM instead avoid.',120),(50,'Make a vision board','Productivity','Fall protect and author. Democrat about room officer.\nFind maintain election game become bed.',300),(51,'Identify time-wasters in your day','Productivity','Bad blue capital worry involve spend cost whatever. Medical long usually.',160),(52,'Take a 30-minute brainstorming session','Productivity','Along yeah stop body executive. Either tend Mrs first. Computer key into campaign.',260),(53,'Outline a presentation','Productivity','Civil article establish bit. War play chance actually hear home. Year eight off high eat.',290),(54,'Backup important data','Productivity','Way bar respond career stuff. Middle minute management page between.',250),(55,'Set SMART goals for yourself','Productivity','Economic behind man establish. Camera man somebody animal guess.',290),(56,'Practice a skill for 1 hour','Productivity','Officer strong customer. Stand impact word.',50),(57,'Plan a healthy meal schedule','Productivity','Military star scene clearly third author. Recent beautiful agent easy during much reason.',50),(58,'Learn a new software tool','Productivity','End prevent near. Begin focus role area.',180),(59,'Review and refine your goals','Productivity','They better realize collection what mother. Sort book involve walk.',80),(60,'Send thank-you emails to colleagues','Productivity','Between our son former third son for. May thought win. Page central want mind hair.',60),(61,'Host a dinner party','Social Life','Push consumer last campaign. Peace player professor we degree movement. Chair respond what church.',120),(62,'Join a community club','Social Life','Fear especially here debate would certainly. Thus represent behavior hair also account recent.',290),(63,'Call an old friend','Social Life','Shake thus what day. Week second drop tax national.',120),(64,'Meet a new person and learn about their life','Social Life','Lead news as treat so rather agreement industry. Throughout grow wrong. Pass my research.',60),(65,'Attend a social networking event','Social Life','Over both heart full yourself size. Kitchen board create performance reduce how down thank.',70),(66,'Volunteer for a local cause','Social Life','Decision amount beautiful wrong near figure political. Agreement according their.',100),(67,'Send a thoughtful gift to someone','Social Life','Front rate yet Democrat so. Rule chair mother care myself down but.',230),(68,'Organize a group outing','Social Life','Property fine scene beat boy describe career she. Pattern foot can draw part positive how.',140),(69,'Celebrate a friends achievement','Social Life','Call yourself learn pattern everything. Design debate child and almost.',160),(70,'Play a board game with friends','Social Life','Entire others Democrat contain. Involve poor street minute focus bill daughter.',220),(71,'Plan a surprise for a loved one','Social Life','Someone else name require peace. Fire goal energy similar ball work discussion guess.',60),(72,'Visit a relative you havenâ€™t seen in a while','Social Life','Congress wait or small less sing special. Tend medical agree tree indicate have.',140),(73,'Join a hobby group or meetup','Social Life','Since rise training perform out song behind. Resource onto particular. Town all necessary behavior.',150),(74,'Write a letter to someone special','Social Life','Worry opportunity air. Reflect pay decision week page.',240),(75,'Go out for coffee with a friend','Social Life','Catch although simply two garden process. Dark rather how both hospital amount.',160),(76,'Help a neighbor with something','Social Life','Because practice attack course some material know. Future establish product end early.',210),(77,'Teach someone a skill you know','Social Life','Truth case discuss. Alone friend travel country be item.',280),(78,'Participate in a charity walk or run','Social Life','Risk land commercial lawyer skin. Director democratic trouble evidence movie cost.',260),(79,'Share a meal with your family','Social Life','Respond whom ahead computer reveal year east. Mr magazine kid between writer their.',270),(80,'Plan a picnic with friends','Social Life','Girl wide hard cold. Yes tax themselves part artist foot knowledge. Often world ago other.',170),(81,'Attend a live concert','Social Life','Establish spring local cost. Choice as inside admit field century.',110),(82,'Invite a friend to an activity you enjoy','Social Life','Candidate store animal central. Gas fact our hear. Ready make there arm standard.',210),(83,'Spend a day with your grandparents','Social Life','Imagine hot responsibility Congress. Reach painting voice election trade growth.',290),(84,'Join a sports league or team','Social Life','Police teach brother threat base. Water follow toward long. Future glass country half throughout.',270),(85,'Catch up with an old friend','Social Life','Stuff always any few south eye. Since economic price chair. Pressure enjoy smile someone.',170),(86,'Organize a movie night','Social Life','Population build box show visit. Hot wait blue author.',160),(87,'Start a book club with friends','Social Life','Actually one order. Only white show action force.',210),(88,'Volunteer to teach at a community center','Social Life','Religious company accept interesting. Act surface man together.',90),(89,'Plan a weekend road trip with friends','Social Life','Popular dog worker else owner prevent.\nTime language listen effort. Large camera personal star.',300),(90,'Create a shared photo album with friends','Social Life','Key difference sell attorney. Bring own executive them total each.',290);

-- Table: goaltask
CREATE TABLE `goaltask` (
    `goal_task_id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `goal_id` INTEGER NOT NULL,
    `task_id` INTEGER NOT NULL,
    FOREIGN KEY (`goal_id`) REFERENCES `goals` (`goal_id`) ON DELETE CASCADE,
    FOREIGN KEY (`task_id`) REFERENCES `tasks` (`task_id`) ON DELETE CASCADE
);

INSERT INTO `goaltask` (`goal_task_id`,`goal_id`, `task_id`) 
VALUES (1,1,5),(2,1,24),(3,1,4),(4,1,28),(5,1,25),(6,2,13),(7,2,28),(8,2,23),(9,2,7),(10,2,11),(11,3,26),(12,3,10),(13,3,28),(14,3,15),(15,3,8),(16,4,25),(17,4,30),(18,4,15),(19,4,13),(20,4,3),(21,5,13),(22,5,20),(23,5,23),(24,5,1),(25,5,25),(26,6,39),(27,6,37),(28,6,60),(29,6,43),(30,6,47),(31,7,44),(32,7,50),(33,7,37),(34,7,51),(35,7,45),(36,8,33),(37,8,36),(38,8,46),(39,8,58),(40,8,55),(41,9,45),(42,9,42),(43,9,31),(44,9,48),(45,9,47),(46,10,59),(47,10,32),(48,10,60),(49,10,56),(50,10,36),(51,11,62),(52,11,72),(53,11,81),(54,11,84),(55,11,69),(56,12,72),(57,12,69),(58,12,82),(59,12,74),(60,12,79),(61,13,63),(62,13,62),(63,13,90),(64,13,71),(65,13,69),(66,14,74),(67,14,68),(68,14,63),(69,14,69),(70,14,66),(71,15,68),(72,15,63),(73,15,72),(74,15,64),(75,15,79);

-- Table: users
CREATE TABLE `users` (
    `user_id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `username` TEXT NOT NULL,
    `email` TEXT NOT NULL UNIQUE,
    `password` TEXT NOT NULL,
    `gold` INTEGER DEFAULT 0,
    `created_at` TEXT DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO `users` (`user_id`, `username`, `email`, `password`, `gold`, `created_at`) 
VALUES 
(1, 'user1', 'user1', 'password1', 650, '2025-01-07 19:55:21'), (2,'user2','user2','password2',1360,'2025-01-07 04:23:08');


-- Table: usertasks
CREATE TABLE `usertasks` (
    `user_id` INTEGER NOT NULL,
    `task_id` INTEGER NOT NULL,
    `is_completed` BOOLEAN DEFAULT 0,
    `completed_at` TEXT DEFAULT NULL,
    `photo_decision` TEXT DEFAULT NULL,
    PRIMARY KEY (`user_id`, `task_id`),
    FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
    FOREIGN KEY (`task_id`) REFERENCES `tasks` (`task_id`) ON DELETE CASCADE
);


INSERT INTO `usertasks` (`user_id`, `task_id`, `is_completed`, `completed_at`, `photo_decision`) 
VALUES 
(1,1,1,'2024-12-01 20:54:27',NULL),
(1,3,0,NULL,NULL),
(1,4,0,NULL,NULL),
(1,5,1,'2024-12-07 20:54:27',NULL),
(1,7,1,'2024-12-09 20:54:27',NULL),
(1,11,1,'2024-12-03 20:54:27',NULL),
(1,13,0,NULL,NULL),
(1,15,0,NULL,NULL),
(1,20,0,NULL,NULL),
(1,23,0,NULL,NULL),
(1,24,0,NULL,NULL),
(1,25,0,NULL,NULL),
(1,28,0,NULL,NULL),
(1,30,0,NULL,NULL),
(1,33,0,NULL,NULL),
(1,36,0,NULL,NULL),
(1,37,0,NULL,NULL),
(1,39,0,NULL,NULL),
(1,43,0,NULL,NULL),
(1,44,0,NULL,NULL),
(1,45,0,NULL,NULL),
(1,46,0,NULL,NULL),
(1,47,1,'2024-12-12 20:54:27',NULL),
(1,50,0,NULL,NULL),
(1,51,0,NULL,NULL),
(1,55,1,'2024-12-14 20:54:27',NULL),
(1,58,0,NULL,NULL),
(1,60,0,NULL,NULL),
(1,62,1,'2024-12-15 21:32:05',NULL),
(1,63,0,NULL,NULL),
(1,66,1,'2024-12-20 20:54:27',NULL),
(1,68,0,NULL,NULL),
(1,69,0,NULL,NULL),
(1,71,1,'2024-12-25 21:32:05',NULL),
(1,74,0,NULL,NULL),
(1,90,1,'2024-12-23 20:54:27',NULL),
(2,3,1,'2024-12-28 20:58:59',NULL),
(2,8,1,'2024-12-30 20:58:59',NULL),
(2,10,0,NULL,NULL),
(2,13,1,'2025-01-01 20:58:59',NULL),
(2,15,0,NULL,NULL),
(2,25,0,NULL,NULL),
(2,26,1,'2025-01-03 20:58:59',NULL),
(2,28,0,NULL,NULL),
(2,30,0,NULL,NULL),
(2,31,0,NULL,NULL),
(2,32,0,NULL,NULL),
(2,36,1,'2025-01-10 21:31:09',NULL),
(2,42,0,NULL,NULL),
(2,45,1,'2025-01-10 21:31:09',NULL),
(2,47,1,'2025-01-10 20:58:59',NULL),
(2,48,0,NULL,NULL),
(2,56,0,NULL,NULL),
(2,59,0,NULL,NULL),
(2,60,0,NULL,NULL),
(2,62,0,NULL,NULL),
(2,69,0,NULL,NULL),
(2,72,0,NULL,NULL),
(2,74,0,NULL,NULL),
(2,79,0,NULL,NULL),
(2,81,0,NULL,NULL),
(2,82,0,NULL,NULL),
(2,84,0,NULL,NULL);


-- Table: usergoals
CREATE TABLE `usergoals` (
    `user_id` INTEGER NOT NULL,
    `goal_id` INTEGER NOT NULL,
    `progress` INTEGER DEFAULT 0,
    `is_completed` BOOLEAN DEFAULT 0,
    `completed_at` TEXT DEFAULT NULL,
    PRIMARY KEY (`user_id`, `goal_id`),
    FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
    FOREIGN KEY (`goal_id`) REFERENCES `goals` (`goal_id`) ON DELETE CASCADE
);

INSERT INTO `usergoals` (`user_id`, `goal_id`, `progress`, `is_completed`, `completed_at`) 
VALUES (1,1,1,0,NULL),(1,2,2,0,NULL),(1,4,0,0,NULL),(1,5,1,0,NULL),(1,6,1,0,NULL),(1,7,0,0,NULL),(1,8,1,0,NULL),(1,13,3,0,NULL),(1,14,1,0,NULL),(2,3,2,0,NULL),(2,4,2,0,NULL),(2,9,2,0,NULL),(2,10,1,0,NULL),(2,11,0,0,NULL),(2,12,0,0,NULL);

-- Table: items
CREATE TABLE `items` (
    `item_id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `name` TEXT NOT NULL,
    `description` TEXT,
    `type` TEXT,
    `price` INTEGER NOT NULL,
    `photo_id` INTEGER NOT NULL,
    FOREIGN KEY (`photo_id`) REFERENCES `photos` (`photo_id`) ON DELETE CASCADE
);
INSERT INTO `items` (`name`, `description`, `type`, `price`, `photo_id`)
VALUES 
('Yellow Cap', 'A stylish yellow cap.', 'Hat', 100, 1),
('Black Cap', 'A trendy black cap.', 'Hat', 120, 2),
('Fire Glasses', 'Hot fire glasses.', 'glasses', 200, 3),
('Heart Glasses', 'Cute heart glasses.', 'glasses', 300, 4),
('Crown', 'A stunning crown.', 'accessories', 400, 5);


-- Table: photos
CREATE TABLE `photos` (
    `photo_id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `user_id` INTEGER,
    `task_id` INTEGER,
    `url` TEXT NOT NULL,
    `uploaded_at` TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
    FOREIGN KEY (`task_id`) REFERENCES `tasks` (`task_id`) ON DELETE CASCADE
);

INSERT INTO `photos` (`photo_id`, `url`)
VALUES 
(1, 'assets/images/yellowcap.jpg'),
(2, 'assets/images/blackcap.jpg'),
(3, 'assets/images/fireglasses.jpg'),
(4, 'assets/images/heartglasses.jpg'),
(5, 'assets/images/crown.jpg');


-- Table: useritems
CREATE TABLE `useritems` (
    `user_id` INTEGER NOT NULL,
    `item_id` INTEGER NOT NULL,
    `is_equipped` BOOLEAN DEFAULT 0,
    PRIMARY KEY (`user_id`, `item_id`),
    FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
    FOREIGN KEY (`item_id`) REFERENCES `items` (`item_id`) ON DELETE CASCADE
);
