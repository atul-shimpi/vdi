-- MySQL Administrator dump 1.4
--
-- ------------------------------------------------------
-- Server version	5.1.37-1ubuntu5.1


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


--
-- Create schema gdevvdi
--

CREATE DATABASE IF NOT EXISTS gdevvdi;
USE gdevvdi;

--
-- Definition of table `gdevvdi`.`actions`
--

DROP TABLE IF EXISTS `gdevvdi`.`actions`;
CREATE TABLE  `gdevvdi`.`actions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `action` varchar(45) NOT NULL DEFAULT '',
  `controller` varchar(45) NOT NULL DEFAULT '',
  `description` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8;


--
-- Dumping data for table `gdevvdi`.`actions`
--

/*!40000 ALTER TABLE `actions` DISABLE KEYS */;
LOCK TABLES `actions` WRITE;
INSERT INTO `gdevvdi`.`actions` VALUES  (1,'welcome','user','user welcome page'),
 (2,'index','users','user listing page'),
 (3,'new','roles','create roles'),
 (4,'new','actions','create action '),
 (5,'index','groups','groups listing'),
 (6,'new','groups',''),
 (7,'create','groups','create groups'),
 (8,'show','groups','assing user to groups'),
 (9,'index','actions','actions listing page'),
 (11,'new','jobs','job creation page'),
 (12,'create','jobs','create action for job'),
 (13,'index','templates','Template listing page'),
 (14,'index','jobs','Job Listing Page'),
 (15,'update_user_group','groups','add or remove user'),
 (16,'edit','users','user edit profile page'),
 (17,'update','users','user update profile'),
 (18,'edit','jobs','job edit page'),
 (19,'update','jobs','job update action'),
 (20,'destroy','jobs','Job delete action'),
 (21,'show','jobs','job show page'),
 (22,'index','securities','security port'),
 (23,'edit','securities','security port'),
 (24,'destroy','securities','security port'),
 (25,'new','securities','security port'),
 (26,'update_group_table','groups','filter for group sorting'),
 (27,'index','securitygroups','security groups'),
 (28,'edit','securitygroups','security groups'),
 (29,'destroy','securitygroups','security groups'),
 (30,'new','securitygroups','security groups'),
 (31,'show','securitygroups','security groups'),
 (32,'index','actives','Actives Jobs'),
 (33,'index','histroys','Histroys Jobs'),
 (34,'index','configurations','Configuration listing page');
UNLOCK TABLES;
/*!40000 ALTER TABLE `actions` ENABLE KEYS */;

--
-- Definition of table `gdevvdi`.`command`
--

DROP TABLE IF EXISTS `gdevvdi`.`cmds`;
CREATE TABLE  `gdevvdi`.`cmds` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_id` int(11) NOT NULL DEFAULT '0',
  `command` TEXT NOT NULL DEFAULT '',
  `state` varchar(45) NOT NULL DEFAULT '',
  `job_type` varchar(45) NOT NULL DEFAULT '',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `retry` int(11) NOT NULL DEFAULT '0',
  `error_log` TEXT DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8;



--
-- Definition of table `gdevvdi`.`securitygroups_security`
--

DROP TABLE IF EXISTS `gdevvdi`.`securities_securitygroups`;
CREATE TABLE  `gdevvdi`.`securities_securitygroups` (
  `securitygroup_id` int(11) NOT NULL DEFAULT '0',
  `security_id` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Definition of table `gdevvdi`.`actions_roles`
--

DROP TABLE IF EXISTS `gdevvdi`.`actions_roles`;
CREATE TABLE  `gdevvdi`.`actions_roles` (
  `role_id` int(11) NOT NULL DEFAULT '0',
  `action_id` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `gdevvdi`.`actions_roles`
--

/*!40000 ALTER TABLE `actions_roles` DISABLE KEYS */;
LOCK TABLES `actions_roles` WRITE;
INSERT INTO `gdevvdi`.`actions_roles` VALUES  (2,4),
 (2,3),
 (2,1),
 (2,2),
 (2,6),
 (2,7),
 (6,3),
 (6,1),
 (2,8),
 (6,13),
 (6,14),
 (6,11),
 (6,12),
 (7,8),
 (7,5),
 (7,15),
 (2,5),
 (6,16),
 (6,17),
 (6,19),
 (6,18),
 (6,20),
 (7,14),
 (7,18),
 (7,19),
 (7,20),
 (7,24);
UNLOCK TABLES;
/*!40000 ALTER TABLE `actions_roles` ENABLE KEYS */;


--
-- Definition of table `gdevvdi`.`ec2machines`
--

DROP TABLE IF EXISTS `gdevvdi`.`ec2machines`;
CREATE TABLE  `gdevvdi`.`ec2machines` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `instance_id` varchar(15) DEFAULT NULL,
  `public_dns` varchar(255) DEFAULT NULL,
  `private_dns` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `zone` varchar(255) DEFAULT NULL,
  `platform` varchar(255) DEFAULT NULL,
  `virtualization` varchar(255) DEFAULT NULL,
  `block_devices` varchar(255) DEFAULT NULL,
  `lifecycle` varchar(255) DEFAULT NULL,
  `security_group` varchar(255) DEFAULT NULL,
  `key_pair` varchar(255) DEFAULT NULL,
  `launch_time` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `public_ip` varchar(255) DEFAULT NULL,
  `private_ip` varchar(255) DEFAULT NULL,
  `sg_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;



--
-- Definition of table `gdevvdi`.`active_ilandmachines`
--

DROP TABLE IF EXISTS `gdevvdi`.`active_ilandmachines`;

CREATE TABLE `gdevvdi`.`active_ilandmachines` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `instance_id` varchar(255) DEFAULT NULL,
  `vapp_href` varchar(255) DEFAULT NULL,
  `public_dns` varchar(255) DEFAULT NULL,
  `private_dns` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `region` varchar(45) DEFAULT NULL,
  `os` varchar(45) DEFAULT NULL,
  `instance_type` varchar(255) DEFAULT NULL,
  `launch_time` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `public_ip` varchar(255) DEFAULT NULL,
  `private_ip` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;


--
-- Definition of table `gdevvdi`.`active_machines`
--

DROP TABLE IF EXISTS `gdevvdi`.`active_machines`;
CREATE TABLE  `gdevvdi`.`active_machines` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `instance_id` varchar(15) DEFAULT NULL,
  `ami_id` varchar(15) DEFAULT NULL,
  `public_dns` varchar(255) DEFAULT NULL,
  `private_dns` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `zone` varchar(255) DEFAULT NULL,
  `region` varchar(45) DEFAULT NULL,
  `os` varchar(45) DEFAULT NULL,
  `block_devices` varchar(255) DEFAULT NULL,
  `instance_type` varchar(255) DEFAULT NULL,
  `security_group` varchar(255) DEFAULT NULL,
  `key_pair` varchar(255) DEFAULT NULL,
  `launch_time` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `public_ip` varchar(255) DEFAULT NULL,
  `private_ip` varchar(255) DEFAULT NULL,
  `sg_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `gdevvdi`.`active_volumes`;
CREATE TABLE  `gdevvdi`.`active_volumes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `volume_id` varchar(15) DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  `snapshot_id` varchar(15) DEFAULT NULL,
  `instance_id` varchar(15) DEFAULT NULL,
  `attach_device` varchar(45) DEFAULT NULL,
  `availabilityZone` varchar(45) DEFAULT NULL,
  `status` varchar(15) DEFAULT NULL,
  `region` varchar(15) DEFAULT NULL,
  `createTime` datetime DEFAULT NULL,
  `deleted` tinyint DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `gdevvdi`.`active_snapshots`;
CREATE TABLE  `gdevvdi`.`active_snapshots` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `snapshot_id` varchar(15) DEFAULT NULL,
  `ami` varchar(15) DEFAULT NULL,
  `volume_id` varchar(15) DEFAULT NULL,
  `status` varchar(15) DEFAULT NULL,
  `start_at` datetime DEFAULT NULL,
  `volumeSize` int(11) DEFAULT NULL,
  `region` varchar(15) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `gdevvdi`.`active_amis`;
CREATE TABLE  `gdevvdi`.`active_amis` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ami_id` varchar(15) DEFAULT NULL,
  `imageState` varchar(15) DEFAULT NULL,
  `architecture` varchar(15) DEFAULT NULL,
  `platform` varchar(15) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `region` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
--
-- Definition of table `gdevvdi`.`groups`
--

DROP TABLE IF EXISTS `gdevvdi`.`active_spots`;
CREATE TABLE  `gdevvdi`.`active_spots` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `spot_id` varchar(15) DEFAULT NULL,
  `os` varchar(15) DEFAULT NULL,
  `status` varchar(15) DEFAULT NULL,
  `instance_id` varchar(15) DEFAULT NULL,
  `region` varchar(15) DEFAULT NULL,
  `instance_type` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `gdevvdi`.`groups`;
CREATE TABLE  `gdevvdi`.`groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `manager_id` int(11) DEFAULT NULL,
  `ispublic` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `gdevvdi`.`groups`
--

--
-- Definition of table `gdevvdi`.`groups_users`
--

DROP TABLE IF EXISTS `gdevvdi`.`groups_users`;
CREATE TABLE  `gdevvdi`.`groups_users` (
  `user_id` int(11) NOT NULL DEFAULT '0',
  `group_id` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `gdevvdi`.`groups_users`
--

/*!40000 ALTER TABLE `groups_users` DISABLE KEYS */;
LOCK TABLES `groups_users` WRITE;
INSERT INTO `gdevvdi`.`groups_users` VALUES  (3,5),
 (1,5);
UNLOCK TABLES;
/*!40000 ALTER TABLE `groups_users` ENABLE KEYS */;

--
-- Definition of table `gdevvdi`.`ilandmachines`
--


DROP TABLE IF EXISTS `gdevvdi`.`ilandmachines`;

CREATE TABLE `gdevvdi`.`ilandmachines` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `instance_id` varchar(255) DEFAULT NULL,
  `vapp_id` varchar(255) DEFAULT NULL,
  `public_dns` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `private_dns` varchar(255) DEFAULT NULL,
  `zone` varchar(45) DEFAULT NULL,
  `platform` varchar(45) DEFAULT NULL,
  `virtualization` varchar(45) DEFAULT NULL,
  `block_devices` varchar(255) DEFAULT NULL,
  `lifecycle` varchar(45) DEFAULT NULL,
  `key_pair` varchar(255) DEFAULT NULL,
  `launch_time` datetime DEFAULT NULL,
  `status` varchar(45) DEFAULT NULL,
  `public_ip` varchar(255) DEFAULT NULL,
  `sg_id` varchar(255) DEFAULT NULL,
  `private_ip` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `public_dns` (`public_dns`)
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `gdevvdi`.`ilandmachines`
--

--
-- Definition of table `gdevvdi`.`instancetypes`
--

DROP TABLE IF EXISTS `gdevvdi`.`instancetypes`;
CREATE TABLE  `gdevvdi`.`instancetypes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `architecture` varchar(20) DEFAULT NULL,
  `windows_maxprice` float DEFAULT NULL,
  `linux_maxprice` float DEFAULT NULL,
  `windows_price` float DEFAULT NULL,
  `linux_price` float DEFAULT NULL,
  `cpusize` int(4) DEFAULT NULL,
  `memorysize` int(16) DEFAULT NULL,
  `dc` varchar(45) NOT NULL DEFAULT 'us-east-1',
  `seq` int(11),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `gdevvdi`.`instancetypes`
--

/*!40000 ALTER TABLE `instancetypes` DISABLE KEYS */;
LOCK TABLES `instancetypes` WRITE;
INSERT INTO `gdevvdi`.`instancetypes` VALUES  (1,'m1.small', '1GHz-1.7GB','2010-06-11 12:02:30','2010-06-11 12:02:30','i386', 2, 2, 2, 2, NULL, Null, 'us-east-1'),
 (2,'c1.medium', '5GHz-1.7GB','2010-06-11 12:02:36','2010-06-11 12:02:36','i386', 2, 2, 2, 2, NULL, Null, 'us-east-1'),
 (3,'m1.large', '4GHz-7.3GB','2010-06-11 12:02:30','2010-06-11 12:02:30','x86_64', 2, 2, 2, 2, NULL, Null, 'us-east-1'),
 (4,'m1.xlarge', '8GHz-15GB', '2010-06-11 12:02:30','2010-06-11 12:02:30','x86_64', 2, 2, 2, 2, NULL, Null, 'us-east-1'),
 (5,'m2.xlarge', '6.5GHz-17GB', '2010-06-11 12:02:30','2010-06-11 12:02:30','x86_64', 2, 2, 2, 2, NULL, Null, 'us-east-1'),
 (6,'m2.2xlarge', '13GHz-34GB', '2010-06-11 12:02:30','2010-06-11 12:02:30','x86_64', 2, 2, 2, 2, NULL, Null, 'us-east-1'),
 (7,'m2.4xlarge','26GHz-68GB', '2010-06-11 12:02:30','2010-06-11 12:02:30','x86_64', 2, 2, 2, 2, NULL, Null, 'us-east-1'),
 (8,'c1.xlarge', '20GHz-7GB', '2010-06-11 12:02:30','2010-06-11 12:02:30','x86_64', 2, 2, 2, 2��NULL, Null, 'us-east-1'),
 (9,'iland.samll',NULL,NULL,'i386','1GHz-1GB',2,2,2,2,1,1024,'iland'),
 (10,'iland.medium',NULL,NULL,'i386','5GHZ-16GB',2,2,2,2,5,16384,'iland'),
 (11,'iland.xlarge',NULL,NULL,'i386','8GHZ-32GB',2,2,2,2,8,32768,'iland');
UNLOCK TABLES;
/*!40000 ALTER TABLE `instancetypes` ENABLE KEYS */;

--
-- Definition of table `gdevvdi`.`instancetypes`
--

DROP TABLE IF EXISTS `gdevvdi`.`securitytypes`;
CREATE TABLE  `gdevvdi`.`securitytypes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `securitygroup_id` varchar(255) DEFAULT NULL,
  `region` varchar(45) DEFAULT 'us-east-1',
  `state` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

--
-- Definition of table `gdevvdi`.`configurations`
--

DROP TABLE IF EXISTS `gdevvdi`.`configurations`;
CREATE TABLE  `gdevvdi`.`configurations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `template_id` int(11) DEFAULT NULL,
  `template_mapping_id` int(11) DEFAULT NULL,
  `template_name` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `rpermission` varchar(255) DEFAULT NULL,
  `permission` varchar(255) DEFAULT NULL,
  `lease_time` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `instancetype_id` int(11) DEFAULT NULL,
  `securitygroup_id` int(11) DEFAULT NULL,
  `deploymentway` varchar(255) DEFAULT NULL,
  `commands` varchar(1000) DEFAULT NULL,
  `init_commands` varchar(1000) DEFAULT NULL,
  `cmd_path` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `poweroff_hour` int(11) DEFAULT 0,
  `poweroff_min` int(11) DEFAULT 0,
  `subnet_id` int(11) DEFAULT NULL,
  `deleted` int(11) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

--
-- Definition of table `gdevvdi`.`jobs`
--

DROP TABLE IF EXISTS `gdevvdi`.`jobs`;
CREATE TABLE  `gdevvdi`.`jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `rpermission` varchar(255) DEFAULT NULL,
  `permission` varchar(255) DEFAULT NULL,
  `lease_time` datetime DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `usage` varchar(45) DEFAULT NULL,
  `project_id` int(11) DEFAULT NULL,
  `template_id` int(11) DEFAULT NULL,
  `ami_name` varchar(255) DEFAULT NULL,
  `ec2machine_id` int(11) DEFAULT NULL,
  `ilandmachine_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `instancetype_id` int(11) DEFAULT NULL,
  `securitygroup_id` int(11) DEFAULT NULL,
  `configuration_id` int(11) DEFAULT NULL,
  `init_commands` MEDIUMTEXT,
  `runcluster_id` int(11) DEFAULT NULL,
  `role` varchar(255) DEFAULT NULL,
  `request_id` varchar(255) DEFAULT NULL,
  `securitytype_name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deploymentway` varchar(255) DEFAULT NULL,
  `max_price` float DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `is_busy` tinyint DEFAULT 0,
  `locked` tinyint DEFAULT 0,
  `poweroff_hour` int(11) DEFAULT 0,
  `poweroff_min` int(11) DEFAULT 0,
  `telnet_service` varchar(45) DEFAULT NULL,
  `subnet_id` int(11) DEFAULT NULL,
  `cost` float DEFAULT 0,
  `machinepassword` varchar(255) DEFAULT NULL,
  `support_id` int(11) DEFAULT NULL,
  `region` varchar(45) DEFAULT 'us-east-1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;




--
-- Definition of table `gdevvdi`.`roles`
--

DROP TABLE IF EXISTS `gdevvdi`.`roles`;
CREATE TABLE  `gdevvdi`.`roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `role_name` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `parent_role` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `gdevvdi`.`roles`
--

/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
LOCK TABLES `roles` WRITE;
INSERT INTO `gdevvdi`.`roles` VALUES  (2,'admin','admin role',0),
 (4,'client','client role',2),
 (5,'TAM','TAM User',2),
 (6,'user','user login',2),
 (7,'manager','manager role',2);
UNLOCK TABLES;
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;


--
-- Definition of table `gdevvdi`.`roles_users`
--

DROP TABLE IF EXISTS `gdevvdi`.`roles_users`;
CREATE TABLE  `gdevvdi`.`roles_users` (
  `user_id` int(11) NOT NULL DEFAULT '0',
  `role_id` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `gdevvdi`.`roles_users`
--

/*!40000 ALTER TABLE `roles_users` DISABLE KEYS */;
LOCK TABLES `roles_users` WRITE;
INSERT INTO `gdevvdi`.`roles_users` VALUES  (3,4),
 (1,6),
 (1,2),
 (1,4),
 (1,5),
 (2,6),
 (4,7);
UNLOCK TABLES;
/*!40000 ALTER TABLE `roles_users` ENABLE KEYS */;


--
-- Definition of table `gdevvdi`.`schema_migrations`
--

DROP TABLE IF EXISTS `gdevvdi`.`schema_migrations`;
CREATE TABLE  `gdevvdi`.`schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `gdevvdi`.`schema_migrations`
--

/*!40000 ALTER TABLE `schema_migrations` DISABLE KEYS */;
LOCK TABLES `schema_migrations` WRITE;
INSERT INTO `gdevvdi`.`schema_migrations` VALUES  ('20100608103335'),
 ('20100608103643'),
 ('20100608105235'),
 ('20100608113345'),
 ('20100608114139'),
 ('20100610111332'),
 ('20100610111755'),
 ('20100610141558'),
 ('20100611095729'),
 ('20100611100513'),
 ('20100611100620'),
 ('20100611100736');
UNLOCK TABLES;
/*!40000 ALTER TABLE `schema_migrations` ENABLE KEYS */;


--
-- Definition of table `gdevvdi`.`securitygroups`
--

DROP TABLE IF EXISTS `gdevvdi`.`securitygroups`;
CREATE TABLE  `gdevvdi`.`securitygroups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `gdevvdi`.`securitygroups`
--

/*!40000 ALTER TABLE `securitygroups` DISABLE KEYS */;
LOCK TABLES `securitygroups` WRITE;
INSERT INTO `gdevvdi`.`securitygroups` VALUES  (1,'max3','2010-06-11 12:03:00','2010-06-11 12:03:00'),
 (2,'security_nex','2010-06-11 12:03:08','2010-06-11 12:03:08');
UNLOCK TABLES;
/*!40000 ALTER TABLE `securitygroups` ENABLE KEYS */;


--
-- Definition of table `gdevvdi`.`templates`
--

DROP TABLE IF EXISTS `gdevvdi`.`templates`;
CREATE TABLE  `gdevvdi`.`templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `ec2_ami` varchar(255) DEFAULT NULL,
  `user` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `architecture` varchar(55) DEFAULT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `image_type` varchar(55) DEFAULT NULL,
  `image_size` varchar(55) DEFAULT NULL,
  `dev_pay` int(11) DEFAULT 0,
  `is_cluster_instance` int(11) DEFAULT 0,
  `telnet_enabled` int(11) DEFAULT 0,
  `deleted` int(11) DEFAULT 0,
  `is_unsecure` int(11) DEFAULT 0,
  `deleted_by` int(11) DEFAULT NULL,
  `team_id` int(11),
  `creator_id` int(11),
  `job_id` int(11),
  `state` varchar(55) DEFAULT NULL,
  `region` varchar(45) DEFAULT 'us-east-1',
  `ispublic` int(11) DEFAULT 0,
  `group_id` int(11) DEFAULT 0,
  `allow_large` int(11) DEFAULT 0,  
  `template_mapping_id` int(11) DEFAULT 0,
  `export_path` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;


--
-- Definition of table `gdevvdi`.`users`
--

DROP TABLE IF EXISTS `gdevvdi`.`users`;
CREATE TABLE  `gdevvdi`.`users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `quota` int(11) DEFAULT NULL,
  `disabled` tinyint(1) DEFAULT '0',
  `svn_name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

--
-- Definition of table `gdevvdi`.`securities`
--

DROP TABLE IF EXISTS `gdevvdi`.`securities`;
CREATE TABLE  `gdevvdi`.`securities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `protocol` varchar(255) DEFAULT NULL,
  `port_from` int(10) DEFAULT NULL,
  `port_to` int(10) DEFAULT NULL,
  `source` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;


--
-- Dumping data for table `gdevvdi`.`users`
--

/*!40000 ALTER TABLE `users` DISABLE KEYS */;
LOCK TABLES `users` WRITE;
INSERT INTO `gdevvdi`.`users` VALUES  (1,'ankur_jain','da39a3ee5e6b4b0d3255bfef95601890afd80709','ankur','ankur_jain@example.com',NULL,NULL,0,NULL,'2010-06-10 11:42:53','2010-06-10 11:42:53'),
 (2,'dummy','da39a3ee5e6b4b0d3255bfef95601890afd80709','dummy user','eer@jsdk.com','',NULL,0,NULL,'2010-06-10 13:58:02','2010-06-14 10:44:02'),
 (3,'dummy1','da39a3ee5e6b4b0d3255bfef95601890afd80709','dsfs','eer@jsdk.com',NULL,NULL,0,NULL,'2010-06-10 13:59:09','2010-06-10 13:59:09'),
 (4,'manager','da39a3ee5e6b4b0d3255bfef95601890afd80709','manager','manager@example.com',NULL,NULL,0,NULL,'2010-06-14 09:44:59','2010-06-14 09:44:59');
UNLOCK TABLES;
/*!40000 ALTER TABLE `users` ENABLE KEYS */;

DROP TABLE IF EXISTS `gdevvdi`.`emails`;
CREATE TABLE  `gdevvdi`.`emails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `subject` varchar(255) DEFAULT NULL,
  `from` varchar(255) DEFAULT NULL,
  `to` varchar(255) DEFAULT NULL,
  `bcc` varchar(255) DEFAULT NULL,
  `cc` varchar(255) DEFAULT NULL,
  `content` TEXT DEFAULT '',
  `create_at` datetime DEFAULT NULL,
  `update_at` datetime DEFAULT NULL,
  `send_count` int(11) DEFAULT 0,
  `send_successful` int(11) DEFAULT 0,
  `status` varchar(255) DEFAULT NULL,  
  `mailer` varchar(45) DEFAULT NULL, 
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

--
-- Definition of table `gdevvdi`.`newcommands`
--

DROP TABLE IF EXISTS `gdevvdi`.`newcommands`;
CREATE TABLE  `gdevvdi`.`newcommands` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `configuration_id` int(11) NOT NULL DEFAULT '0',
  `commands` varchar(255) NOT NULL DEFAULT '',
  `description` varchar(255) DEFAULT NULL,
  `cmd_path` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

--
-- Definition of table `gdevvdi`.`runcommands`
--

DROP TABLE IF EXISTS `gdevvdi`.`runcommands`;
CREATE TABLE  `gdevvdi`.`runcommands` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_id` int(11) NOT NULL DEFAULT '0',
  `commands` varchar(255) NOT NULL DEFAULT '',
  `description` varchar(255) DEFAULT NULL,
  `cmd_path` varchar(255) DEFAULT NULL,
  `state` varchar(45) DEFAULT NULL,
  `cmd_type` varchar(45) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `ret_mark` mediumtext DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

--
-- Definition of table `gdevvdi`.`cluster`
--

DROP TABLE IF EXISTS `gdevvdi`.`clusters`;
CREATE TABLE  `gdevvdi`.`clusters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `description` varchar(255) DEFAULT NULL,
  `state` varchar(45) DEFAULT NULL,
  `user_id` int(11)
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

--
-- Definition of table `gdevvdi`.`clusterconfigurations`
--

DROP TABLE IF EXISTS `gdevvdi`.`clusterconfigurations`;
CREATE TABLE  `gdevvdi`.`clusterconfigurations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cluster_id` int(11) NOT NULL DEFAULT '0',
  `configuration_id` int(11) NOT NULL DEFAULT '0',
  `role` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


--
-- Definition of table `gdevvdi`.`runclusters`
--

DROP TABLE IF EXISTS `gdevvdi`.`runclusters`;
CREATE TABLE  `gdevvdi`.`runclusters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `description` varchar(255) DEFAULT NULL,
  `cluster_id` int(11) NOT NULL DEFAULT '0',
  `state` varchar(45) DEFAULT NULL,
  `user_id` int(11)
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

--
-- Definition of table `gdevvdi`.`locks`
--

DROP TABLE IF EXISTS `gdevvdi`.`locks`;
CREATE TABLE  `gdevvdi`.`locks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `cluster_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

--
-- Definition of table `gdevvdi`.`clusterlocks`
--

DROP TABLE IF EXISTS `gdevvdi`.`clusterlocks`;
CREATE TABLE  `gdevvdi`.`clusterlocks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `runcluster_id` int(11) NOT NULL DEFAULT '0',
  `job_id` int(11) NOT NULL DEFAULT '0',
  `lock_id` int(11) NOT NULL DEFAULT '0',
  `lock_status` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `gdevvdi`.`template_mappings`;
CREATE TABLE `template_mappings` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL DEFAULT '',
  `template_id` INT(11) NOT NULL DEFAULT '0',
  `is_deleted` INT(11) NOT NULL DEFAULT '0',
  `version` INT(11) NOT NULL DEFAULT '1',
  `usage` VARCHAR(255) NOT NULL DEFAULT 'other',
   PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `gdevvdi`.`ebsvolumes`;
CREATE TABLE `ebsvolumes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `job_id` int(11) DEFAULT NULL,
  `volume_id` varchar(15) DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  `snapshot_id` varchar(15) DEFAULT NULL,
  `instance_id` varchar(15) DEFAULT NULL,
  `attach_device` varchar(45) DEFAULT NULL,
  `availabilityZone` varchar(45) DEFAULT NULL,
  `status` varchar(15) DEFAULT NULL,
  `region` varchar(15) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted` int(11) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `gdevvdi`.`snapshots`;
CREATE TABLE `snapshots` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `snapshot_id` varchar(15) DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  `job_id` int(11) DEFAULT NULL,
  `volume_id` varchar(15) DEFAULT NULL,
  `status` varchar(15) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `region` varchar(15) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `deleted` int(11) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `gdevvdi`.`spot_quotas`;
CREATE TABLE `spot_quotas` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `instance_type` VARCHAR(45) NOT NULL DEFAULT '',
  `region` VARCHAR(45) NOT NULL DEFAULT '',
  `os` VARCHAR(45) NOT NULL DEFAULT '',
  `quota` int(11) DEFAULT 0,
   PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `gdevvdi`.`demos`;
CREATE TABLE `demos` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL DEFAULT '',
  `demo_product_id` INT(11) DEFAULT NULL,
  `configuration_id` INT(11) DEFAULT NULL,
   PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `gdevvdi`.`demo_products`;
CREATE TABLE `demo_products` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL DEFAULT '',
  `contact_mail` VARCHAR(255) NOT NULL DEFAULT '',
  `sale_mail` VARCHAR(255) NOT NULL DEFAULT '',
  `logo` MEDIUMBLOB,
  `mail_template` TEXT,
  `mail_subject` VARCHAR(255) NOT NULL DEFAULT '',
  `auth_key` VARCHAR(45),
   PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `gdevvdi`.`demo_jobs`;
CREATE TABLE `demo_jobs` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `job_id` INT(11) NOT NULL DEFAULT 0,
  `demo_id` INT(11) NOT NULL DEFAULT 0,
  `name` VARCHAR(255) NOT NULL DEFAULT '',
  `company` VARCHAR(255) NOT NULL DEFAULT '',
  `email` VARCHAR(255) NOT NULL DEFAULT '',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
   PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `gdevvdi`.`elasticips`;
CREATE TABLE `elasticips` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `job_id` INT(11),
  `name` VARCHAR(255) NOT NULL DEFAULT '',
  `ip` VARCHAR(255) NOT NULL DEFAULT '',
  `user_id` INT(11) NOT NULL DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `region` VARCHAR(45) NOT NULL DEFAULT '',
  `instance_id` VARCHAR(255),
  `scope` VARCHAR(255),
  `allocation_id` VARCHAR(255),
  `associate_id` VARCHAR(255),
  `deleted` int(11) DEFAULT 0,
   PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `gdevvdi`.`subnets`;
CREATE TABLE `subnets` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `subnet_id` VARCHAR(255) NOT NULL DEFAULT '',
  `vpc_id` VARCHAR(255) NOT NULL DEFAULT '',
  `region` VARCHAR(45) NOT NULL DEFAULT '',
  `deleted` int(11) DEFAULT 0,
  `name` VARCHAR(255) NOT NULL DEFAULT '',
   PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `gdevvdi`.`softwares`;
CREATE TABLE `softwares` (
	id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
	name VARCHAR(255),
	version VARCHAR(255),
	license_count INT,
	download_link VARCHAR(255),
	download_account VARCHAR(255),
	open_for_requst BOOLEAN,
	`password` VARCHAR(255),
	license_detail VARCHAR(255),
	is_free BOOLEAN
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `gdevvdi`.`license_requests`;
CREATE TABLE `license_requests`
(
	id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
	request_id INT,
	approval_id INT,
	software_id INT,
	count INT,
	last_edit_by INT, 
	status VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `gdevvdi`.`templates_softwares`;
CREATE TABLE `templates_softwares` (
	template_id INT  NOT NULL,
	software_id INT  NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `gdevvdi`.`active_ips`;
CREATE TABLE `active_ips` (
    `id` INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
	`ip` VARCHAR(45),
	`instance_id` VARCHAR(45),
	`scope` VARCHAR(45),
	`alloc` VARCHAR(45),
	`assoc` VARCHAR(45),
	`region` VARCHAR(45) NOT NULL DEFAULT '',
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `gdevvdi`.`sensitivemasks`;
CREATE TABLE `sensitivemasks` (
	`id` INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
	`name` VARCHAR(45),
	`sensitive_string` VARCHAR(255),
	`mask_string` VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `gdevvdi`.`cluster_params`;
CREATE TABLE `gdevvdi`.`cluster_params` (
  `id` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  `param_name` VARCHAR(255) NOT NULL,
  `runcluster_id` INTEGER UNSIGNED NOT NULL,
  `param_value` TEXT,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;