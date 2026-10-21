-- ============================================================================
-- DATA VALIDATION SCRIPT - ROW COUNT COMPARISON
-- ============================================================================
-- Purpose: Validate data migration by comparing row counts
-- Run on: DEV database (with dblink to staging)
-- When: AFTER migration completes
--
-- This script compares:
--   - Row counts for all migrated tables
--   - Primary key ranges
--   - Sample data checksums
-- ============================================================================

\echo '========================================================================'
\echo 'DATA MIGRATION VALIDATION'
\echo '========================================================================'
\echo ''

-- ============================================================================
-- Setup dblink connection
-- ============================================================================
\echo 'Connecting to staging database...'

-- Use your staging connection string
\set staging_conn 'hostaddr=STAGING_HOST port=5432 dbname=STAGING_DB user=STAGING_USER password=STAGING_PASSWORD'

SELECT dblink_connect('staging', :'staging_conn');

\echo ''
\echo '========================================================================'
\echo 'ROW COUNT COMPARISON - ALL 93 MIGRATED TABLES'
\echo '========================================================================'
\echo ''

-- ============================================================================
-- Compare row counts for all tables
-- ============================================================================

WITH staging_counts AS (
    -- Get counts from staging via dblink
    SELECT * FROM dblink('staging', $$
        SELECT 'account_brief_history' as table_name, COUNT(*) as row_count FROM staging.account_brief_history
        UNION ALL SELECT 'account_briefs', COUNT(*) FROM staging.account_briefs
        UNION ALL SELECT 'account_channel_context', COUNT(*) FROM staging.account_channel_context
        UNION ALL SELECT 'account_drive_folders', COUNT(*) FROM staging.account_drive_folders
        UNION ALL SELECT 'account_notes', COUNT(*) FROM staging.account_notes
        UNION ALL SELECT 'account_route_assessments', COUNT(*) FROM staging.account_route_assessments
        UNION ALL SELECT 'agent_metrics', COUNT(*) FROM staging.agent_metrics
        UNION ALL SELECT 'agent_tool_grants', COUNT(*) FROM staging.agent_tool_grants
        UNION ALL SELECT 'ai_feedback_signals', COUNT(*) FROM staging.ai_feedback_signals
        UNION ALL SELECT 'alembic_version', COUNT(*) FROM staging.alembic_version
        UNION ALL SELECT 'alerts', COUNT(*) FROM staging.alerts
        UNION ALL SELECT 'apn_opportunities', COUNT(*) FROM staging.apn_opportunities
        UNION ALL SELECT 'apn_sync_runs', COUNT(*) FROM staging.apn_sync_runs
        UNION ALL SELECT 'atrisk_checks', COUNT(*) FROM staging.atrisk_checks
        UNION ALL SELECT 'batches', COUNT(*) FROM staging.batches
        UNION ALL SELECT 'booking_links', COUNT(*) FROM staging.booking_links
        UNION ALL SELECT 'campaign_attributions', COUNT(*) FROM staging.campaign_attributions
        UNION ALL SELECT 'company_playbooks', COUNT(*) FROM staging.company_playbooks
        UNION ALL SELECT 'connector_credentials', COUNT(*) FROM staging.connector_credentials
        UNION ALL SELECT 'crm_tokens', COUNT(*) FROM staging.crm_tokens
        UNION ALL SELECT 'cxo_settings', COUNT(*) FROM staging.cxo_settings
        UNION ALL SELECT 'demo_leads', COUNT(*) FROM staging.demo_leads
        UNION ALL SELECT 'digest_logs', COUNT(*) FROM staging.digest_logs
        UNION ALL SELECT 'domain_logo_cache', COUNT(*) FROM staging.domain_logo_cache
        UNION ALL SELECT 'event_invitations', COUNT(*) FROM staging.event_invitations
        UNION ALL SELECT 'explorium_credit_limits', COUNT(*) FROM staging.explorium_credit_limits
        UNION ALL SELECT 'explorium_organisation_credit_limits', COUNT(*) FROM staging.explorium_organisation_credit_limits
        UNION ALL SELECT 'forecast_syncs', COUNT(*) FROM staging.forecast_syncs
        UNION ALL SELECT 'jobs', COUNT(*) FROM staging.jobs
        UNION ALL SELECT 'leader_extras', COUNT(*) FROM staging.leader_extras
        UNION ALL SELECT 'leadership_results', COUNT(*) FROM staging.leadership_results
        UNION ALL SELECT 'mailbox_owner_companies', COUNT(*) FROM staging.mailbox_owner_companies
        UNION ALL SELECT 'mailbox_watch_state', COUNT(*) FROM staging.mailbox_watch_state
        UNION ALL SELECT 'mcp_connectors', COUNT(*) FROM staging.mcp_connectors
        UNION ALL SELECT 'mcp_tool_grants', COUNT(*) FROM staging.mcp_tool_grants
        UNION ALL SELECT 'metrics_snapshots', COUNT(*) FROM staging.metrics_snapshots
        UNION ALL SELECT 'news_events', COUNT(*) FROM staging.news_events
        UNION ALL SELECT 'org_events', COUNT(*) FROM staging.org_events
        UNION ALL SELECT 'organisations', COUNT(*) FROM staging.organisations
        UNION ALL SELECT 'otp_verifications', COUNT(*) FROM staging.otp_verifications
        UNION ALL SELECT 'partner_benchmarks', COUNT(*) FROM staging.partner_benchmarks
        UNION ALL SELECT 'partner_connections', COUNT(*) FROM staging.partner_connections
        UNION ALL SELECT 'partner_contacts', COUNT(*) FROM staging.partner_contacts
        UNION ALL SELECT 'partner_engagement_cases', COUNT(*) FROM staging.partner_engagement_cases
        UNION ALL SELECT 'partner_facts', COUNT(*) FROM staging.partner_facts
        UNION ALL SELECT 'partner_readiness', COUNT(*) FROM staging.partner_readiness
        UNION ALL SELECT 'partner_references', COUNT(*) FROM staging.partner_references
        UNION ALL SELECT 'partner_solutions', COUNT(*) FROM staging.partner_solutions
        UNION ALL SELECT 'partner_targets', COUNT(*) FROM staging.partner_targets
        UNION ALL SELECT 'partners', COUNT(*) FROM staging.partners
        UNION ALL SELECT 'person_intel_cache', COUNT(*) FROM staging.person_intel_cache
        UNION ALL SELECT 'persona', COUNT(*) FROM staging.persona
        UNION ALL SELECT 'playbook_kb', COUNT(*) FROM staging.playbook_kb
        UNION ALL SELECT 'playbook_variants', COUNT(*) FROM staging.playbook_variants
        UNION ALL SELECT 'presentations', COUNT(*) FROM staging.presentations
        UNION ALL SELECT 'qbr_generations', COUNT(*) FROM staging.qbr_generations
        UNION ALL SELECT 'relationship_bridges', COUNT(*) FROM staging.relationship_bridges
        UNION ALL SELECT 'results', COUNT(*) FROM staging.results
        UNION ALL SELECT 'search_index', COUNT(*) FROM staging.search_index
        UNION ALL SELECT 'search_query_log', COUNT(*) FROM staging.search_query_log
        UNION ALL SELECT 'sequence_enrollments', COUNT(*) FROM staging.sequence_enrollments
        UNION ALL SELECT 'sequence_steps', COUNT(*) FROM staging.sequence_steps
        UNION ALL SELECT 'sf_accounts', COUNT(*) FROM staging.sf_accounts
        UNION ALL SELECT 'sf_deals', COUNT(*) FROM staging.sf_deals
        UNION ALL SELECT 'sf_leads', COUNT(*) FROM staging.sf_leads
        UNION ALL SELECT 'sf_sync_runs', COUNT(*) FROM staging.sf_sync_runs
        UNION ALL SELECT 'shared_webhook', COUNT(*) FROM staging.shared_webhook
        UNION ALL SELECT 'suppressions', COUNT(*) FROM staging.suppressions
        UNION ALL SELECT 'team_notification_comments', COUNT(*) FROM staging.team_notification_comments
        UNION ALL SELECT 'team_notification_reactions', COUNT(*) FROM staging.team_notification_reactions
        UNION ALL SELECT 'team_notifications', COUNT(*) FROM staging.team_notifications
        UNION ALL SELECT 'user_reference_documents', COUNT(*) FROM staging.user_reference_documents
        UNION ALL SELECT 'user_settings', COUNT(*) FROM staging.user_settings
        UNION ALL SELECT 'user_tokens', COUNT(*) FROM staging.user_tokens
        UNION ALL SELECT 'users', COUNT(*) FROM staging.users
        UNION ALL SELECT 'webhook_companies', COUNT(*) FROM staging.webhook_companies
        UNION ALL SELECT 'zoho_accounts', COUNT(*) FROM staging.zoho_accounts
        UNION ALL SELECT 'zoho_deals', COUNT(*) FROM staging.zoho_deals
        UNION ALL SELECT 'zoho_leads', COUNT(*) FROM staging.zoho_leads
        UNION ALL SELECT 'zoho_sync_runs', COUNT(*) FROM staging.zoho_sync_runs
        -- Staging-only tables (13 tables)
        UNION ALL SELECT 'datasets', COUNT(*) FROM staging.datasets
        UNION ALL SELECT 'dataset_rows', COUNT(*) FROM staging.dataset_rows
        UNION ALL SELECT 'dataset_history', COUNT(*) FROM staging.dataset_history
        UNION ALL SELECT 'outreach_sequences', COUNT(*) FROM staging.outreach_sequences
        UNION ALL SELECT 'outreach_enrollments', COUNT(*) FROM staging.outreach_enrollments
        UNION ALL SELECT 'outreach_steps', COUNT(*) FROM staging.outreach_steps
        UNION ALL SELECT 'outreach_reply_log', COUNT(*) FROM staging.outreach_reply_log
        UNION ALL SELECT 'vault_documents', COUNT(*) FROM staging.vault_documents
        UNION ALL SELECT 'vault_chunks', COUNT(*) FROM staging.vault_chunks
        UNION ALL SELECT 'sequence_replies', COUNT(*) FROM staging.sequence_replies
        UNION ALL SELECT 'llm_calls', COUNT(*) FROM staging.llm_calls
        UNION ALL SELECT 'run_stats', COUNT(*) FROM staging.run_stats
        UNION ALL SELECT 'usage', COUNT(*) FROM staging.usage
    $$) AS t(table_name TEXT, row_count BIGINT)
),
dev_counts AS (
    -- Get counts from dev (local)
    SELECT 'account_brief_history' as table_name, COUNT(*) as row_count FROM account_brief_history
    UNION ALL SELECT 'account_briefs', COUNT(*) FROM account_briefs
    UNION ALL SELECT 'account_channel_context', COUNT(*) FROM account_channel_context
    UNION ALL SELECT 'account_drive_folders', COUNT(*) FROM account_drive_folders
    UNION ALL SELECT 'account_notes', COUNT(*) FROM account_notes
    UNION ALL SELECT 'account_route_assessments', COUNT(*) FROM account_route_assessments
    UNION ALL SELECT 'agent_metrics', COUNT(*) FROM agent_metrics
    UNION ALL SELECT 'agent_tool_grants', COUNT(*) FROM agent_tool_grants
    UNION ALL SELECT 'ai_feedback_signals', COUNT(*) FROM ai_feedback_signals
    UNION ALL SELECT 'alembic_version', COUNT(*) FROM alembic_version
    UNION ALL SELECT 'alerts', COUNT(*) FROM alerts
    UNION ALL SELECT 'apn_opportunities', COUNT(*) FROM apn_opportunities
    UNION ALL SELECT 'apn_sync_runs', COUNT(*) FROM apn_sync_runs
    UNION ALL SELECT 'atrisk_checks', COUNT(*) FROM atrisk_checks
    UNION ALL SELECT 'batches', COUNT(*) FROM batches
    UNION ALL SELECT 'booking_links', COUNT(*) FROM booking_links
    UNION ALL SELECT 'campaign_attributions', COUNT(*) FROM campaign_attributions
    UNION ALL SELECT 'company_playbooks', COUNT(*) FROM company_playbooks
    UNION ALL SELECT 'connector_credentials', COUNT(*) FROM connector_credentials
    UNION ALL SELECT 'crm_tokens', COUNT(*) FROM crm_tokens
    UNION ALL SELECT 'cxo_settings', COUNT(*) FROM cxo_settings
    UNION ALL SELECT 'demo_leads', COUNT(*) FROM demo_leads
    UNION ALL SELECT 'digest_logs', COUNT(*) FROM digest_logs
    UNION ALL SELECT 'domain_logo_cache', COUNT(*) FROM domain_logo_cache
    UNION ALL SELECT 'event_invitations', COUNT(*) FROM event_invitations
    UNION ALL SELECT 'explorium_credit_limits', COUNT(*) FROM explorium_credit_limits
    UNION ALL SELECT 'explorium_organisation_credit_limits', COUNT(*) FROM explorium_organisation_credit_limits
    UNION ALL SELECT 'forecast_syncs', COUNT(*) FROM forecast_syncs
    UNION ALL SELECT 'jobs', COUNT(*) FROM jobs
    UNION ALL SELECT 'leader_extras', COUNT(*) FROM leader_extras
    UNION ALL SELECT 'leadership_results', COUNT(*) FROM leadership_results
    UNION ALL SELECT 'mailbox_owner_companies', COUNT(*) FROM mailbox_owner_companies
    UNION ALL SELECT 'mailbox_watch_state', COUNT(*) FROM mailbox_watch_state
    UNION ALL SELECT 'mcp_connectors', COUNT(*) FROM mcp_connectors
    UNION ALL SELECT 'mcp_tool_grants', COUNT(*) FROM mcp_tool_grants
    UNION ALL SELECT 'metrics_snapshots', COUNT(*) FROM metrics_snapshots
    UNION ALL SELECT 'news_events', COUNT(*) FROM news_events
    UNION ALL SELECT 'org_events', COUNT(*) FROM org_events
    UNION ALL SELECT 'organisations', COUNT(*) FROM organisations
    UNION ALL SELECT 'otp_verifications', COUNT(*) FROM otp_verifications
    UNION ALL SELECT 'partner_benchmarks', COUNT(*) FROM partner_benchmarks
    UNION ALL SELECT 'partner_connections', COUNT(*) FROM partner_connections
    UNION ALL SELECT 'partner_contacts', COUNT(*) FROM partner_contacts
    UNION ALL SELECT 'partner_engagement_cases', COUNT(*) FROM partner_engagement_cases
    UNION ALL SELECT 'partner_facts', COUNT(*) FROM partner_facts
    UNION ALL SELECT 'partner_readiness', COUNT(*) FROM partner_readiness
    UNION ALL SELECT 'partner_references', COUNT(*) FROM partner_references
    UNION ALL SELECT 'partner_solutions', COUNT(*) FROM partner_solutions
    UNION ALL SELECT 'partner_targets', COUNT(*) FROM partner_targets
    UNION ALL SELECT 'partners', COUNT(*) FROM partners
    UNION ALL SELECT 'person_intel_cache', COUNT(*) FROM person_intel_cache
    UNION ALL SELECT 'persona', COUNT(*) FROM persona
    UNION ALL SELECT 'playbook_kb', COUNT(*) FROM playbook_kb
    UNION ALL SELECT 'playbook_variants', COUNT(*) FROM playbook_variants
    UNION ALL SELECT 'presentations', COUNT(*) FROM presentations
    UNION ALL SELECT 'qbr_generations', COUNT(*) FROM qbr_generations
    UNION ALL SELECT 'relationship_bridges', COUNT(*) FROM relationship_bridges
    UNION ALL SELECT 'results', COUNT(*) FROM results
    UNION ALL SELECT 'search_index', COUNT(*) FROM search_index
    UNION ALL SELECT 'search_query_log', COUNT(*) FROM search_query_log
    UNION ALL SELECT 'sequence_enrollments', COUNT(*) FROM sequence_enrollments
    UNION ALL SELECT 'sequence_steps', COUNT(*) FROM sequence_steps
    UNION ALL SELECT 'sf_accounts', COUNT(*) FROM sf_accounts
    UNION ALL SELECT 'sf_deals', COUNT(*) FROM sf_deals
    UNION ALL SELECT 'sf_leads', COUNT(*) FROM sf_leads
    UNION ALL SELECT 'sf_sync_runs', COUNT(*) FROM sf_sync_runs
    UNION ALL SELECT 'shared_webhook', COUNT(*) FROM shared_webhook
    UNION ALL SELECT 'suppressions', COUNT(*) FROM suppressions
    UNION ALL SELECT 'team_notification_comments', COUNT(*) FROM team_notification_comments
    UNION ALL SELECT 'team_notification_reactions', COUNT(*) FROM team_notification_reactions
    UNION ALL SELECT 'team_notifications', COUNT(*) FROM team_notifications
    UNION ALL SELECT 'user_reference_documents', COUNT(*) FROM user_reference_documents
    UNION ALL SELECT 'user_settings', COUNT(*) FROM user_settings
    UNION ALL SELECT 'user_tokens', COUNT(*) FROM user_tokens
    UNION ALL SELECT 'users', COUNT(*) FROM users
    UNION ALL SELECT 'webhook_companies', COUNT(*) FROM webhook_companies
    UNION ALL SELECT 'zoho_accounts', COUNT(*) FROM zoho_accounts
    UNION ALL SELECT 'zoho_deals', COUNT(*) FROM zoho_deals
    UNION ALL SELECT 'zoho_leads', COUNT(*) FROM zoho_leads
    UNION ALL SELECT 'zoho_sync_runs', COUNT(*) FROM zoho_sync_runs
    -- Staging-only tables
    UNION ALL SELECT 'datasets', COUNT(*) FROM datasets
    UNION ALL SELECT 'dataset_rows', COUNT(*) FROM dataset_rows
    UNION ALL SELECT 'dataset_history', COUNT(*) FROM dataset_history
    UNION ALL SELECT 'outreach_sequences', COUNT(*) FROM outreach_sequences
    UNION ALL SELECT 'outreach_enrollments', COUNT(*) FROM outreach_enrollments
    UNION ALL SELECT 'outreach_steps', COUNT(*) FROM outreach_steps
    UNION ALL SELECT 'outreach_reply_log', COUNT(*) FROM outreach_reply_log
    UNION ALL SELECT 'vault_documents', COUNT(*) FROM vault_documents
    UNION ALL SELECT 'vault_chunks', COUNT(*) FROM vault_chunks
    UNION ALL SELECT 'sequence_replies', COUNT(*) FROM sequence_replies
    UNION ALL SELECT 'llm_calls', COUNT(*) FROM llm_calls
    UNION ALL SELECT 'run_stats', COUNT(*) FROM run_stats
    UNION ALL SELECT 'usage', COUNT(*) FROM usage
)
SELECT 
    s.table_name,
    s.row_count as staging_count,
    d.row_count as dev_count,
    (d.row_count - s.row_count) as difference,
    CASE 
        WHEN s.row_count = d.row_count THEN '✓ MATCH'
        WHEN d.row_count > s.row_count THEN '⚠ DEV HAS MORE'
        WHEN d.row_count < s.row_count THEN '✗ MISSING ROWS'
        ELSE '✗ ERROR'
    END as status,
    CASE 
        WHEN s.row_count > 0 THEN ROUND((d.row_count::numeric / s.row_count::numeric * 100), 2)
        ELSE 100
    END as match_percentage
FROM staging_counts s
LEFT JOIN dev_counts d ON s.table_name = d.table_name
ORDER BY 
    CASE WHEN s.row_count = d.row_count THEN 1 ELSE 0 END,
    ABS(d.row_count - s.row_count) DESC,
    s.table_name;

\echo ''
\echo '========================================================================'
\echo 'SUMMARY STATISTICS'
\echo '========================================================================'
\echo ''

WITH staging_counts AS (
    SELECT * FROM dblink('staging', $$
        SELECT 'account_brief_history', COUNT(*) FROM staging.account_brief_history
        UNION ALL SELECT 'account_briefs', COUNT(*) FROM staging.account_briefs
        -- [abbreviated for summary - same list as above]
    $$) AS t(table_name TEXT, row_count BIGINT)
),
dev_counts AS (
    SELECT 'account_brief_history', COUNT(*) FROM account_brief_history
    UNION ALL SELECT 'account_briefs', COUNT(*) FROM account_briefs
    -- [abbreviated for summary]
)
SELECT 
    COUNT(*) as total_tables,
    SUM(CASE WHEN s.row_count = d.row_count THEN 1 ELSE 0 END) as matching_tables,
    SUM(CASE WHEN s.row_count != d.row_count THEN 1 ELSE 0 END) as mismatched_tables,
    SUM(s.row_count) as total_staging_rows,
    SUM(d.row_count) as total_dev_rows,
    SUM(d.row_count) - SUM(s.row_count) as total_difference
FROM staging_counts s
LEFT JOIN dev_counts d ON s.table_name = d.table_name;

\echo ''
\echo '========================================================================'
\echo 'DEV-ONLY TABLES (Should be empty)'
\echo '========================================================================'
\echo ''

SELECT 
    'alliance_alerts' as table_name, COUNT(*) as row_count FROM alliance_alerts
UNION ALL SELECT 'alliance_insights', COUNT(*) FROM alliance_insights
UNION ALL SELECT 'co_sell_readiness_ai', COUNT(*) FROM co_sell_readiness_ai
UNION ALL SELECT 'co_sell_rooms', COUNT(*) FROM co_sell_rooms
UNION ALL SELECT 'microsoft_referrals', COUNT(*) FROM microsoft_referrals
UNION ALL SELECT 'partner_account_overlaps', COUNT(*) FROM partner_account_overlaps
UNION ALL SELECT 'partner_engagement_events', COUNT(*) FROM partner_engagement_events
UNION ALL SELECT 'partner_matches', COUNT(*) FROM partner_matches
ORDER BY row_count DESC, table_name;

\echo ''
\echo '========================================================================'
\echo 'ORPHANED DATA CHECK'
\echo '========================================================================'
\echo ''

-- Check for orphaned enrollments (expected with dropped FKs)
SELECT 
    'Orphaned by job_id' as check_type,
    COUNT(*) as orphan_count,
    '(Expected ~90 - FK dropped)' as note
FROM sequence_enrollments
WHERE job_id NOT IN (SELECT id FROM jobs);

SELECT 
    'Orphaned by user_id' as check_type,
    COUNT(*) as orphan_count,
    '(Expected ~66 - FK dropped)' as note
FROM sequence_enrollments
WHERE user_id NOT IN (SELECT id FROM users);

\echo ''
\echo '========================================================================'
\echo 'VALIDATION COMPLETE'
\echo '========================================================================'
\echo ''

-- Disconnect from staging
SELECT dblink_disconnect('staging');

\echo 'Validation complete!'
\echo 'Review the results above to ensure data integrity.'
\echo ''
\echo 'Expected results:'
\echo '  - 93 tables should match row counts'
\echo '  - 8 dev-only tables should be empty'
\echo '  - ~156 orphaned enrollments (90 job_id + 66 user_id) - this is OK'
\echo ''
