CREATE DATABASE  IF NOT EXISTS `goaldigger` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `goaldigger`;
-- MySQL dump 10.13  Distrib 8.0.36, for Win64 (x86_64)
--
-- Host: localhost    Database: goaldigger
-- ------------------------------------------------------
-- Server version	8.4.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `goals`
--

DROP TABLE IF EXISTS `goals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `goals` (
  `goal_id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `category` varchar(20) NOT NULL,
  `description` text,
  `target` int NOT NULL DEFAULT '0',
  `tasks_completed` int DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`goal_id`),
  KEY `idx_goals_title` (`title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `goaltask`
--

DROP TABLE IF EXISTS `goaltask`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `goaltask` (
  `goal_task_id` int NOT NULL AUTO_INCREMENT,
  `goal_id` int NOT NULL,
  `task_id` int NOT NULL,
  PRIMARY KEY (`goal_task_id`),
  KEY `goal_id` (`goal_id`),
  KEY `task_id` (`task_id`),
  CONSTRAINT `goaltask_ibfk_1` FOREIGN KEY (`goal_id`) REFERENCES `goals` (`goal_id`),
  CONSTRAINT `goaltask_ibfk_2` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`task_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `items`
--

DROP TABLE IF EXISTS `items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `items` (
  `item_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` text,
  `type` varchar(50) DEFAULT NULL,
  `price` int NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `photos`
--

DROP TABLE IF EXISTS `photos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `photos` (
  `photo_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `task_id` int DEFAULT NULL,
  `goal_id` int DEFAULT NULL,
  `url` text NOT NULL,
  `uploaded_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`photo_id`),
  KEY `user_id` (`user_id`),
  KEY `task_id` (`task_id`),
  KEY `goal_id` (`goal_id`),
  CONSTRAINT `photos_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `photos_ibfk_2` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`task_id`),
  CONSTRAINT `photos_ibfk_3` FOREIGN KEY (`goal_id`) REFERENCES `goals` (`goal_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tasks`
--

DROP TABLE IF EXISTS `tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tasks` (
  `task_id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `category` varchar(50) NOT NULL,
  `description` text,
  `gold_reward` int DEFAULT NULL,
  `photo` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`task_id`),
  KEY `idx_tasks_title` (`title`),
  KEY `idx_tasks_category` (`category`),
  FULLTEXT KEY `title` (`title`,`description`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `usercompletedgoals`
--

DROP TABLE IF EXISTS `usercompletedgoals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usercompletedgoals` (
  `completed_goal_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `goal_id` int NOT NULL,
  `completed_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`completed_goal_id`),
  KEY `user_id` (`user_id`),
  KEY `goal_id` (`goal_id`),
  CONSTRAINT `usercompletedgoals_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `usercompletedgoals_ibfk_2` FOREIGN KEY (`goal_id`) REFERENCES `goals` (`goal_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `usercompletedtasks`
--

DROP TABLE IF EXISTS `usercompletedtasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usercompletedtasks` (
  `completed_task_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `task_id` int NOT NULL,
  `completed_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`completed_task_id`),
  KEY `user_id` (`user_id`),
  KEY `task_id` (`task_id`),
  CONSTRAINT `usercompletedtasks_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `usercompletedtasks_ibfk_2` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`task_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `userequippeditems`
--

DROP TABLE IF EXISTS `userequippeditems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `userequippeditems` (
  `equipped_item_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `item_id` int NOT NULL,
  `is_equipped` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`equipped_item_id`),
  KEY `user_id` (`user_id`),
  KEY `item_id` (`item_id`),
  CONSTRAINT `userequippeditems_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `userequippeditems_ibfk_2` FOREIGN KEY (`item_id`) REFERENCES `items` (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `usergoals`
--

DROP TABLE IF EXISTS `usergoals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usergoals` (
  `user_goal_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `goal_id` int NOT NULL,
  `progress` int DEFAULT '0',
  `is_completed` tinyint(1) DEFAULT '0',
  `completed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`user_goal_id`),
  KEY `user_id` (`user_id`),
  KEY `goal_id` (`goal_id`),
  CONSTRAINT `usergoals_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `usergoals_ibfk_2` FOREIGN KEY (`goal_id`) REFERENCES `goals` (`goal_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `userinprogressgoals`
--

DROP TABLE IF EXISTS `userinprogressgoals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `userinprogressgoals` (
  `in_progress_goal_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `goal_id` int NOT NULL,
  `progress` int DEFAULT '0',
  PRIMARY KEY (`in_progress_goal_id`),
  KEY `user_id` (`user_id`),
  KEY `goal_id` (`goal_id`),
  CONSTRAINT `userinprogressgoals_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `userinprogressgoals_ibfk_2` FOREIGN KEY (`goal_id`) REFERENCES `goals` (`goal_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `useritems`
--

DROP TABLE IF EXISTS `useritems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `useritems` (
  `user_item_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `item_id` int NOT NULL,
  PRIMARY KEY (`user_item_id`),
  KEY `user_id` (`user_id`),
  KEY `item_id` (`item_id`),
  CONSTRAINT `useritems_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `useritems_ibfk_2` FOREIGN KEY (`item_id`) REFERENCES `items` (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `profile_photo` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `usertasks`
--

DROP TABLE IF EXISTS `usertasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usertasks` (
  `user_task_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `task_id` int NOT NULL,
  `is_completed` tinyint(1) DEFAULT '0',
  `completed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`user_task_id`),
  KEY `user_id` (`user_id`),
  KEY `task_id` (`task_id`),
  CONSTRAINT `usertasks_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `usertasks_ibfk_2` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`task_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping events for database 'goaldigger'
--

--
-- Dumping routines for database 'goaldigger'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
