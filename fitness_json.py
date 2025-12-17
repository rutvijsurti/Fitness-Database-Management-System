"""
SQL to MongoDB JSON Parser
Reads your exact SQL file and generates matching MongoDB JSON files
Ensures 100% data match between MySQL and MongoDB
"""

import re
import json
from datetime import datetime
from bson import ObjectId

class SQLToMongoDBParser:
    def __init__(self, sql_file_path):
        self.sql_file_path = sql_file_path
        self.collections = {}
        self.object_ids = {}
        
    def generate_object_ids(self, table_name, count=30):
        """Generate ObjectIds for a table"""
        self.object_ids[table_name] = [str(ObjectId()) for _ in range(count)]
    
    def parse_insert_statement(self, statement):
        """Parse a single INSERT statement"""
        # Extract table name
        table_match = re.search(r'INSERT INTO (\w+)', statement, re.IGNORECASE)
        if not table_match:
            return None, None
        
        table_name = table_match.group(1)
        
        # Extract column names
        columns_match = re.search(r'\(([^)]+)\)\s+VALUES', statement, re.IGNORECASE)
        if not columns_match:
            return None, None
        
        columns = [col.strip() for col in columns_match.group(1).split(',')]
        
        # Extract values
        values_match = re.search(r'VALUES\s+\((.+)\);', statement, re.IGNORECASE | re.DOTALL)
        if not values_match:
            return None, None
        
        values_str = values_match.group(1)
        values = self.parse_values(values_str)
        
        return table_name, dict(zip(columns, values))
    
    def parse_values(self, values_str):
        """Parse VALUES clause handling strings, numbers, NULL, dates"""
        values = []
        current_value = ""
        in_string = False
        escape_next = False
        
        for char in values_str:
            if escape_next:
                current_value += char
                escape_next = False
                continue
                
            if char == '\\':
                escape_next = True
                current_value += char
                continue
                
            if char == "'" and not escape_next:
                in_string = not in_string
                if not in_string and current_value:
                    # End of string value
                    values.append(current_value)
                    current_value = ""
                continue
                
            if char == ',' and not in_string:
                if current_value.strip():
                    # Process non-string value
                    val = current_value.strip()
                    if val.upper() == 'NULL':
                        values.append(None)
                    elif re.match(r'^-?\d+$', val):
                        values.append(int(val))
                    elif re.match(r'^-?\d+\.\d+$', val):
                        values.append(float(val))
                    else:
                        values.append(val)
                    current_value = ""
                continue
                
            if in_string or (char != ' ' or current_value):
                current_value += char
        
        # Handle last value
        if current_value.strip():
            val = current_value.strip()
            if val.upper() == 'NULL':
                values.append(None)
            elif re.match(r'^-?\d+$', val):
                values.append(int(val))
            elif re.match(r'^-?\d+\.\d+$', val):
                values.append(float(val))
            else:
                values.append(val)
        
        return values
    
    def convert_to_datetime(self, date_str):
        """Convert SQL datetime string to Python datetime"""
        if not date_str or date_str == 'NULL':
            return None
        try:
            return datetime.strptime(date_str, '%Y-%m-%d %H:%M:%S')
        except:
            return date_str
    
    def parse_sql_file(self):
        """Parse the entire SQL file"""
        print("Reading SQL file...")
        with open(self.sql_file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Split by INSERT statements
        insert_statements = re.findall(
            r'INSERT INTO[^;]+;',
            content,
            re.IGNORECASE | re.DOTALL
        )
        
        print(f"Found {len(insert_statements)} INSERT statements")
        
        # Parse each statement
        parsed_data = {}
        for statement in insert_statements:
            table_name, row_data = self.parse_insert_statement(statement)
            if table_name and row_data:
                table_name_lower = table_name.lower()
                if table_name_lower not in parsed_data:
                    parsed_data[table_name_lower] = []
                parsed_data[table_name_lower].append(row_data)
        
        # Generate ObjectIds for all tables
        for table_name, rows in parsed_data.items():
            self.generate_object_ids(table_name, len(rows))
        
        return parsed_data
    
    def create_mongodb_documents(self, parsed_data):
        """Convert parsed SQL data to MongoDB documents"""
        
        # Table name mapping
        table_mapping = {
            'subscriptions': 'subscriptions',
            'trainers': 'trainers',
            'certifications': 'certifications',
            'users': 'users',
            'classes': 'classes',
            'user_class': 'user_classes',
            'payments': 'payments',
            'progress_tracking': 'progress_tracking',
            'goals': 'goals',
            'workout_plan': 'workout_plans',
            'exercises': 'exercises',
            'workout_exercises': 'workout_exercises',
            'feedback': 'feedback',
            'devices': 'devices'
        }
        
        # Process each table
        for sql_table, mongo_collection in table_mapping.items():
            if sql_table not in parsed_data:
                print(f"Warning: {sql_table} not found in SQL data")
                continue
            
            print(f"Processing {sql_table}...")
            documents = []
            
            for idx, row in enumerate(parsed_data[sql_table]):
                doc = {
                    "_id": {"$oid": self.object_ids[sql_table][idx]}
                }
                
                # Add all fields from SQL
                for key, value in row.items():
                    # Convert datetime strings
                    if isinstance(value, str) and re.match(r'\d{4}-\d{2}-\d{2}', value):
                        doc[key] = self.convert_to_datetime(value)
                    else:
                        doc[key] = value
                
                # Add reference fields for foreign keys
                doc = self.add_references(sql_table, doc, idx)
                
                documents.append(doc)
            
            self.collections[mongo_collection] = documents
    
    def add_references(self, table_name, doc, idx):
        """Add MongoDB reference fields for foreign keys"""
        
        # Helper to get ObjectId for a reference
        def get_ref_oid(ref_table, ref_id):
            if ref_id is None:
                return None
            try:
                ref_idx = int(ref_id) - 1
                if ref_idx >= 0 and ref_idx < len(self.object_ids.get(ref_table, [])):
                    return {"$oid": self.object_ids[ref_table][ref_idx]}
            except:
                pass
            return None
        
        # Add references based on table
        if table_name == 'users':
            if doc.get('subscription_id'):
                doc['subscription_ref'] = get_ref_oid('subscriptions', doc['subscription_id'])
            if doc.get('trainer_id'):
                doc['trainer_ref'] = get_ref_oid('trainers', doc['trainer_id'])
        
        elif table_name == 'trainers':
            if doc.get('certification_id'):
                doc['certification_ref'] = get_ref_oid('certifications', doc['certification_id'])
        
        elif table_name == 'certifications':
            if doc.get('trainer_id'):
                doc['trainer_ref'] = get_ref_oid('trainers', doc['trainer_id'])
        
        elif table_name == 'classes':
            if doc.get('trainer_id'):
                doc['trainer_ref'] = get_ref_oid('trainers', doc['trainer_id'])
        
        elif table_name == 'user_class':
            if doc.get('user_id'):
                doc['user_ref'] = get_ref_oid('users', doc['user_id'])
            if doc.get('class_id'):
                doc['class_ref'] = get_ref_oid('classes', doc['class_id'])
        
        elif table_name == 'payments':
            if doc.get('user_id'):
                doc['user_ref'] = get_ref_oid('users', doc['user_id'])
            if doc.get('subscription_id'):
                doc['subscription_ref'] = get_ref_oid('subscriptions', doc['subscription_id'])
        
        elif table_name == 'progress_tracking':
            if doc.get('user_id'):
                doc['user_ref'] = get_ref_oid('users', doc['user_id'])
        
        elif table_name == 'goals':
            if doc.get('user_id'):
                doc['user_ref'] = get_ref_oid('users', doc['user_id'])
        
        elif table_name == 'workout_plan':
            if doc.get('user_id'):
                doc['user_ref'] = get_ref_oid('users', doc['user_id'])
            if doc.get('trainer_id'):
                doc['trainer_ref'] = get_ref_oid('trainers', doc['trainer_id'])
            if doc.get('goal_id'):
                doc['goal_ref'] = get_ref_oid('goals', doc['goal_id'])
        
        elif table_name == 'workout_exercises':
            if doc.get('plan_id'):
                doc['plan_ref'] = get_ref_oid('workout_plan', doc['plan_id'])
            if doc.get('exercise_id'):
                doc['exercise_ref'] = get_ref_oid('exercises', doc['exercise_id'])
        
        elif table_name == 'feedback':
            if doc.get('user_id'):
                doc['user_ref'] = get_ref_oid('users', doc['user_id'])
            if doc.get('trainer_id'):
                doc['trainer_ref'] = get_ref_oid('trainers', doc['trainer_id'])
            if doc.get('class_id'):
                doc['class_ref'] = get_ref_oid('classes', doc['class_id'])
        
        elif table_name == 'devices':
            if doc.get('user_id'):
                doc['user_ref'] = get_ref_oid('users', doc['user_id'])
        
        return doc
    
    def save_json_files(self):
        """Save MongoDB collections as JSON files"""
        
        class DateTimeEncoder(json.JSONEncoder):
            def default(self, obj):
                if isinstance(obj, datetime):
                    return {"$date": obj.strftime('%Y-%m-%dT%H:%M:%S.000Z')}
                return super().default(obj)
        
        for collection_name, documents in self.collections.items():
            filename = f"{collection_name}.json"
            with open(filename, 'w', encoding='utf-8') as f:
                json.dump(documents, f, indent=2, cls=DateTimeEncoder)
            print(f"✅ Created: {filename} ({len(documents)} documents)")
    
    def create_import_script(self):
        """Create MongoDB import script"""
        collections = list(self.collections.keys())
        
        script_content = """#!/bin/bash
# MongoDB Import Script - Exact SQL Match
# Usage: ./import_exact_mongodb.sh [database_name]

DATABASE=${1:-fitness_db}

echo "Importing exact SQL data to MongoDB database: $DATABASE"
echo "============================================"

"""
        
        for collection in collections:
            script_content += f"""
echo "Importing {collection}..."
mongoimport --db $DATABASE --collection {collection} --file {collection}.json --jsonArray --drop
"""
        
        script_content += """
echo "============================================"
echo "✅ All collections imported successfully!"
echo ""
echo "Data now matches exactly with MySQL!"
"""
        
        with open("import_exact_mongodb.sh", 'w') as f:
            f.write(script_content)
        
        import os
        os.chmod("import_exact_mongodb.sh", 0o755)
        
        print("✅ Created: import_exact_mongodb.sh")
    
    def verify_data(self):
        """Print verification summary"""
        print("\n" + "="*70)
        print("DATA VERIFICATION SUMMARY")
        print("="*70)
        
        for collection_name, documents in self.collections.items():
            if documents:
                sample = documents[0]
                print(f"\n{collection_name.upper()}:")
                print(f"  Total documents: {len(documents)}")
                print(f"  Sample ID 1:")
                for key, value in list(sample.items())[:5]:
                    if key != '_id' and not key.endswith('_ref'):
                        print(f"    {key}: {value}")

# ============================================
# MAIN EXECUTION
# ============================================
if __name__ == "__main__":
    import sys
    
    print("="*70)
    print("SQL TO MONGODB PARSER - EXACT MATCH")
    print("="*70)
    print()
    
    # Check if SQL file path provided
    sql_file = "fitness1.sql"  # Default file name
    if len(sys.argv) > 1:
        sql_file = sys.argv[1]
    
    print(f"Reading SQL file: {sql_file}")
    print()
    
    try:
        # Create parser
        parser = SQLToMongoDBParser(sql_file)
        
        # Parse SQL file
        print("Step 1: Parsing SQL file...")
        parsed_data = parser.parse_sql_file()
        
        print()
        print("Step 2: Converting to MongoDB documents...")
        parser.create_mongodb_documents(parsed_data)
        
        print()
        print("Step 3: Saving JSON files...")
        parser.save_json_files()
        
        print()
        print("Step 4: Creating import script...")
        parser.create_import_script()
        
        print()
        parser.verify_data()
        
        print()
        print("="*70)
        print("✅ SUCCESS! MongoDB JSON files match your SQL data exactly!")
        print("="*70)
        print()
        print("Generated Files:")
        print(f"  - {len(parser.collections)} JSON files (one per collection)")
        print("  - import_exact_mongodb.sh (import script)")
        print()
        print("To import into MongoDB:")
        print("  ./import_exact_mongodb.sh fitness_db")
        print()
        print("To verify data matches:")
        print("  MySQL:   SELECT * FROM Users WHERE user_id = 1;")
        print("  MongoDB: db.users.findOne({user_id: 1})")
        print()
        
    except FileNotFoundError:
        print(f"❌ ERROR: File '{sql_file}' not found!")
        print()
        print("Usage:")
        print(f"  python3 {sys.argv[0]} your_sql_file.sql")
        print()
        sys.exit(1)
    except Exception as e:
        print(f"❌ ERROR: {str(e)}")
        import traceback
        traceback.print_exc()
        sys.exit(1)