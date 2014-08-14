CREATE TABLE `user`
(
    `user_id`       INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `username`      VARCHAR(255) DEFAULT NULL UNIQUE,
    `email`         VARCHAR(255) DEFAULT NULL UNIQUE,
    `display_name`  VARCHAR(50) DEFAULT NULL,
    `password`      VARCHAR(128) NOT NULL,
    `state`         SMALLINT UNSIGNED
) ENGINE=InnoDB CHARSET="utf8";

INSERT INTO `user` (`user_id`, `username`, `email`, `display_name`, `password`, `state`) VALUES
(1, NULL, 'test@test.com', NULL, '$2y$14$zG3OABCDjmDZ/bZ6f2fROeFPRzhJQ0PdLZn5fGDWjl1FlDF/JiNWS', NULL);
