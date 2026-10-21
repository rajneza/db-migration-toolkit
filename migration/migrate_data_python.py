#!/usr/bin/env python3
"""
Direct Data Migration Script (No dblink required)
==================================================
Migrates data from staging to dev using Python and psycopg2.
This replaces the dblink-based SQL approach.

Usage:
    python migrate_data_python.py                    # Migrate all tables
    python migrate_data_python.py --tables users,jobs  # Specific tables
    python migrate_data_python.py --batch-size 500   # Custom batch size
    python migrate_data_python.py --dry-run          # Preview without copying
"""

import os
import sys
import time
import psycopg2
from psycopg2.extras import execute_batch
from datetime import datetime
from dotenv import load_dotenv

# ============================================================================
# Configuration
# ============================================================================

# Load .env file
load_dotenv()

# Tables to migrate (93 tables)
ALL_TABLES = [
    'account_brief_history', 'account_briefs', 'account_channel_context',
    'account_drive_folders', 'account_notes', 'account_route_assessments',
    'agent_metrics', 'agent_tool_grants', 'ai_feedback_signals',
    'alembic_version', 'alerts', 'apn_opportunities', 'apn_sync_runs',
    'atrisk_checks', 'batches', 'booking_links', 'campaign_attributions',
    'company_playbooks', 'connector_credentials', 'crm_tokens',
    'cxo_settings', 'demo_leads', 'digest_logs', 'domain_logo_cache',
    'event_invitations', 'explorium_credit_limits',
    'explorium_organisation_credit_limits', 'forecast_syncs', 'jobs',
    'leader_extras', 'leadership_results', 'mailbox_owner_companies',
    'mailbox_watch_state', 'mcp_connectors', 'mcp_tool_grants',
    'metrics_snapshots', 'news_events', 'org_events', 'organisations',
    'otp_verifications', 'partner_benchmarks', 'partner_connections',
    'partner_contacts', 'partner_engagement_cases', 'partner_facts',
    'partner_readiness', 'partner_references', 'partner_solutions',
    'partner_targets', 'partners', 'person_intel_cache', 'persona',
    'playbook_kb', 'playbook_variants', 'presentations', 'qbr_generations',
    'relationship_bridges', 'results', 'search_index', 'search_query_log',
    'sequence_enrollments', 'sequence_steps', 'sf_accounts', 'sf_deals',
    'sf_leads', 'sf_sync_runs', 'shared_webhook', 'suppressions',
    'team_notification_comments', 'team_notification_reactions',
    'team_notifications', 'user_reference_documents', 'user_settings',
    'user_tokens', 'users', 'webhook_companies', 'zoho_accounts',
    'zoho_deals', 'zoho_leads', 'zoho_sync_runs',
    # Staging-only tables (13 tables)
    'datasets', 'dataset_rows', 'dataset_history',
    'outreach_sequences', 'outreach_enrollments', 'outreach_steps',
    'outreach_reply_log', 'vault_documents', 'vault_chunks',
    'sequence_replies', 'llm_calls', 'run_stats', 'usage'
]

# Colors for output
class Colors:
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    BOLD = '\033[1m'
    END = '\033[0m'

# ============================================================================
# Helper Functions
# ============================================================================

def log(message, level='INFO'):
    """Print colored log message"""
    colors = {
        'INFO': Colors.CYAN,
        'SUCCESS': Colors.GREEN,
        'WARNING': Colors.YELLOW,
        'ERROR': Colors.RED,
    }
    color = colors.get(level, '')
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    print(f"{color}[{timestamp}] {level}: {message}{Colors.END}")

def get_connection(is_staging=False):
    """Create database connection"""
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

def get_table_info(conn, schema, table_name):
    """Get table structure (columns)"""
    with conn.cursor() as cur:
        cur.execute("""
            SELECT column_name, data_type, is_nullable
            FROM information_schema.columns
            WHERE table_schema = %s AND table_name = %s
            ORDER BY ordinal_position
        """, (schema, table_name))
        return cur.fetchall()

def get_row_count(conn, schema, table_name):
    """Get row count for a table"""
    with conn.cursor() as cur:
        cur.execute(f"SELECT COUNT(*) FROM {schema}.{table_name}")
        return cur.fetchone()[0]

def table_exists(conn, schema, table_name):
    """Check if table exists"""
    with conn.cursor() as cur:
        cur.execute("""
            SELECT EXISTS (
                SELECT 1 FROM information_schema.tables
                WHERE table_schema = %s AND table_name = %s
            )
        """, (schema, table_name))
        return cur.fetchone()[0]

def migrate_table(staging_conn, dev_conn, table_name, batch_size=1000, dry_run=False):
    """Migrate data from one table"""
    
    staging_schema = os.getenv('STAGING_SCHEMA', 'staging')
    dev_schema = os.getenv('DEV_SCHEMA', 'public')
    
    # Check if table exists in both databases
    if not table_exists(staging_conn, staging_schema, table_name):
        log(f"Table {table_name} not found in staging - SKIPPING", 'WARNING')
        return 0, 0
    
    if not table_exists(dev_conn, dev_schema, table_name):
        log(f"Table {table_name} not found in dev - SKIPPING", 'WARNING')
        return 0, 0
    
    # Get row count
    row_count = get_row_count(staging_conn, staging_schema, table_name)
    
    if row_count == 0:
        log(f"Table {table_name} is empty - SKIPPING", 'INFO')
        return 0, 0
    
    log(f"Migrating {table_name}: {row_count:,} rows", 'INFO')
    
    if dry_run:
        log(f"  DRY RUN: Would migrate {row_count:,} rows", 'INFO')
        return row_count, 0
    
    start_time = time.time()
    
    try:
        # Get column names
        staging_columns = get_table_info(staging_conn, staging_schema, table_name)
        dev_columns = get_table_info(dev_conn, dev_schema, table_name)
        
        staging_col_names = [col[0] for col in staging_columns]
        dev_col_names = [col[0] for col in dev_columns]
        
        # Use only common columns
        common_columns = [col for col in staging_col_names if col in dev_col_names]
        
        if not common_columns:
            log(f"  No common columns found - SKIPPING", 'ERROR')
            return 0, 0
        
        columns_str = ', '.join(common_columns)
        placeholders = ', '.join(['%s'] * len(common_columns))
        
        # Read data from staging
        staging_cur = staging_conn.cursor()
        staging_cur.execute(f"SELECT {columns_str} FROM {staging_schema}.{table_name}")
        
        # Insert into dev in batches
        dev_cur = dev_conn.cursor()
        insert_sql = f"INSERT INTO {dev_schema}.{table_name} ({columns_str}) VALUES ({placeholders})"
        
        rows_migrated = 0
        batch = []
        
        for row in staging_cur:
            batch.append(row)
            
            if len(batch) >= batch_size:
                execute_batch(dev_cur, insert_sql, batch)
                dev_conn.commit()
                rows_migrated += len(batch)
                
                # Progress update
                progress = (rows_migrated / row_count) * 100
                print(f"\r  Progress: {rows_migrated:,}/{row_count:,} ({progress:.1f}%)", end='', flush=True)
                
                batch = []
        
        # Insert remaining rows
        if batch:
            execute_batch(dev_cur, insert_sql, batch)
            dev_conn.commit()
            rows_migrated += len(batch)
        
        print()  # New line after progress
        
        staging_cur.close()
        dev_cur.close()
        
        duration = time.time() - start_time
        rate = rows_migrated / duration if duration > 0 else 0
        
        log(f"  ✓ Migrated {rows_migrated:,} rows in {duration:.1f}s ({rate:.0f} rows/sec)", 'SUCCESS')
        
        return row_count, rows_migrated
        
    except Exception as e:
        log(f"  ✗ Error migrating {table_name}: {str(e)}", 'ERROR')
        dev_conn.rollback()
        return row_count, 0

# ============================================================================
# Main Migration
# ============================================================================

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description='Migrate data from staging to dev')
    parser.add_argument('--tables', type=str, help='Comma-separated list of tables to migrate')
    parser.add_argument('--batch-size', type=int, default=1000, help='Batch size for inserts (default: 1000)')
    parser.add_argument('--dry-run', action='store_true', help='Preview without copying data')
    parser.add_argument('--skip-empty', action='store_true', default=True, help='Skip empty tables')
    
    args = parser.parse_args()
    
    # Determine which tables to migrate
    if args.tables:
        tables = [t.strip() for t in args.tables.split(',')]
    else:
        tables = ALL_TABLES
    
    print(f"\n{Colors.BOLD}{Colors.CYAN}{'='*70}{Colors.END}")
    print(f"{Colors.BOLD}{Colors.CYAN}DATA MIGRATION - STAGING TO DEV{Colors.END}")
    print(f"{Colors.BOLD}{Colors.CYAN}{'='*70}{Colors.END}\n")
    
    if args.dry_run:
        log("DRY RUN MODE - No data will be copied", 'WARNING')
    
    log(f"Tables to migrate: {len(tables)}", 'INFO')
    log(f"Batch size: {args.batch_size:,}", 'INFO')
    print()
    
    # Connect to databases
    log("Connecting to staging database...", 'INFO')
    try:
        staging_conn = get_connection(is_staging=True)
        log("✓ Connected to staging", 'SUCCESS')
    except Exception as e:
        log(f"✗ Failed to connect to staging: {e}", 'ERROR')
        return 1
    
    log("Connecting to dev database...", 'INFO')
    try:
        dev_conn = get_connection(is_staging=False)
        log("✓ Connected to dev", 'SUCCESS')
    except Exception as e:
        log(f"✗ Failed to connect to dev: {e}", 'ERROR')
        return 1
    
    print(f"\n{Colors.BOLD}{'='*70}{Colors.END}")
    print(f"{Colors.BOLD}MIGRATING TABLES{Colors.END}")
    print(f"{Colors.BOLD}{'='*70}{Colors.END}\n")
    
    # Migrate tables
    start_time = time.time()
    total_rows = 0
    migrated_rows = 0
    successful_tables = 0
    failed_tables = []
    
    for i, table in enumerate(tables, 1):
        print(f"\n[{i}/{len(tables)}] {table}")
        print("-" * 70)
        
        try:
            rows, migrated = migrate_table(
                staging_conn, 
                dev_conn, 
                table, 
                batch_size=args.batch_size,
                dry_run=args.dry_run
            )
            
            total_rows += rows
            migrated_rows += migrated
            
            if migrated > 0 or rows == 0:
                successful_tables += 1
            else:
                failed_tables.append(table)
                
        except KeyboardInterrupt:
            log("\n\nMigration interrupted by user", 'WARNING')
            break
        except Exception as e:
            log(f"Unexpected error: {e}", 'ERROR')
            failed_tables.append(table)
    
    # Close connections
    staging_conn.close()
    dev_conn.close()
    
    # Summary
    duration = time.time() - start_time
    
    print(f"\n{Colors.BOLD}{'='*70}{Colors.END}")
    print(f"{Colors.BOLD}MIGRATION SUMMARY{Colors.END}")
    print(f"{Colors.BOLD}{'='*70}{Colors.END}\n")
    
    log(f"Total time: {duration:.1f}s ({duration/60:.1f} minutes)", 'INFO')
    log(f"Tables processed: {len(tables)}", 'INFO')
    log(f"Successful: {successful_tables}", 'SUCCESS')
    log(f"Failed: {len(failed_tables)}", 'ERROR' if failed_tables else 'INFO')
    log(f"Total rows found: {total_rows:,}", 'INFO')
    log(f"Rows migrated: {migrated_rows:,}", 'SUCCESS')
    
    if failed_tables:
        print(f"\n{Colors.RED}Failed tables:{Colors.END}")
        for table in failed_tables:
            print(f"  - {table}")
    
    print(f"\n{Colors.BOLD}{'='*70}{Colors.END}\n")
    
    if not args.dry_run:
        log("Migration complete! Run validation to verify data.", 'SUCCESS')
        log("  python migrate_data_python.py --dry-run  # Check what would be copied", 'INFO')
        log("  psql ... -f check_data_quick.sql  # Verify data was copied", 'INFO')
    
    return 0 if not failed_tables else 1

if __name__ == '__main__':
    sys.exit(main())
