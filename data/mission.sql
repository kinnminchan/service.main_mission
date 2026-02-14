CREATE TABLE IF NOT EXISTS `mission` (
    `id` VARCHAR(64) NOT NULL,
    `mission` VARCHAR(64) NOT NULL,
    `level` INT NOT NULL DEFAULT 0,
    `exp` INT NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`, `mission`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;