CREATE TABLE IF NOT EXISTS `player_prizes` (
  `player_identifier` varchar(50) NOT NULL DEFAULT '',
  `prize_name` int(11) NOT NULL,
  PRIMARY KEY (`player_identifier`,`prize_name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
