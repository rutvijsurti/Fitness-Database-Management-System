-- ============================================
-- 1. SUBSCRIPTIONS (No dependencies)
-- ============================================

CREATE DATABASE fitness;
USE fitness;

CREATE TABLE Subscriptions (
    subscription_id INT PRIMARY KEY AUTO_INCREMENT,
    plan_name VARCHAR(100) NOT NULL,
    duration_months INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    features TEXT
);

-- ============================================
-- 2. TRAINERS (Initially without certification_id FK)
-- ============================================
CREATE TABLE Trainers (
    trainer_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    specialization VARCHAR(100),
    experience_years DECIMAL(4,1),
    certification_id INT NULL,
    rating DECIMAL(3,2) CHECK (rating >= 0 AND rating <= 5)
);

-- ============================================
-- 3. CERTIFICATIONS
-- ============================================
CREATE TABLE Certifications (
    certification_id INT PRIMARY KEY AUTO_INCREMENT,
    trainer_id INT NOT NULL,
    certification_name VARCHAR(100) NOT NULL,
    issued_by VARCHAR(100) NOT NULL,
    issue_date DATETIME NOT NULL,
    expiry_date DATETIME,
    FOREIGN KEY (trainer_id) REFERENCES Trainers(trainer_id) ON DELETE CASCADE
);

-- Now add the foreign key constraint to Trainers
ALTER TABLE Trainers 
ADD CONSTRAINT fk_trainers_certification 
FOREIGN KEY (certification_id) REFERENCES Certifications(certification_id) ON DELETE SET NULL;

-- ============================================
-- 4. USERS
-- ============================================
CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    gender VARCHAR(20),
    age INT,
    height DECIMAL(5,2),
    weight DECIMAL(5,2),
    goal VARCHAR(100),
    subscription_id INT NULL,
    trainer_id INT NULL,
    FOREIGN KEY (subscription_id) REFERENCES Subscriptions(subscription_id) ON DELETE SET NULL,
    FOREIGN KEY (trainer_id) REFERENCES Trainers(trainer_id) ON DELETE SET NULL
);

-- ============================================
-- 5. CLASSES
-- ============================================
CREATE TABLE Classes (
    class_id INT PRIMARY KEY AUTO_INCREMENT,
    trainer_id INT NOT NULL,
    class_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    mode VARCHAR(20),
    schedule_date DATETIME NOT NULL,
    duration_minutes INT NOT NULL,
    max_participants INT,
    FOREIGN KEY (trainer_id) REFERENCES Trainers(trainer_id) ON DELETE CASCADE
);

-- ============================================
-- 6. USER_CLASS (Junction Table)
-- ============================================
CREATE TABLE User_Class (
    user_id INT NOT NULL,
    class_id INT NOT NULL,
    enrollment_date DATETIME NOT NULL,
    attendance_status VARCHAR(20),
    PRIMARY KEY (user_id, class_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (class_id) REFERENCES Classes(class_id) ON DELETE CASCADE
);

-- ============================================
-- 7. PAYMENTS
-- ============================================
CREATE TABLE Payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    subscription_id INT NULL,
    payment_date DATETIME NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (subscription_id) REFERENCES Subscriptions(subscription_id) ON DELETE SET NULL
);

-- ============================================
-- 8. PROGRESS_TRACKING
-- ============================================
CREATE TABLE Progress_Tracking (
    progress_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    date DATETIME NOT NULL,
    calories_burned INT,
    steps INT,
    workout_time_min INT,
    weight DECIMAL(5,2),
    bmi DECIMAL(4,2),
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- ============================================
-- 9. GOALS
-- ============================================
CREATE TABLE Goals (
    goal_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    goal_type VARCHAR(50) NOT NULL,
    target_weight DECIMAL(5,2),
    start_date DATETIME NOT NULL,
    end_date DATETIME,
    status VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- ============================================
-- 10. WORKOUT_PLAN
-- ============================================
CREATE TABLE Workout_Plan (
    plan_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    trainer_id INT NULL,
    goal_id INT NULL,
    plan_name VARCHAR(100) NOT NULL,
    plan_description TEXT,
    start_date DATETIME NOT NULL,
    end_date DATETIME,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (trainer_id) REFERENCES Trainers(trainer_id) ON DELETE SET NULL,
    FOREIGN KEY (goal_id) REFERENCES Goals(goal_id) ON DELETE SET NULL
);

-- ============================================
-- 11. EXERCISES
-- ============================================
CREATE TABLE Exercises (
    exercise_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL,
    difficulty_level VARCHAR(20),
    calories_per_hour INT,
    muscle_group VARCHAR(50)
);

-- ============================================
-- 12. WORKOUT_EXERCISES (Junction Table)
-- ============================================
CREATE TABLE Workout_Exercises (
    plan_id INT NOT NULL,
    exercise_id INT NOT NULL,
    sets INT,
    reps INT,
    duration_min INT,
    PRIMARY KEY (plan_id, exercise_id),
    FOREIGN KEY (plan_id) REFERENCES Workout_Plan(plan_id) ON DELETE CASCADE,
    FOREIGN KEY (exercise_id) REFERENCES Exercises(exercise_id) ON DELETE CASCADE
);

-- ============================================
-- 13. FEEDBACK
-- ============================================
CREATE TABLE Feedback (
    feedback_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    trainer_id INT NULL,
    class_id INT NULL,
    rating DECIMAL(3,2) CHECK (rating >= 0 AND rating <= 5),
    comments TEXT,
    date DATETIME NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (trainer_id) REFERENCES Trainers(trainer_id) ON DELETE SET NULL,
    FOREIGN KEY (class_id) REFERENCES Classes(class_id) ON DELETE SET NULL
);

-- ============================================
-- 14. DEVICES
-- ============================================
CREATE TABLE Devices (
    device_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    device_name VARCHAR(100) NOT NULL,
    model VARCHAR(100),
    sync_date DATETIME,
    battery_level INT,
    firmware_version VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);


-- ################################################################### 

-- ============================================
-- FITNESS MANAGEMENT SYSTEM - DML (MySQL)
-- Generated Insert Statements
-- 30 Records per table
-- ============================================

SET FOREIGN_KEY_CHECKS = 0;

-- ============================================
-- SUBSCRIPTIONS DATA (30 records)
-- ============================================
INSERT INTO Subscriptions (plan_name, duration_months, price, features) VALUES ('Basic Monthly', 1, 29.99, 'Access to gym, Basic tracking');
INSERT INTO Subscriptions (plan_name, duration_months, price, features) VALUES ('Basic Quarterly', 3, 79.99, 'Access to gym, Basic tracking, 10% discount');
INSERT INTO Subscriptions (plan_name, duration_months, price, features) VALUES ('Basic Annual', 12, 299.99, 'Access to gym, Basic tracking, 20% discount');
INSERT INTO Subscriptions (plan_name, duration_months, price, features) VALUES ('Premium Monthly', 1, 49.99, 'Gym access, Personal trainer, Advanced tracking');
INSERT INTO Subscriptions (plan_name, duration_months, price, features) VALUES ('Premium Quarterly', 3, 134.99, 'Gym access, Personal trainer, Advanced tracking, 10% discount');
INSERT INTO Subscriptions (plan_name, duration_months, price, features) VALUES ('Premium Annual', 12, 499.99, 'Gym access, Personal trainer, Advanced tracking, 20% discount');
INSERT INTO Subscriptions (plan_name, duration_months, price, features) VALUES ('Elite Monthly', 1, 99.99, 'All features, Unlimited classes, Nutrition plans');
INSERT INTO Subscriptions (plan_name, duration_months, price, features) VALUES ('Elite Quarterly', 3, 269.99, 'All features, Unlimited classes, Nutrition plans, 10% discount');
INSERT INTO Subscriptions (plan_name, duration_months, price, features) VALUES ('Elite Annual', 12, 999.99, 'All features, Unlimited classes, Nutrition plans, 20% discount');
INSERT INTO Subscriptions (plan_name, duration_months, price, features) VALUES ('Student Monthly', 1, 19.99, 'Basic access for students');
INSERT INTO Subscriptions (plan_name, duration_months, price, features) VALUES ('Custom Plan 11', 6, 136.76, 'Custom features package 11');
INSERT INTO Subscriptions (plan_name, duration_months, price, features) VALUES ('Custom Plan 12', 1, 40.84, 'Custom features package 12');
INSERT INTO Subscriptions (plan_name, duration_months, price, features) VALUES ('Custom Plan 13', 6, 106.88, 'Custom features package 13');
INSERT INTO Subscriptions (plan_name, duration_months, price, features) VALUES ('Custom Plan 14', 12, 138.54, 'Custom features package 14');
INSERT INTO Subscriptions (plan_name, duration_months, price, features) VALUES ('Custom Plan 15', 3, 85.53, 'Custom features package 15');
INSERT INTO Subscriptions (plan_name, duration_months, price, features) VALUES ('Custom Plan 16', 1, 146.44, 'Custom features package 16');
INSERT INTO Subscriptions (plan_name, duration_months, price, features) VALUES ('Custom Plan 17', 3, 131.08, 'Custom features package 17');
INSERT INTO Subscriptions (plan_name, duration_months, price, features) VALUES ('Custom Plan 18', 12, 98.43, 'Custom features package 18');
INSERT INTO Subscriptions (plan_name, duration_months, price, features) VALUES ('Custom Plan 19', 12, 117.31, 'Custom features package 19');
INSERT INTO Subscriptions (plan_name, duration_months, price, features) VALUES ('Custom Plan 20', 1, 67.24, 'Custom features package 20');
INSERT INTO Subscriptions (plan_name, duration_months, price, features) VALUES ('Custom Plan 21', 3, 93.46, 'Custom features package 21');
INSERT INTO Subscriptions (plan_name, duration_months, price, features) VALUES ('Custom Plan 22', 12, 79.07, 'Custom features package 22');
INSERT INTO Subscriptions (plan_name, duration_months, price, features) VALUES ('Custom Plan 23', 3, 92.59, 'Custom features package 23');
INSERT INTO Subscriptions (plan_name, duration_months, price, features) VALUES ('Custom Plan 24', 6, 25.2, 'Custom features package 24');
INSERT INTO Subscriptions (plan_name, duration_months, price, features) VALUES ('Custom Plan 25', 12, 36.27, 'Custom features package 25');
INSERT INTO Subscriptions (plan_name, duration_months, price, features) VALUES ('Custom Plan 26', 3, 27.42, 'Custom features package 26');
INSERT INTO Subscriptions (plan_name, duration_months, price, features) VALUES ('Custom Plan 27', 1, 58.99, 'Custom features package 27');
INSERT INTO Subscriptions (plan_name, duration_months, price, features) VALUES ('Custom Plan 28', 3, 124.64, 'Custom features package 28');
INSERT INTO Subscriptions (plan_name, duration_months, price, features) VALUES ('Custom Plan 29', 3, 106.35, 'Custom features package 29');
INSERT INTO Subscriptions (plan_name, duration_months, price, features) VALUES ('Custom Plan 30', 1, 124.15, 'Custom features package 30');

-- ============================================
-- TRAINERS DATA (30 records)
-- ============================================
INSERT INTO Trainers (full_name, email, password, specialization, experience_years, rating) VALUES ('Mike Johnson', 'mike.johnson@trainers.fit', '$2y$10$Kujkpt9lXEcWo8WoOBG2FvFQeoMsd4AOdCK5ZlYtgz1AceJWxZ', 'Functional Training', 16.0, 4.76);
INSERT INTO Trainers (full_name, email, password, specialization, experience_years, rating) VALUES ('Sarah Williams', 'sarah.williams@trainers.fit', '$2y$10$ThGSF7llFATqdcs0c6Rpzc6ZOhhHaY3b3tz9uCZj9q2VLMYfPZ', 'CrossFit', 19.1, 3.99);
INSERT INTO Trainers (full_name, email, password, specialization, experience_years, rating) VALUES ('David Brown', 'david.brown@trainers.fit', '$2y$10$utMWLnOO9y7VM1qVfDKcAUFvnd6ERMdwe2FoaFNyjhphyfSOrY', 'Functional Training', 16.4, 4.31);
INSERT INTO Trainers (full_name, email, password, specialization, experience_years, rating) VALUES ('Emma Davis', 'emma.davis@trainers.fit', '$2y$10$nL1qwllBxeELF1lK4wPPtK8mRYcO4rloTCmCdJGjQYoD95HUGt', 'Pilates', 10.4, 3.58);
INSERT INTO Trainers (full_name, email, password, specialization, experience_years, rating) VALUES ('James Miller', 'james.miller@trainers.fit', '$2y$10$JTO4az47wGYlW26RyJS0DpJLoL2LN9SMY8Q7qK3Gn07IlShGSI', 'Strength Training', 9.1, 4.47);
INSERT INTO Trainers (full_name, email, password, specialization, experience_years, rating) VALUES ('Olivia Wilson', 'olivia.wilson@trainers.fit', '$2y$10$qZCe9Z3qDBzz6bWIm43vz1TZcx0QgtbIuuap6eghyM3KDeQXGk', 'Weight Loss', 4.6, 4.39);
INSERT INTO Trainers (full_name, email, password, specialization, experience_years, rating) VALUES ('Robert Moore', 'robert.moore@trainers.fit', '$2y$10$QvRofxbjVrPSfS4ejBefjEbg7ksOxbTrpYhKaUdk5cV5347bcX', 'Yoga', 4.2, 3.93);
INSERT INTO Trainers (full_name, email, password, specialization, experience_years, rating) VALUES ('Sophia Taylor', 'sophia.taylor@trainers.fit', '$2y$10$qP6lJMIJM7NEY9nJWXtGhUuKtYkW164qRzuIocGjivtA4qdYMC', 'HIIT', 12.8, 4.02);
INSERT INTO Trainers (full_name, email, password, specialization, experience_years, rating) VALUES ('Michael Anderson', 'michael.anderson@trainers.fit', '$2y$10$W4w8SzpYTHOnYo9Ki43kG8hsh2SnGsSSstiU7jG1TsTZ06tqKD', 'HIIT', 8.4, 4.02);
INSERT INTO Trainers (full_name, email, password, specialization, experience_years, rating) VALUES ('Isabella Thomas', 'isabella.thomas@trainers.fit', '$2y$10$J4Lq8x2k3K8SvsgM45hvuABqfyqjJ70UcxmLVYOmSDpUfAOuVj', 'Strength Training', 19.0, 4.43);
INSERT INTO Trainers (full_name, email, password, specialization, experience_years, rating) VALUES ('William Jackson', 'william.jackson@trainers.fit', '$2y$10$l4GwrJ9THotJDbrPtWR2Q9icL36G4sjC1PyTCHSDHUTK8E12v1', 'Pilates', 12.9, 3.55);
INSERT INTO Trainers (full_name, email, password, specialization, experience_years, rating) VALUES ('Mia White', 'mia.white@trainers.fit', '$2y$10$ZeUMgEzA8jIhaO0aCvjL2GROPGkARTp4ZcnCJa2seggYTf2bqt', 'Weight Loss', 10.9, 4.24);
INSERT INTO Trainers (full_name, email, password, specialization, experience_years, rating) VALUES ('Daniel Harris', 'daniel.harris@trainers.fit', '$2y$10$UB1MyuOxTbzPiJ1eiAvEL7HCShEx6IXwWZASyV9OUgjSBQZFem', 'HIIT', 16.8, 4.47);
INSERT INTO Trainers (full_name, email, password, specialization, experience_years, rating) VALUES ('Charlotte Martin', 'charlotte.martin@trainers.fit', '$2y$10$RGhqf6Q3ovUQAhhOtFE8oICxlrUq2e6j6dYXxSTfocGE0ttWbE', 'Weight Loss', 15.2, 4.98);
INSERT INTO Trainers (full_name, email, password, specialization, experience_years, rating) VALUES ('Matthew Thompson', 'matthew.thompson@trainers.fit', '$2y$10$t7qVAflGZCuOWog7Kt4Im0r3ky0RvKTID4UV53HG8MaaZ5k1Uo', 'Functional Training', 18.9, 4.0);
INSERT INTO Trainers (full_name, email, password, specialization, experience_years, rating) VALUES ('Amelia Garcia', 'amelia.garcia@trainers.fit', '$2y$10$US6u7tM3JUTuz1IdDccdAbCZFbrjjTTZb6vep8AOfZFJ1q3BSO', 'HIIT', 11.3, 3.9);
INSERT INTO Trainers (full_name, email, password, specialization, experience_years, rating) VALUES ('Joseph Martinez', 'joseph.martinez@trainers.fit', '$2y$10$faIEjaddS2IWTS1UwbUdiKVqokwRt6ABwTyShzq35KPNJRYjjf', 'Cardio', 18.0, 4.38);
INSERT INTO Trainers (full_name, email, password, specialization, experience_years, rating) VALUES ('Harper Robinson', 'harper.robinson@trainers.fit', '$2y$10$qSjgah6nHSfYqju7dwDSlHHn8mELAE1WLXj4G6jcozXEGKBeUq', 'CrossFit', 18.6, 4.88);
INSERT INTO Trainers (full_name, email, password, specialization, experience_years, rating) VALUES ('Christopher Clark', 'christopher.clark@trainers.fit', '$2y$10$i1mJoaXvg9fU4NekMyyptCLZ5WVo5wF6xUXnO7ECmKVtpO2OzM', 'HIIT', 13.5, 4.43);
INSERT INTO Trainers (full_name, email, password, specialization, experience_years, rating) VALUES ('Evelyn Rodriguez', 'evelyn.rodriguez@trainers.fit', '$2y$10$dm1Uf56VP5uWnjYCwpwThmDbroZpuXk1y6nqvL4iw1cCUbemI1', 'Yoga', 5.6, 4.5);
INSERT INTO Trainers (full_name, email, password, specialization, experience_years, rating) VALUES ('Andrew Lewis', 'andrew.lewis@trainers.fit', '$2y$10$jyOVwm64iRMhr3trFBXtQIA7DQbSmDeatYaq4Bwv3GRNSnfhtq', 'Functional Training', 3.4, 4.22);
INSERT INTO Trainers (full_name, email, password, specialization, experience_years, rating) VALUES ('Abigail Lee', 'abigail.lee@trainers.fit', '$2y$10$9lKgEz25PYpW7RHQ7co6KZxrGSTZmXB8trI6oqrGJQe4XMAZ5S', 'CrossFit', 6.3, 3.63);
INSERT INTO Trainers (full_name, email, password, specialization, experience_years, rating) VALUES ('Joshua Walker', 'joshua.walker@trainers.fit', '$2y$10$CcOkqO8BJo5qR2zmnQoXIqpKXCyd6MD0ScPgwssn8f8EVITtDB', 'Functional Training', 16.8, 4.4);
INSERT INTO Trainers (full_name, email, password, specialization, experience_years, rating) VALUES ('Emily Hall', 'emily.hall@trainers.fit', '$2y$10$xznFcLWt0bEhfeazW1XKFnWRlERsYxmUpGMNwAn5LRp2ID6xNF', 'HIIT', 2.5, 4.75);
INSERT INTO Trainers (full_name, email, password, specialization, experience_years, rating) VALUES ('Ryan Allen', 'ryan.allen@trainers.fit', '$2y$10$YvycczFxsjV8CYoEiCgmfPANGaQg70NFVjSIAWnDotc23h7yjj', 'Cardio', 6.6, 3.59);
INSERT INTO Trainers (full_name, email, password, specialization, experience_years, rating) VALUES ('Elizabeth Young', 'elizabeth.young@trainers.fit', '$2y$10$QAzq9lEKrgxj2H6mWRwlsMpFvTyup5iOKqgEKeGatpjQ85KeZ1', 'Cardio', 6.9, 3.79);
INSERT INTO Trainers (full_name, email, password, specialization, experience_years, rating) VALUES ('Nicholas Hernandez', 'nicholas.hernandez@trainers.fit', '$2y$10$azW4acF62NGOE971u9ic2magnYy9lUgabJV9jHupma6bRzBDb6', 'HIIT', 19.1, 3.63);
INSERT INTO Trainers (full_name, email, password, specialization, experience_years, rating) VALUES ('Sofia King', 'sofia.king@trainers.fit', '$2y$10$mGE5PswzLxaRrghjKTfh60gGtwwFrOET1ITFscInEkijwuEm7T', 'HIIT', 9.4, 3.54);
INSERT INTO Trainers (full_name, email, password, specialization, experience_years, rating) VALUES ('Alexander Wright', 'alexander.wright@trainers.fit', '$2y$10$GeTei2hJfJ6b2b7ccmPQnAJFh4dQGqTdsfoFhyMzsCfuC8NPZO', 'Boxing', 13.4, 3.83);
INSERT INTO Trainers (full_name, email, password, specialization, experience_years, rating) VALUES ('Avery Lopez', 'avery.lopez@trainers.fit', '$2y$10$jsPpz8ktvrEELBYTF4AsKy1HmQmlGFIlVjzC2b0Z8PaTdfO6W5', 'Weight Loss', 17.3, 4.66);

-- ============================================
-- CERTIFICATIONS DATA (30 records)
-- ============================================
INSERT INTO Certifications (trainer_id, certification_name, issued_by, issue_date, expiry_date) VALUES (1, 'Nutrition Specialist', 'ACE', '2022-05-04 00:00:00', '2025-05-03 00:00:00');
INSERT INTO Certifications (trainer_id, certification_name, issued_by, issue_date, expiry_date) VALUES (2, 'CrossFit Level 1', 'NCSF', '2022-11-18 00:00:00', '2025-11-17 00:00:00');
INSERT INTO Certifications (trainer_id, certification_name, issued_by, issue_date, expiry_date) VALUES (3, 'ACE Personal Trainer', 'NCSF', '2022-04-03 00:00:00', '2025-04-02 00:00:00');
INSERT INTO Certifications (trainer_id, certification_name, issued_by, issue_date, expiry_date) VALUES (4, 'Sports Nutrition Certificate', 'ISSA', '2021-04-14 00:00:00', '2024-04-13 00:00:00');
INSERT INTO Certifications (trainer_id, certification_name, issued_by, issue_date, expiry_date) VALUES (5, 'Sports Nutrition Certificate', 'Yoga Alliance', '2021-05-09 00:00:00', '2024-05-08 00:00:00');
INSERT INTO Certifications (trainer_id, certification_name, issued_by, issue_date, expiry_date) VALUES (6, 'Certified Personal Trainer', 'NSCA', '2022-06-18 00:00:00', '2025-06-17 00:00:00');
INSERT INTO Certifications (trainer_id, certification_name, issued_by, issue_date, expiry_date) VALUES (7, 'CrossFit Level 1', 'Cooper Institute', '2021-07-05 00:00:00', '2024-07-04 00:00:00');
INSERT INTO Certifications (trainer_id, certification_name, issued_by, issue_date, expiry_date) VALUES (8, 'ACE Personal Trainer', 'Cooper Institute', '2023-04-23 00:00:00', '2026-04-22 00:00:00');
INSERT INTO Certifications (trainer_id, certification_name, issued_by, issue_date, expiry_date) VALUES (9, 'ACE Personal Trainer', 'CrossFit Inc', '2023-09-01 00:00:00', '2026-08-31 00:00:00');
INSERT INTO Certifications (trainer_id, certification_name, issued_by, issue_date, expiry_date) VALUES (10, 'Nutrition Specialist', 'NASM', '2022-03-17 00:00:00', '2025-03-16 00:00:00');
INSERT INTO Certifications (trainer_id, certification_name, issued_by, issue_date, expiry_date) VALUES (11, 'Nutrition Specialist', 'NCSF', '2022-05-24 00:00:00', '2025-05-23 00:00:00');
INSERT INTO Certifications (trainer_id, certification_name, issued_by, issue_date, expiry_date) VALUES (12, 'Pilates Instructor', 'NCSF', '2021-06-12 00:00:00', '2024-06-11 00:00:00');
INSERT INTO Certifications (trainer_id, certification_name, issued_by, issue_date, expiry_date) VALUES (13, 'Sports Nutrition Certificate', 'ACE', '2022-05-15 00:00:00', '2025-05-14 00:00:00');
INSERT INTO Certifications (trainer_id, certification_name, issued_by, issue_date, expiry_date) VALUES (14, 'Yoga Instructor Certification', 'ISSA', '2024-04-29 00:00:00', '2027-04-29 00:00:00');
INSERT INTO Certifications (trainer_id, certification_name, issued_by, issue_date, expiry_date) VALUES (15, 'NASM CPT', 'NASM', '2021-05-17 00:00:00', '2024-05-16 00:00:00');
INSERT INTO Certifications (trainer_id, certification_name, issued_by, issue_date, expiry_date) VALUES (16, 'ACE Personal Trainer', 'AFAA', '2024-02-22 00:00:00', '2027-02-21 00:00:00');
INSERT INTO Certifications (trainer_id, certification_name, issued_by, issue_date, expiry_date) VALUES (17, 'Pilates Instructor', 'NCSF', '2021-01-13 00:00:00', '2024-01-13 00:00:00');
INSERT INTO Certifications (trainer_id, certification_name, issued_by, issue_date, expiry_date) VALUES (18, 'Pilates Instructor', 'Yoga Alliance', '2024-08-27 00:00:00', '2027-08-27 00:00:00');
INSERT INTO Certifications (trainer_id, certification_name, issued_by, issue_date, expiry_date) VALUES (19, 'CrossFit Level 1', 'Yoga Alliance', '2024-12-16 00:00:00', '2027-12-16 00:00:00');
INSERT INTO Certifications (trainer_id, certification_name, issued_by, issue_date, expiry_date) VALUES (20, 'NASM CPT', 'ACE', '2023-04-27 00:00:00', '2026-04-26 00:00:00');
INSERT INTO Certifications (trainer_id, certification_name, issued_by, issue_date, expiry_date) VALUES (21, 'Nutrition Specialist', 'ACSM', '2020-12-18 00:00:00', '2023-12-18 00:00:00');
INSERT INTO Certifications (trainer_id, certification_name, issued_by, issue_date, expiry_date) VALUES (22, 'Certified Strength Coach', 'ISSA', '2021-09-17 00:00:00', '2024-09-16 00:00:00');
INSERT INTO Certifications (trainer_id, certification_name, issued_by, issue_date, expiry_date) VALUES (23, 'ACE Personal Trainer', 'Cooper Institute', '2022-07-20 00:00:00', '2025-07-19 00:00:00');
INSERT INTO Certifications (trainer_id, certification_name, issued_by, issue_date, expiry_date) VALUES (24, 'Pilates Instructor', 'NSCA', '2022-08-04 00:00:00', '2025-08-03 00:00:00');
INSERT INTO Certifications (trainer_id, certification_name, issued_by, issue_date, expiry_date) VALUES (25, 'Yoga Instructor Certification', 'NASM', '2023-12-19 00:00:00', '2026-12-18 00:00:00');
INSERT INTO Certifications (trainer_id, certification_name, issued_by, issue_date, expiry_date) VALUES (26, 'ACE Personal Trainer', 'Cooper Institute', '2022-11-22 00:00:00', '2025-11-21 00:00:00');
INSERT INTO Certifications (trainer_id, certification_name, issued_by, issue_date, expiry_date) VALUES (27, 'CrossFit Level 1', 'AFAA', '2020-05-21 00:00:00', '2023-05-21 00:00:00');
INSERT INTO Certifications (trainer_id, certification_name, issued_by, issue_date, expiry_date) VALUES (28, 'ISSA Fitness Trainer', 'CrossFit Inc', '2024-02-27 00:00:00', '2027-02-26 00:00:00');
INSERT INTO Certifications (trainer_id, certification_name, issued_by, issue_date, expiry_date) VALUES (29, 'Pilates Instructor', 'Cooper Institute', '2024-05-05 00:00:00', '2027-05-05 00:00:00');
INSERT INTO Certifications (trainer_id, certification_name, issued_by, issue_date, expiry_date) VALUES (30, 'Certified Personal Trainer', 'NASM', '2022-11-23 00:00:00', '2025-11-22 00:00:00');

-- ============================================
-- UPDATE TRAINERS with certification_id
-- ============================================
UPDATE Trainers SET certification_id = 1 WHERE trainer_id = 1;
UPDATE Trainers SET certification_id = 2 WHERE trainer_id = 2;
UPDATE Trainers SET certification_id = 3 WHERE trainer_id = 3;
UPDATE Trainers SET certification_id = 4 WHERE trainer_id = 4;
UPDATE Trainers SET certification_id = 5 WHERE trainer_id = 5;
UPDATE Trainers SET certification_id = 6 WHERE trainer_id = 6;
UPDATE Trainers SET certification_id = 8 WHERE trainer_id = 8;
UPDATE Trainers SET certification_id = 9 WHERE trainer_id = 9;
UPDATE Trainers SET certification_id = 10 WHERE trainer_id = 10;
UPDATE Trainers SET certification_id = 12 WHERE trainer_id = 12;
UPDATE Trainers SET certification_id = 13 WHERE trainer_id = 13;
UPDATE Trainers SET certification_id = 14 WHERE trainer_id = 14;
UPDATE Trainers SET certification_id = 15 WHERE trainer_id = 15;
UPDATE Trainers SET certification_id = 16 WHERE trainer_id = 16;
UPDATE Trainers SET certification_id = 17 WHERE trainer_id = 17;
UPDATE Trainers SET certification_id = 18 WHERE trainer_id = 18;
UPDATE Trainers SET certification_id = 20 WHERE trainer_id = 20;
UPDATE Trainers SET certification_id = 21 WHERE trainer_id = 21;
UPDATE Trainers SET certification_id = 22 WHERE trainer_id = 22;
UPDATE Trainers SET certification_id = 23 WHERE trainer_id = 23;
UPDATE Trainers SET certification_id = 24 WHERE trainer_id = 24;
UPDATE Trainers SET certification_id = 28 WHERE trainer_id = 28;
UPDATE Trainers SET certification_id = 29 WHERE trainer_id = 29;
UPDATE Trainers SET certification_id = 30 WHERE trainer_id = 30;

-- ============================================
-- USERS DATA (30 records)
-- ============================================
INSERT INTO Users (full_name, email, password, gender, age, height, weight, goal, subscription_id, trainer_id) VALUES ('John Smith', 'john.smith@users.fit', '$2y$10$lchZqdZZfUmA2VFIUOJOK4fMjnHU9PYZPdYefWAPLrwuAIrz47', 'Male', 23, 183.87, 54.11, 'Flexibility', NULL, 7);
INSERT INTO Users (full_name, email, password, gender, age, height, weight, goal, subscription_id, trainer_id) VALUES ('Alice Johnson', 'alice.johnson@users.fit', '$2y$10$rSZr4305WDhiNP739pFmJ7QYToIZIPcgM591ptVJxkuWmrEoin', 'Female', 22, 158.15, 67.05, 'General Fitness', 30, 27);
INSERT INTO Users (full_name, email, password, gender, age, height, weight, goal, subscription_id, trainer_id) VALUES ('Bob Williams', 'bob.williams@users.fit', '$2y$10$NmSo651ielWeEA8o5xpH6CxXiq7NOU4cc8FyG7wlUUIDUXPQ30', 'Non-binary', 32, 180.44, 110.98, 'Flexibility', 17, NULL);
INSERT INTO Users (full_name, email, password, gender, age, height, weight, goal, subscription_id, trainer_id) VALUES ('Carol Brown', 'carol.brown@users.fit', '$2y$10$4Xo94nYXgYpmHOGQLhbWOkYmxvd0pWEXsYNdgH9ICgE0V1pcKz', 'Non-binary', 60, 175.98, 90.15, 'Weight Loss', NULL, 29);
INSERT INTO Users (full_name, email, password, gender, age, height, weight, goal, subscription_id, trainer_id) VALUES ('David Jones', 'david.jones@users.fit', '$2y$10$qIVbZ6bZO4Dpq8ymCSHknicQxMD5ZuwPtpTstjYdiFZn2mEQb1', 'Female', 54, 195.12, 56.81, 'General Fitness', 22, 29);
INSERT INTO Users (full_name, email, password, gender, age, height, weight, goal, subscription_id, trainer_id) VALUES ('Eve Garcia', 'eve.garcia@users.fit', '$2y$10$2oJadi8GDifhDPOz1yjCQT3pgsRam1iYWtVynINIyl3qAmyeEO', 'Female', 30, 194.98, 67.15, 'Endurance', 20, NULL);
INSERT INTO Users (full_name, email, password, gender, age, height, weight, goal, subscription_id, trainer_id) VALUES ('Frank Miller', 'frank.miller@users.fit', '$2y$10$uRiVmdU4eCWkPFwzenQFBf7GrY9lHx11A5BXZBMiefdJUTH6Zz', 'Non-binary', 20, 196.41, 113.3, 'Weight Loss', 19, NULL);
INSERT INTO Users (full_name, email, password, gender, age, height, weight, goal, subscription_id, trainer_id) VALUES ('Grace Davis', 'grace.davis@users.fit', '$2y$10$OoX4yggOS02MmCrEeQJEm0xTuWJTb4RfQhG58idpTvECBzcwq2', 'Male', 40, 182.1, 56.1, 'Muscle Gain', NULL, NULL);
INSERT INTO Users (full_name, email, password, gender, age, height, weight, goal, subscription_id, trainer_id) VALUES ('Henry Rodriguez', 'henry.rodriguez@users.fit', '$2y$10$VG7zQvFLiMNHQP5yjQAXEIwkgs9NBsCCLjiMnpyLImICKfzljy', 'Non-binary', 27, 179.6, 99.87, 'Flexibility', 28, 29);
INSERT INTO Users (full_name, email, password, gender, age, height, weight, goal, subscription_id, trainer_id) VALUES ('Ivy Martinez', 'ivy.martinez@users.fit', '$2y$10$kquOuTEIT0dTgEPMBTifaFaTDT6L8SO0OFvh668OjQRg7YUA1H', 'Prefer not to say', 49, 173.42, 109.51, 'General Fitness', NULL, 2);
INSERT INTO Users (full_name, email, password, gender, age, height, weight, goal, subscription_id, trainer_id) VALUES ('Jack Hernandez', 'jack.hernandez@users.fit', '$2y$10$nWq7RfpISGEs7H7GCFYbFgI8Ml9Kh0moAW4vcGRIJ1FC0P9714', 'Non-binary', 49, 176.33, 114.2, 'Endurance', NULL, NULL);
INSERT INTO Users (full_name, email, password, gender, age, height, weight, goal, subscription_id, trainer_id) VALUES ('Kelly Lopez', 'kelly.lopez@users.fit', '$2y$10$iYX3ewCfbpH6LOP28ZXdyPHBU1b1mAm15w9thIPRIF2uy1Lw8V', 'Prefer not to say', 31, 173.0, 114.0, 'Endurance', NULL, 17);
INSERT INTO Users (full_name, email, password, gender, age, height, weight, goal, subscription_id, trainer_id) VALUES ('Leo Gonzalez', 'leo.gonzalez@users.fit', '$2y$10$MR8K7iQI8O5aQx7jrJdIxN9vsrvAVxSTzbyMJHcyh4RZnBZqza', 'Non-binary', 34, 197.73, 118.42, 'Weight Loss', NULL, 23);
INSERT INTO Users (full_name, email, password, gender, age, height, weight, goal, subscription_id, trainer_id) VALUES ('Megan Wilson', 'megan.wilson@users.fit', '$2y$10$zNuIwSFqxnjnz2qi4CAm41korKIw6BAmzOcPVSe7R8l5XHohi6', 'Prefer not to say', 62, 158.11, 70.32, 'Muscle Gain', 24, NULL);
INSERT INTO Users (full_name, email, password, gender, age, height, weight, goal, subscription_id, trainer_id) VALUES ('Nathan Anderson', 'nathan.anderson@users.fit', '$2y$10$vdfLEtGmOUt6BLQ24jWNq2HTunBOw47Y60XQagV72LlkceBY8j', 'Prefer not to say', 30, 192.17, 102.79, 'Weight Loss', 4, 24);
INSERT INTO Users (full_name, email, password, gender, age, height, weight, goal, subscription_id, trainer_id) VALUES ('Olivia Thomas', 'olivia.thomas@users.fit', '$2y$10$NMbZFmnDhYk7cZxtINioDwFkDbUNMLhLdGFKBrtAk2gf2umq2P', 'Male', 56, 174.46, 110.45, 'Weight Loss', 15, NULL);
INSERT INTO Users (full_name, email, password, gender, age, height, weight, goal, subscription_id, trainer_id) VALUES ('Peter Taylor', 'peter.taylor@users.fit', '$2y$10$jgPQbVDRxgkQDlygiXZ2p4SNJ4PFqgIo9BgvfXdNYNLMoGv47H', 'Female', 40, 153.03, 61.32, 'Muscle Gain', 24, NULL);
INSERT INTO Users (full_name, email, password, gender, age, height, weight, goal, subscription_id, trainer_id) VALUES ('Quinn Moore', 'quinn.moore@users.fit', '$2y$10$4Rf5TIyDlcBbrsJtw0DIeA46qKZLOpqVCp9jaY6CDSaJKflvKH', 'Non-binary', 64, 161.35, 119.08, 'Muscle Gain', 15, NULL);
INSERT INTO Users (full_name, email, password, gender, age, height, weight, goal, subscription_id, trainer_id) VALUES ('Rachel Jackson', 'rachel.jackson@users.fit', '$2y$10$2V08Q9tvhNvHUQwiykbSosBo8YVJYt3FxNa0I9IFuKDKG20O5I', 'Non-binary', 26, 184.16, 52.14, 'General Fitness', 6, NULL);
INSERT INTO Users (full_name, email, password, gender, age, height, weight, goal, subscription_id, trainer_id) VALUES ('Steve Martin', 'steve.martin@users.fit', '$2y$10$F4bPwpezcYmVkWVtpYLwQa6uLOz7eT95piCOwww1cvksq6kje8', 'Female', 63, 160.1, 79.68, 'Flexibility', 7, 2);
INSERT INTO Users (full_name, email, password, gender, age, height, weight, goal, subscription_id, trainer_id) VALUES ('Tina Lee', 'tina.lee@users.fit', '$2y$10$vEiWiUBFBhAH2hCNCBURPS3aLRIpE8uPCL2adAwzokjJwgHCtK', 'Prefer not to say', 61, 155.82, 50.04, 'Weight Loss', 22, NULL);
INSERT INTO Users (full_name, email, password, gender, age, height, weight, goal, subscription_id, trainer_id) VALUES ('Uma Perez', 'uma.perez@users.fit', '$2y$10$6Ess4RcvkhTscaoBPc55tB1PTF9dtjvZ9RXj3FwOx6KE3XrESU', 'Female', 57, 170.06, 71.24, 'Flexibility', NULL, NULL);
INSERT INTO Users (full_name, email, password, gender, age, height, weight, goal, subscription_id, trainer_id) VALUES ('Victor Thompson', 'victor.thompson@users.fit', '$2y$10$oNpfAaEAf4yfMy6TTYK5RKuLLISCj7OhQGz0YSncV3OTb8ykaU', 'Prefer not to say', 34, 187.11, 84.23, 'Flexibility', 25, NULL);
INSERT INTO Users (full_name, email, password, gender, age, height, weight, goal, subscription_id, trainer_id) VALUES ('Wendy White', 'wendy.white@users.fit', '$2y$10$TnRZ10MnMyhzvwu2NIaRLLXiXAz9yIJS7scpJ7d5qDB2ZnBOwA', 'Prefer not to say', 19, 193.81, 115.34, 'Endurance', 19, 14);
INSERT INTO Users (full_name, email, password, gender, age, height, weight, goal, subscription_id, trainer_id) VALUES ('Xavier Harris', 'xavier.harris@users.fit', '$2y$10$sjXlk3zWc38HVTrqsXD0DvVjOfTaoxeQTpatXgvyBLSXzlL9XI', 'Female', 64, 198.16, 90.3, 'Flexibility', 4, NULL);
INSERT INTO Users (full_name, email, password, gender, age, height, weight, goal, subscription_id, trainer_id) VALUES ('Yara Sanchez', 'yara.sanchez@users.fit', '$2y$10$puUUTa0KJSVnAjmajgipcEKjZviT7Kp5tIBGPFa0IpDCdtjmMy', 'Non-binary', 47, 171.35, 100.11, 'Endurance', 14, NULL);
INSERT INTO Users (full_name, email, password, gender, age, height, weight, goal, subscription_id, trainer_id) VALUES ('Zack Clark', 'zack.clark@users.fit', '$2y$10$EbPUZZGU1grEXUOevic8GgEB79Q6LKXo88cUhNpYv7PzVVUkgg', 'Male', 62, 151.95, 87.3, 'Muscle Gain', 5, NULL);
INSERT INTO Users (full_name, email, password, gender, age, height, weight, goal, subscription_id, trainer_id) VALUES ('Amy Ramirez', 'amy.ramirez@users.fit', '$2y$10$YZyuhhqRwzKlxvrqceEJ3hH4W5rOSlDGR0wEbVm5apcH3u2Wkv', 'Non-binary', 25, 193.19, 56.64, 'Weight Loss', 27, 7);
INSERT INTO Users (full_name, email, password, gender, age, height, weight, goal, subscription_id, trainer_id) VALUES ('Brian Lewis', 'brian.lewis@users.fit', '$2y$10$xjYgymOp9V4qYoD96e0wPu8tr8OToJdPXqMByMOnOvUlDl2A99', 'Prefer not to say', 24, 163.36, 111.0, 'Muscle Gain', 24, NULL);
INSERT INTO Users (full_name, email, password, gender, age, height, weight, goal, subscription_id, trainer_id) VALUES ('Chloe Robinson', 'chloe.robinson@users.fit', '$2y$10$CQlhqTNb3lopeTvWJFzu6YkHq0LQtimaim4m53lvWslHpBKsBc', 'Female', 20, 154.17, 55.02, 'Weight Loss', NULL, NULL);

-- ============================================
-- CLASSES DATA (30 records)
-- ============================================
INSERT INTO Classes (trainer_id, class_name, category, mode, schedule_date, duration_minutes, max_participants) VALUES (29, 'HIIT Blast 1', 'Cardio', 'Virtual', '2025-11-15 00:00:00', 90, 11);
INSERT INTO Classes (trainer_id, class_name, category, mode, schedule_date, duration_minutes, max_participants) VALUES (20, 'HIIT Blast 2', 'Martial Arts', 'Virtual', '2025-07-08 00:00:00', 60, 45);
INSERT INTO Classes (trainer_id, class_name, category, mode, schedule_date, duration_minutes, max_participants) VALUES (15, 'Cardio Kickboxing 3', 'Cardio', 'In-Person', '2025-05-29 00:00:00', 45, 40);
INSERT INTO Classes (trainer_id, class_name, category, mode, schedule_date, duration_minutes, max_participants) VALUES (13, 'Power Yoga 4', 'Flexibility', 'Hybrid', '2025-08-26 00:00:00', 45, 28);
INSERT INTO Classes (trainer_id, class_name, category, mode, schedule_date, duration_minutes, max_participants) VALUES (13, 'Morning Yoga 5', 'Martial Arts', 'Hybrid', '2025-03-25 00:00:00', 30, 27);
INSERT INTO Classes (trainer_id, class_name, category, mode, schedule_date, duration_minutes, max_participants) VALUES (14, 'Morning Yoga 6', 'Dance', 'In-Person', '2025-12-01 00:00:00', 45, 28);
INSERT INTO Classes (trainer_id, class_name, category, mode, schedule_date, duration_minutes, max_participants) VALUES (26, 'Zumba Dance 7', 'Flexibility', 'Virtual', '2026-01-02 00:00:00', 45, 41);
INSERT INTO Classes (trainer_id, class_name, category, mode, schedule_date, duration_minutes, max_participants) VALUES (18, 'CrossFit WOD 8', 'Martial Arts', 'In-Person', '2025-02-17 00:00:00', 45, 32);
INSERT INTO Classes (trainer_id, class_name, category, mode, schedule_date, duration_minutes, max_participants) VALUES (6, 'Cardio Kickboxing 9', 'Dance', 'Hybrid', '2025-05-15 00:00:00', 30, 47);
INSERT INTO Classes (trainer_id, class_name, category, mode, schedule_date, duration_minutes, max_participants) VALUES (7, 'Morning Yoga 10', 'Strength', 'Virtual', '2026-01-03 00:00:00', 45, 30);
INSERT INTO Classes (trainer_id, class_name, category, mode, schedule_date, duration_minutes, max_participants) VALUES (23, 'Power Yoga 11', 'Cardio', 'In-Person', '2025-12-27 00:00:00', 60, 36);
INSERT INTO Classes (trainer_id, class_name, category, mode, schedule_date, duration_minutes, max_participants) VALUES (5, 'Spin Class 12', 'Martial Arts', 'Hybrid', '2025-10-13 00:00:00', 60, 48);
INSERT INTO Classes (trainer_id, class_name, category, mode, schedule_date, duration_minutes, max_participants) VALUES (17, 'Power Yoga 13', 'Martial Arts', 'Hybrid', '2026-02-17 00:00:00', 45, 39);
INSERT INTO Classes (trainer_id, class_name, category, mode, schedule_date, duration_minutes, max_participants) VALUES (2, 'Power Yoga 14', 'Cardio', 'Hybrid', '2026-01-16 00:00:00', 45, 29);
INSERT INTO Classes (trainer_id, class_name, category, mode, schedule_date, duration_minutes, max_participants) VALUES (9, 'Strength Training 15', 'Martial Arts', 'Hybrid', '2025-12-05 00:00:00', 45, 18);
INSERT INTO Classes (trainer_id, class_name, category, mode, schedule_date, duration_minutes, max_participants) VALUES (28, 'Power Yoga 16', 'Flexibility', 'In-Person', '2025-04-14 00:00:00', 30, 43);
INSERT INTO Classes (trainer_id, class_name, category, mode, schedule_date, duration_minutes, max_participants) VALUES (30, 'Boxing Bootcamp 17', 'Flexibility', 'Hybrid', '2025-07-23 00:00:00', 90, 40);
INSERT INTO Classes (trainer_id, class_name, category, mode, schedule_date, duration_minutes, max_participants) VALUES (16, 'Cardio Kickboxing 18', 'Strength', 'Virtual', '2025-03-22 00:00:00', 60, 22);
INSERT INTO Classes (trainer_id, class_name, category, mode, schedule_date, duration_minutes, max_participants) VALUES (2, 'Spin Class 19', 'Flexibility', 'Hybrid', '2026-03-09 00:00:00', 60, 39);
INSERT INTO Classes (trainer_id, class_name, category, mode, schedule_date, duration_minutes, max_participants) VALUES (5, 'Power Yoga 20', 'Flexibility', 'Hybrid', '2025-08-22 00:00:00', 60, 38);
INSERT INTO Classes (trainer_id, class_name, category, mode, schedule_date, duration_minutes, max_participants) VALUES (21, 'Cardio Kickboxing 21', 'Cardio', 'Hybrid', '2025-11-15 00:00:00', 45, 22);
INSERT INTO Classes (trainer_id, class_name, category, mode, schedule_date, duration_minutes, max_participants) VALUES (7, 'Cardio Kickboxing 22', 'Flexibility', 'In-Person', '2025-10-25 00:00:00', 90, 34);
INSERT INTO Classes (trainer_id, class_name, category, mode, schedule_date, duration_minutes, max_participants) VALUES (30, 'Spin Class 23', 'Cardio', 'In-Person', '2025-05-02 00:00:00', 45, 31);
INSERT INTO Classes (trainer_id, class_name, category, mode, schedule_date, duration_minutes, max_participants) VALUES (16, 'Spin Class 24', 'Martial Arts', 'In-Person', '2025-08-16 00:00:00', 90, 11);
INSERT INTO Classes (trainer_id, class_name, category, mode, schedule_date, duration_minutes, max_participants) VALUES (23, 'Zumba Dance 25', 'Strength', 'Virtual', '2025-12-15 00:00:00', 60, 38);
INSERT INTO Classes (trainer_id, class_name, category, mode, schedule_date, duration_minutes, max_participants) VALUES (29, 'Strength Training 26', 'Flexibility', 'Virtual', '2025-12-04 00:00:00', 90, 49);
INSERT INTO Classes (trainer_id, class_name, category, mode, schedule_date, duration_minutes, max_participants) VALUES (10, 'Cardio Kickboxing 27', 'Strength', 'Virtual', '2025-02-24 00:00:00', 60, 20);
INSERT INTO Classes (trainer_id, class_name, category, mode, schedule_date, duration_minutes, max_participants) VALUES (20, 'Boxing Bootcamp 28', 'Dance', 'In-Person', '2026-01-01 00:00:00', 90, 44);
INSERT INTO Classes (trainer_id, class_name, category, mode, schedule_date, duration_minutes, max_participants) VALUES (26, 'Spin Class 29', 'Dance', 'Hybrid', '2025-04-03 00:00:00', 45, 32);
INSERT INTO Classes (trainer_id, class_name, category, mode, schedule_date, duration_minutes, max_participants) VALUES (14, 'Pilates Core 30', 'Martial Arts', 'In-Person', '2025-05-25 00:00:00', 45, 45);

-- ============================================
-- USER_CLASS DATA (30 records)
-- ============================================
INSERT INTO User_Class (user_id, class_id, enrollment_date, attendance_status) VALUES (22, 26, '2025-05-21 00:00:00', 'Attended');
INSERT INTO User_Class (user_id, class_id, enrollment_date, attendance_status) VALUES (16, 11, '2025-03-11 00:00:00', 'Attended');
INSERT INTO User_Class (user_id, class_id, enrollment_date, attendance_status) VALUES (7, 2, '2024-11-01 00:00:00', 'Missed');
INSERT INTO User_Class (user_id, class_id, enrollment_date, attendance_status) VALUES (8, 1, '2024-11-18 00:00:00', 'Missed');
INSERT INTO User_Class (user_id, class_id, enrollment_date, attendance_status) VALUES (10, 13, '2025-08-24 00:00:00', 'Missed');
INSERT INTO User_Class (user_id, class_id, enrollment_date, attendance_status) VALUES (27, 18, '2025-05-03 00:00:00', 'Missed');
INSERT INTO User_Class (user_id, class_id, enrollment_date, attendance_status) VALUES (9, 17, '2025-04-20 00:00:00', 'Attended');
INSERT INTO User_Class (user_id, class_id, enrollment_date, attendance_status) VALUES (26, 10, '2025-09-30 00:00:00', 'Missed');
INSERT INTO User_Class (user_id, class_id, enrollment_date, attendance_status) VALUES (17, 11, '2025-11-25 00:00:00', 'Missed');
INSERT INTO User_Class (user_id, class_id, enrollment_date, attendance_status) VALUES (12, 2, '2024-12-03 00:00:00', 'Missed');
INSERT INTO User_Class (user_id, class_id, enrollment_date, attendance_status) VALUES (12, 16, '2024-03-06 00:00:00', 'Attended');
INSERT INTO User_Class (user_id, class_id, enrollment_date, attendance_status) VALUES (20, 20, '2024-08-13 00:00:00', 'Enrolled');
INSERT INTO User_Class (user_id, class_id, enrollment_date, attendance_status) VALUES (26, 6, '2025-03-01 00:00:00', 'Cancelled');
INSERT INTO User_Class (user_id, class_id, enrollment_date, attendance_status) VALUES (28, 7, '2024-01-01 00:00:00', 'Cancelled');
INSERT INTO User_Class (user_id, class_id, enrollment_date, attendance_status) VALUES (6, 15, '2024-05-21 00:00:00', 'Enrolled');
INSERT INTO User_Class (user_id, class_id, enrollment_date, attendance_status) VALUES (11, 2, '2024-07-05 00:00:00', 'Cancelled');
INSERT INTO User_Class (user_id, class_id, enrollment_date, attendance_status) VALUES (17, 16, '2024-05-13 00:00:00', 'Attended');
INSERT INTO User_Class (user_id, class_id, enrollment_date, attendance_status) VALUES (21, 20, '2025-12-05 00:00:00', 'Attended');
INSERT INTO User_Class (user_id, class_id, enrollment_date, attendance_status) VALUES (13, 6, '2024-03-07 00:00:00', 'Enrolled');
INSERT INTO User_Class (user_id, class_id, enrollment_date, attendance_status) VALUES (30, 11, '2025-08-14 00:00:00', 'Missed');
INSERT INTO User_Class (user_id, class_id, enrollment_date, attendance_status) VALUES (16, 28, '2025-11-29 00:00:00', 'Attended');
INSERT INTO User_Class (user_id, class_id, enrollment_date, attendance_status) VALUES (27, 3, '2025-02-21 00:00:00', 'Cancelled');
INSERT INTO User_Class (user_id, class_id, enrollment_date, attendance_status) VALUES (5, 13, '2025-08-10 00:00:00', 'Cancelled');
INSERT INTO User_Class (user_id, class_id, enrollment_date, attendance_status) VALUES (10, 9, '2025-03-06 00:00:00', 'Attended');
INSERT INTO User_Class (user_id, class_id, enrollment_date, attendance_status) VALUES (5, 25, '2025-03-25 00:00:00', 'Attended');
INSERT INTO User_Class (user_id, class_id, enrollment_date, attendance_status) VALUES (14, 5, '2025-08-23 00:00:00', 'Missed');
INSERT INTO User_Class (user_id, class_id, enrollment_date, attendance_status) VALUES (6, 14, '2025-04-18 00:00:00', 'Missed');
INSERT INTO User_Class (user_id, class_id, enrollment_date, attendance_status) VALUES (17, 8, '2024-06-10 00:00:00', 'Attended');
INSERT INTO User_Class (user_id, class_id, enrollment_date, attendance_status) VALUES (12, 5, '2025-12-25 00:00:00', 'Attended');
INSERT INTO User_Class (user_id, class_id, enrollment_date, attendance_status) VALUES (21, 11, '2025-12-20 00:00:00', 'Attended');

-- ============================================
-- PAYMENTS DATA (30 records)
-- ============================================
INSERT INTO Payments (user_id, subscription_id, payment_date, amount, payment_method, status) VALUES (1, 25, '2025-06-13 00:00:00', 137.03, 'PayPal', 'Failed');
INSERT INTO Payments (user_id, subscription_id, payment_date, amount, payment_method, status) VALUES (2, 1, '2025-01-27 00:00:00', 901.03, 'PayPal', 'Failed');
INSERT INTO Payments (user_id, subscription_id, payment_date, amount, payment_method, status) VALUES (3, 28, '2024-03-30 00:00:00', 613.74, 'Apple Pay', 'Refunded');
INSERT INTO Payments (user_id, subscription_id, payment_date, amount, payment_method, status) VALUES (4, 17, '2024-06-05 00:00:00', 962.78, 'Bank Transfer', 'Pending');
INSERT INTO Payments (user_id, subscription_id, payment_date, amount, payment_method, status) VALUES (5, 6, '2024-12-11 00:00:00', 71.66, 'PayPal', 'Completed');
INSERT INTO Payments (user_id, subscription_id, payment_date, amount, payment_method, status) VALUES (6, 10, '2025-07-06 00:00:00', 456.97, 'Bank Transfer', 'Pending');
INSERT INTO Payments (user_id, subscription_id, payment_date, amount, payment_method, status) VALUES (7, 28, '2025-07-11 00:00:00', 279.29, 'Debit Card', 'Completed');
INSERT INTO Payments (user_id, subscription_id, payment_date, amount, payment_method, status) VALUES (8, 18, '2025-11-04 00:00:00', 244.02, 'Google Pay', 'Failed');
INSERT INTO Payments (user_id, subscription_id, payment_date, amount, payment_method, status) VALUES (9, NULL, '2024-11-08 00:00:00', 522.99, 'Credit Card', 'Failed');
INSERT INTO Payments (user_id, subscription_id, payment_date, amount, payment_method, status) VALUES (10, 17, '2024-01-04 00:00:00', 912.19, 'Bank Transfer', 'Refunded');
INSERT INTO Payments (user_id, subscription_id, payment_date, amount, payment_method, status) VALUES (11, 16, '2025-09-27 00:00:00', 806.17, 'Bank Transfer', 'Completed');
INSERT INTO Payments (user_id, subscription_id, payment_date, amount, payment_method, status) VALUES (12, 30, '2025-03-15 00:00:00', 673.23, 'Google Pay', 'Pending');
INSERT INTO Payments (user_id, subscription_id, payment_date, amount, payment_method, status) VALUES (13, 14, '2024-01-10 00:00:00', 638.67, 'Debit Card', 'Completed');
INSERT INTO Payments (user_id, subscription_id, payment_date, amount, payment_method, status) VALUES (14, NULL, '2025-11-13 00:00:00', 205.18, 'Apple Pay', 'Failed');
INSERT INTO Payments (user_id, subscription_id, payment_date, amount, payment_method, status) VALUES (15, NULL, '2024-09-03 00:00:00', 192.7, 'Credit Card', 'Pending');
INSERT INTO Payments (user_id, subscription_id, payment_date, amount, payment_method, status) VALUES (16, 3, '2024-09-03 00:00:00', 36.36, 'Apple Pay', 'Completed');
INSERT INTO Payments (user_id, subscription_id, payment_date, amount, payment_method, status) VALUES (17, 1, '2024-03-27 00:00:00', 280.46, 'Debit Card', 'Pending');
INSERT INTO Payments (user_id, subscription_id, payment_date, amount, payment_method, status) VALUES (18, 27, '2024-07-11 00:00:00', 630.13, 'Google Pay', 'Refunded');
INSERT INTO Payments (user_id, subscription_id, payment_date, amount, payment_method, status) VALUES (19, 1, '2025-06-14 00:00:00', 360.79, 'Credit Card', 'Failed');
INSERT INTO Payments (user_id, subscription_id, payment_date, amount, payment_method, status) VALUES (20, 18, '2024-10-17 00:00:00', 195.53, 'PayPal', 'Refunded');
INSERT INTO Payments (user_id, subscription_id, payment_date, amount, payment_method, status) VALUES (21, 17, '2025-08-22 00:00:00', 884.72, 'PayPal', 'Completed');
INSERT INTO Payments (user_id, subscription_id, payment_date, amount, payment_method, status) VALUES (22, 23, '2025-08-12 00:00:00', 426.3, 'Google Pay', 'Completed');
INSERT INTO Payments (user_id, subscription_id, payment_date, amount, payment_method, status) VALUES (23, 29, '2024-02-28 00:00:00', 976.72, 'PayPal', 'Completed');
INSERT INTO Payments (user_id, subscription_id, payment_date, amount, payment_method, status) VALUES (24, 11, '2024-12-11 00:00:00', 628.43, 'Debit Card', 'Refunded');
INSERT INTO Payments (user_id, subscription_id, payment_date, amount, payment_method, status) VALUES (25, 20, '2025-06-24 00:00:00', 127.73, 'Bank Transfer', 'Pending');
INSERT INTO Payments (user_id, subscription_id, payment_date, amount, payment_method, status) VALUES (26, 7, '2024-12-15 00:00:00', 54.1, 'PayPal', 'Refunded');
INSERT INTO Payments (user_id, subscription_id, payment_date, amount, payment_method, status) VALUES (27, NULL, '2024-04-27 00:00:00', 408.07, 'Debit Card', 'Pending');
INSERT INTO Payments (user_id, subscription_id, payment_date, amount, payment_method, status) VALUES (28, 25, '2024-06-19 00:00:00', 993.89, 'Credit Card', 'Refunded');
INSERT INTO Payments (user_id, subscription_id, payment_date, amount, payment_method, status) VALUES (29, NULL, '2025-09-27 00:00:00', 997.67, 'Google Pay', 'Refunded');
INSERT INTO Payments (user_id, subscription_id, payment_date, amount, payment_method, status) VALUES (30, NULL, '2024-02-26 00:00:00', 262.42, 'Bank Transfer', 'Refunded');

-- ============================================
-- PROGRESS_TRACKING DATA (30 records)
-- ============================================
INSERT INTO Progress_Tracking (user_id, date, calories_burned, steps, workout_time_min, weight, bmi) VALUES (1, '2025-08-21 00:00:00', 863, 12951, 54, 91.35, 33.28);
INSERT INTO Progress_Tracking (user_id, date, calories_burned, steps, workout_time_min, weight, bmi) VALUES (2, '2024-03-13 00:00:00', 300, 8964, 61, 78.01, 21.36);
INSERT INTO Progress_Tracking (user_id, date, calories_burned, steps, workout_time_min, weight, bmi) VALUES (3, '2024-03-26 00:00:00', 320, 12997, 17, 114.33, 28.9);
INSERT INTO Progress_Tracking (user_id, date, calories_burned, steps, workout_time_min, weight, bmi) VALUES (4, '2024-01-01 00:00:00', 640, 13848, 15, 57.62, 19.14);
INSERT INTO Progress_Tracking (user_id, date, calories_burned, steps, workout_time_min, weight, bmi) VALUES (5, '2025-08-13 00:00:00', 556, 12556, 40, 60.28, 18.56);
INSERT INTO Progress_Tracking (user_id, date, calories_burned, steps, workout_time_min, weight, bmi) VALUES (6, '2024-01-11 00:00:00', 127, 4635, 104, 108.05, 30.98);
INSERT INTO Progress_Tracking (user_id, date, calories_burned, steps, workout_time_min, weight, bmi) VALUES (7, '2025-02-18 00:00:00', 352, 2566, 17, 100.19, 25.38);
INSERT INTO Progress_Tracking (user_id, date, calories_burned, steps, workout_time_min, weight, bmi) VALUES (8, '2024-04-03 00:00:00', 639, 14473, 117, 109.82, 37.08);
INSERT INTO Progress_Tracking (user_id, date, calories_burned, steps, workout_time_min, weight, bmi) VALUES (9, '2024-01-29 00:00:00', 818, 11802, 101, 73.41, 24.73);
INSERT INTO Progress_Tracking (user_id, date, calories_burned, steps, workout_time_min, weight, bmi) VALUES (10, '2024-07-16 00:00:00', 263, 12087, 69, 114.34, 47.23);
INSERT INTO Progress_Tracking (user_id, date, calories_burned, steps, workout_time_min, weight, bmi) VALUES (11, '2024-12-04 00:00:00', 276, 6082, 99, 70.57, 28.97);
INSERT INTO Progress_Tracking (user_id, date, calories_burned, steps, workout_time_min, weight, bmi) VALUES (12, '2025-03-01 00:00:00', 238, 6675, 36, 103.43, 31.55);
INSERT INTO Progress_Tracking (user_id, date, calories_burned, steps, workout_time_min, weight, bmi) VALUES (13, '2025-01-02 00:00:00', 670, 11398, 57, 89.06, 31.93);
INSERT INTO Progress_Tracking (user_id, date, calories_burned, steps, workout_time_min, weight, bmi) VALUES (14, '2024-11-05 00:00:00', 814, 9135, 84, 102.65, 25.77);
INSERT INTO Progress_Tracking (user_id, date, calories_burned, steps, workout_time_min, weight, bmi) VALUES (15, '2024-06-12 00:00:00', 562, 14955, 38, 75.82, 22.29);
INSERT INTO Progress_Tracking (user_id, date, calories_burned, steps, workout_time_min, weight, bmi) VALUES (16, '2025-06-21 00:00:00', 789, 3232, 48, 116.33, 29.18);
INSERT INTO Progress_Tracking (user_id, date, calories_burned, steps, workout_time_min, weight, bmi) VALUES (17, '2025-10-30 00:00:00', 864, 1239, 16, 89.49, 36.66);
INSERT INTO Progress_Tracking (user_id, date, calories_burned, steps, workout_time_min, weight, bmi) VALUES (18, '2024-11-09 00:00:00', 809, 6681, 20, 64.29, 23.16);
INSERT INTO Progress_Tracking (user_id, date, calories_burned, steps, workout_time_min, weight, bmi) VALUES (19, '2025-06-14 00:00:00', 811, 6765, 69, 119.31, 39.91);
INSERT INTO Progress_Tracking (user_id, date, calories_burned, steps, workout_time_min, weight, bmi) VALUES (20, '2025-12-13 00:00:00', 345, 15618, 112, 100.83, 26.77);
INSERT INTO Progress_Tracking (user_id, date, calories_burned, steps, workout_time_min, weight, bmi) VALUES (21, '2025-09-13 00:00:00', 469, 2275, 119, 90.12, 30.99);
INSERT INTO Progress_Tracking (user_id, date, calories_burned, steps, workout_time_min, weight, bmi) VALUES (22, '2025-04-26 00:00:00', 595, 15450, 113, 106.15, 36.9);
INSERT INTO Progress_Tracking (user_id, date, calories_burned, steps, workout_time_min, weight, bmi) VALUES (23, '2024-02-19 00:00:00', 199, 8954, 50, 77.21, 19.8);
INSERT INTO Progress_Tracking (user_id, date, calories_burned, steps, workout_time_min, weight, bmi) VALUES (24, '2024-10-29 00:00:00', 790, 18968, 95, 74.06, 20.91);
INSERT INTO Progress_Tracking (user_id, date, calories_burned, steps, workout_time_min, weight, bmi) VALUES (25, '2025-08-15 00:00:00', 144, 6071, 22, 110.38, 37.73);
INSERT INTO Progress_Tracking (user_id, date, calories_burned, steps, workout_time_min, weight, bmi) VALUES (26, '2024-11-03 00:00:00', 108, 12026, 22, 72.89, 22.69);
INSERT INTO Progress_Tracking (user_id, date, calories_burned, steps, workout_time_min, weight, bmi) VALUES (27, '2025-03-14 00:00:00', 279, 4753, 21, 55.67, 16.05);
INSERT INTO Progress_Tracking (user_id, date, calories_burned, steps, workout_time_min, weight, bmi) VALUES (28, '2024-03-28 00:00:00', 890, 11165, 73, 75.8, 20.13);
INSERT INTO Progress_Tracking (user_id, date, calories_burned, steps, workout_time_min, weight, bmi) VALUES (29, '2024-08-05 00:00:00', 843, 7365, 114, 94.38, 29.42);
INSERT INTO Progress_Tracking (user_id, date, calories_burned, steps, workout_time_min, weight, bmi) VALUES (30, '2024-05-30 00:00:00', 874, 13014, 76, 82.14, 23.13);

-- ============================================
-- GOALS DATA (30 records)
-- ============================================
INSERT INTO Goals (user_id, goal_type, target_weight, start_date, end_date, status) VALUES (1, 'Fat Loss', 66.91, '2024-09-24 00:00:00', '2025-03-10 00:00:00', 'On Hold');
INSERT INTO Goals (user_id, goal_type, target_weight, start_date, end_date, status) VALUES (2, 'Weight Gain', 96.48, '2024-01-13 00:00:00', '2024-03-02 00:00:00', 'Active');
INSERT INTO Goals (user_id, goal_type, target_weight, start_date, end_date, status) VALUES (3, 'Endurance', 52.28, '2024-10-12 00:00:00', '2024-11-30 00:00:00', 'Active');
INSERT INTO Goals (user_id, goal_type, target_weight, start_date, end_date, status) VALUES (4, 'Muscle Building', 58.5, '2025-10-02 00:00:00', '2025-11-08 00:00:00', 'Active');
INSERT INTO Goals (user_id, goal_type, target_weight, start_date, end_date, status) VALUES (5, 'Endurance', 70.38, '2024-11-13 00:00:00', '2025-02-14 00:00:00', 'Active');
INSERT INTO Goals (user_id, goal_type, target_weight, start_date, end_date, status) VALUES (6, 'Weight Gain', 84.11, '2024-04-11 00:00:00', '2024-06-26 00:00:00', 'Abandoned');
INSERT INTO Goals (user_id, goal_type, target_weight, start_date, end_date, status) VALUES (7, 'Weight Gain', 56.66, '2025-02-28 00:00:00', '2025-08-04 00:00:00', 'Active');
INSERT INTO Goals (user_id, goal_type, target_weight, start_date, end_date, status) VALUES (8, 'Flexibility', 98.47, '2025-02-22 00:00:00', '2025-05-08 00:00:00', 'Abandoned');
INSERT INTO Goals (user_id, goal_type, target_weight, start_date, end_date, status) VALUES (9, 'Muscle Building', 99.46, '2024-12-15 00:00:00', '2025-05-20 00:00:00', 'Completed');
INSERT INTO Goals (user_id, goal_type, target_weight, start_date, end_date, status) VALUES (10, 'Weight Gain', 80.41, '2025-08-05 00:00:00', '2026-01-16 00:00:00', 'Abandoned');
INSERT INTO Goals (user_id, goal_type, target_weight, start_date, end_date, status) VALUES (11, 'Endurance', 94.22, '2024-05-09 00:00:00', '2024-06-22 00:00:00', 'Abandoned');
INSERT INTO Goals (user_id, goal_type, target_weight, start_date, end_date, status) VALUES (12, 'Fat Loss', 99.82, '2024-03-16 00:00:00', '2024-05-10 00:00:00', 'On Hold');
INSERT INTO Goals (user_id, goal_type, target_weight, start_date, end_date, status) VALUES (13, 'Muscle Building', 63.29, '2024-07-06 00:00:00', '2024-08-09 00:00:00', 'Abandoned');
INSERT INTO Goals (user_id, goal_type, target_weight, start_date, end_date, status) VALUES (14, 'Fat Loss', 61.0, '2025-10-24 00:00:00', '2025-12-27 00:00:00', 'Abandoned');
INSERT INTO Goals (user_id, goal_type, target_weight, start_date, end_date, status) VALUES (15, 'Weight Gain', 78.14, '2025-05-21 00:00:00', '2025-07-13 00:00:00', 'On Hold');
INSERT INTO Goals (user_id, goal_type, target_weight, start_date, end_date, status) VALUES (16, 'Flexibility', 98.85, '2024-10-02 00:00:00', '2025-01-08 00:00:00', 'Completed');
INSERT INTO Goals (user_id, goal_type, target_weight, start_date, end_date, status) VALUES (17, 'Weight Gain', 92.01, '2024-10-05 00:00:00', '2025-02-19 00:00:00', 'Active');
INSERT INTO Goals (user_id, goal_type, target_weight, start_date, end_date, status) VALUES (18, 'Muscle Building', 60.5, '2024-12-02 00:00:00', '2025-04-25 00:00:00', 'Completed');
INSERT INTO Goals (user_id, goal_type, target_weight, start_date, end_date, status) VALUES (19, 'Flexibility', 67.87, '2025-12-09 00:00:00', '2026-05-03 00:00:00', 'Abandoned');
INSERT INTO Goals (user_id, goal_type, target_weight, start_date, end_date, status) VALUES (20, 'Endurance', 95.76, '2025-11-01 00:00:00', '2025-12-15 00:00:00', 'Completed');
INSERT INTO Goals (user_id, goal_type, target_weight, start_date, end_date, status) VALUES (21, 'Muscle Building', 78.09, '2024-06-27 00:00:00', '2024-10-02 00:00:00', 'Completed');
INSERT INTO Goals (user_id, goal_type, target_weight, start_date, end_date, status) VALUES (22, 'Weight Loss', 87.19, '2025-03-06 00:00:00', '2025-07-09 00:00:00', 'Completed');
INSERT INTO Goals (user_id, goal_type, target_weight, start_date, end_date, status) VALUES (23, 'Endurance', 76.44, '2025-03-31 00:00:00', '2025-08-12 00:00:00', 'On Hold');
INSERT INTO Goals (user_id, goal_type, target_weight, start_date, end_date, status) VALUES (24, 'Muscle Building', 60.58, '2025-02-22 00:00:00', '2025-03-28 00:00:00', 'Active');
INSERT INTO Goals (user_id, goal_type, target_weight, start_date, end_date, status) VALUES (25, 'Muscle Building', 94.27, '2024-09-18 00:00:00', '2024-10-29 00:00:00', 'Active');
INSERT INTO Goals (user_id, goal_type, target_weight, start_date, end_date, status) VALUES (26, 'Weight Loss', 60.96, '2025-02-09 00:00:00', '2025-05-06 00:00:00', 'Completed');
INSERT INTO Goals (user_id, goal_type, target_weight, start_date, end_date, status) VALUES (27, 'Weight Gain', 62.26, '2024-01-31 00:00:00', '2024-05-10 00:00:00', 'On Hold');
INSERT INTO Goals (user_id, goal_type, target_weight, start_date, end_date, status) VALUES (28, 'Endurance', 64.65, '2024-04-05 00:00:00', '2024-08-21 00:00:00', 'Abandoned');
INSERT INTO Goals (user_id, goal_type, target_weight, start_date, end_date, status) VALUES (29, 'Fat Loss', 80.69, '2025-09-22 00:00:00', '2025-11-08 00:00:00', 'On Hold');
INSERT INTO Goals (user_id, goal_type, target_weight, start_date, end_date, status) VALUES (30, 'Endurance', 79.03, '2025-05-09 00:00:00', '2025-08-25 00:00:00', 'Abandoned');

-- ============================================
-- WORKOUT_PLAN DATA (30 records)
-- ============================================
INSERT INTO Workout_Plan (user_id, trainer_id, goal_id, plan_name, plan_description, start_date, end_date) VALUES (1, 29, 1, 'Full Body Transformation 1', 'Customized workout plan focusing on specific fitness goals and progress tracking', '2024-05-16 00:00:00', '2024-10-11 00:00:00');
INSERT INTO Workout_Plan (user_id, trainer_id, goal_id, plan_name, plan_description, start_date, end_date) VALUES (2, 5, 2, 'Muscle Builder Pro 2', 'Customized workout plan focusing on specific fitness goals and progress tracking', '2025-07-10 00:00:00', '2025-08-10 00:00:00');
INSERT INTO Workout_Plan (user_id, trainer_id, goal_id, plan_name, plan_description, start_date, end_date) VALUES (3, 5, 3, 'Fat Burn Challenge 3', 'Customized workout plan focusing on specific fitness goals and progress tracking', '2024-06-16 00:00:00', '2024-12-06 00:00:00');
INSERT INTO Workout_Plan (user_id, trainer_id, goal_id, plan_name, plan_description, start_date, end_date) VALUES (4, NULL, 4, 'Strength Foundation 4', 'Customized workout plan focusing on specific fitness goals and progress tracking', '2024-05-11 00:00:00', '2024-09-21 00:00:00');
INSERT INTO Workout_Plan (user_id, trainer_id, goal_id, plan_name, plan_description, start_date, end_date) VALUES (5, NULL, 5, 'Beginners Start 5', 'Customized workout plan focusing on specific fitness goals and progress tracking', '2025-03-18 00:00:00', '2025-08-20 00:00:00');
INSERT INTO Workout_Plan (user_id, trainer_id, goal_id, plan_name, plan_description, start_date, end_date) VALUES (6, 22, 6, 'Core Crusher 6', 'Customized workout plan focusing on specific fitness goals and progress tracking', '2025-03-31 00:00:00', '2025-06-19 00:00:00');
INSERT INTO Workout_Plan (user_id, trainer_id, goal_id, plan_name, plan_description, start_date, end_date) VALUES (7, NULL, NULL, 'Endurance Builder 7', 'Customized workout plan focusing on specific fitness goals and progress tracking', '2025-07-25 00:00:00', '2025-12-23 00:00:00');
INSERT INTO Workout_Plan (user_id, trainer_id, goal_id, plan_name, plan_description, start_date, end_date) VALUES (8, 12, 8, 'Muscle Builder Pro 8', 'Customized workout plan focusing on specific fitness goals and progress tracking', '2025-10-31 00:00:00', '2026-01-30 00:00:00');
INSERT INTO Workout_Plan (user_id, trainer_id, goal_id, plan_name, plan_description, start_date, end_date) VALUES (9, NULL, 9, 'Cardio Blast 9', 'Customized workout plan focusing on specific fitness goals and progress tracking', '2025-03-05 00:00:00', '2025-04-24 00:00:00');
INSERT INTO Workout_Plan (user_id, trainer_id, goal_id, plan_name, plan_description, start_date, end_date) VALUES (10, NULL, 10, 'Fat Burn Challenge 10', 'Customized workout plan focusing on specific fitness goals and progress tracking', '2025-08-12 00:00:00', '2025-10-21 00:00:00');
INSERT INTO Workout_Plan (user_id, trainer_id, goal_id, plan_name, plan_description, start_date, end_date) VALUES (11, 5, 11, 'Strength Foundation 11', 'Customized workout plan focusing on specific fitness goals and progress tracking', '2024-04-26 00:00:00', '2024-07-28 00:00:00');
INSERT INTO Workout_Plan (user_id, trainer_id, goal_id, plan_name, plan_description, start_date, end_date) VALUES (12, 10, 12, 'Full Body Transformation 12', 'Customized workout plan focusing on specific fitness goals and progress tracking', '2024-07-21 00:00:00', '2024-11-19 00:00:00');
INSERT INTO Workout_Plan (user_id, trainer_id, goal_id, plan_name, plan_description, start_date, end_date) VALUES (13, NULL, 13, 'Strength Foundation 13', 'Customized workout plan focusing on specific fitness goals and progress tracking', '2024-11-18 00:00:00', '2025-01-11 00:00:00');
INSERT INTO Workout_Plan (user_id, trainer_id, goal_id, plan_name, plan_description, start_date, end_date) VALUES (14, 20, NULL, 'Fat Burn Challenge 14', 'Customized workout plan focusing on specific fitness goals and progress tracking', '2024-02-19 00:00:00', '2024-05-26 00:00:00');
INSERT INTO Workout_Plan (user_id, trainer_id, goal_id, plan_name, plan_description, start_date, end_date) VALUES (15, NULL, 15, 'Full Body Transformation 15', 'Customized workout plan focusing on specific fitness goals and progress tracking', '2024-07-21 00:00:00', '2024-09-07 00:00:00');
INSERT INTO Workout_Plan (user_id, trainer_id, goal_id, plan_name, plan_description, start_date, end_date) VALUES (16, 11, NULL, 'Athletic Performance 16', 'Customized workout plan focusing on specific fitness goals and progress tracking', '2025-09-20 00:00:00', '2026-01-29 00:00:00');
INSERT INTO Workout_Plan (user_id, trainer_id, goal_id, plan_name, plan_description, start_date, end_date) VALUES (17, 4, 17, 'HIIT Master 17', 'Customized workout plan focusing on specific fitness goals and progress tracking', '2024-05-02 00:00:00', '2024-10-24 00:00:00');
INSERT INTO Workout_Plan (user_id, trainer_id, goal_id, plan_name, plan_description, start_date, end_date) VALUES (18, NULL, 18, 'Endurance Builder 18', 'Customized workout plan focusing on specific fitness goals and progress tracking', '2024-01-18 00:00:00', '2024-02-18 00:00:00');
INSERT INTO Workout_Plan (user_id, trainer_id, goal_id, plan_name, plan_description, start_date, end_date) VALUES (19, NULL, 19, 'Muscle Builder Pro 19', 'Customized workout plan focusing on specific fitness goals and progress tracking', '2024-04-17 00:00:00', '2024-09-02 00:00:00');
INSERT INTO Workout_Plan (user_id, trainer_id, goal_id, plan_name, plan_description, start_date, end_date) VALUES (20, 29, 20, 'Cardio Blast 20', 'Customized workout plan focusing on specific fitness goals and progress tracking', '2025-04-02 00:00:00', '2025-05-28 00:00:00');
INSERT INTO Workout_Plan (user_id, trainer_id, goal_id, plan_name, plan_description, start_date, end_date) VALUES (21, 19, 21, 'Athletic Performance 21', 'Customized workout plan focusing on specific fitness goals and progress tracking', '2025-06-07 00:00:00', '2025-10-23 00:00:00');
INSERT INTO Workout_Plan (user_id, trainer_id, goal_id, plan_name, plan_description, start_date, end_date) VALUES (22, 8, 22, 'Core Crusher 22', 'Customized workout plan focusing on specific fitness goals and progress tracking', '2024-04-04 00:00:00', '2024-05-25 00:00:00');
INSERT INTO Workout_Plan (user_id, trainer_id, goal_id, plan_name, plan_description, start_date, end_date) VALUES (23, NULL, 23, 'HIIT Master 23', 'Customized workout plan focusing on specific fitness goals and progress tracking', '2024-08-20 00:00:00', '2025-01-10 00:00:00');
INSERT INTO Workout_Plan (user_id, trainer_id, goal_id, plan_name, plan_description, start_date, end_date) VALUES (24, NULL, NULL, 'Muscle Builder Pro 24', 'Customized workout plan focusing on specific fitness goals and progress tracking', '2025-02-25 00:00:00', '2025-08-19 00:00:00');
INSERT INTO Workout_Plan (user_id, trainer_id, goal_id, plan_name, plan_description, start_date, end_date) VALUES (25, NULL, 25, 'Core Crusher 25', 'Customized workout plan focusing on specific fitness goals and progress tracking', '2024-03-15 00:00:00', '2024-08-04 00:00:00');
INSERT INTO Workout_Plan (user_id, trainer_id, goal_id, plan_name, plan_description, start_date, end_date) VALUES (26, NULL, NULL, 'Core Crusher 26', 'Customized workout plan focusing on specific fitness goals and progress tracking', '2024-07-08 00:00:00', '2024-09-02 00:00:00');
INSERT INTO Workout_Plan (user_id, trainer_id, goal_id, plan_name, plan_description, start_date, end_date) VALUES (27, 21, NULL, 'Fat Burn Challenge 27', 'Customized workout plan focusing on specific fitness goals and progress tracking', '2024-08-16 00:00:00', '2024-10-13 00:00:00');
INSERT INTO Workout_Plan (user_id, trainer_id, goal_id, plan_name, plan_description, start_date, end_date) VALUES (28, NULL, 28, 'Fat Burn Challenge 28', 'Customized workout plan focusing on specific fitness goals and progress tracking', '2024-08-23 00:00:00', '2024-10-24 00:00:00');
INSERT INTO Workout_Plan (user_id, trainer_id, goal_id, plan_name, plan_description, start_date, end_date) VALUES (29, NULL, 29, 'Full Body Transformation 29', 'Customized workout plan focusing on specific fitness goals and progress tracking', '2024-11-11 00:00:00', '2025-01-13 00:00:00');
INSERT INTO Workout_Plan (user_id, trainer_id, goal_id, plan_name, plan_description, start_date, end_date) VALUES (30, 4, 30, 'Cardio Blast 30', 'Customized workout plan focusing on specific fitness goals and progress tracking', '2025-04-30 00:00:00', '2025-07-02 00:00:00');

-- ============================================
-- EXERCISES DATA (30 records)
-- ============================================
INSERT INTO Exercises (name, type, difficulty_level, calories_per_hour, muscle_group) VALUES ('Push-ups', 'Strength', 'Beginner', 300, 'Chest');
INSERT INTO Exercises (name, type, difficulty_level, calories_per_hour, muscle_group) VALUES ('Squats', 'Strength', 'Beginner', 400, 'Legs');
INSERT INTO Exercises (name, type, difficulty_level, calories_per_hour, muscle_group) VALUES ('Running', 'Cardio', 'Intermediate', 600, 'Full Body');
INSERT INTO Exercises (name, type, difficulty_level, calories_per_hour, muscle_group) VALUES ('Bench Press', 'Strength', 'Intermediate', 350, 'Chest');
INSERT INTO Exercises (name, type, difficulty_level, calories_per_hour, muscle_group) VALUES ('Deadlift', 'Strength', 'Advanced', 450, 'Back');
INSERT INTO Exercises (name, type, difficulty_level, calories_per_hour, muscle_group) VALUES ('Pull-ups', 'Strength', 'Intermediate', 400, 'Back');
INSERT INTO Exercises (name, type, difficulty_level, calories_per_hour, muscle_group) VALUES ('Lunges', 'Strength', 'Beginner', 350, 'Legs');
INSERT INTO Exercises (name, type, difficulty_level, calories_per_hour, muscle_group) VALUES ('Plank', 'Core', 'Beginner', 200, 'Core');
INSERT INTO Exercises (name, type, difficulty_level, calories_per_hour, muscle_group) VALUES ('Burpees', 'Cardio', 'Advanced', 800, 'Full Body');
INSERT INTO Exercises (name, type, difficulty_level, calories_per_hour, muscle_group) VALUES ('Mountain Climbers', 'Cardio', 'Intermediate', 700, 'Full Body');
INSERT INTO Exercises (name, type, difficulty_level, calories_per_hour, muscle_group) VALUES ('Bicep Curls', 'Strength', 'Beginner', 250, 'Arms');
INSERT INTO Exercises (name, type, difficulty_level, calories_per_hour, muscle_group) VALUES ('Tricep Dips', 'Strength', 'Intermediate', 300, 'Arms');
INSERT INTO Exercises (name, type, difficulty_level, calories_per_hour, muscle_group) VALUES ('Shoulder Press', 'Strength', 'Intermediate', 350, 'Shoulders');
INSERT INTO Exercises (name, type, difficulty_level, calories_per_hour, muscle_group) VALUES ('Leg Press', 'Strength', 'Intermediate', 400, 'Legs');
INSERT INTO Exercises (name, type, difficulty_level, calories_per_hour, muscle_group) VALUES ('Rowing', 'Cardio', 'Intermediate', 550, 'Back');
INSERT INTO Exercises (name, type, difficulty_level, calories_per_hour, muscle_group) VALUES ('Box Jumps', 'Plyometric', 'Advanced', 650, 'Legs');
INSERT INTO Exercises (name, type, difficulty_level, calories_per_hour, muscle_group) VALUES ('Kettlebell Swings', 'Strength', 'Intermediate', 500, 'Full Body');
INSERT INTO Exercises (name, type, difficulty_level, calories_per_hour, muscle_group) VALUES ('Battle Ropes', 'Cardio', 'Advanced', 700, 'Arms');
INSERT INTO Exercises (name, type, difficulty_level, calories_per_hour, muscle_group) VALUES ('Jumping Jacks', 'Cardio', 'Beginner', 450, 'Full Body');
INSERT INTO Exercises (name, type, difficulty_level, calories_per_hour, muscle_group) VALUES ('Sit-ups', 'Core', 'Beginner', 250, 'Core');
INSERT INTO Exercises (name, type, difficulty_level, calories_per_hour, muscle_group) VALUES ('Russian Twists', 'Core', 'Intermediate', 300, 'Core');
INSERT INTO Exercises (name, type, difficulty_level, calories_per_hour, muscle_group) VALUES ('Leg Raises', 'Core', 'Intermediate', 280, 'Core');
INSERT INTO Exercises (name, type, difficulty_level, calories_per_hour, muscle_group) VALUES ('Cycling', 'Cardio', 'Beginner', 500, 'Legs');
INSERT INTO Exercises (name, type, difficulty_level, calories_per_hour, muscle_group) VALUES ('Swimming', 'Cardio', 'Intermediate', 600, 'Full Body');
INSERT INTO Exercises (name, type, difficulty_level, calories_per_hour, muscle_group) VALUES ('Yoga Sun Salutation', 'Flexibility', 'Beginner', 200, 'Full Body');
INSERT INTO Exercises (name, type, difficulty_level, calories_per_hour, muscle_group) VALUES ('Pilates Roll-up', 'Core', 'Intermediate', 250, 'Core');
INSERT INTO Exercises (name, type, difficulty_level, calories_per_hour, muscle_group) VALUES ('Dumbbell Rows', 'Strength', 'Intermediate', 350, 'Back');
INSERT INTO Exercises (name, type, difficulty_level, calories_per_hour, muscle_group) VALUES ('Calf Raises', 'Strength', 'Beginner', 200, 'Legs');
INSERT INTO Exercises (name, type, difficulty_level, calories_per_hour, muscle_group) VALUES ('Side Plank', 'Core', 'Intermediate', 220, 'Core');
INSERT INTO Exercises (name, type, difficulty_level, calories_per_hour, muscle_group) VALUES ('Wall Sits', 'Strength', 'Beginner', 300, 'Legs');

-- ============================================
-- WORKOUT_EXERCISES DATA (30 records)
-- ============================================
INSERT INTO Workout_Exercises (plan_id, exercise_id, sets, reps, duration_min) VALUES (11, 5, 3, 10, 49);
INSERT INTO Workout_Exercises (plan_id, exercise_id, sets, reps, duration_min) VALUES (4, 23, 5, 8, 51);
INSERT INTO Workout_Exercises (plan_id, exercise_id, sets, reps, duration_min) VALUES (26, 22, 3, 12, 49);
INSERT INTO Workout_Exercises (plan_id, exercise_id, sets, reps, duration_min) VALUES (23, 6, 4, 8, 19);
INSERT INTO Workout_Exercises (plan_id, exercise_id, sets, reps, duration_min) VALUES (13, 29, 5, 13, 19);
INSERT INTO Workout_Exercises (plan_id, exercise_id, sets, reps, duration_min) VALUES (14, 27, 5, 15, 36);
INSERT INTO Workout_Exercises (plan_id, exercise_id, sets, reps, duration_min) VALUES (29, 23, 2, 20, 11);
INSERT INTO Workout_Exercises (plan_id, exercise_id, sets, reps, duration_min) VALUES (15, 11, 4, 20, 41);
INSERT INTO Workout_Exercises (plan_id, exercise_id, sets, reps, duration_min) VALUES (25, 4, 3, 17, 36);
INSERT INTO Workout_Exercises (plan_id, exercise_id, sets, reps, duration_min) VALUES (5, 2, 5, 14, 46);
INSERT INTO Workout_Exercises (plan_id, exercise_id, sets, reps, duration_min) VALUES (30, 6, 3, 8, 17);
INSERT INTO Workout_Exercises (plan_id, exercise_id, sets, reps, duration_min) VALUES (29, 26, 3, 10, 35);
INSERT INTO Workout_Exercises (plan_id, exercise_id, sets, reps, duration_min) VALUES (17, 26, 3, 11, 43);
INSERT INTO Workout_Exercises (plan_id, exercise_id, sets, reps, duration_min) VALUES (19, 2, 5, 19, 39);
INSERT INTO Workout_Exercises (plan_id, exercise_id, sets, reps, duration_min) VALUES (30, 24, 5, 11, 46);
INSERT INTO Workout_Exercises (plan_id, exercise_id, sets, reps, duration_min) VALUES (22, 15, 5, 14, 49);
INSERT INTO Workout_Exercises (plan_id, exercise_id, sets, reps, duration_min) VALUES (13, 24, 4, 9, 55);
INSERT INTO Workout_Exercises (plan_id, exercise_id, sets, reps, duration_min) VALUES (19, 28, 5, 13, 24);
INSERT INTO Workout_Exercises (plan_id, exercise_id, sets, reps, duration_min) VALUES (29, 28, 4, 9, 39);
INSERT INTO Workout_Exercises (plan_id, exercise_id, sets, reps, duration_min) VALUES (14, 9, 3, 10, 39);
INSERT INTO Workout_Exercises (plan_id, exercise_id, sets, reps, duration_min) VALUES (10, 25, 2, 20, 51);
INSERT INTO Workout_Exercises (plan_id, exercise_id, sets, reps, duration_min) VALUES (29, 13, 2, 9, 36);
INSERT INTO Workout_Exercises (plan_id, exercise_id, sets, reps, duration_min) VALUES (19, 29, 5, 20, 43);
INSERT INTO Workout_Exercises (plan_id, exercise_id, sets, reps, duration_min) VALUES (10, 23, 3, 12, 33);
INSERT INTO Workout_Exercises (plan_id, exercise_id, sets, reps, duration_min) VALUES (28, 27, 3, 18, 18);
INSERT INTO Workout_Exercises (plan_id, exercise_id, sets, reps, duration_min) VALUES (8, 22, 2, 17, 13);
INSERT INTO Workout_Exercises (plan_id, exercise_id, sets, reps, duration_min) VALUES (26, 9, 5, 18, 21);
INSERT INTO Workout_Exercises (plan_id, exercise_id, sets, reps, duration_min) VALUES (27, 18, 3, 18, 23);
INSERT INTO Workout_Exercises (plan_id, exercise_id, sets, reps, duration_min) VALUES (24, 19, 3, 13, 47);
INSERT INTO Workout_Exercises (plan_id, exercise_id, sets, reps, duration_min) VALUES (14, 4, 4, 13, 54);

-- ============================================
-- FEEDBACK DATA (30 records)
-- ============================================
INSERT INTO Feedback (user_id, trainer_id, class_id, rating, comments, date) VALUES (1, 8, NULL, 4.94, 'Great class, highly recommend!', '2025-10-09 00:00:00');
INSERT INTO Feedback (user_id, trainer_id, class_id, rating, comments, date) VALUES (2, NULL, NULL, 3.65, 'Excellent trainer, very knowledgeable!', '2024-08-27 00:00:00');
INSERT INTO Feedback (user_id, trainer_id, class_id, rating, comments, date) VALUES (3, 7, 16, 4.82, 'Best fitness class I have attended!', '2025-02-07 00:00:00');
INSERT INTO Feedback (user_id, trainer_id, class_id, rating, comments, date) VALUES (4, 8, NULL, 4.83, 'The class was too crowded.', '2024-11-24 00:00:00');
INSERT INTO Feedback (user_id, trainer_id, class_id, rating, comments, date) VALUES (5, 20, 29, 3.67, 'Great class, highly recommend!', '2025-06-26 00:00:00');
INSERT INTO Feedback (user_id, trainer_id, class_id, rating, comments, date) VALUES (6, 24, NULL, 3.01, 'Trainer needs to be more attentive.', '2025-02-23 00:00:00');
INSERT INTO Feedback (user_id, trainer_id, class_id, rating, comments, date) VALUES (7, 14, NULL, 3.03, 'Best fitness class I have attended!', '2025-05-01 00:00:00');
INSERT INTO Feedback (user_id, trainer_id, class_id, rating, comments, date) VALUES (8, NULL, 3, 4.74, 'Very professional and motivating.', '2024-01-29 00:00:00');
INSERT INTO Feedback (user_id, trainer_id, class_id, rating, comments, date) VALUES (9, 5, 1, 3.38, 'Excellent trainer, very knowledgeable!', '2024-10-12 00:00:00');
INSERT INTO Feedback (user_id, trainer_id, class_id, rating, comments, date) VALUES (10, 13, NULL, 4.39, 'Perfect for beginners!', '2025-02-04 00:00:00');
INSERT INTO Feedback (user_id, trainer_id, class_id, rating, comments, date) VALUES (11, 18, 25, 4.73, 'Excellent trainer, very knowledgeable!', '2024-12-25 00:00:00');
INSERT INTO Feedback (user_id, trainer_id, class_id, rating, comments, date) VALUES (12, 23, 1, 4.36, 'Best fitness class I have attended!', '2024-05-08 00:00:00');
INSERT INTO Feedback (user_id, trainer_id, class_id, rating, comments, date) VALUES (13, 13, 8, 3.98, 'Excellent trainer, very knowledgeable!', '2024-09-25 00:00:00');
INSERT INTO Feedback (user_id, trainer_id, class_id, rating, comments, date) VALUES (14, 26, NULL, 3.56, 'Amazing workout session!', '2024-05-12 00:00:00');
INSERT INTO Feedback (user_id, trainer_id, class_id, rating, comments, date) VALUES (15, 5, 20, 3.96, 'Very professional and motivating.', '2025-02-08 00:00:00');
INSERT INTO Feedback (user_id, trainer_id, class_id, rating, comments, date) VALUES (16, 1, 8, 4.76, 'Amazing workout session!', '2024-07-18 00:00:00');
INSERT INTO Feedback (user_id, trainer_id, class_id, rating, comments, date) VALUES (17, 2, 2, 3.67, 'Trainer needs to be more attentive.', '2025-09-09 00:00:00');
INSERT INTO Feedback (user_id, trainer_id, class_id, rating, comments, date) VALUES (18, 30, 28, 3.4, 'Very professional and motivating.', '2024-05-26 00:00:00');
INSERT INTO Feedback (user_id, trainer_id, class_id, rating, comments, date) VALUES (19, NULL, 13, 4.63, 'Great class, highly recommend!', '2024-01-22 00:00:00');
INSERT INTO Feedback (user_id, trainer_id, class_id, rating, comments, date) VALUES (20, NULL, 20, 4.2, 'The class was too crowded.', '2024-03-31 00:00:00');
INSERT INTO Feedback (user_id, trainer_id, class_id, rating, comments, date) VALUES (21, NULL, NULL, 3.93, 'Very professional and motivating.', '2025-10-25 00:00:00');
INSERT INTO Feedback (user_id, trainer_id, class_id, rating, comments, date) VALUES (22, NULL, 5, 4.66, 'Best fitness class I have attended!', '2025-04-27 00:00:00');
INSERT INTO Feedback (user_id, trainer_id, class_id, rating, comments, date) VALUES (23, 22, NULL, 4.06, 'Best fitness class I have attended!', '2025-02-28 00:00:00');
INSERT INTO Feedback (user_id, trainer_id, class_id, rating, comments, date) VALUES (24, 17, 10, 4.37, 'Best fitness class I have attended!', '2024-03-10 00:00:00');
INSERT INTO Feedback (user_id, trainer_id, class_id, rating, comments, date) VALUES (25, 19, 28, 3.77, 'The class was too crowded.', '2025-08-06 00:00:00');
INSERT INTO Feedback (user_id, trainer_id, class_id, rating, comments, date) VALUES (26, 1, 23, 4.92, 'Excellent trainer, very knowledgeable!', '2024-07-04 00:00:00');
INSERT INTO Feedback (user_id, trainer_id, class_id, rating, comments, date) VALUES (27, 3, NULL, 4.2, 'Excellent trainer, very knowledgeable!', '2024-01-28 00:00:00');
INSERT INTO Feedback (user_id, trainer_id, class_id, rating, comments, date) VALUES (28, 24, 9, 3.14, 'Perfect for beginners!', '2025-11-09 00:00:00');
INSERT INTO Feedback (user_id, trainer_id, class_id, rating, comments, date) VALUES (29, 24, NULL, 4.88, 'Challenging but rewarding.', '2025-10-21 00:00:00');
INSERT INTO Feedback (user_id, trainer_id, class_id, rating, comments, date) VALUES (30, 12, NULL, 4.79, 'Excellent trainer, very knowledgeable!', '2024-12-28 00:00:00');

-- ============================================
-- DEVICES DATA (30 records)
-- ============================================
INSERT INTO Devices (user_id, device_name, model, sync_date, battery_level, firmware_version) VALUES (1, 'Fitbit', 'Forerunner 945', '2025-01-27 00:00:00', 75, '4.6.2');
INSERT INTO Devices (user_id, device_name, model, sync_date, battery_level, firmware_version) VALUES (2, 'Samsung Galaxy Watch', 'Ultra', '2024-06-29 00:00:00', 57, '1.7.7');
INSERT INTO Devices (user_id, device_name, model, sync_date, battery_level, firmware_version) VALUES (3, 'Fitbit', 'Band 7', '2025-10-20 00:00:00', 73, '2.9.7');
INSERT INTO Devices (user_id, device_name, model, sync_date, battery_level, firmware_version) VALUES (4, 'Samsung Galaxy Watch', 'Series 8', '2025-01-30 00:00:00', 91, '1.6.4');
INSERT INTO Devices (user_id, device_name, model, sync_date, battery_level, firmware_version) VALUES (5, 'Xiaomi Mi Band', 'Band 7', '2024-03-11 00:00:00', 51, '3.6.7');
INSERT INTO Devices (user_id, device_name, model, sync_date, battery_level, firmware_version) VALUES (6, 'Apple Watch', 'Venu 2', '2025-03-10 00:00:00', 33, '5.0.2');
INSERT INTO Devices (user_id, device_name, model, sync_date, battery_level, firmware_version) VALUES (7, 'Samsung Galaxy Watch', 'Band 7', '2024-09-28 00:00:00', 13, '5.0.7');
INSERT INTO Devices (user_id, device_name, model, sync_date, battery_level, firmware_version) VALUES (8, 'Apple Watch', 'Series 8', '2024-09-19 00:00:00', 40, '2.3.5');
INSERT INTO Devices (user_id, device_name, model, sync_date, battery_level, firmware_version) VALUES (9, 'Samsung Galaxy Watch', 'Charge 5', '2024-06-02 00:00:00', 39, '3.5.1');
INSERT INTO Devices (user_id, device_name, model, sync_date, battery_level, firmware_version) VALUES (10, 'Apple Watch', 'Charge 5', '2024-08-20 00:00:00', 11, '2.5.6');
INSERT INTO Devices (user_id, device_name, model, sync_date, battery_level, firmware_version) VALUES (11, 'Garmin', 'Forerunner 945', '2025-07-17 00:00:00', 87, '1.3.1');
INSERT INTO Devices (user_id, device_name, model, sync_date, battery_level, firmware_version) VALUES (12, 'Apple Watch', 'Ultra', '2024-07-31 00:00:00', 75, '4.1.4');
INSERT INTO Devices (user_id, device_name, model, sync_date, battery_level, firmware_version) VALUES (13, 'Samsung Galaxy Watch', 'Ultra', '2024-11-10 00:00:00', 99, '3.3.5');
INSERT INTO Devices (user_id, device_name, model, sync_date, battery_level, firmware_version) VALUES (14, 'Garmin', 'Band 7', '2025-03-26 00:00:00', 12, '3.8.1');
INSERT INTO Devices (user_id, device_name, model, sync_date, battery_level, firmware_version) VALUES (15, 'Xiaomi Mi Band', 'Venu 2', '2024-02-28 00:00:00', 69, '5.8.0');
INSERT INTO Devices (user_id, device_name, model, sync_date, battery_level, firmware_version) VALUES (16, 'Samsung Galaxy Watch', 'Forerunner 945', '2024-06-21 00:00:00', 40, '4.6.8');
INSERT INTO Devices (user_id, device_name, model, sync_date, battery_level, firmware_version) VALUES (17, 'Apple Watch', 'Venu 2', '2025-07-07 00:00:00', 14, '4.8.8');
INSERT INTO Devices (user_id, device_name, model, sync_date, battery_level, firmware_version) VALUES (18, 'Xiaomi Mi Band', 'Charge 5', '2024-07-12 00:00:00', 34, '3.4.4');
INSERT INTO Devices (user_id, device_name, model, sync_date, battery_level, firmware_version) VALUES (19, 'Garmin', 'Ultra', '2024-02-22 00:00:00', 16, '3.4.8');
INSERT INTO Devices (user_id, device_name, model, sync_date, battery_level, firmware_version) VALUES (20, 'Garmin', 'Active 2', '2025-10-03 00:00:00', 69, '3.3.5');
INSERT INTO Devices (user_id, device_name, model, sync_date, battery_level, firmware_version) VALUES (21, 'Garmin', 'Active 2', '2025-02-02 00:00:00', 21, '2.4.2');
INSERT INTO Devices (user_id, device_name, model, sync_date, battery_level, firmware_version) VALUES (22, 'Xiaomi Mi Band', 'Active 2', '2024-08-28 00:00:00', 90, '5.6.9');
INSERT INTO Devices (user_id, device_name, model, sync_date, battery_level, firmware_version) VALUES (23, 'Garmin', 'Forerunner 945', '2025-02-24 00:00:00', 98, '2.9.2');
INSERT INTO Devices (user_id, device_name, model, sync_date, battery_level, firmware_version) VALUES (24, 'Samsung Galaxy Watch', 'Band 7', '2025-10-26 00:00:00', 66, '5.5.9');
INSERT INTO Devices (user_id, device_name, model, sync_date, battery_level, firmware_version) VALUES (25, 'Garmin', 'Ultra', '2024-01-14 00:00:00', 44, '2.4.0');
INSERT INTO Devices (user_id, device_name, model, sync_date, battery_level, firmware_version) VALUES (26, 'Xiaomi Mi Band', 'Venu 2', '2024-01-31 00:00:00', 34, '2.2.9');
INSERT INTO Devices (user_id, device_name, model, sync_date, battery_level, firmware_version) VALUES (27, 'Samsung Galaxy Watch', 'Active 2', '2025-10-23 00:00:00', 38, '2.5.2');
INSERT INTO Devices (user_id, device_name, model, sync_date, battery_level, firmware_version) VALUES (28, 'Fitbit', 'Series 8', '2024-10-06 00:00:00', 50, '4.4.5');
INSERT INTO Devices (user_id, device_name, model, sync_date, battery_level, firmware_version) VALUES (29, 'Samsung Galaxy Watch', 'Active 2', '2025-12-28 00:00:00', 48, '3.4.6');
INSERT INTO Devices (user_id, device_name, model, sync_date, battery_level, firmware_version) VALUES (30, 'Xiaomi Mi Band', 'Series 8', '2025-12-14 00:00:00', 54, '2.0.8');

-- SET FOREIGN_KEY_CHECKS = 1;

-- ============================================
-- END OF DML
-- ============================================