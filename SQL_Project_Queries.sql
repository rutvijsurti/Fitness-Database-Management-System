-- 1.	Simple Query 

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

-- 2.	Aggregate Query
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

-- 3.	Joins Query
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

-- 4.	Nested Query
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

-- 5.	Correlated Query
SELECT 
    u.user_id,
    u.full_name,
    t.full_name AS trainer_name,
    AVG(pt.calories_burned) AS user_avg_calories,
    (SELECT AVG(pt2.calories_burned)
     FROM Progress_Tracking pt2
     INNER JOIN Users u2 ON pt2.user_id = u2.user_id
     WHERE u2.trainer_id = u.trainer_id  -- Correlated: references outer query
     AND pt2.calories_burned IS NOT NULL) AS trainer_clients_avg_calories
FROM Users u
INNER JOIN Trainers t ON u.trainer_id = t.trainer_id
INNER JOIN Progress_Tracking pt ON u.user_id = pt.user_id
WHERE pt.calories_burned IS NOT NULL
GROUP BY u.user_id, u.full_name, t.full_name, u.trainer_id
HAVING AVG(pt.calories_burned) > 
    (SELECT AVG(pt3.calories_burned)
     FROM Progress_Tracking pt3
     INNER JOIN Users u3 ON pt3.user_id = u3.user_id
     WHERE u3.trainer_id = u.trainer_id  -- Correlated: references outer query
     AND pt3.calories_burned IS NOT NULL)
ORDER BY user_avg_calories DESC;


-- 6.	>= ALL Query

SELECT 
    s.subscription_id,
    s.plan_name,
    s.price,
    s.duration_months,
    s.description,
    COUNT(DISTINCT u.user_id) AS total_subscribers,
    SUM(CASE WHEN p.status = 'Completed' THEN p.amount ELSE 0 END) AS total_revenue
FROM Subscriptions s
LEFT JOIN Users u ON s.subscription_id = u.subscription_id
LEFT JOIN Payments p ON s.subscription_id = p.subscription_id
WHERE s.price >= ALL (SELECT price FROM Subscriptions)
GROUP BY s.subscription_id, s.plan_name, s.price, 
         s.duration_months, s.description;


-- 7.	> ANY Query

SELECT 
    t.trainer_id,
    t.full_name AS trainer_name,
    t.specialization,
    t.experience_years,
    t.rating,
    COUNT(DISTINCT u.user_id) AS total_clients
FROM Trainers t
LEFT JOIN Users u ON t.trainer_id = u.trainer_id
WHERE t.rating > ANY (
    SELECT t2.rating
    FROM Trainers t2
    WHERE t2.experience_years <= 2  -- Beginner trainers
)
GROUP BY t.trainer_id, t.full_name, t.specialization, 
         t.experience_years, t.rating
ORDER BY t.rating DESC;


-- 8.	EXISTS/NOT EXISTS Query

SELECT 
    t.trainer_id,
    t.full_name AS trainer_name,
    t.email,
    t.specialization,
    t.experience_years,
    t.rating,
    COUNT(DISTINCT u.user_id) AS total_clients,
    COUNT(DISTINCT cl.class_id) AS classes_taught
FROM Trainers t
LEFT JOIN Users u ON t.trainer_id = u.trainer_id
LEFT JOIN Classes cl ON t.trainer_id = cl.trainer_id
WHERE NOT EXISTS (
    SELECT 1
    FROM Feedback f
    WHERE f.trainer_id = t.trainer_id
)
GROUP BY t.trainer_id, t.full_name, t.email, t.specialization, 
         t.experience_years, t.rating
HAVING total_clients > 0  -- Only trainers with clients
ORDER BY total_clients DESC;


-- 9.	UNION Query

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


-- 10.	Subquery in FROM

SELECT 
    u.user_id,
    u.full_name,
    u.goal,
    goal_stats.goal_type,
    goal_stats.avg_calories AS goal_type_avg_calories,
    goal_stats.avg_workout_time AS goal_type_avg_workout_time,
    user_progress.user_avg_calories,
    user_progress.user_avg_workout_time,
    ROUND((user_progress.user_avg_calories / NULLIF(goal_stats.avg_calories, 0)) * 100, 2) 
        AS calories_performance_percent,
    CASE 
        WHEN user_progress.user_avg_calories > goal_stats.avg_calories THEN 'Above Average'
        WHEN user_progress.user_avg_calories = goal_stats.avg_calories THEN 'Average'
        ELSE 'Below Average'
    END AS performance_level
FROM Users u
-- Subquery in FROM: Calculate per-user averages
INNER JOIN (
    SELECT 
        pt.user_id,
        AVG(pt.calories_burned) AS user_avg_calories,
        AVG(pt.workout_time_min) AS user_avg_workout_time,
        COUNT(pt.progress_id) AS total_logs
    FROM Progress_Tracking pt
    GROUP BY pt.user_id
) AS user_progress ON u.user_id = user_progress.user_id
-- Subquery in FROM: Calculate goal-type averages
INNER JOIN (
    SELECT 
        g.goal_type,
        AVG(pt2.calories_burned) AS avg_calories,
        AVG(pt2.workout_time_min) AS avg_workout_time,
        COUNT(DISTINCT g.user_id) AS users_in_goal
    FROM Goals g
    INNER JOIN Progress_Tracking pt2 ON g.user_id = pt2.user_id
    GROUP BY g.goal_type
) AS goal_stats ON u.goal = goal_stats.goal_type
WHERE user_progress.total_logs >= 3  -- Users with meaningful data
ORDER BY calories_performance_percent DESC;
