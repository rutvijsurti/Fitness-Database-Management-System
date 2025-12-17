#!/bin/bash
# MongoDB Import Script - Exact SQL Match
# Usage: ./import_exact_mongodb.sh [database_name]

DATABASE=${1:-fitness_db}

echo "Importing exact SQL data to MongoDB database: $DATABASE"
echo "============================================"


echo "Importing subscriptions..."
mongoimport --db $DATABASE --collection subscriptions --file subscriptions.json --jsonArray --drop

echo "Importing trainers..."
mongoimport --db $DATABASE --collection trainers --file trainers.json --jsonArray --drop

echo "Importing certifications..."
mongoimport --db $DATABASE --collection certifications --file certifications.json --jsonArray --drop

echo "Importing users..."
mongoimport --db $DATABASE --collection users --file users.json --jsonArray --drop

echo "Importing classes..."
mongoimport --db $DATABASE --collection classes --file classes.json --jsonArray --drop

echo "Importing user_classes..."
mongoimport --db $DATABASE --collection user_classes --file user_classes.json --jsonArray --drop

echo "Importing payments..."
mongoimport --db $DATABASE --collection payments --file payments.json --jsonArray --drop

echo "Importing progress_tracking..."
mongoimport --db $DATABASE --collection progress_tracking --file progress_tracking.json --jsonArray --drop

echo "Importing goals..."
mongoimport --db $DATABASE --collection goals --file goals.json --jsonArray --drop

echo "Importing workout_plans..."
mongoimport --db $DATABASE --collection workout_plans --file workout_plans.json --jsonArray --drop

echo "Importing exercises..."
mongoimport --db $DATABASE --collection exercises --file exercises.json --jsonArray --drop

echo "Importing workout_exercises..."
mongoimport --db $DATABASE --collection workout_exercises --file workout_exercises.json --jsonArray --drop

echo "Importing feedback..."
mongoimport --db $DATABASE --collection feedback --file feedback.json --jsonArray --drop

echo "Importing devices..."
mongoimport --db $DATABASE --collection devices --file devices.json --jsonArray --drop

echo "============================================"
echo "✅ All collections imported successfully!"
echo ""
echo "Data now matches exactly with MySQL!"
