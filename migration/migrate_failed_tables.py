#!/usr/bin/env python3
"""
Migrate Failed Tables with Special Handling
============================================
Fixes specific issues for the 7 failed tables:
- partners (must migrate first - dependency)
- partner_contacts, partner_targets, partner_connections, partner_facts, 
  partner_readiness, partner_solutions (depend on partners)
- dataset_rows (array type issue)
- sequence_enrollments (NULL job_id issue)
- sequence_steps (depends on enrollments)
"""

import os
import sys
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

def migrate_partners(staging_conn, dev_conn):
    """Migrate partners table (with JSON handling)"""
    log("Migrating partners table...", 'INFO')
    
    staging_schema = os.getenv('STAGING_SCHEMA', 'staging')
    dev_schema = os.getenv('DEV_SCHEMA', 'public')
    
    try:
        staging_cur = staging_conn.cursor()
        staging_cur.execute(f"SELECT * FROM {staging_schema}.partners")
        rows = staging_cur.fetchall()
        
        if not rows:
            log("No data in partners table", 'WARNING')
            return 0
        
        # Get column names
        columns = [desc[0] for desc in staging_cur.description]
        columns_str = ', '.join(columns)
        placeholders = ', '.join(['%s'] * len(columns))
        
        dev_cur = dev_conn.cursor()
        insert_sql = f"INSERT INTO {dev_schema}.partners ({columns_str}) VALUES ({placeholders})"
        
        # Convert dict/list to JSON
        converted_rows = []
        for row in rows:
            converted_row = []
            for val in row:
                if isinstance(val, (dict, list)):
                    converted_row.append(Json(val))
                else:
                    converted_row.append(val)
            converted_rows.append(tuple(converted_row))
        
        execute_batch(dev_cur, insert_sql, converted_rows)
        dev_conn.commit()
        
        log(f"✓ Migrated {len(rows)} partners", 'SUCCESS')
        return len(rows)
        
    except Exception as e:
        log(f"Error migrating partners: {e}", 'ERROR')
        dev_conn.rollback()
        return 0

def migrate_partner_table(staging_conn, dev_conn, table_name):
    """Migrate partner_* tables (depend on partners)"""
    log(f"Migrating {table_name}...", 'INFO')
    
    staging_schema = os.getenv('STAGING_SCHEMA', 'staging')
    dev_schema = os.getenv('DEV_SCHEMA', 'public')
    
    try:
        staging_cur = staging_conn.cursor()
        staging_cur.execute(f"SELECT * FROM {staging_schema}.{table_name}")
        rows = staging_cur.fetchall()
        
        if not rows:
            log(f"No data in {table_name}", 'WARNING')
            return 0
        
        columns = [desc[0] for desc in staging_cur.description]
        columns_str = ', '.join(columns)
        placeholders = ', '.join(['%s'] * len(columns))
        
        dev_cur = dev_conn.cursor()
        insert_sql = f"INSERT INTO {dev_schema}.{table_name} ({columns_str}) VALUES ({placeholders})"
        
        # Convert dict/list to JSON
        migrated = 0
        for row in rows:
            converted_row = []
            for val in row:
                if isinstance(val, (dict, list)):
                    converted_row.append(Json(val))
                else:
                    converted_row.append(val)
            
            try:
                dev_cur.execute(insert_sql, tuple(converted_row))
                dev_conn.commit()
                migrated += 1
            except Exception as e:
                log(f"  Row error: {e}", 'ERROR')
                dev_conn.rollback()
        
        log(f"✓ Migrated {migrated}/{len(rows)} rows from {table_name}", 'SUCCESS')
        return migrated
        
    except Exception as e:
        log(f"Error migrating {table_name}: {e}", 'ERROR')
        dev_conn.rollback()
        return 0

def migrate_dataset_rows(staging_conn, dev_conn):
    """Migrate dataset_rows (array type fix)"""
    log("Migrating dataset_rows...", 'INFO')
    
    staging_schema = os.getenv('STAGING_SCHEMA', 'staging')
    dev_schema = os.getenv('DEV_SCHEMA', 'public')
    
    try:
        staging_cur = staging_conn.cursor()
        staging_cur.execute(f"SELECT * FROM {staging_schema}.dataset_rows")
        rows = staging_cur.fetchall()
        
        if not rows:
            log("No data in dataset_rows", 'WARNING')
            return 0
        
        columns = [desc[0] for desc in staging_cur.description]
        columns_str = ', '.join(columns)
        placeholders = ', '.join(['%s'] * len(columns))
        
        dev_cur = dev_conn.cursor()
        insert_sql = f"INSERT INTO {dev_schema}.dataset_rows ({columns_str}) VALUES ({placeholders})"
        
        # Convert dict/list to JSON, handle arrays and strings that look like arrays
        migrated = 0
        errors = 0
        for row in rows:
            converted_row = []
            for val in row:
                if isinstance(val, dict):
                    converted_row.append(Json(val))
                elif isinstance(val, list):
                    # Already a list - keep as is
                    converted_row.append(val)
                elif isinstance(val, str) and val.startswith('["') and val.endswith('"]'):
                    # String that looks like a JSON array - parse it
                    try:
                        import json
                        parsed = json.loads(val)
                        converted_row.append(parsed)
                    except:
                        # If parsing fails, keep as string
                        converted_row.append(val)
                else:
                    converted_row.append(val)
            
            try:
                dev_cur.execute(insert_sql, tuple(converted_row))
                dev_conn.commit()
                migrated += 1
            except Exception as e:
                error_msg = str(e)
                if "malformed array literal" in error_msg:
                    log(f"  Array parsing error for row {migrated+1}: {error_msg[:80]}", 'ERROR')
                else:
                    log(f"  Row error: {error_msg[:80]}", 'ERROR')
                dev_conn.rollback()
                errors += 1
        
        log(f"✓ Migrated {migrated}/{len(rows)} rows from dataset_rows ({errors} errors)", 'SUCCESS')
        return migrated
        
    except Exception as e:
        log(f"Error migrating dataset_rows: {e}", 'ERROR')
        dev_conn.rollback()
        return 0

def migrate_sequence_enrollments(staging_conn, dev_conn):
    """Migrate sequence_enrollments (skip rows with NULL job_id)"""
    log("Migrating sequence_enrollments (skipping NULL job_id)...", 'INFO')
    
    staging_schema = os.getenv('STAGING_SCHEMA', 'staging')
    dev_schema = os.getenv('DEV_SCHEMA', 'public')
    
    try:
        staging_cur = staging_conn.cursor()
        # Only select rows where job_id is NOT NULL
        staging_cur.execute(f"SELECT * FROM {staging_schema}.sequence_enrollments WHERE job_id IS NOT NULL")
        rows = staging_cur.fetchall()
        
        if not rows:
            log("No valid data in sequence_enrollments", 'WARNING')
            return 0
        
        columns = [desc[0] for desc in staging_cur.description]
        columns_str = ', '.join(columns)
        placeholders = ', '.join(['%s'] * len(columns))
        
        dev_cur = dev_conn.cursor()
        insert_sql = f"INSERT INTO {dev_schema}.sequence_enrollments ({columns_str}) VALUES ({placeholders})"
        
        migrated = 0
        for row in rows:
            try:
                dev_cur.execute(insert_sql, row)
                dev_conn.commit()
                migrated += 1
            except Exception as e:
                log(f"  Row error: {e}", 'ERROR')
                dev_conn.rollback()
        
        log(f"✓ Migrated {migrated} rows from sequence_enrollments (skipped NULL job_id)", 'SUCCESS')
        return migrated
        
    except Exception as e:
        log(f"Error migrating sequence_enrollments: {e}", 'ERROR')
        dev_conn.rollback()
        return 0

def migrate_sequence_steps(staging_conn, dev_conn):
    """Migrate sequence_steps (only for existing enrollments)"""
    log("Migrating sequence_steps...", 'INFO')
    
    staging_schema = os.getenv('STAGING_SCHEMA', 'staging')
    dev_schema = os.getenv('DEV_SCHEMA', 'public')
    
    try:
        # Get valid enrollment IDs from dev
        dev_cur = dev_conn.cursor()
        dev_cur.execute(f"SELECT id FROM {dev_schema}.sequence_enrollments")
        valid_enrollment_ids = set(row[0] for row in dev_cur.fetchall())
        
        log(f"Found {len(valid_enrollment_ids)} valid enrollment IDs", 'INFO')
        
        staging_cur = staging_conn.cursor()
        staging_cur.execute(f"SELECT * FROM {staging_schema}.sequence_steps")
        rows = staging_cur.fetchall()
        
        if not rows:
            log("No data in sequence_steps", 'WARNING')
            return 0
        
        columns = [desc[0] for desc in staging_cur.description]
        enrollment_id_idx = columns.index('enrollment_id')
        columns_str = ', '.join(columns)
        placeholders = ', '.join(['%s'] * len(columns))
        
        insert_sql = f"INSERT INTO {dev_schema}.sequence_steps ({columns_str}) VALUES ({placeholders})"
        
        migrated = 0
        skipped = 0
        for row in rows:
            if row[enrollment_id_idx] in valid_enrollment_ids:
                try:
                    dev_cur.execute(insert_sql, row)
                    dev_conn.commit()
                    migrated += 1
                except Exception as e:
                    log(f"  Row error: {e}", 'ERROR')
                    dev_conn.rollback()
            else:
                skipped += 1
        
        log(f"✓ Migrated {migrated} rows from sequence_steps (skipped {skipped} orphans)", 'SUCCESS')
        return migrated
        
    except Exception as e:
        log(f"Error migrating sequence_steps: {e}", 'ERROR')
        dev_conn.rollback()
        return 0

def main():
    print(f"\n{'='*70}")
    print("MIGRATE FAILED TABLES - Special Handling")
    print(f"{'='*70}\n")
    
    # Connect
    log("Connecting to databases...", 'INFO')
    staging_conn = get_connection(is_staging=True)
    dev_conn = get_connection(is_staging=False)
    log("✓ Connected", 'SUCCESS')
    
    print(f"\n{'='*70}")
    print("MIGRATION ORDER")
    print(f"{'='*70}\n")
    
    total_migrated = 0
    
    # 1. Partners (must be first)
    total_migrated += migrate_partners(staging_conn, dev_conn)
    
    # 2. Partner tables (depend on partners)
    partner_tables = [
        'partner_contacts', 'partner_targets', 'partner_connections',
        'partner_facts', 'partner_readiness', 'partner_solutions'
    ]
    for table in partner_tables:
        total_migrated += migrate_partner_table(staging_conn, dev_conn, table)
    
    # 3. Dataset rows (array type fix)
    total_migrated += migrate_dataset_rows(staging_conn, dev_conn)
    
    # 4. Sequence enrollments (skip NULL job_id)
    total_migrated += migrate_sequence_enrollments(staging_conn, dev_conn)
    
    # 5. Sequence steps (only valid enrollment_ids)
    total_migrated += migrate_sequence_steps(staging_conn, dev_conn)
    
    # Close connections
    staging_conn.close()
    dev_conn.close()
    
    print(f"\n{'='*70}")
    print("MIGRATION COMPLETE")
    print(f"{'='*70}\n")
    log(f"Total rows migrated: {total_migrated}", 'SUCCESS')
    print()

if __name__ == '__main__':
    main()
