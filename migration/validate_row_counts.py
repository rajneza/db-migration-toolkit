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

# All 93 tables to migrate (same order as migrate_data_python.py)
TABLES_TO_MIGRATE = [
    'organisations', 'users', 'batches', 'jobs', 'account_briefs',
    'account_channel_context', 'account_drive_folders', 'account_notes',
    'account_route_assessments', 'agent_metrics', 'ai_feedback_signals',
    'alerts', 'apn_opportunities', 'apn_sync_runs', 'atrisk_checks',
    'booking_links', 'connector_credentials', 'crm_tokens', 'cxo_settings',
    'digest_logs', 'explorium_credit_limits', 'explorium_organisation_credit_limits',
    'forecast_syncs', 'leader_extras', 'leadership_results', 'partner_contacts',
    'partner_targets', 'mailbox_owner_companies', 'news_events', 'partners',
    'persona', 'playbook_kb', 'playbook_variants', 'presentations',
    'qbr_generations', 'results', 'search_query_log', 'sequence_enrollments',
    'sequence_steps', 'sf_sync_runs', 'team_notifications', 'user_settings',
    'user_tokens', 'zoho_accounts', 'zoho_deals', 'zoho_leads',
    'partner_connections', 'partner_facts', 'partner_readiness',
    'partner_solutions', 'zoho_sync_runs', 'datasets', 'dataset_columns',
    'dataset_metadata', 'dataset_owners', 'dataset_rows', 'dataset_services',
    'organisation_dataset_services', 'queries', 'query_columns',
    'query_data_sources', 'jobs_run_history', 'ai_api_usage',
    'assistant_threads', 'crm_auth_accounts', 'crm_sync_runs',
    'entity_map_settings', 'event_state', 'groq_playground_prompts',
    'llm_model_map', 'messages', 'notification_schedules', 'playbook_evaluations',
    'playbook_runs', 'slack_channels', 'user_agents', 'workflow_request_reviews',
    'workflow_requests', 'workflows', 'dataset_usage_logs', 'session_activities',
    'account_meeting_summaries', 'ai_assisted_jobs', 'chat_sessions',
    'message_feedback', 'slack_tokens', 'alert_check_log', 'data_assets',
    'data_assets_columns', 'message_runs', 'search_logs'
]

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
    try:
        cur = conn.cursor()
        cur.execute(f"SELECT COUNT(*) FROM {schema}.{table}")
        count = cur.fetchone()[0]
        cur.close()
        return count
    except Exception as e:
        return f"ERROR: {str(e)[:50]}"

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
    
    print(f"{Colors.BOLD}{'─'*80}{Colors.END}")
    print(f"{Colors.BOLD}{'Table Name':<40} {'Staging':>12} {'Dev':>12} {'Status':>12}{Colors.END}")
    print(f"{Colors.BOLD}{'─'*80}{Colors.END}")
    
    total_staging = 0
    total_dev = 0
    matched = 0
    mismatched = 0
    errors = 0
    
    validation_results = []
    
    for table in TABLES_TO_MIGRATE:
        staging_count = get_row_count(staging_conn, staging_schema, table)
        dev_count = get_row_count(dev_conn, dev_schema, table)
        
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
        else:
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
        
        # Format counts
        staging_str = str(staging_count) if not isinstance(staging_count, str) else staging_count[:12]
        dev_str = str(dev_count) if not isinstance(dev_count, str) else dev_count[:12]
        
        print(f"{table:<40} {staging_str:>12} {dev_str:>12} {status:>12}")
    
    print(f"{Colors.BOLD}{'─'*80}{Colors.END}")
    print(f"{Colors.BOLD}{'TOTAL':<40} {total_staging:>12} {total_dev:>12}{Colors.END}")
    print(f"{Colors.BOLD}{'='*80}{Colors.END}\n")
    
    # Summary
    print(f"{Colors.BOLD}{Colors.CYAN}VALIDATION SUMMARY{Colors.END}")
    print(f"{Colors.BOLD}{'─'*80}{Colors.END}")
    print(f"  Total tables validated:  {len(TABLES_TO_MIGRATE)}")
    print(f"  {Colors.GREEN}✓ Matched:{Colors.END}              {matched}")
    print(f"  {Colors.YELLOW}⚠ Mismatched:{Colors.END}           {mismatched}")
    print(f"  {Colors.RED}✗ Errors:{Colors.END}               {errors}")
    print(f"{Colors.BOLD}{'─'*80}{Colors.END}")
    print(f"  Total rows in staging:   {Colors.CYAN}{total_staging:,}{Colors.END}")
    print(f"  Total rows in dev:       {Colors.CYAN}{total_dev:,}{Colors.END}")
    
    if total_staging == total_dev and errors == 0:
        print(f"\n{Colors.BOLD}{Colors.GREEN}✓✓✓ VALIDATION SUCCESSFUL - ALL COUNTS MATCH! ✓✓✓{Colors.END}\n")
    elif mismatched > 0:
        print(f"\n{Colors.BOLD}{Colors.YELLOW}⚠ VALIDATION WARNING - Some tables have different counts{Colors.END}")
        print(f"\n{Colors.YELLOW}Mismatched tables:{Colors.END}")
        for result in validation_results:
            if result['status'].startswith('DIFF'):
                print(f"  • {result['table']}: staging={result['staging']}, dev={result['dev']} ({result['status']})")
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
    
    # Exit code
    if total_staging == total_dev and errors == 0:
        sys.exit(0)
    else:
        sys.exit(1)

if __name__ == '__main__':
    main()
