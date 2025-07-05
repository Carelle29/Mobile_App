-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 05, 2025 at 02:01 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `flutter_auth_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password` varchar(100) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password`, `is_active`) VALUES
(61, 'Louis', 'louismarcotoque@gmail.com', '$2y$10$LPS2SeJWQxvkgY6YWNYl4u7REKG2vra5f1lqLLzK6CwOg/7YlqVAS', 1),
(62, 'luis', 'luis@gmail.com', '$2y$10$v4P.DI89IN/Oae6ArZNBeOLOAw8ylj4.HMyhO/oNGhWHpTt1W7OU6', 1),
(63, 'Bunny', 'bunny@gmail.com', '$2y$10$JO8Ca9HmdGWwOlIPMcmh/O98Z3sl7.pBMpm3kaaYo.ZjTO56bJJuG', 1),
(64, 'marco', 'marco@gmail.com', '$2y$10$pKG7/L3TLNY3YAtz540W0ecCQ8.eCN8G7GGBeHYZpWSiCxTLN0xTG', 1),
(65, 'Red', 'Red@gmail.com', '$2y$10$WgHbQGnC5hkAP1pR6kpXze94Z43xLWE3zFe5Qb6tXSajC6fdSW9DO', 1),
(66, 'Tanggol', 'tanggolmontenegro@gmail.com', '$2y$10$P2Dr4OMDPTUUyJQ8ylyCQuCmzrVSYOw0dh4xS2H5SUc1D5P.Zo1XC', 1),
(67, 'kyrie', 'kyrie11@gmail.com', '$2y$10$S3PCnakZ/eOLOMEqMbkKoe5Rn6bUyLscMTN5XKqeQT8/Zr6RIBifS', 1),
(68, 'Violet', 'violet@gmail.com', '$2y$10$3kip.Utrn88.1f/Z2xsgj.WMW4WN3SB4ZTKcFGoQjVJwL2SZDFcLe', 1),
(69, 'Edward', 'edward23@gmail.com', '$2y$10$J79OUCwIuzp1WSUdAZPBROtBctXEv0XQ/q3TlGTYEyCXpAV2CVHW.', 1);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=70;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
