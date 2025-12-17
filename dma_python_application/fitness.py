"""
LEVEL UP - Fitness Tracking Platform
Python Application for Database Analytics
Group 14: Rutvij Surti & Kush Patel
"""

import pandas as pd
import mysql.connector
from mysql.connector import Error
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np

# Set style for better visualizations
plt.style.use('seaborn-v0_8-darkgrid')
sns.set_palette("husl")

# Database connection function
def create_connection():
    """Connect to MySQL database"""
    try:
        connection = mysql.connector.connect(
            host='localhost',
            database='fitness',
            user='root',
            password='kushp9819',
            auth_plugin='mysql_native_password'
        )
        
        if connection.is_connected():
            cursor = connection.cursor()
            cursor.execute("select database();")
            record = cursor.fetchone()
            print("✓ Connected to database:", record[0])
            print()
            return connection
            
    except Error as e:
        print("✗ Error connecting to MySQL:", e)
        return None


# QUERY 1: Subscription Revenue Analysis
def query1_subscription_revenue(connection):
    print("=" * 75)
    print("QUERY 1: SUBSCRIPTION REVENUE ANALYSIS")
    print("=" * 75)
    
    sql_query = """
    SELECT 
        s.subscription_id,
        s.plan_name,
        s.price AS plan_price,
        COUNT(DISTINCT p.user_id) AS total_subscribers,
        SUM(CASE WHEN p.status = 'Completed' THEN p.amount ELSE 0 END) AS total_revenue
    FROM Subscriptions s
    LEFT JOIN Payments p ON s.subscription_id = p.subscription_id
    GROUP BY s.subscription_id, s.plan_name, s.price
    HAVING total_revenue > 0
    ORDER BY total_revenue DESC
    LIMIT 10;
    """
    
    df = pd.read_sql_query(sql_query, connection)
    print(df)
    print()
    
    # Statistics
    print(" Summary Statistics:")
    print(f"   Total Revenue: ${df['total_revenue'].sum():,.2f}")
    print(f"   Average Revenue per Plan: ${df['total_revenue'].mean():,.2f}")
    print(f"   Total Subscribers: {df['total_subscribers'].sum()}")
    print(f"   Most Popular Plan: {df.iloc[0]['plan_name']}")
    print()
    
    # Create figure with two subplots
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6))
    
    # Plot 1: Gradient Bar Chart
    colors = plt.cm.viridis(np.linspace(0.3, 0.9, len(df)))
    bars = ax1.bar(range(len(df)), df['total_revenue'], color=colors, edgecolor='black', linewidth=1.2)
    ax1.set_xlabel('Subscription Plans', fontsize=12, fontweight='bold')
    ax1.set_ylabel('Total Revenue ($)', fontsize=12, fontweight='bold')
    ax1.set_title('Revenue by Subscription Plan', fontsize=14, fontweight='bold', pad=15)
    ax1.set_xticks(range(len(df)))
    ax1.set_xticklabels(df['plan_name'], rotation=45, ha='right')
    ax1.grid(axis='y', alpha=0.3, linestyle='--')
    
    # Add value labels on bars
    for i, bar in enumerate(bars):
        height = bar.get_height()
        ax1.text(bar.get_x() + bar.get_width()/2., height,
                f'${height:,.0f}',
                ha='center', va='bottom', fontsize=9, fontweight='bold')
    
    # Plot 2: Pie Chart with custom colors
    colors_pie = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#FFA07A', '#98D8C8']
    explode = [0.05 if i == 0 else 0 for i in range(len(df.head(5)))]
    
    ax2.pie(df['total_revenue'].head(5), labels=df['plan_name'].head(5), 
            autopct='%1.1f%%', startangle=90, colors=colors_pie,
            explode=explode, shadow=True, textprops={'fontsize': 10, 'fontweight': 'bold'})
    ax2.set_title('Revenue Distribution - Top 5 Plans', fontsize=14, fontweight='bold', pad=15)
    
    plt.tight_layout()
    plt.savefig('query1_revenue_analysis.png', dpi=300, bbox_inches='tight')
    print("✓ Saved: query1_revenue_analysis.png\n")
    plt.close()


# QUERY 2: Trainer Performance Analysis
def query2_trainer_performance(connection):
    print("=" * 75)
    print("QUERY 2: TRAINER PERFORMANCE ANALYSIS")
    print("=" * 75)
    
    sql_query = """
    SELECT 
        t.trainer_id,
        t.full_name AS trainer_name,
        t.specialization,
        t.rating AS overall_rating,
        COUNT(DISTINCT cl.class_id) AS total_classes,
        COUNT(DISTINCT f.feedback_id) AS feedback_count,
        AVG(f.rating) AS avg_feedback_rating
    FROM Trainers t
    LEFT JOIN Classes cl ON t.trainer_id = cl.trainer_id
    LEFT JOIN Feedback f ON t.trainer_id = f.trainer_id
    GROUP BY t.trainer_id, t.full_name, t.specialization, t.rating
    HAVING total_classes > 0
    ORDER BY avg_feedback_rating DESC
    LIMIT 12;
    """
    
    df = pd.read_sql_query(sql_query, connection)
    print(df)
    print()
    
    # Statistics
    print(" Summary Statistics:")
    print(f"   Total Trainers: {len(df)}")
    print(f"   Average Classes per Trainer: {df['total_classes'].mean():.1f}")
    print(f"   Average Feedback Rating: {df['avg_feedback_rating'].mean():.2f}/5.0")
    print(f"   Top Trainer: {df.iloc[0]['trainer_name']} ({df.iloc[0]['avg_feedback_rating']:.2f})")
    print()
    
    # Create figure with two subplots
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6))
    
    # Plot 1: Horizontal Bar Chart with gradient
    colors = plt.cm.RdYlGn(np.linspace(0.3, 0.9, len(df)))
    y_pos = np.arange(len(df))
    ax1.barh(y_pos, df['total_classes'], color=colors, edgecolor='black', linewidth=1)
    ax1.set_yticks(y_pos)
    ax1.set_yticklabels(df['trainer_name'], fontsize=10)
    ax1.set_xlabel('Total Classes Taught', fontsize=12, fontweight='bold')
    ax1.set_title('Classes Taught by Each Trainer', fontsize=14, fontweight='bold', pad=15)
    ax1.grid(axis='x', alpha=0.3, linestyle='--')
    
    # Plot 2: Box Plot for Ratings Distribution
    ratings_data = [df['overall_rating'], df['avg_feedback_rating']]
    bp = ax2.boxplot(ratings_data, labels=['Overall Rating', 'Feedback Rating'],
                     patch_artist=True, notch=True, showmeans=True)
    
    # Color the box plots
    colors_box = ['#FF6B6B', '#4ECDC4']
    for patch, color in zip(bp['boxes'], colors_box):
        patch.set_facecolor(color)
        patch.set_alpha(0.7)
    
    ax2.set_ylabel('Rating (out of 5)', fontsize=12, fontweight='bold')
    ax2.set_title('Trainer Ratings Distribution', fontsize=14, fontweight='bold', pad=15)
    ax2.grid(axis='y', alpha=0.3, linestyle='--')
    
    plt.tight_layout()
    plt.savefig('query2_trainer_performance.png', dpi=300, bbox_inches='tight')
    print("✓ Saved: query2_trainer_performance.png\n")
    plt.close()


# QUERY 3: Class Attendance Analysis
def query3_class_attendance(connection):
    print("=" * 75)
    print("QUERY 3: CLASS ATTENDANCE ANALYSIS")
    print("=" * 75)
    
    sql_query = """
    SELECT 
        cl.class_id,
        cl.class_name,
        cl.category,
        COUNT(uc.user_id) AS enrolled_count,
        SUM(CASE WHEN uc.attendance_status = 'Attended' THEN 1 ELSE 0 END) AS attended_count,
        SUM(CASE WHEN uc.attendance_status = 'Missed' THEN 1 ELSE 0 END) AS missed_count,
        ROUND((SUM(CASE WHEN uc.attendance_status = 'Attended' THEN 1 ELSE 0 END) * 100.0 / 
               NULLIF(COUNT(uc.user_id), 0)), 2) AS attendance_rate
    FROM Classes cl
    LEFT JOIN User_Class uc ON cl.class_id = uc.class_id
    GROUP BY cl.class_id, cl.class_name, cl.category
    HAVING enrolled_count > 0
    ORDER BY enrolled_count DESC
    LIMIT 12;
    """
    
    df = pd.read_sql_query(sql_query, connection)
    print(df)
    print()
    
    # Statistics
    print(" Summary Statistics:")
    print(f"   Total Classes: {len(df)}")
    print(f"   Average Enrollment: {df['enrolled_count'].mean():.1f} students/class")
    print(f"   Average Attendance Rate: {df['attendance_rate'].mean():.1f}%")
    print(f"   Total Attended: {df['attended_count'].sum()}")
    print(f"   Total Missed: {df['missed_count'].sum()}")
    print()
    
    # Create figure with two subplots
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6))
    
    # Plot 1: Grouped Bar Chart
    x = np.arange(len(df))
    width = 0.35
    
    bars1 = ax1.bar(x - width/2, df['attended_count'], width, 
                    label='Attended', color='#2ECC71', edgecolor='black', linewidth=1)
    bars2 = ax1.bar(x + width/2, df['missed_count'], width,
                    label='Missed', color='#E74C3C', edgecolor='black', linewidth=1)
    
    ax1.set_xlabel('Class Name', fontsize=12, fontweight='bold')
    ax1.set_ylabel('Number of Students', fontsize=12, fontweight='bold')
    ax1.set_title('Class Attendance: Attended vs Missed', fontsize=14, fontweight='bold', pad=15)
    ax1.set_xticks(x)
    ax1.set_xticklabels(df['class_name'], rotation=45, ha='right')
    ax1.legend(fontsize=11, loc='upper right')
    ax1.grid(axis='y', alpha=0.3, linestyle='--')
    
    # Plot 2: Line Chart for Attendance Rate
    ax2.plot(range(len(df)), df['attendance_rate'], marker='o', 
            color='#3498DB', linewidth=2.5, markersize=8, markerfacecolor='#E74C3C')
    ax2.axhline(y=50, color='orange', linestyle='--', linewidth=2, label='50% Threshold')
    ax2.fill_between(range(len(df)), df['attendance_rate'], alpha=0.3, color='#3498DB')
    ax2.set_xlabel('Class Index', fontsize=12, fontweight='bold')
    ax2.set_ylabel('Attendance Rate (%)', fontsize=12, fontweight='bold')
    ax2.set_title('Attendance Rate by Class', fontsize=14, fontweight='bold', pad=15)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3, linestyle='--')
    
    plt.tight_layout()
    plt.savefig('query3_class_attendance.png', dpi=300, bbox_inches='tight')
    print("✓ Saved: query3_class_attendance.png\n")
    plt.close()


# QUERY 4: User Progress Tracking
def query4_user_progress(connection):
    print("=" * 75)
    print("QUERY 4: USER PROGRESS TRACKING")
    print("=" * 75)
    
    sql_query = """
    SELECT 
        u.user_id,
        u.full_name,
        pt.date AS tracking_date,
        pt.weight,
        pt.bmi,
        pt.calories_burned,
        pt.steps
    FROM Users u
    INNER JOIN Progress_Tracking pt ON u.user_id = pt.user_id
    WHERE u.user_id IN (1, 2, 5, 10, 15, 20, 25)
    ORDER BY u.user_id, pt.date;
    """
    
    df = pd.read_sql_query(sql_query, connection)
    df['tracking_date'] = pd.to_datetime(df['tracking_date'])
    print(df)
    print()
    
    # Statistics
    print("📊 Summary Statistics:")
    print(f"   Users Tracked: {df['user_id'].nunique()}")
    print(f"   Average Weight: {df['weight'].mean():.2f} kg")
    print(f"   Average BMI: {df['bmi'].mean():.2f}")
    print(f"   Average Calories: {df['calories_burned'].mean():.0f} cal")
    print(f"   Average Steps: {df['steps'].mean():.0f}")
    print()
    
    # Create figure with two subplots
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6))
    
    # Plot 1: Line Chart for Weight Progress
    colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#FFA07A', '#98D8C8', '#DDA15E', '#BC6C25']
    for i, user_id in enumerate(df['user_id'].unique()):
        user_data = df[df['user_id'] == user_id]
        ax1.plot(user_data['tracking_date'], user_data['weight'], 
                marker='o', label=user_data['full_name'].iloc[0],
                linewidth=2, markersize=6, color=colors[i % len(colors)])
    
    ax1.set_xlabel('Date', fontsize=12, fontweight='bold')
    ax1.set_ylabel('Weight (kg)', fontsize=12, fontweight='bold')
    ax1.set_title('Weight Progress Over Time', fontsize=14, fontweight='bold', pad=15)
    ax1.legend(fontsize=9, loc='best')
    ax1.grid(True, alpha=0.3, linestyle='--')
    plt.setp(ax1.xaxis.get_majorticklabels(), rotation=45, ha='right')
    
    # Plot 2: Histogram for Calories Distribution
    ax2.hist(df['calories_burned'], bins=15, color='#FF6B6B', 
            edgecolor='black', linewidth=1.2, alpha=0.7)
    ax2.axvline(df['calories_burned'].mean(), color='blue', 
               linestyle='--', linewidth=2, label=f"Mean: {df['calories_burned'].mean():.0f}")
    ax2.set_xlabel('Calories Burned', fontsize=12, fontweight='bold')
    ax2.set_ylabel('Frequency', fontsize=12, fontweight='bold')
    ax2.set_title('Distribution of Calories Burned', fontsize=14, fontweight='bold', pad=15)
    ax2.legend(fontsize=11)
    ax2.grid(axis='y', alpha=0.3, linestyle='--')
    
    plt.tight_layout()
    plt.savefig('query4_user_progress.png', dpi=300, bbox_inches='tight')
    print("✓ Saved: query4_user_progress.png\n")
    plt.close()


# QUERY 5: Goal Achievement Analysis
def query5_goal_achievement(connection):
    print("=" * 75)
    print("QUERY 5: GOAL ACHIEVEMENT ANALYSIS")
    print("=" * 75)
    
    sql_query = """
    SELECT 
        goal_type,
        status,
        COUNT(*) as goal_count
    FROM Goals
    GROUP BY goal_type, status
    ORDER BY goal_type, status;
    """
    
    df = pd.read_sql_query(sql_query, connection)
    print(df)
    print()
    
    # Statistics
    total_goals = df['goal_count'].sum()
    status_summary = df.groupby('status')['goal_count'].sum()
    
    print(" Summary Statistics:")
    print(f"   Total Goals: {total_goals}")
    print("   Goals by Status:")
    for status, count in status_summary.items():
        print(f"      {status}: {count} ({count/total_goals*100:.1f}%)")
    print()
    
    # Create figure with two subplots
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6))
    
    # Plot 1: Pie Chart with custom colors
    colors_status = ['#2ECC71', '#E74C3C', '#F39C12', '#3498DB']
    explode = [0.05 if i == status_summary.idxmax() else 0 for i in range(len(status_summary))]
    
    wedges, texts, autotexts = ax1.pie(status_summary.values, labels=status_summary.index, 
            autopct='%1.1f%%', startangle=90, colors=colors_status,
            explode=explode, shadow=True,
            textprops={'fontsize': 11, 'fontweight': 'bold'})
    
    for autotext in autotexts:
        autotext.set_color('white')
        autotext.set_fontsize(11)
    
    ax1.set_title('Goal Status Distribution', fontsize=14, fontweight='bold', pad=15)
    
    # Plot 2: Stacked Bar Chart by Goal Type
    pivot_df = df.pivot(index='goal_type', columns='status', values='goal_count').fillna(0)
    pivot_df.plot(kind='bar', stacked=True, ax=ax2, 
                 color=['#E74C3C', '#3498DB', '#F39C12', '#2ECC71'],
                 edgecolor='black', linewidth=1.2)
    
    ax2.set_xlabel('Goal Type', fontsize=12, fontweight='bold')
    ax2.set_ylabel('Number of Goals', fontsize=12, fontweight='bold')
    ax2.set_title('Goals by Type and Status', fontsize=14, fontweight='bold', pad=15)
    ax2.legend(title='Status', fontsize=10, title_fontsize=11, loc='upper right')
    ax2.grid(axis='y', alpha=0.3, linestyle='--')
    plt.setp(ax2.xaxis.get_majorticklabels(), rotation=45, ha='right')
    
    plt.tight_layout()
    plt.savefig('query5_goal_achievement.png', dpi=300, bbox_inches='tight')
    print("✓ Saved: query5_goal_achievement.png\n")
    plt.close()


# Main function
def main():
    print("\n" + "="*75)
    print("LEVEL UP - FITNESS TRACKING PLATFORM")
    print("Database Analytics Application")
    print("Group 14: Rutvij Surti & Kush Patel")
    print("="*75 + "\n")
    
    # Connect to database
    connection = create_connection()
    
    if connection is None:
        print("Failed to connect to database")
        return
    
    try:
        # Run all queries
        query1_subscription_revenue(connection)
        query2_trainer_performance(connection)
        query3_class_attendance(connection)
        query4_user_progress(connection)
        query5_goal_achievement(connection)
        
        print("="*75)
        print("✓ ALL ANALYSES COMPLETED SUCCESSFULLY")
        print("="*75)
        print("\n Generated Files:")
        print("   1. query1_revenue_analysis.png")
        print("   2. query2_trainer_performance.png")
        print("   3. query3_class_attendance.png")
        print("   4. query4_user_progress.png")
        print("   5. query5_goal_achievement.png")
        print()
        
    except Error as e:
        print("Error:", e)
        
    finally:
        if connection.is_connected():
            connection.close()
            print("✓ Database connection closed\n")

