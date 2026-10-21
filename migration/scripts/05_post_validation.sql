-- ============================================================================
-- POST-MIGRATION VALIDATION SCRIPT
-- ============================================================================
-- Purpose: Verify data migration completed successfully
-- Run on: NEW (target) database with dblink to staging
-- When: AFTER data migration and sequence reset complete
-- 
-- This script validates:
--   1. Row counts match between staging and new database
--   2. All foreign key constraints are valid
--   3. All sequences are correctly set
--   4. Sample data integrity checks
--   5. Target-only tables are empty (as expected)
-- 
-- Any failures indicate migration issues that must be resolved.
-- ============================================================================

\echo '========================================================================'
\echo 'POST-MIGRATION VALIDATION'
\echo '========================================================================'
\echo ''

-- ============================================================================
-- Setup: Enable dblink extension
-- ============================================================================
\echo 'Setting up dblink connection to staging...'
CREATE EXTENSION IF NOT EXISTS dblink;

\set staging_conn 'hostaddr=STAGING_HOST port=5432 dbname=STAGING_DB user=STAGING_USER password=STAGING_PASSWORD'

SELECT dblink_connect('staging', :'staging_conn');
\echo '✓ Connected to staging'
\echo ''

-- ============================================================================
-- VALIDATION 1: Row Count Comparison
-- ============================================================================
\echo '========================================================================'
\echo 'VALIDATION 1: Row Count Comparison (Staging vs New)'
\echo '========================================================================'
\echo ''

WITH row_counts AS (
    -- Level 1
    SELECT 'agent_tool_grants' as table_name, COUNT(*) as new_count FROM agent_tool_grants
    UNION ALL SELECT 'company_playbooks', COUNT(*) FROM company_playbooks
    UNION ALL SELECT 'demo_leads', COUNT(*) FROM demo_leads
    UNION ALL SELECT 'domain_logo_cache', COUNT(*) FROM domain_logo_cache
    UNION ALL SELECT 'mcp_connectors', COUNT(*) FROM mcp_connectors
    UNION ALL SELECT 'organisations', COUNT(*) FROM organisations
    UNION ALL SELECT 'otp_verifications', COUNT(*) FROM otp_verifications
    UNION ALL SELECT 'person_intel_cache', COUNT(*) FROM person_intel_cache
    UNION ALL SELECT 'playbook_kb', COUNT(*) FROM playbook_kb
    UNION ALL SELECT 'shared_webhook', COUNT(*) FROM shared_webhook
    UNION ALL SELECT 'suppressions', COUNT(*) FROM suppressions
    
    -- Level 2
    UNION ALL SELECT 'explorium_organisation_credit_limits', COUNT(*) FROM explorium_organisation_credit_limits
    UNION ALL SELECT 'mcp_tool_grants', COUNT(*) FROM mcp_tool_grants
    UNION ALL SELECT 'partners', COUNT(*) FROM partners
    UNION ALL SELECT 'users', COUNT(*) FROM users
    
    -- Level 3
    UNION ALL SELECT 'apn_sync_runs', COUNT(*) FROM apn_sync_runs
    UNION ALL SELECT 'batches', COUNT(*) FROM batches
    UNION ALL SELECT 'booking_links', COUNT(*) FROM booking_links
    UNION ALL SELECT 'connector_credentials', COUNT(*) FROM connector_credentials
    UNION ALL SELECT 'crm_tokens', COUNT(*) FROM crm_tokens
    UNION ALL SELECT 'cxo_settings', COUNT(*) FROM cxo_settings
    UNION ALL SELECT 'digest_logs', COUNT(*) FROM digest_logs
    UNION ALL SELECT 'explorium_credit_limits', COUNT(*) FROM explorium_credit_limits
    UNION ALL SELECT 'forecast_syncs', COUNT(*) FROM forecast_syncs
    UNION ALL SELECT 'mailbox_watch_state', COUNT(*) FROM mailbox_watch_state
    UNION ALL SELECT 'metrics_snapshots', COUNT(*) FROM metrics_snapshots
    UNION ALL SELECT 'org_events', COUNT(*) FROM org_events
    UNION ALL SELECT 'partner_benchmarks', COUNT(*) FROM partner_benchmarks
    UNION ALL SELECT 'partner_connections', COUNT(*) FROM partner_connections
    UNION ALL SELECT 'partner_contacts', COUNT(*) FROM partner_contacts
    UNION ALL SELECT 'partner_facts', COUNT(*) FROM partner_facts
    UNION ALL SELECT 'partner_readiness', COUNT(*) FROM partner_readiness
    UNION ALL SELECT 'partner_references', COUNT(*) FROM partner_references
    UNION ALL SELECT 'partner_solutions', COUNT(*) FROM partner_solutions
    UNION ALL SELECT 'partner_targets', COUNT(*) FROM partner_targets
    UNION ALL SELECT 'persona', COUNT(*) FROM persona
    UNION ALL SELECT 'qbr_generations', COUNT(*) FROM qbr_generations
    UNION ALL SELECT 'search_index', COUNT(*) FROM search_index
    UNION ALL SELECT 'search_query_log', COUNT(*) FROM search_query_log
    UNION ALL SELECT 'sf_sync_runs', COUNT(*) FROM sf_sync_runs
    UNION ALL SELECT 'user_reference_documents', COUNT(*) FROM user_reference_documents
    UNION ALL SELECT 'user_settings', COUNT(*) FROM user_settings
    UNION ALL SELECT 'user_tokens', COUNT(*) FROM user_tokens
    UNION ALL SELECT 'zoho_sync_runs', COUNT(*) FROM zoho_sync_runs
    
    -- Level 4
    UNION ALL SELECT 'jobs', COUNT(*) FROM jobs
    
    -- Level 5
    UNION ALL SELECT 'account_brief_history', COUNT(*) FROM account_brief_history
    UNION ALL SELECT 'account_briefs', COUNT(*) FROM account_briefs
    UNION ALL SELECT 'account_channel_context', COUNT(*) FROM account_channel_context
    UNION ALL SELECT 'account_drive_folders', COUNT(*) FROM account_drive_folders
    UNION ALL SELECT 'account_notes', COUNT(*) FROM account_notes
    UNION ALL SELECT 'account_route_assessments', COUNT(*) FROM account_route_assessments
    UNION ALL SELECT 'agent_metrics', COUNT(*) FROM agent_metrics
    UNION ALL SELECT 'ai_feedback_signals', COUNT(*) FROM ai_feedback_signals
    UNION ALL SELECT 'alerts', COUNT(*) FROM alerts
    UNION ALL SELECT 'apn_opportunities', COUNT(*) FROM apn_opportunities
    UNION ALL SELECT 'atrisk_checks', COUNT(*) FROM atrisk_checks
    UNION ALL SELECT 'campaign_attributions', COUNT(*) FROM campaign_attributions
    UNION ALL SELECT 'leader_extras', COUNT(*) FROM leader_extras
    UNION ALL SELECT 'leadership_results', COUNT(*) FROM leadership_results
    UNION ALL SELECT 'mailbox_owner_companies', COUNT(*) FROM mailbox_owner_companies
    UNION ALL SELECT 'news_events', COUNT(*) FROM news_events
    UNION ALL SELECT 'partner_engagement_cases', COUNT(*) FROM partner_engagement_cases
    UNION ALL SELECT 'playbook_variants', COUNT(*) FROM playbook_variants
    UNION ALL SELECT 'presentations', COUNT(*) FROM presentations
    UNION ALL SELECT 'relationship_bridges', COUNT(*) FROM relationship_bridges
    UNION ALL SELECT 'results', COUNT(*) FROM results
    UNION ALL SELECT 'sequence_enrollments', COUNT(*) FROM sequence_enrollments
    UNION ALL SELECT 'sf_accounts', COUNT(*) FROM sf_accounts
    UNION ALL SELECT 'sf_deals', COUNT(*) FROM sf_deals
    UNION ALL SELECT 'sf_leads', COUNT(*) FROM sf_leads
    UNION ALL SELECT 'team_notifications', COUNT(*) FROM team_notifications
    UNION ALL SELECT 'webhook_companies', COUNT(*) FROM webhook_companies
    UNION ALL SELECT 'zoho_accounts', COUNT(*) FROM zoho_accounts
    UNION ALL SELECT 'zoho_deals', COUNT(*) FROM zoho_deals
    UNION ALL SELECT 'zoho_leads', COUNT(*) FROM zoho_leads
    
    -- Level 6
    UNION ALL SELECT 'event_invitations', COUNT(*) FROM event_invitations
    UNION ALL SELECT 'sequence_steps', COUNT(*) FROM sequence_steps
    UNION ALL SELECT 'team_notification_comments', COUNT(*) FROM team_notification_comments
    UNION ALL SELECT 'team_notification_reactions', COUNT(*) FROM team_notification_reactions
),
staging_counts AS (
    SELECT * FROM dblink('staging', '
        SELECT table_name, row_count FROM (
            SELECT ''agent_tool_grants'' as table_name, COUNT(*)::bigint as row_count FROM agent_tool_grants
            UNION ALL SELECT ''company_playbooks'', COUNT(*)::bigint FROM company_playbooks
            UNION ALL SELECT ''demo_leads'', COUNT(*)::bigint FROM demo_leads
            UNION ALL SELECT ''domain_logo_cache'', COUNT(*)::bigint FROM domain_logo_cache
            UNION ALL SELECT ''mcp_connectors'', COUNT(*)::bigint FROM mcp_connectors
            UNION ALL SELECT ''organisations'', COUNT(*)::bigint FROM organisations
            UNION ALL SELECT ''otp_verifications'', COUNT(*)::bigint FROM otp_verifications
            UNION ALL SELECT ''person_intel_cache'', COUNT(*)::bigint FROM person_intel_cache
            UNION ALL SELECT ''playbook_kb'', COUNT(*)::bigint FROM playbook_kb
            UNION ALL SELECT ''shared_webhook'', COUNT(*)::bigint FROM shared_webhook
            UNION ALL SELECT ''suppressions'', COUNT(*)::bigint FROM suppressions
            UNION ALL SELECT ''explorium_organisation_credit_limits'', COUNT(*)::bigint FROM explorium_organisation_credit_limits
            UNION ALL SELECT ''mcp_tool_grants'', COUNT(*)::bigint FROM mcp_tool_grants
            UNION ALL SELECT ''partners'', COUNT(*)::bigint FROM partners
            UNION ALL SELECT ''users'', COUNT(*)::bigint FROM users
            UNION ALL SELECT ''apn_sync_runs'', COUNT(*)::bigint FROM apn_sync_runs
            UNION ALL SELECT ''batches'', COUNT(*)::bigint FROM batches
            UNION ALL SELECT ''booking_links'', COUNT(*)::bigint FROM booking_links
            UNION ALL SELECT ''connector_credentials'', COUNT(*)::bigint FROM connector_credentials
            UNION ALL SELECT ''crm_tokens'', COUNT(*)::bigint FROM crm_tokens
            UNION ALL SELECT ''cxo_settings'', COUNT(*)::bigint FROM cxo_settings
            UNION ALL SELECT ''digest_logs'', COUNT(*)::bigint FROM digest_logs
            UNION ALL SELECT ''explorium_credit_limits'', COUNT(*)::bigint FROM explorium_credit_limits
            UNION ALL SELECT ''forecast_syncs'', COUNT(*)::bigint FROM forecast_syncs
            UNION ALL SELECT ''mailbox_watch_state'', COUNT(*)::bigint FROM mailbox_watch_state
            UNION ALL SELECT ''metrics_snapshots'', COUNT(*)::bigint FROM metrics_snapshots
            UNION ALL SELECT ''org_events'', COUNT(*)::bigint FROM org_events
            UNION ALL SELECT ''partner_benchmarks'', COUNT(*)::bigint FROM partner_benchmarks
            UNION ALL SELECT ''partner_connections'', COUNT(*)::bigint FROM partner_connections
            UNION ALL SELECT ''partner_contacts'', COUNT(*)::bigint FROM partner_contacts
            UNION ALL SELECT ''partner_facts'', COUNT(*)::bigint FROM partner_facts
            UNION ALL SELECT ''partner_readiness'', COUNT(*)::bigint FROM partner_readiness
            UNION ALL SELECT ''partner_references'', COUNT(*)::bigint FROM partner_references
            UNION ALL SELECT ''partner_solutions'', COUNT(*)::bigint FROM partner_solutions
            UNION ALL SELECT ''partner_targets'', COUNT(*)::bigint FROM partner_targets
            UNION ALL SELECT ''persona'', COUNT(*)::bigint FROM persona
            UNION ALL SELECT ''qbr_generations'', COUNT(*)::bigint FROM qbr_generations
            UNION ALL SELECT ''search_index'', COUNT(*)::bigint FROM search_index
            UNION ALL SELECT ''search_query_log'', COUNT(*)::bigint FROM search_query_log
            UNION ALL SELECT ''sf_sync_runs'', COUNT(*)::bigint FROM sf_sync_runs
            UNION ALL SELECT ''user_reference_documents'', COUNT(*)::bigint FROM user_reference_documents
            UNION ALL SELECT ''user_settings'', COUNT(*)::bigint FROM user_settings
            UNION ALL SELECT ''user_tokens'', COUNT(*)::bigint FROM user_tokens
            UNION ALL SELECT ''zoho_sync_runs'', COUNT(*)::bigint FROM zoho_sync_runs
            UNION ALL SELECT ''jobs'', COUNT(*)::bigint FROM jobs
            UNION ALL SELECT ''account_brief_history'', COUNT(*)::bigint FROM account_brief_history
            UNION ALL SELECT ''account_briefs'', COUNT(*)::bigint FROM account_briefs
            UNION ALL SELECT ''account_channel_context'', COUNT(*)::bigint FROM account_channel_context
            UNION ALL SELECT ''account_drive_folders'', COUNT(*)::bigint FROM account_drive_folders
            UNION ALL SELECT ''account_notes'', COUNT(*)::bigint FROM account_notes
            UNION ALL SELECT ''account_route_assessments'', COUNT(*)::bigint FROM account_route_assessments
            UNION ALL SELECT ''agent_metrics'', COUNT(*)::bigint FROM agent_metrics
            UNION ALL SELECT ''ai_feedback_signals'', COUNT(*)::bigint FROM ai_feedback_signals
            UNION ALL SELECT ''alerts'', COUNT(*)::bigint FROM alerts
            UNION ALL SELECT ''apn_opportunities'', COUNT(*)::bigint FROM apn_opportunities
            UNION ALL SELECT ''atrisk_checks'', COUNT(*)::bigint FROM atrisk_checks
            UNION ALL SELECT ''campaign_attributions'', COUNT(*)::bigint FROM campaign_attributions
            UNION ALL SELECT ''leader_extras'', COUNT(*)::bigint FROM leader_extras
            UNION ALL SELECT ''leadership_results'', COUNT(*)::bigint FROM leadership_results
            UNION ALL SELECT ''mailbox_owner_companies'', COUNT(*)::bigint FROM mailbox_owner_companies
            UNION ALL SELECT ''news_events'', COUNT(*)::bigint FROM news_events
            UNION ALL SELECT ''partner_engagement_cases'', COUNT(*)::bigint FROM partner_engagement_cases
            UNION ALL SELECT ''playbook_variants'', COUNT(*)::bigint FROM playbook_variants
            UNION ALL SELECT ''presentations'', COUNT(*)::bigint FROM presentations
            UNION ALL SELECT ''relationship_bridges'', COUNT(*)::bigint FROM relationship_bridges
            UNION ALL SELECT ''results'', COUNT(*)::bigint FROM results
            UNION ALL SELECT ''sequence_enrollments'', COUNT(*)::bigint FROM sequence_enrollments
            UNION ALL SELECT ''sf_accounts'', COUNT(*)::bigint FROM sf_accounts
            UNION ALL SELECT ''sf_deals'', COUNT(*)::bigint FROM sf_deals
            UNION ALL SELECT ''sf_leads'', COUNT(*)::bigint FROM sf_leads
            UNION ALL SELECT ''team_notifications'', COUNT(*)::bigint FROM team_notifications
            UNION ALL SELECT ''webhook_companies'', COUNT(*)::bigint FROM webhook_companies
            UNION ALL SELECT ''zoho_accounts'', COUNT(*)::bigint FROM zoho_accounts
            UNION ALL SELECT ''zoho_deals'', COUNT(*)::bigint FROM zoho_deals
            UNION ALL SELECT ''zoho_leads'', COUNT(*)::bigint FROM zoho_leads
            UNION ALL SELECT ''event_invitations'', COUNT(*)::bigint FROM event_invitations
            UNION ALL SELECT ''sequence_steps'', COUNT(*)::bigint FROM sequence_steps
            UNION ALL SELECT ''team_notification_comments'', COUNT(*)::bigint FROM team_notification_comments
            UNION ALL SELECT ''team_notification_reactions'', COUNT(*)::bigint FROM team_notification_reactions
        ) x
    ') AS t(table_name TEXT, staging_count BIGINT)
)
SELECT 
    COALESCE(rc.table_name, sc.table_name) as table_name,
    COALESCE(sc.staging_count, 0) as staging_rows,
    COALESCE(rc.new_count, 0) as new_rows,
    COALESCE(rc.new_count, 0) - COALESCE(sc.staging_count, 0) as difference,
    CASE 
        WHEN COALESCE(rc.new_count, 0) = COALESCE(sc.staging_count, 0) THEN '✓ MATCH'
        ELSE '✗ MISMATCH'
    END as status
FROM row_counts rc
FULL OUTER JOIN staging_counts sc ON rc.table_name = sc.table_name
ORDER BY 
    CASE WHEN COALESCE(rc.new_count, 0) = COALESCE(sc.staging_count, 0) THEN 1 ELSE 0 END,
    table_name;

\echo ''
\echo 'All tables should show "MATCH". Investigate any mismatches.'
\echo ''

-- Summary
WITH row_counts AS (
    SELECT 'agent_tool_grants' as table_name, COUNT(*) as new_count FROM agent_tool_grants
    UNION ALL SELECT 'company_playbooks', COUNT(*) FROM company_playbooks
    -- ... (abbreviated for summary)
),
staging_counts AS (
    SELECT * FROM dblink('staging', '
        SELECT COUNT(*)::bigint FROM (
            SELECT ''dummy'' FROM agent_tool_grants
            UNION ALL SELECT ''dummy'' FROM company_playbooks
            UNION ALL SELECT ''dummy'' FROM demo_leads
            UNION ALL SELECT ''dummy'' FROM domain_logo_cache
            UNION ALL SELECT ''dummy'' FROM mcp_connectors
            UNION ALL SELECT ''dummy'' FROM organisations
            UNION ALL SELECT ''dummy'' FROM otp_verifications
            UNION ALL SELECT ''dummy'' FROM person_intel_cache
            UNION ALL SELECT ''dummy'' FROM playbook_kb
            UNION ALL SELECT ''dummy'' FROM shared_webhook
            UNION ALL SELECT ''dummy'' FROM suppressions
            UNION ALL SELECT ''dummy'' FROM explorium_organisation_credit_limits
            UNION ALL SELECT ''dummy'' FROM mcp_tool_grants
            UNION ALL SELECT ''dummy'' FROM partners
            UNION ALL SELECT ''dummy'' FROM users
            UNION ALL SELECT ''dummy'' FROM apn_sync_runs
            UNION ALL SELECT ''dummy'' FROM batches
            UNION ALL SELECT ''dummy'' FROM booking_links
            UNION ALL SELECT ''dummy'' FROM connector_credentials
            UNION ALL SELECT ''dummy'' FROM crm_tokens
            UNION ALL SELECT ''dummy'' FROM cxo_settings
            UNION ALL SELECT ''dummy'' FROM digest_logs
            UNION ALL SELECT ''dummy'' FROM explorium_credit_limits
            UNION ALL SELECT ''dummy'' FROM forecast_syncs
            UNION ALL SELECT ''dummy'' FROM mailbox_watch_state
            UNION ALL SELECT ''dummy'' FROM metrics_snapshots
            UNION ALL SELECT ''dummy'' FROM org_events
            UNION ALL SELECT ''dummy'' FROM partner_benchmarks
            UNION ALL SELECT ''dummy'' FROM partner_connections
            UNION ALL SELECT ''dummy'' FROM partner_contacts
            UNION ALL SELECT ''dummy'' FROM partner_facts
            UNION ALL SELECT ''dummy'' FROM partner_readiness
            UNION ALL SELECT ''dummy'' FROM partner_references
            UNION ALL SELECT ''dummy'' FROM partner_solutions
            UNION ALL SELECT ''dummy'' FROM partner_targets
            UNION ALL SELECT ''persona'' FROM persona
            UNION ALL SELECT ''dummy'' FROM qbr_generations
            UNION ALL SELECT ''dummy'' FROM search_index
            UNION ALL SELECT ''dummy'' FROM search_query_log
            UNION ALL SELECT ''dummy'' FROM sf_sync_runs
            UNION ALL SELECT ''dummy'' FROM user_reference_documents
            UNION ALL SELECT ''dummy'' FROM user_settings
            UNION ALL SELECT ''dummy'' FROM user_tokens
            UNION ALL SELECT ''dummy'' FROM zoho_sync_runs
            UNION ALL SELECT ''dummy'' FROM jobs
            UNION ALL SELECT ''dummy'' FROM account_brief_history
            UNION ALL SELECT ''dummy'' FROM account_briefs
            UNION ALL SELECT ''dummy'' FROM account_channel_context
            UNION ALL SELECT ''dummy'' FROM account_drive_folders
            UNION ALL SELECT ''dummy'' FROM account_notes
            UNION ALL SELECT ''dummy'' FROM account_route_assessments
            UNION ALL SELECT ''dummy'' FROM agent_metrics
            UNION ALL SELECT ''dummy'' FROM ai_feedback_signals
            UNION ALL SELECT ''dummy'' FROM alerts
            UNION ALL SELECT ''dummy'' FROM apn_opportunities
            UNION ALL SELECT ''dummy'' FROM atrisk_checks
            UNION ALL SELECT ''dummy'' FROM campaign_attributions
            UNION ALL SELECT ''dummy'' FROM leader_extras
            UNION ALL SELECT ''dummy'' FROM leadership_results
            UNION ALL SELECT ''dummy'' FROM mailbox_owner_companies
            UNION ALL SELECT ''dummy'' FROM news_events
            UNION ALL SELECT ''dummy'' FROM partner_engagement_cases
            UNION ALL SELECT ''dummy'' FROM playbook_variants
            UNION ALL SELECT ''dummy'' FROM presentations
            UNION ALL SELECT ''dummy'' FROM relationship_bridges
            UNION ALL SELECT ''dummy'' FROM results
            UNION ALL SELECT ''dummy'' FROM sequence_enrollments
            UNION ALL SELECT ''dummy'' FROM sf_accounts
            UNION ALL SELECT ''dummy'' FROM sf_deals
            UNION ALL SELECT ''dummy'' FROM sf_leads
            UNION ALL SELECT ''dummy'' FROM team_notifications
            UNION ALL SELECT ''dummy'' FROM webhook_companies
            UNION ALL SELECT ''dummy'' FROM zoho_accounts
            UNION ALL SELECT ''dummy'' FROM zoho_deals
            UNION ALL SELECT ''dummy'' FROM zoho_leads
            UNION ALL SELECT ''dummy'' FROM event_invitations
            UNION ALL SELECT ''dummy'' FROM sequence_steps
            UNION ALL SELECT ''dummy'' FROM team_notification_comments
            UNION ALL SELECT ''dummy'' FROM team_notification_reactions
        ) total
    ') AS t(total_staging_rows BIGINT)
)
SELECT 
    'Row Count Summary' as check_name,
    (SELECT SUM(new_count) FROM row_counts) as total_new_rows,
    (SELECT total_staging_rows FROM staging_counts) as total_staging_rows,
    CASE 
        WHEN (SELECT SUM(new_count) FROM row_counts) = (SELECT total_staging_rows FROM staging_counts)
        THEN '✓ PASS'
        ELSE '✗ FAIL'
    END as status;

\echo ''

-- ============================================================================
-- VALIDATION 2: Target-Only Tables (Should Be Empty)
-- ============================================================================
\echo '========================================================================'
\echo 'VALIDATION 2: Target-Only Tables (Should Be Empty)'
\echo '========================================================================'
\echo ''

WITH target_only_counts AS (
    SELECT 'alliance_alerts' as table_name, COUNT(*) as row_count FROM alliance_alerts
    UNION ALL SELECT 'alliance_insights', COUNT(*) FROM alliance_insights
    UNION ALL SELECT 'background_tasks', COUNT(*) FROM background_tasks
    UNION ALL SELECT 'co_sell_readiness_ai', COUNT(*) FROM co_sell_readiness_ai
    UNION ALL SELECT 'co_sell_rooms', COUNT(*) FROM co_sell_rooms
    UNION ALL SELECT 'microsoft_referrals', COUNT(*) FROM microsoft_referrals
    UNION ALL SELECT 'partner_account_overlaps', COUNT(*) FROM partner_account_overlaps
    UNION ALL SELECT 'partner_engagement_events', COUNT(*) FROM partner_engagement_events
    UNION ALL SELECT 'partner_matches', COUNT(*) FROM partner_matches
)
SELECT 
    table_name,
    row_count,
    CASE 
        WHEN row_count = 0 THEN '✓ Empty (expected)'
        ELSE '✗ Has data (unexpected!)'
    END as status
FROM target_only_counts
ORDER BY table_name;

\echo ''
\echo 'All target-only tables should be empty.'
\echo ''

-- ============================================================================
-- VALIDATION 3: Foreign Key Constraint Validation
-- ============================================================================
\echo '========================================================================'
\echo 'VALIDATION 3: Foreign Key Constraint Validation'
\echo '========================================================================'
\echo ''
\echo 'Checking for foreign key violations...'
\echo ''

-- This query finds all FK violations by checking each constraint
-- Note: This is expensive on large databases, but critical for validation

DO $$
DECLARE
    fk_record RECORD;
    violation_count INTEGER;
    total_fks INTEGER := 0;
    valid_fks INTEGER := 0;
    invalid_fks INTEGER := 0;
BEGIN
    FOR fk_record IN 
        SELECT
            tc.table_name as child_table,
            kcu.column_name as child_column,
            ccu.table_name AS parent_table,
            ccu.column_name AS parent_column,
            tc.constraint_name
        FROM information_schema.table_constraints AS tc 
        JOIN information_schema.key_column_usage AS kcu
          ON tc.constraint_name = kcu.constraint_name
          AND tc.table_schema = kcu.table_schema
        JOIN information_schema.constraint_column_usage AS ccu
          ON ccu.constraint_name = tc.constraint_name
          AND ccu.table_schema = tc.table_schema
        WHERE tc.constraint_type = 'FOREIGN KEY'
          AND tc.table_schema = 'public'
        ORDER BY tc.table_name, tc.constraint_name
    LOOP
        total_fks := total_fks + 1;
        
        -- Check for violations
        EXECUTE format('
            SELECT COUNT(*) FROM %I child
            WHERE child.%I IS NOT NULL
              AND NOT EXISTS (
                SELECT 1 FROM %I parent
                WHERE parent.%I = child.%I
              )
        ', fk_record.child_table, fk_record.child_column, 
           fk_record.parent_table, fk_record.parent_column, fk_record.child_column)
        INTO violation_count;
        
        IF violation_count = 0 THEN
            valid_fks := valid_fks + 1;
        ELSE
            invalid_fks := invalid_fks + 1;
            RAISE WARNING 'FK VIOLATION: %.% -> %.% has % orphaned rows',
                fk_record.child_table, fk_record.child_column,
                fk_record.parent_table, fk_record.parent_column,
                violation_count;
        END IF;
    END LOOP;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Foreign Key Validation Summary:';
    RAISE NOTICE '  Total FKs checked: %', total_fks;
    RAISE NOTICE '  Valid FKs: %', valid_fks;
    RAISE NOTICE '  Invalid FKs: %', invalid_fks;
    
    IF invalid_fks = 0 THEN
        RAISE NOTICE '  Status: ✓ ALL FK CONSTRAINTS VALID';
    ELSE
        RAISE NOTICE '  Status: ✗ FK VIOLATIONS FOUND';
        RAISE NOTICE '';
        RAISE NOTICE 'Action required: Fix orphaned rows in tables listed above';
    END IF;
    RAISE NOTICE '========================================';
END $$;

\echo ''

-- ============================================================================
-- VALIDATION 4: Sequence Validation
-- ============================================================================
\echo '========================================================================'
\echo 'VALIDATION 4: Sequence Validation'
\echo '========================================================================'
\echo ''
\echo 'Checking that all sequences are set correctly...'
\echo ''

WITH sequence_validation AS (
    SELECT 
        t.table_name,
        pg_get_serial_sequence('public.' || t.table_name, 'id') as sequence_name,
        CASE 
            WHEN pg_get_serial_sequence('public.' || t.table_name, 'id') IS NOT NULL
            THEN currval(pg_get_serial_sequence('public.' || t.table_name, 'id'))
            ELSE NULL
        END as current_value,
        (SELECT COALESCE(MAX(id), 0)::BIGINT
         FROM (SELECT ('SELECT MAX(id)::BIGINT FROM ' || t.table_name)::TEXT as q) x,
         LATERAL (SELECT * FROM dblink('dbname=' || current_database(), x.q) AS t(max_id BIGINT)) y
        ) as max_id
    FROM (
        SELECT unnest(ARRAY[
            'organisations', 'users', 'partners', 'sequence_enrollments',
            'company_playbooks', 'demo_leads', 'otp_verifications'
        ]) as table_name
    ) t
    WHERE pg_get_serial_sequence('public.' || t.table_name, 'id') IS NOT NULL
)
SELECT 
    table_name,
    sequence_name,
    current_value as sequence_value,
    max_id as max_row_id,
    CASE 
        WHEN current_value >= max_id THEN '✓ OK'
        ELSE '✗ TOO LOW'
    END as status
FROM sequence_validation
ORDER BY table_name;

\echo ''
\echo 'All sequences should show "OK"'
\echo ''

-- ============================================================================
-- VALIDATION 5: Sample Data Integrity
-- ============================================================================
\echo '========================================================================'
\echo 'VALIDATION 5: Sample Data Integrity Checks'
\echo '========================================================================'
\echo ''

-- Check that key relationships exist
\echo 'Checking key data relationships...'
\echo ''

SELECT 
    'Users with valid organisations' as check_name,
    COUNT(*) as count,
    CASE 
        WHEN COUNT(*) > 0 THEN '✓ PASS'
        ELSE '✗ FAIL'
    END as status
FROM users u
JOIN organisations o ON u.organization_id = o.id;

SELECT 
    'Partners with valid organisations' as check_name,
    COUNT(*) as count,
    CASE 
        WHEN COUNT(*) > 0 THEN '✓ PASS'
        ELSE '✗ FAIL'
    END as status
FROM partners p
JOIN organisations o ON p.organisation_id = o.id;

SELECT 
    'Jobs with valid users' as check_name,
    COUNT(*) as count,
    CASE 
        WHEN COUNT(*) > 0 THEN '✓ PASS'
        ELSE '⚠ WARNING (may be OK if no jobs)'
    END as status
FROM jobs j
JOIN users u ON j.user_id = u.id;

SELECT 
    'Sequence enrollments with valid users & jobs' as check_name,
    COUNT(*) as count,
    CASE 
        WHEN COUNT(*) > 0 THEN '✓ PASS'
        ELSE '⚠ WARNING (may be OK if no enrollments)'
    END as status
FROM sequence_enrollments se
JOIN users u ON se.user_id = u.id
JOIN jobs j ON se.job_id = j.id;

\echo ''

-- ============================================================================
-- VALIDATION 6: Table Count Verification
-- ============================================================================
\echo '========================================================================'
\echo 'VALIDATION 6: Table Count Verification'
\echo '========================================================================'
\echo ''

SELECT 
    COUNT(*) as total_tables,
    CASE 
        WHEN COUNT(*) = 88 THEN '✓ Expected 88 tables'
        ELSE '✗ Expected 88, found ' || COUNT(*)::TEXT
    END as status
FROM pg_tables 
WHERE schemaname = 'public';

\echo ''

-- ============================================================================
-- Cleanup: Disconnect from staging
-- ============================================================================
SELECT dblink_disconnect('staging');

-- ============================================================================
-- Final Summary
-- ============================================================================
\echo '========================================================================'
\echo 'POST-MIGRATION VALIDATION SUMMARY'
\echo '========================================================================'
\echo ''
\echo 'Review the results above. All checks should show PASS or OK.'
\echo ''
\echo 'If any validation failed:'
\echo '  1. Review the specific failure details'
\echo '  2. Check migration logs for errors'
\echo '  3. Re-run failed migration steps'
\echo '  4. Re-run this validation'
\echo ''
\echo 'If all validations passed:'
\echo '  ✓ Data migration completed successfully'
\echo '  ✓ Row counts match staging'
\echo '  ✓ All foreign keys valid'
\echo '  ✓ Sequences correctly set'
\echo ''
\echo 'Final steps:'
\echo '  1. Set alembic_version to microservices head'
\echo '  2. Run: make alembic-check (should show 0 ops)'
\echo '  3. Run application smoke tests'
\echo '  4. Monitor application logs for issues'
\echo ''
\echo '========================================================================'
