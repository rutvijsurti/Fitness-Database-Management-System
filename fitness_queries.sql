-- ============================================
-- FITNESS MANAGEMENT SYSTEM - 15 COMPLEX QUERIES
-- Covering: Multiple Joins, Aggregations, Subqueries, 
-- Referential Integrity, and Real-world Use Cases
-- ============================================

-- ============================================
-- QUERY 1: User Subscription and Trainer Details with Payment Status
-- USE CASE: Get complete user profile with subscription and trainer info
-- JOINS: Users -> Subscriptions, Users -> Trainers, Users -> Payments
-- ============================================
SELECT 
    u.user_id,
    u.full_name AS user_name,
    u.email,
    u.goal,
    s.plan_name,
    s.price AS subscription_price,
    s.duration_months,
    t.full_name AS trainer_name,
    t.specialization,
    t.rating AS trainer_rating,
    p.payment_date,
    p.amount AS payment_amount,
    p.status AS payment_status
FROM Users u
LEFT JOIN Subscriptions s ON u.subscription_id = s.subscription_id
LEFT JOIN Trainers t ON u.trainer_id = t.trainer_id
LEFT JOIN Payments p ON u.user_id = p.user_id AND p.subscription_id = s.subscription_id
WHERE u.subscription_id IS NOT NULL
ORDER BY u.user_id;


-- ============================================
-- QUERY 2: Trainer Performance Analysis with Class and Feedback Statistics
-- USE CASE: Evaluate trainer effectiveness
-- JOINS: Trainers -> Classes, Trainers -> Feedback, Trainers -> Certifications
-- AGGREGATION: COUNT, AVG
-- ============================================
SELECT 
    t.trainer_id,
    t.full_name AS trainer_name,
    t.specialization,
    t.experience_years,
    t.rating AS overall_rating,
    c.certification_name,
    c.issued_by,
    COUNT(DISTINCT cl.class_id) AS total_classes,
    COUNT(DISTINCT f.feedback_id) AS feedback_count,
    AVG(f.rating) AS avg_feedback_rating,
    SUM(cl.max_participants) AS total_capacity
FROM Trainers t
LEFT JOIN Certifications c ON t.certification_id = c.certification_id
LEFT JOIN Classes cl ON t.trainer_id = cl.trainer_id
LEFT JOIN Feedback f ON t.trainer_id = f.trainer_id
GROUP BY t.trainer_id, t.full_name, t.specialization, t.experience_years, 
         t.rating, c.certification_name, c.issued_by
HAVING total_classes > 0
ORDER BY avg_feedback_rating DESC, total_classes DESC;


-- ============================================
-- QUERY 3: Class Enrollment Analysis with Attendance
-- USE CASE: Track class popularity and attendance rates
-- JOINS: Classes -> User_Class -> Users -> Trainers
-- ============================================
SELECT 
    cl.class_id,
    cl.class_name,
    cl.category,
    cl.mode,
    cl.schedule_date,
    t.full_name AS trainer_name,
    cl.max_participants,
    COUNT(uc.user_id) AS enrolled_count,
    SUM(CASE WHEN uc.attendance_status = 'Attended' THEN 1 ELSE 0 END) AS attended_count,
    SUM(CASE WHEN uc.attendance_status = 'Missed' THEN 1 ELSE 0 END) AS missed_count,
    SUM(CASE WHEN uc.attendance_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_count,
    ROUND((SUM(CASE WHEN uc.attendance_status = 'Attended' THEN 1 ELSE 0 END) * 100.0 / 
           NULLIF(COUNT(uc.user_id), 0)), 2) AS attendance_rate_percent
FROM Classes cl
LEFT JOIN User_Class uc ON cl.class_id = uc.class_id
LEFT JOIN Trainers t ON cl.trainer_id = t.trainer_id
GROUP BY cl.class_id, cl.class_name, cl.category, cl.mode, 
         cl.schedule_date, t.full_name, cl.max_participants
ORDER BY enrolled_count DESC, attendance_rate_percent DESC;


-- ============================================
-- QUERY 4: User Progress Tracking with Goal Achievement
-- USE CASE: Monitor user fitness journey and goal progress
-- JOINS: Users -> Progress_Tracking -> Goals -> Workout_Plan
-- ============================================
SELECT 
    u.user_id,
    u.full_name,
    u.goal AS primary_goal,
    u.weight AS current_weight,
    g.goal_type,
    g.target_weight,
    g.status AS goal_status,
    pt.date AS tracking_date,
    pt.weight AS tracked_weight,
    pt.bmi,
    pt.calories_burned,
    pt.steps,
    pt.workout_time_min,
    (u.weight - g.target_weight) AS weight_difference,
    wp.plan_name AS workout_plan
FROM Users u
INNER JOIN Goals g ON u.user_id = g.user_id
LEFT JOIN Progress_Tracking pt ON u.user_id = pt.user_id
LEFT JOIN Workout_Plan wp ON u.user_id = wp.user_id AND wp.goal_id = g.goal_id
WHERE g.status IN ('Active', 'Completed')
ORDER BY u.user_id, pt.date DESC;


-- ============================================
-- QUERY 5: Revenue Analysis by Subscription Plan
-- USE CASE: Financial reporting and subscription performance
-- JOINS: Subscriptions -> Payments -> Users
-- AGGREGATION: SUM, COUNT, AVG
-- ============================================
SELECT 
    s.subscription_id,
    s.plan_name,
    s.duration_months,
    s.price AS plan_price,
    COUNT(DISTINCT p.user_id) AS total_subscribers,
    COUNT(p.payment_id) AS total_payments,
    SUM(CASE WHEN p.status = 'Completed' THEN p.amount ELSE 0 END) AS total_revenue,
    SUM(CASE WHEN p.status = 'Pending' THEN p.amount ELSE 0 END) AS pending_revenue,
    SUM(CASE WHEN p.status = 'Failed' THEN p.amount ELSE 0 END) AS failed_revenue,
    SUM(CASE WHEN p.status = 'Refunded' THEN p.amount ELSE 0 END) AS refunded_amount,
    AVG(p.amount) AS avg_payment_amount
FROM Subscriptions s
LEFT JOIN Payments p ON s.subscription_id = p.subscription_id
GROUP BY s.subscription_id, s.plan_name, s.duration_months, s.price
ORDER BY total_revenue DESC;


-- ============================================
-- QUERY 6: Workout Plan Effectiveness Analysis
-- USE CASE: Evaluate workout plans with exercises and user outcomes
-- JOINS: Workout_Plan -> Users -> Goals -> Workout_Exercises -> Exercises
-- ============================================
SELECT 
    wp.plan_id,
    wp.plan_name,
    u.full_name AS user_name,
    g.goal_type,
    g.status AS goal_status,
    t.full_name AS trainer_name,
    COUNT(DISTINCT we.exercise_id) AS total_exercises,
    SUM(we.sets * we.reps) AS total_reps,
    AVG(we.duration_min) AS avg_exercise_duration,
    GROUP_CONCAT(DISTINCT e.muscle_group ORDER BY e.muscle_group) AS muscle_groups_targeted,
    DATEDIFF(wp.end_date, wp.start_date) AS plan_duration_days
FROM Workout_Plan wp
INNER JOIN Users u ON wp.user_id = u.user_id
LEFT JOIN Goals g ON wp.goal_id = g.goal_id
LEFT JOIN Trainers t ON wp.trainer_id = t.trainer_id
LEFT JOIN Workout_Exercises we ON wp.plan_id = we.plan_id
LEFT JOIN Exercises e ON we.exercise_id = e.exercise_id
GROUP BY wp.plan_id, wp.plan_name, u.full_name, g.goal_type, 
         g.status, t.full_name, wp.start_date, wp.end_date
ORDER BY wp.plan_id;


-- ============================================
-- QUERY 7: Trainers with Expired Certifications (Referential Integrity Check)
-- USE CASE: Compliance monitoring - identify trainers needing recertification
-- JOINS: Trainers -> Certifications
-- ============================================
SELECT 
    t.trainer_id,
    t.full_name AS trainer_name,
    t.email,
    t.specialization,
    c.certification_name,
    c.issued_by,
    c.issue_date,
    c.expiry_date,
    DATEDIFF(CURDATE(), c.expiry_date) AS days_expired,
    COUNT(cl.class_id) AS scheduled_classes
FROM Trainers t
INNER JOIN Certifications c ON t.certification_id = c.certification_id
LEFT JOIN Classes cl ON t.trainer_id = cl.trainer_id AND cl.schedule_date > CURDATE()
WHERE c.expiry_date < CURDATE()
GROUP BY t.trainer_id, t.full_name, t.email, t.specialization,
         c.certification_name, c.issued_by, c.issue_date, c.expiry_date
ORDER BY days_expired DESC;


-- ============================================
-- QUERY 8: User Engagement Score with Multiple Metrics
-- USE CASE: Calculate user engagement based on class attendance, payments, and progress
-- JOINS: Users -> User_Class -> Payments -> Progress_Tracking -> Devices
-- ============================================
SELECT 
    u.user_id,
    u.full_name,
    u.email,
    COUNT(DISTINCT uc.class_id) AS classes_enrolled,
    SUM(CASE WHEN uc.attendance_status = 'Attended' THEN 1 ELSE 0 END) AS classes_attended,
    COUNT(DISTINCT p.payment_id) AS total_payments,
    SUM(CASE WHEN p.status = 'Completed' THEN 1 ELSE 0 END) AS successful_payments,
    COUNT(DISTINCT pt.progress_id) AS progress_entries,
    COUNT(DISTINCT d.device_id) AS synced_devices,
    (COUNT(DISTINCT uc.class_id) * 2 + 
     SUM(CASE WHEN uc.attendance_status = 'Attended' THEN 1 ELSE 0 END) * 5 +
     COUNT(DISTINCT pt.progress_id) * 3 +
     COUNT(DISTINCT d.device_id) * 2) AS engagement_score
FROM Users u
LEFT JOIN User_Class uc ON u.user_id = uc.user_id
LEFT JOIN Payments p ON u.user_id = p.user_id
LEFT JOIN Progress_Tracking pt ON u.user_id = pt.user_id
LEFT JOIN Devices d ON u.user_id = d.user_id
GROUP BY u.user_id, u.full_name, u.email
ORDER BY engagement_score DESC
LIMIT 20;


-- ============================================
-- QUERY 9: Class Schedule with Trainer Availability
-- USE CASE: View upcoming classes with complete details
-- JOINS: Classes -> Trainers -> User_Class
-- ============================================
SELECT 
    cl.class_id,
    cl.class_name,
    cl.category,
    cl.mode,
    DATE_FORMAT(cl.schedule_date, '%Y-%m-%d %H:%i') AS scheduled_time,
    cl.duration_minutes,
    cl.max_participants,
    t.full_name AS trainer_name,
    t.specialization,
    t.rating AS trainer_rating,
    COUNT(uc.user_id) AS current_enrollment,
    (cl.max_participants - COUNT(uc.user_id)) AS available_spots,
    CASE 
        WHEN COUNT(uc.user_id) >= cl.max_participants THEN 'Full'
        WHEN COUNT(uc.user_id) >= cl.max_participants * 0.8 THEN 'Almost Full'
        ELSE 'Available'
    END AS enrollment_status
FROM Classes cl
INNER JOIN Trainers t ON cl.trainer_id = t.trainer_id
LEFT JOIN User_Class uc ON cl.class_id = uc.class_id 
    AND uc.attendance_status IN ('Enrolled', 'Attended')
WHERE cl.schedule_date >= CURDATE()
GROUP BY cl.class_id, cl.class_name, cl.category, cl.mode, cl.schedule_date,
         cl.duration_minutes, cl.max_participants, t.full_name, 
         t.specialization, t.rating
ORDER BY cl.schedule_date;


-- ============================================
-- QUERY 10: Orphaned Records Check (Referential Integrity)
-- USE CASE: Identify data integrity issues with NULL foreign keys
-- JOINS: Multiple LEFT JOINs to find orphaned records
-- ============================================
SELECT 
    'Users without Subscription' AS record_type,
    COUNT(*) AS count
FROM Users
WHERE subscription_id IS NULL

UNION ALL

SELECT 
    'Users without Trainer' AS record_type,
    COUNT(*) AS count
FROM Users
WHERE trainer_id IS NULL

UNION ALL

SELECT 
    'Payments without Subscription' AS record_type,
    COUNT(*) AS count
FROM Payments
WHERE subscription_id IS NULL

UNION ALL

SELECT 
    'Workout Plans without Trainer' AS record_type,
    COUNT(*) AS count
FROM Workout_Plan
WHERE trainer_id IS NULL

UNION ALL

SELECT 
    'Workout Plans without Goal' AS record_type,
    COUNT(*) AS count
FROM Workout_Plan
WHERE goal_id IS NULL

UNION ALL

SELECT 
    'Trainers without Certification' AS record_type,
    COUNT(*) AS count
FROM Trainers
WHERE certification_id IS NULL;


-- ============================================
-- QUERY 11: Exercise Library with Usage Statistics
-- USE CASE: Understand which exercises are most popular
-- JOINS: Exercises -> Workout_Exercises -> Workout_Plan
-- ============================================
SELECT 
    e.exercise_id,
    e.name AS exercise_name,
    e.type,
    e.difficulty_level,
    e.muscle_group,
    e.calories_per_hour,
    COUNT(DISTINCT we.plan_id) AS used_in_plans,
    AVG(we.sets) AS avg_sets,
    AVG(we.reps) AS avg_reps,
    AVG(we.duration_min) AS avg_duration_minutes,
    SUM(we.sets * we.reps) AS total_reps_across_plans
FROM Exercises e
LEFT JOIN Workout_Exercises we ON e.exercise_id = we.exercise_id
GROUP BY e.exercise_id, e.name, e.type, e.difficulty_level, 
         e.muscle_group, e.calories_per_hour
ORDER BY used_in_plans DESC, total_reps_across_plans DESC;


-- ============================================
-- QUERY 12: Payment Method Performance Analysis
-- USE CASE: Understand payment preferences and success rates
-- JOINS: Payments -> Users -> Subscriptions
-- AGGREGATION: Complex status calculations
-- ============================================
SELECT 
    p.payment_method,
    COUNT(p.payment_id) AS total_transactions,
    COUNT(DISTINCT p.user_id) AS unique_users,
    SUM(CASE WHEN p.status = 'Completed' THEN 1 ELSE 0 END) AS completed,
    SUM(CASE WHEN p.status = 'Failed' THEN 1 ELSE 0 END) AS failed,
    SUM(CASE WHEN p.status = 'Pending' THEN 1 ELSE 0 END) AS pending,
    SUM(CASE WHEN p.status = 'Refunded' THEN 1 ELSE 0 END) AS refunded,
    ROUND((SUM(CASE WHEN p.status = 'Completed' THEN 1 ELSE 0 END) * 100.0 / 
           COUNT(p.payment_id)), 2) AS success_rate_percent,
    SUM(CASE WHEN p.status = 'Completed' THEN p.amount ELSE 0 END) AS total_revenue,
    AVG(CASE WHEN p.status = 'Completed' THEN p.amount END) AS avg_transaction_value
FROM Payments p
GROUP BY p.payment_method
ORDER BY total_revenue DESC;


-- ============================================
-- QUERY 13: Device Sync Health Check
-- USE CASE: Monitor device connectivity and battery status
-- JOINS: Devices -> Users -> Progress_Tracking
-- ============================================
SELECT 
    d.device_id,
    d.device_name,
    d.model,
    u.full_name AS user_name,
    d.sync_date,
    d.battery_level,
    d.firmware_version,
    DATEDIFF(CURDATE(), d.sync_date) AS days_since_sync,
    COUNT(pt.progress_id) AS progress_entries,
    CASE 
        WHEN d.battery_level < 20 THEN 'Critical'
        WHEN d.battery_level < 50 THEN 'Low'
        ELSE 'Good'
    END AS battery_status,
    CASE 
        WHEN DATEDIFF(CURDATE(), d.sync_date) > 7 THEN 'Inactive'
        WHEN DATEDIFF(CURDATE(), d.sync_date) > 3 THEN 'Low Activity'
        ELSE 'Active'
    END AS sync_status
FROM Devices d
INNER JOIN Users u ON d.user_id = u.user_id
LEFT JOIN Progress_Tracking pt ON u.user_id = pt.user_id 
    AND pt.date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY d.device_id, d.device_name, d.model, u.full_name,
         d.sync_date, d.battery_level, d.firmware_version
ORDER BY days_since_sync DESC;


-- ============================================
-- QUERY 14: Comprehensive User Activity Report
-- USE CASE: Complete user activity overview for management
-- JOINS: All major tables joined through Users
-- ============================================
SELECT 
    u.user_id,
    u.full_name,
    u.email,
    u.age,
    u.goal,
    s.plan_name AS subscription,
    t.full_name AS assigned_trainer,
    COUNT(DISTINCT uc.class_id) AS classes_taken,
    COUNT(DISTINCT wp.plan_id) AS workout_plans,
    COUNT(DISTINCT g.goal_id) AS goals_set,
    SUM(CASE WHEN g.status = 'Completed' THEN 1 ELSE 0 END) AS goals_completed,
    COUNT(DISTINCT pt.progress_id) AS progress_logs,
    AVG(pt.calories_burned) AS avg_calories_burned,
    COUNT(DISTINCT f.feedback_id) AS feedback_given,
    AVG(f.rating) AS avg_feedback_rating,
    MAX(pt.date) AS last_activity_date
FROM Users u
LEFT JOIN Subscriptions s ON u.subscription_id = s.subscription_id
LEFT JOIN Trainers t ON u.trainer_id = t.trainer_id
LEFT JOIN User_Class uc ON u.user_id = uc.user_id
LEFT JOIN Workout_Plan wp ON u.user_id = wp.user_id
LEFT JOIN Goals g ON u.user_id = g.user_id
LEFT JOIN Progress_Tracking pt ON u.user_id = pt.user_id
LEFT JOIN Feedback f ON u.user_id = f.user_id
GROUP BY u.user_id, u.full_name, u.email, u.age, u.goal,
         s.plan_name, t.full_name
ORDER BY classes_taken DESC, progress_logs DESC;


-- ============================================
-- QUERY 15: Goal Achievement Analysis with Trainer Impact
-- USE CASE: Measure trainer effectiveness on goal completion
-- JOINS: Goals -> Users -> Trainers -> Workout_Plan
-- SUBQUERY: Calculate average completion rate
-- ============================================
SELECT 
    t.trainer_id,
    t.full_name AS trainer_name,
    t.specialization,
    COUNT(DISTINCT u.user_id) AS total_clients,
    COUNT(DISTINCT g.goal_id) AS total_goals,
    SUM(CASE WHEN g.status = 'Completed' THEN 1 ELSE 0 END) AS completed_goals,
    SUM(CASE WHEN g.status = 'Active' THEN 1 ELSE 0 END) AS active_goals,
    SUM(CASE WHEN g.status = 'Abandoned' THEN 1 ELSE 0 END) AS abandoned_goals,
    ROUND((SUM(CASE WHEN g.status = 'Completed' THEN 1 ELSE 0 END) * 100.0 / 
           NULLIF(COUNT(g.goal_id), 0)), 2) AS completion_rate_percent,
    AVG(t.rating) AS trainer_rating,
    (SELECT AVG(CASE WHEN g2.status = 'Completed' THEN 1 ELSE 0 END) * 100
     FROM Goals g2
     INNER JOIN Users u2 ON g2.user_id = u2.user_id
     WHERE u2.trainer_id IS NOT NULL) AS system_avg_completion_rate
FROM Trainers t
LEFT JOIN Users u ON t.trainer_id = u.trainer_id
LEFT JOIN Goals g ON u.user_id = g.user_id
GROUP BY t.trainer_id, t.full_name, t.specialization, t.rating
HAVING total_clients > 0
ORDER BY completion_rate_percent DESC, total_clients DESC;

-- ============================================
-- END OF QUERIES
-- ============================================