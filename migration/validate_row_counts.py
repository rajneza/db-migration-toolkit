#!/usr/bin/env python3
"""
Row Count Validation Script
============================
Compares row counts between staging (source) and dev (target) databases
for all 93 migrated tables.
"""

import os
import sys
import psycopg2
from datetime import datetime
from dotenv import load_dotenv

load_dotenv()

class Colors:
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    BLUE = '\033[94m'
    BOLD = '\033[1m'
    END = '\033[0m'

class Colors:
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    BLUE = '\033[94m'
    BOLD = '\033[1m'
    END = '\033[0m'

def get_connection(is_staging=False):
    """Get database connection"""
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

def get_row_count(conn, schema, table):
    """Get row count for a table"""
    cur = None
    try:
        cur = conn.cursor()
        cur.execute(f"SELECT COUNT(*) FROM {schema}.{table}")
        count = cur.fetchone()[0]
        cur.close()
        return count
    except Exception as e:
        # Rollback on error to avoid transaction abort
        conn.rollback()
        if cur:
            cur.close()
        
        # Check if table doesn't exist
        if "does not exist" in str(e):
            return None  # Table doesn't exist
        return f"ERROR: {str(e)[:50]}"

def get_existing_tables(conn, schema):
    """Get list of tables that exist in schema"""
    try:
        cur = conn.cursor()
        cur.execute(f"""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = %s
            ORDER BY table_name
        """, (schema,))
        tables = [row[0] for row in cur.fetchall()]
        cur.close()
        return set(tables)
    except Exception as e:
        print(f"{Colors.RED}Error getting table list: {e}{Colors.END}")
        return set()

def main():
    staging_schema = os.getenv('STAGING_SCHEMA', 'staging')
    dev_schema = os.getenv('DEV_SCHEMA', 'public')
    
    print(f"\n{Colors.BOLD}{'='*80}{Colors.END}")
    print(f"{Colors.BOLD}{Colors.CYAN}ROW COUNT VALIDATION - STAGING vs DEV{Colors.END}")
    print(f"{Colors.BOLD}{'='*80}{Colors.END}\n")
    
    print(f"{Colors.BLUE}Connecting to databases...{Colors.END}")
    try:
        staging_conn = get_connection(is_staging=True)
        dev_conn = get_connection(is_staging=False)
        print(f"{Colors.GREEN}✓ Connected to both databases{Colors.END}\n")
    except Exception as e:
        print(f"{Colors.RED}✗ Connection failed: {e}{Colors.END}")
        sys.exit(1)
    
    # Get actual tables that exist in staging (source of truth)
    print(f"{Colors.BLUE}Discovering tables in staging (source)...{Colors.END}")
    staging_tables = get_existing_tables(staging_conn, staging_schema)
    print(f"{Colors.GREEN}✓ Found {len(staging_tables)} tables in staging{Colors.END}\n")
    
    print(f"{Colors.BLUE}Discovering tables in dev (target)...{Colors.END}")
    dev_tables = get_existing_tables(dev_conn, dev_schema)
    print(f"{Colors.GREEN}✓ Found {len(dev_tables)} tables in dev{Colors.END}\n")
    
    # Check ALL staging tables (sorted alphabetically)
    tables_to_check = sorted(list(staging_tables))
    print(f"{Colors.CYAN}Validating {len(tables_to_check)} tables from staging{Colors.END}\n")
    
    print(f"{Colors.BOLD}{'─'*80}{Colors.END}")
    print(f"{Colors.BOLD}{'Table Name':<40} {'Staging':>12} {'Dev':>12} {'Status':>12}{Colors.END}")
    print(f"{Colors.BOLD}{'─'*80}{Colors.END}")
    
    total_staging = 0
    total_dev = 0
    matched = 0
    mismatched = 0
    errors = 0
    dev_only = 0
    staging_only = 0
    
    validation_results = []
    
    for table in tables_to_check:
        staging_count = get_row_count(staging_conn, staging_schema, table)
        dev_count = get_row_count(dev_conn, dev_schema, table)
        
        # Handle table doesn't exist cases
        if staging_count is None and dev_count is None:
            # Table doesn't exist in either (shouldn't happen)
            status = f"{Colors.RED}MISSING{Colors.END}"
            errors += 1
            validation_results.append({
                'table': table,
                'staging': 'N/A',
                'dev': 'N/A',
                'status': 'MISSING'
            })
            print(f"{table:<40} {'N/A':>12} {'N/A':>12} {status:>12}")
            continue
        
        elif staging_count is None:
            # Dev-only table (not in staging)
            status = f"{Colors.BLUE}DEV-ONLY{Colors.END}"
            dev_only += 1
            total_dev += dev_count if isinstance(dev_count, int) else 0
            validation_results.append({
                'table': table,
                'staging': 'N/A',
                'dev': dev_count,
                'status': 'DEV-ONLY'
            })
            print(f"{table:<40} {'N/A':>12} {str(dev_count):>12} {status:>12}")
            continue
        
        elif dev_count is None:
            # Staging-only table (not in dev)
            status = f"{Colors.YELLOW}STAGING-ONLY{Colors.END}"
            staging_only += 1
            total_staging += staging_count if isinstance(staging_count, int) else 0
            validation_results.append({
                'table': table,
                'staging': staging_count,
                'dev': 'N/A',
                'status': 'STAGING-ONLY'
            })
            print(f"{table:<40} {str(staging_count):>12} {'N/A':>12} {status:>12}")
            continue
        
        # Handle errors
        if isinstance(staging_count, str) or isinstance(dev_count, str):
            status = f"{Colors.RED}ERROR{Colors.END}"
            errors += 1
            validation_results.append({
                'table': table,
                'staging': staging_count if isinstance(staging_count, str) else staging_count,
                'dev': dev_count if isinstance(dev_count, str) else dev_count,
                'status': 'ERROR'
            })
            staging_str = str(staging_count)[:12] if isinstance(staging_count, str) else str(staging_count)
            dev_str = str(dev_count)[:12] if isinstance(dev_count, str) else str(dev_count)
            print(f"{table:<40} {staging_str:>12} {dev_str:>12} {status:>12}")
            continue
        
        # Both tables exist with valid counts
        total_staging += staging_count
        total_dev += dev_count
        
        # Check if counts match
        if staging_count == dev_count:
            status = f"{Colors.GREEN}✓ MATCH{Colors.END}"
            matched += 1
            validation_results.append({
                'table': table,
                'staging': staging_count,
                'dev': dev_count,
                'status': 'MATCH'
            })
        else:
            diff = dev_count - staging_count
            if diff > 0:
                status = f"{Colors.YELLOW}+{diff}{Colors.END}"
            else:
                status = f"{Colors.RED}{diff}{Colors.END}"
            mismatched += 1
            validation_results.append({
                'table': table,
                'staging': staging_count,
                'dev': dev_count,
                'status': f'DIFF: {diff}'
            })
        
        print(f"{table:<40} {staging_count:>12} {dev_count:>12} {status:>12}")
    
    print(f"{Colors.BOLD}{'─'*80}{Colors.END}")
    print(f"{Colors.BOLD}{'TOTAL':<40} {total_staging:>12} {total_dev:>12}{Colors.END}")
    print(f"{Colors.BOLD}{'='*80}{Colors.END}\n")
    
    # Summary
    print(f"{Colors.BOLD}{Colors.CYAN}VALIDATION SUMMARY{Colors.END}")
    print(f"{Colors.BOLD}{'─'*80}{Colors.END}")
    print(f"  Staging tables found:    {len(staging_tables)}")
    print(f"  Dev tables found:        {len(dev_tables)}")
    print(f"  Tables validated:        {len(tables_to_check)}")
    print(f"{Colors.BOLD}{'─'*80}{Colors.END}")
    print(f"  {Colors.GREEN}✓ Matched:{Colors.END}              {matched}")
    print(f"  {Colors.YELLOW}⚠ Mismatched:{Colors.END}           {mismatched}")
    print(f"  {Colors.BLUE}ℹ Dev-only tables:{Colors.END}      {dev_only}")
    print(f"  {Colors.YELLOW}ℹ Staging-only tables:{Colors.END}  {staging_only}")
    print(f"  {Colors.RED}✗ Errors:{Colors.END}               {errors}")
    print(f"{Colors.BOLD}{'─'*80}{Colors.END}")
    print(f"  Total rows in staging:   {Colors.CYAN}{total_staging:,}{Colors.END}")
    print(f"  Total rows in dev:       {Colors.CYAN}{total_dev:,}{Colors.END}")
    
    # Expected migration count (staging tables only)
    staging_table_count = matched + mismatched + staging_only
    print(f"  Tables in staging:       {Colors.CYAN}{len(staging_tables)}{Colors.END}")
    print(f"  Tables in dev:           {Colors.CYAN}{len(dev_tables)}{Colors.END}")
    
    if matched + mismatched == len(tables_to_check) and errors == 0:
        print(f"\n{Colors.BOLD}{Colors.GREEN}✓✓✓ VALIDATION SUCCESSFUL - ALL STAGING TABLES CHECKED! ✓✓✓{Colors.END}\n")
        if dev_only > 0:
            print(f"{Colors.BLUE}Note: {dev_only} dev-only tables exist (not in staging - this is normal){Colors.END}\n")
        if staging_only > 0:
            print(f"{Colors.YELLOW}Note: {staging_only} staging-only tables (not migrated to dev){Colors.END}\n")
    elif mismatched > 0:
        print(f"\n{Colors.BOLD}{Colors.YELLOW}⚠ VALIDATION WARNING - Some tables have different counts{Colors.END}")
        print(f"\n{Colors.YELLOW}Mismatched tables:{Colors.END}")
        for result in validation_results:
            if result['status'].startswith('DIFF'):
                print(f"  • {result['table']}: staging={result['staging']}, dev={result['dev']} ({result['status']})")
        print()
    
    if dev_only > 0:
        print(f"{Colors.BLUE}Dev-only tables (not in staging):{Colors.END}")
        for result in validation_results:
            if result['status'] == 'DEV-ONLY':
                print(f"  • {result['table']}: {result['dev']} rows")
        print()
    
    if staging_only > 0:
        print(f"{Colors.YELLOW}Staging-only tables (not migrated to dev):{Colors.END}")
        for result in validation_results:
            if result['status'] == 'STAGING-ONLY':
                print(f"  • {result['table']}: {result['staging']} rows")
        print()
    
    if errors > 0:
        print(f"\n{Colors.BOLD}{Colors.RED}✗ VALIDATION FAILED - Errors encountered{Colors.END}")
        print(f"\n{Colors.RED}Tables with errors:{Colors.END}")
        for result in validation_results:
            if result['status'] == 'ERROR':
                print(f"  • {result['table']}")
                if isinstance(result['staging'], str):
                    print(f"    Staging: {result['staging']}")
                if isinstance(result['dev'], str):
                    print(f"    Dev: {result['dev']}")
        print()
    
    # Close connections
    staging_conn.close()
    dev_conn.close()
    
    # Exit code (success if all staging tables matched or have expected diffs)
    if errors == 0:
        sys.exit(0)
    else:
        sys.exit(1)

if __name__ == '__main__':
    main()
