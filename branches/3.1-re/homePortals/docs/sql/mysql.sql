#
# SQL script to create Account table for HomePortals 
#

DROP TABLE IF EXISTS `cfe_user`;
CREATE TABLE `cfe_user` (
	`userID` varchar(35) NOT NULL default '',
	`username` varchar(20) NOT NULL default '' ,
	`password` varchar(50) NOT NULL default '' ,
	`firstName` varchar(100) NULL ,
	`middleName` varchar(100) NULL ,
	`lastName` varchar(100) NULL ,
	`email` varchar(100) NOT NULL ,
	`CreateDate` datetime NOT NULL default '0000-00-00 00:00:00',
	PRIMARY KEY (`userID`)
) ENGINE=InnoDB;
