"""
Fitness Management System - DML Data Generator
Generates 30 records per table with referential integrity
Outputs SQL file ready for MySQL execution
"""

import random
from datetime import datetime, timedelta

def random_date(start_year=2023, end_year=2025):
    """Generate random datetime"""
    start = datetime(start_year, 1, 1)
    end = datetime(end_year, 12, 31)
    delta = end - start
    random_days = random.randint(0, delta.days)
    return start + timedelta(days=random_days)

def random_email(name, domain="fitapp.com"):
    """Generate email from name"""
    clean_name = name.lower().replace(" ", ".")
    return f"{clean_name}@{domain}"

def generate_sql():
    sql_statements = []
    
    # ============================================
    # 1. SUBSCRIPTIONS (30 records)
    # ============================================
    sql_statements.append("-- ============================================")
    sql_statements.append("-- SUBSCRIPTIONS DATA (30 records)")
    sql_statements.append("-- ============================================")
    
    subscription_plans = [
        ("Basic Monthly", 1, 29.99, "Access to gym, Basic tracking"),
        ("Basic Quarterly", 3, 79.99, "Access to gym, Basic tracking, 10% discount"),
        ("Basic Annual", 12, 299.99, "Access to gym, Basic tracking, 20% discount"),
        ("Premium Monthly", 1, 49.99, "Gym access, Personal trainer, Advanced tracking"),
        ("Premium Quarterly", 3, 134.99, "Gym access, Personal trainer, Advanced tracking, 10% discount"),
        ("Premium Annual", 12, 499.99, "Gym access, Personal trainer, Advanced tracking, 20% discount"),
        ("Elite Monthly", 1, 99.99, "All features, Unlimited classes, Nutrition plans"),
        ("Elite Quarterly", 3, 269.99, "All features, Unlimited classes, Nutrition plans, 10% discount"),
        ("Elite Annual", 12, 999.99, "All features, Unlimited classes, Nutrition plans, 20% discount"),
        ("Student Monthly", 1, 19.99, "Basic access for students"),
    ]
    
    # Extend to 30 by adding variations
    for i in range(30):
        if i < len(subscription_plans):
            plan = subscription_plans[i]
        else:
            # Create variations
            plan = (
                f"Custom Plan {i+1}",
                random.choice([1, 3, 6, 12]),
                round(random.uniform(19.99, 149.99), 2),
                f"Custom features package {i+1}"
            )
        
        sql_statements.append(
            f"INSERT INTO Subscriptions (plan_name, duration_months, price, features) VALUES "
            f"('{plan[0]}', {plan[1]}, {plan[2]}, '{plan[3]}');"
        )
    
    # ============================================
    # 2. TRAINERS (30 records - without certification_id initially)
    # ============================================
    sql_statements.append("\n-- ============================================")
    sql_statements.append("-- TRAINERS DATA (30 records)")
    sql_statements.append("-- ============================================")
    
    trainer_names = [
        "Mike Johnson", "Sarah Williams", "David Brown", "Emma Davis",
        "James Miller", "Olivia Wilson", "Robert Moore", "Sophia Taylor",
        "Michael Anderson", "Isabella Thomas", "William Jackson", "Mia White",
        "Daniel Harris", "Charlotte Martin", "Matthew Thompson", "Amelia Garcia",
        "Joseph Martinez", "Harper Robinson", "Christopher Clark", "Evelyn Rodriguez",
        "Andrew Lewis", "Abigail Lee", "Joshua Walker", "Emily Hall",
        "Ryan Allen", "Elizabeth Young", "Nicholas Hernandez", "Sofia King",
        "Alexander Wright", "Avery Lopez"
    ]
    
    specializations = [
        "Strength Training", "Yoga", "Cardio", "CrossFit", "Pilates",
        "HIIT", "Boxing", "Weight Loss", "Bodybuilding", "Functional Training"
    ]
    
    for i, name in enumerate(trainer_names):
        sql_statements.append(
            f"INSERT INTO Trainers (full_name, email, password, specialization, experience_years, rating) VALUES "
            f"('{name}', '{random_email(name, 'trainers.fit')}', "
            f"'$2y$10${''.join(random.choices('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', k=50))}', "
            f"'{random.choice(specializations)}', "
            f"{round(random.uniform(1.0, 20.0), 1)}, "
            f"{round(random.uniform(3.5, 5.0), 2)});"
        )
    
    # ============================================
    # 3. CERTIFICATIONS (30 records)
    # ============================================
    sql_statements.append("\n-- ============================================")
    sql_statements.append("-- CERTIFICATIONS DATA (30 records)")
    sql_statements.append("-- ============================================")
    
    cert_names = [
        "Certified Personal Trainer", "Certified Strength Coach", "Yoga Instructor Certification",
        "CrossFit Level 1", "Pilates Instructor", "NASM CPT", "ACE Personal Trainer",
        "ISSA Fitness Trainer", "Nutrition Specialist", "Sports Nutrition Certificate"
    ]
    
    cert_issuers = [
        "NASM", "ACE", "ISSA", "ACSM", "CrossFit Inc", "Yoga Alliance",
        "NSCA", "AFAA", "Cooper Institute", "NCSF"
    ]
    
    for i in range(30):
        trainer_id = (i % 30) + 1
        issue_date = random_date(2020, 2024)
        expiry_date = issue_date + timedelta(days=365*3)  # 3 years validity
        
        sql_statements.append(
            f"INSERT INTO Certifications (trainer_id, certification_name, issued_by, issue_date, expiry_date) VALUES "
            f"({trainer_id}, '{random.choice(cert_names)}', '{random.choice(cert_issuers)}', "
            f"'{issue_date.strftime('%Y-%m-%d %H:%M:%S')}', '{expiry_date.strftime('%Y-%m-%d %H:%M:%S')}');"
        )
    
    # ============================================
    # Update Trainers with certification_id
    # ============================================
    sql_statements.append("\n-- ============================================")
    sql_statements.append("-- UPDATE TRAINERS with certification_id")
    sql_statements.append("-- ============================================")
    
    for i in range(1, 31):
        # 80% of trainers have certification
        if random.random() < 0.8:
            cert_id = i
            sql_statements.append(f"UPDATE Trainers SET certification_id = {cert_id} WHERE trainer_id = {i};")
    
    # ============================================
    # 4. USERS (30 records)
    # ============================================
    sql_statements.append("\n-- ============================================")
    sql_statements.append("-- USERS DATA (30 records)")
    sql_statements.append("-- ============================================")
    
    user_names = [
        "John Smith", "Alice Johnson", "Bob Williams", "Carol Brown",
        "David Jones", "Eve Garcia", "Frank Miller", "Grace Davis",
        "Henry Rodriguez", "Ivy Martinez", "Jack Hernandez", "Kelly Lopez",
        "Leo Gonzalez", "Megan Wilson", "Nathan Anderson", "Olivia Thomas",
        "Peter Taylor", "Quinn Moore", "Rachel Jackson", "Steve Martin",
        "Tina Lee", "Uma Perez", "Victor Thompson", "Wendy White",
        "Xavier Harris", "Yara Sanchez", "Zack Clark", "Amy Ramirez",
        "Brian Lewis", "Chloe Robinson"
    ]
    
    genders = ["Male", "Female", "Non-binary", "Prefer not to say"]
    goals = ["Weight Loss", "Muscle Gain", "General Fitness", "Endurance", "Flexibility"]
    
    for i, name in enumerate(user_names):
        # 70% have subscriptions
        subscription_id = random.randint(1, 30) if random.random() < 0.7 else "NULL"
        # 50% have trainers
        trainer_id = random.randint(1, 30) if random.random() < 0.5 else "NULL"
        
        sql_statements.append(
            f"INSERT INTO Users (full_name, email, password, gender, age, height, weight, goal, subscription_id, trainer_id) VALUES "
            f"('{name}', '{random_email(name, 'users.fit')}', "
            f"'$2y$10${''.join(random.choices('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', k=50))}', "
            f"'{random.choice(genders)}', {random.randint(18, 65)}, "
            f"{round(random.uniform(150.0, 200.0), 2)}, {round(random.uniform(50.0, 120.0), 2)}, "
            f"'{random.choice(goals)}', {subscription_id}, {trainer_id});"
        )
    
    # ============================================
    # 5. CLASSES (30 records)
    # ============================================
    sql_statements.append("\n-- ============================================")
    sql_statements.append("-- CLASSES DATA (30 records)")
    sql_statements.append("-- ============================================")
    
    class_names = [
        "Morning Yoga", "HIIT Blast", "Spin Class", "Zumba Dance",
        "CrossFit WOD", "Pilates Core", "Boxing Bootcamp", "Strength Training",
        "Cardio Kickboxing", "Power Yoga"
    ]
    
    categories = ["Cardio", "Strength", "Flexibility", "Dance", "Martial Arts"]
    modes = ["In-Person", "Virtual", "Hybrid"]
    
    for i in range(30):
        trainer_id = random.randint(1, 30)
        schedule_date = random_date(2025, 2025) + timedelta(days=random.randint(1, 90))
        
        sql_statements.append(
            f"INSERT INTO Classes (trainer_id, class_name, category, mode, schedule_date, duration_minutes, max_participants) VALUES "
            f"({trainer_id}, '{random.choice(class_names)} {i+1}', '{random.choice(categories)}', "
            f"'{random.choice(modes)}', '{schedule_date.strftime('%Y-%m-%d %H:%M:%S')}', "
            f"{random.choice([30, 45, 60, 90])}, {random.randint(10, 50)});"
        )
    
    # ============================================
    # 6. USER_CLASS (30 records)
    # ============================================
    sql_statements.append("\n-- ============================================")
    sql_statements.append("-- USER_CLASS DATA (30 records)")
    sql_statements.append("-- ============================================")
    
    attendance_statuses = ["Enrolled", "Attended", "Missed", "Cancelled"]
    used_combinations = set()
    
    for i in range(30):
        # Ensure unique user_id, class_id combinations
        while True:
            user_id = random.randint(1, 30)
            class_id = random.randint(1, 30)
            if (user_id, class_id) not in used_combinations:
                used_combinations.add((user_id, class_id))
                break
        
        enrollment_date = random_date(2024, 2025)
        
        sql_statements.append(
            f"INSERT INTO User_Class (user_id, class_id, enrollment_date, attendance_status) VALUES "
            f"({user_id}, {class_id}, '{enrollment_date.strftime('%Y-%m-%d %H:%M:%S')}', '{random.choice(attendance_statuses)}');"
        )
    
    # ============================================
    # 7. PAYMENTS (30 records)
    # ============================================
    sql_statements.append("\n-- ============================================")
    sql_statements.append("-- PAYMENTS DATA (30 records)")
    sql_statements.append("-- ============================================")
    
    payment_methods = ["Credit Card", "Debit Card", "PayPal", "Bank Transfer", "Apple Pay", "Google Pay"]
    payment_statuses = ["Completed", "Pending", "Failed", "Refunded"]
    
    for i in range(30):
        user_id = (i % 30) + 1
        subscription_id = random.randint(1, 30) if random.random() < 0.8 else "NULL"
        payment_date = random_date(2024, 2025)
        
        sql_statements.append(
            f"INSERT INTO Payments (user_id, subscription_id, payment_date, amount, payment_method, status) VALUES "
            f"({user_id}, {subscription_id}, '{payment_date.strftime('%Y-%m-%d %H:%M:%S')}', "
            f"{round(random.uniform(19.99, 999.99), 2)}, '{random.choice(payment_methods)}', '{random.choice(payment_statuses)}');"
        )
    
    # ============================================
    # 8. PROGRESS_TRACKING (30 records)
    # ============================================
    sql_statements.append("\n-- ============================================")
    sql_statements.append("-- PROGRESS_TRACKING DATA (30 records)")
    sql_statements.append("-- ============================================")
    
    for i in range(30):
        user_id = (i % 30) + 1
        date = random_date(2024, 2025)
        weight = round(random.uniform(50.0, 120.0), 2)
        height = round(random.uniform(150.0, 200.0), 2)
        bmi = round(weight / ((height/100) ** 2), 2)
        
        sql_statements.append(
            f"INSERT INTO Progress_Tracking (user_id, date, calories_burned, steps, workout_time_min, weight, bmi) VALUES "
            f"({user_id}, '{date.strftime('%Y-%m-%d %H:%M:%S')}', "
            f"{random.randint(100, 1000)}, {random.randint(1000, 20000)}, "
            f"{random.randint(15, 120)}, {weight}, {bmi});"
        )
    
    # ============================================
    # 9. GOALS (30 records)
    # ============================================
    sql_statements.append("\n-- ============================================")
    sql_statements.append("-- GOALS DATA (30 records)")
    sql_statements.append("-- ============================================")
    
    goal_types = ["Weight Loss", "Weight Gain", "Muscle Building", "Fat Loss", "Endurance", "Flexibility"]
    goal_statuses = ["Active", "Completed", "Abandoned", "On Hold"]
    
    for i in range(30):
        user_id = (i % 30) + 1
        start_date = random_date(2024, 2025)
        end_date = start_date + timedelta(days=random.randint(30, 180))
        
        sql_statements.append(
            f"INSERT INTO Goals (user_id, goal_type, target_weight, start_date, end_date, status) VALUES "
            f"({user_id}, '{random.choice(goal_types)}', {round(random.uniform(50.0, 100.0), 2)}, "
            f"'{start_date.strftime('%Y-%m-%d %H:%M:%S')}', '{end_date.strftime('%Y-%m-%d %H:%M:%S')}', "
            f"'{random.choice(goal_statuses)}');"
        )
    
    # ============================================
    # 10. WORKOUT_PLAN (30 records)
    # ============================================
    sql_statements.append("\n-- ============================================")
    sql_statements.append("-- WORKOUT_PLAN DATA (30 records)")
    sql_statements.append("-- ============================================")
    
    plan_names = [
        "Beginner's Start", "Fat Burn Challenge", "Muscle Builder Pro",
        "Cardio Blast", "Strength Foundation", "HIIT Master", "Endurance Builder",
        "Core Crusher", "Full Body Transformation", "Athletic Performance"
    ]
    
    for i in range(30):
        user_id = (i % 30) + 1
        trainer_id = random.randint(1, 30) if random.random() < 0.6 else "NULL"
        goal_id = (i % 30) + 1 if random.random() < 0.7 else "NULL"
        start_date = random_date(2024, 2025)
        end_date = start_date + timedelta(days=random.randint(30, 180))
        
        sql_statements.append(
            f"INSERT INTO Workout_Plan (user_id, trainer_id, goal_id, plan_name, plan_description, start_date, end_date) VALUES "
            f"({user_id}, {trainer_id}, {goal_id}, '{random.choice(plan_names)} {i+1}', "
            f"'Customized workout plan focusing on specific fitness goals and progress tracking', "
            f"'{start_date.strftime('%Y-%m-%d %H:%M:%S')}', '{end_date.strftime('%Y-%m-%d %H:%M:%S')}');"
        )
    
    # ============================================
    # 11. EXERCISES (30 records)
    # ============================================
    sql_statements.append("\n-- ============================================")
    sql_statements.append("-- EXERCISES DATA (30 records)")
    sql_statements.append("-- ============================================")
    
    exercises = [
        ("Push-ups", "Strength", "Beginner", 300, "Chest"),
        ("Squats", "Strength", "Beginner", 400, "Legs"),
        ("Running", "Cardio", "Intermediate", 600, "Full Body"),
        ("Bench Press", "Strength", "Intermediate", 350, "Chest"),
        ("Deadlift", "Strength", "Advanced", 450, "Back"),
        ("Pull-ups", "Strength", "Intermediate", 400, "Back"),
        ("Lunges", "Strength", "Beginner", 350, "Legs"),
        ("Plank", "Core", "Beginner", 200, "Core"),
        ("Burpees", "Cardio", "Advanced", 800, "Full Body"),
        ("Mountain Climbers", "Cardio", "Intermediate", 700, "Full Body"),
        ("Bicep Curls", "Strength", "Beginner", 250, "Arms"),
        ("Tricep Dips", "Strength", "Intermediate", 300, "Arms"),
        ("Shoulder Press", "Strength", "Intermediate", 350, "Shoulders"),
        ("Leg Press", "Strength", "Intermediate", 400, "Legs"),
        ("Rowing", "Cardio", "Intermediate", 550, "Back"),
        ("Box Jumps", "Plyometric", "Advanced", 650, "Legs"),
        ("Kettlebell Swings", "Strength", "Intermediate", 500, "Full Body"),
        ("Battle Ropes", "Cardio", "Advanced", 700, "Arms"),
        ("Jumping Jacks", "Cardio", "Beginner", 450, "Full Body"),
        ("Sit-ups", "Core", "Beginner", 250, "Core"),
        ("Russian Twists", "Core", "Intermediate", 300, "Core"),
        ("Leg Raises", "Core", "Intermediate", 280, "Core"),
        ("Cycling", "Cardio", "Beginner", 500, "Legs"),
        ("Swimming", "Cardio", "Intermediate", 600, "Full Body"),
        ("Yoga Sun Salutation", "Flexibility", "Beginner", 200, "Full Body"),
        ("Pilates Roll-up", "Core", "Intermediate", 250, "Core"),
        ("Dumbbell Rows", "Strength", "Intermediate", 350, "Back"),
        ("Calf Raises", "Strength", "Beginner", 200, "Legs"),
        ("Side Plank", "Core", "Intermediate", 220, "Core"),
        ("Wall Sits", "Strength", "Beginner", 300, "Legs")
    ]
    
    for i, exercise in enumerate(exercises):
        sql_statements.append(
            f"INSERT INTO Exercises (name, type, difficulty_level, calories_per_hour, muscle_group) VALUES "
            f"('{exercise[0]}', '{exercise[1]}', '{exercise[2]}', {exercise[3]}, '{exercise[4]}');"
        )
    
    # ============================================
    # 12. WORKOUT_EXERCISES (30 records)
    # ============================================
    sql_statements.append("\n-- ============================================")
    sql_statements.append("-- WORKOUT_EXERCISES DATA (30 records)")
    sql_statements.append("-- ============================================")
    
    used_combinations_we = set()
    
    for i in range(30):
        # Ensure unique plan_id, exercise_id combinations
        while True:
            plan_id = random.randint(1, 30)
            exercise_id = random.randint(1, 30)
            if (plan_id, exercise_id) not in used_combinations_we:
                used_combinations_we.add((plan_id, exercise_id))
                break
        
        sql_statements.append(
            f"INSERT INTO Workout_Exercises (plan_id, exercise_id, sets, reps, duration_min) VALUES "
            f"({plan_id}, {exercise_id}, {random.randint(2, 5)}, "
            f"{random.randint(8, 20)}, {random.randint(10, 60)});"
        )
    
    # ============================================
    # 13. FEEDBACK (30 records)
    # ============================================
    sql_statements.append("\n-- ============================================")
    sql_statements.append("-- FEEDBACK DATA (30 records)")
    sql_statements.append("-- ============================================")
    
    feedback_comments = [
        "Excellent trainer, very knowledgeable!",
        "Great class, highly recommend!",
        "Could be better organized.",
        "Amazing workout session!",
        "Very professional and motivating.",
        "The class was too crowded.",
        "Perfect for beginners!",
        "Challenging but rewarding.",
        "Trainer needs to be more attentive.",
        "Best fitness class I've attended!"
    ]
    
    for i in range(30):
        user_id = (i % 30) + 1
        trainer_id = random.randint(1, 30) if random.random() < 0.7 else "NULL"
        class_id = random.randint(1, 30) if random.random() < 0.6 else "NULL"
        date = random_date(2024, 2025)
        
        sql_statements.append(
            f"INSERT INTO Feedback (user_id, trainer_id, class_id, rating, comments, date) VALUES "
            f"({user_id}, {trainer_id}, {class_id}, {round(random.uniform(3.0, 5.0), 2)}, "
            f"'{random.choice(feedback_comments)}', '{date.strftime('%Y-%m-%d %H:%M:%S')}');"
        )
    
    # ============================================
    # 14. DEVICES (30 records)
    # ============================================
    sql_statements.append("\n-- ============================================")
    sql_statements.append("-- DEVICES DATA (30 records)")
    sql_statements.append("-- ============================================")
    
    device_names = ["Fitbit", "Apple Watch", "Garmin", "Samsung Galaxy Watch", "Xiaomi Mi Band"]
    models = ["Series 8", "Charge 5", "Venu 2", "Active 2", "Band 7", "Ultra", "Forerunner 945"]
    
    for i in range(30):
        user_id = (i % 30) + 1
        sync_date = random_date(2024, 2025)
        
        sql_statements.append(
            f"INSERT INTO Devices (user_id, device_name, model, sync_date, battery_level, firmware_version) VALUES "
            f"({user_id}, '{random.choice(device_names)}', '{random.choice(models)}', "
            f"'{sync_date.strftime('%Y-%m-%d %H:%M:%S')}', {random.randint(10, 100)}, "
            f"'{random.randint(1, 5)}.{random.randint(0, 9)}.{random.randint(0, 9)}');"
        )
    
    return sql_statements

# ============================================
# MAIN EXECUTION
# ============================================
if __name__ == "__main__":
    print("Generating DML statements...")
    sql_statements = generate_sql()
    
    # Write to file
    output_file = "fitness_dml_insert.sql"
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("-- ============================================\n")
        f.write("-- FITNESS MANAGEMENT SYSTEM - DML (MySQL)\n")
        f.write("-- Generated Insert Statements\n")
        f.write("-- 30 Records per table\n")
        f.write("-- ============================================\n\n")
        f.write("SET FOREIGN_KEY_CHECKS = 0;\n\n")
        
        for statement in sql_statements:
            f.write(statement + "\n")
        
        f.write("\nSET FOREIGN_KEY_CHECKS = 1;\n")
        f.write("\n-- ============================================\n")
        f.write("-- END OF DML\n")
        f.write("-- ============================================\n")
    
    print(f"✅ Successfully generated {len(sql_statements)} SQL statements!")
    print(f"✅ Output file: {output_file}")
    print(f"\nTo execute in MySQL:")
    print(f"1. Run the DDL file first: mysql -u your_user -p your_database < fitness_ddl.sql")
    print(f"2. Run this DML file: mysql -u your_user -p your_database < {output_file}")