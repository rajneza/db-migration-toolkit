#!/usr/bin/env python3
"""
Migrate Dataset Rows Table Only
================================
Fixes array type issues for dataset_rows table migration.
"""

import os
import sys
import json
import psycopg2
from psycopg2.extras import execute_batch, Json
from psycopg2.extensions import register_adapter
from datetime import datetime
from dotenv import load_dotenv

load_dotenv()

# Register JSON adapter
register_adapter(dict, Json)
register_adapter(list, Json)

class Colors:
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    BLUE = '\033[94m'
    BOLD = '\033[1m'
    END = '\033[0m'

def log(message, level='INFO'):
    colors = {'INFO': Colors.CYAN, 'SUCCESS': Colors.GREEN, 'WARNING': Colors.YELLOW, 'ERROR': Colors.RED}
    color = colors.get(level, '')
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    print(f"{color}[{timestamp}] {level}: {message}{Colors.END}")

def get_connection(is_staging=False):
    if is_staging:
        return psycopg2.connect(
            host=os.getenv('STAGING_HOST'),
            port=os.getenv('STAGING_PORT', 5432),
            database=os.getenv('STAGING_DB'),
            user=os.getenv('STAGING_USER'),
            password=os.getenv('STAGING_PASSWORD')
        )
    else:
        return psycopg2.connect(
            host=os.getenv('DEV_HOST'),
            port=os.getenv('DEV_PORT', 5432),
            database=os.getenv('DEV_DB'),
            user=os.getenv('DEV_USER'),
            password=os.getenv('DEV_PASSWORD')
        )

def truncate_table(dev_conn):
    """Truncate dataset_rows table before migration"""
    dev_schema = os.getenv('DEV_SCHEMA', 'public')
    
    try:
        log("Truncating dataset_rows table...", 'INFO')
        dev_cur = dev_conn.cursor()
        dev_cur.execute(f"TRUNCATE TABLE {dev_schema}.dataset_rows CASCADE")
        dev_conn.commit()
        dev_cur.close()
        log("✓ Table truncated", 'SUCCESS')
        return True
    except Exception as e:
        log(f"Error truncating table: {e}", 'ERROR')
        dev_conn.rollback()
        return False

def migrate_dataset_rows(staging_conn, dev_conn):
    """Migrate dataset_rows with advanced array/JSON handling"""
    staging_schema = os.getenv('STAGING_SCHEMA', 'staging')
    dev_schema = os.getenv('DEV_SCHEMA', 'public')
    
    try:
        # Get data from staging
        staging_cur = staging_conn.cursor()
        staging_cur.execute(f"SELECT * FROM {staging_schema}.dataset_rows")
        rows = staging_cur.fetchall()
        
        if not rows:
            log("No data in dataset_rows", 'WARNING')
            return 0
        
        log(f"Found {len(rows)} rows in staging", 'INFO')
        
        # Get column info
        columns = [desc[0] for desc in staging_cur.description]
        columns_str = ', '.join(columns)
        placeholders = ', '.join(['%s'] * len(columns))
        
        dev_cur = dev_conn.cursor()
        insert_sql = f"INSERT INTO {dev_schema}.dataset_rows ({columns_str}) VALUES ({placeholders})"
        
        migrated = 0
        errors = 0
        
        for idx, row in enumerate(rows, 1):
            converted_row = []
            
            for col_idx, val in enumerate(row):
                col_name = columns[col_idx]
                
                if val is None:
                    converted_row.append(None)
                elif isinstance(val, dict):
                    # Dict → JSON
                    converted_row.append(Json(val))
                elif isinstance(val, list):
                    # Already a list → keep as array
                    converted_row.append(val)
                elif isinstance(val, str):
                    # Check if string looks like a JSON array
                    val_stripped = val.strip()
                    if val_stripped.startswith('[') and val_stripped.endswith(']'):
                        try:
                            # Try to parse as JSON
                            parsed = json.loads(val_stripped)
                            if isinstance(parsed, list):
                                log(f"  Row {idx}: Converted string array in column '{col_name}' to list", 'INFO')
                                converted_row.append(parsed)
                            else:
                                converted_row.append(val)
                        except json.JSONDecodeError:
                            # Not valid JSON, keep as string
                            log(f"  Row {idx}: Column '{col_name}' looks like array but invalid JSON, keeping as string", 'WARNING')
                            converted_row.append(val)
                    else:
                        # Regular string
                        converted_row.append(val)
                else:
                    # Other types (int, float, datetime, etc.)
                    converted_row.append(val)
            
            # Try to insert
            try:
                dev_cur.execute(insert_sql, tuple(converted_row))
                dev_conn.commit()
                migrated += 1
                if migrated % 10 == 0:
                    log(f"Progress: {migrated}/{len(rows)} rows migrated", 'INFO')
            except Exception as e:
                error_msg = str(e)
                log(f"  Row {idx} error: {error_msg[:150]}", 'ERROR')
                
                # Print row details for debugging
                if errors < 5:  # Only show first 5 errors in detail
                    log(f"    Row data preview: {str(row)[:200]}", 'ERROR')
                
                dev_conn.rollback()
                errors += 1
        
        staging_cur.close()
        dev_cur.close()
        
        log(f"✓ Migration complete: {migrated}/{len(rows)} rows migrated, {errors} errors", 'SUCCESS')
        return migrated
        
    except Exception as e:
        log(f"Fatal error during migration: {e}", 'ERROR')
        import traceback
        traceback.print_exc()
        return 0

def main():
    print(f"\n{Colors.BOLD}{'='*70}{Colors.END}")
    print(f"{Colors.BOLD}{Colors.CYAN}MIGRATE DATASET_ROWS TABLE ONLY{Colors.END}")
    print(f"{Colors.BOLD}{'='*70}{Colors.END}\n")
    
    # Connect
    log("Connecting to databases...", 'INFO')
    try:
        staging_conn = get_connection(is_staging=True)
        dev_conn = get_connection(is_staging=False)
        log("✓ Connected to both databases", 'SUCCESS')
    except Exception as e:
        log(f"Connection failed: {e}", 'ERROR')
        sys.exit(1)
    
    print(f"\n{Colors.BOLD}{'='*70}{Colors.END}")
    print(f"{Colors.BOLD}STEP 1: TRUNCATE TABLE{Colors.END}")
    print(f"{Colors.BOLD}{'='*70}{Colors.END}\n")
    
    if not truncate_table(dev_conn):
        log("Failed to truncate table, aborting", 'ERROR')
        sys.exit(1)
    
    print(f"\n{Colors.BOLD}{'='*70}{Colors.END}")
    print(f"{Colors.BOLD}STEP 2: MIGRATE DATA{Colors.END}")
    print(f"{Colors.BOLD}{'='*70}{Colors.END}\n")
    
    total_migrated = migrate_dataset_rows(staging_conn, dev_conn)
    
    # Close connections
    staging_conn.close()
    dev_conn.close()
    
    print(f"\n{Colors.BOLD}{'='*70}{Colors.END}")
    print(f"{Colors.BOLD}MIGRATION SUMMARY{Colors.END}")
    print(f"{Colors.BOLD}{'='*70}{Colors.END}\n")
    
    if total_migrated > 0:
        log(f"✓✓✓ SUCCESS: {total_migrated} rows migrated ✓✓✓", 'SUCCESS')
        print()
        sys.exit(0)
    else:
        log("✗✗✗ FAILED: No rows migrated ✗✗✗", 'ERROR')
        print()
        sys.exit(1)

if __name__ == '__main__':
    main()
