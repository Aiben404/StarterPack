CREATE TABLE IF NOT EXISTS `starterpacks` (
    `identifier` varchar(60) NOT NULL,
    `claimed` tinyint(1) NOT NULL DEFAULT 1,
    `claimed_at` timestamp NOT NULL DEFAULT current_timestamp(),
    PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
