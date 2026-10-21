-- ============================================================================
-- SEQUENCE RESET SCRIPT
-- ============================================================================
-- Purpose: Reset all serial sequences to MAX(id) + 1 after data migration
-- Run on: NEW (target) database
-- When: AFTER data migration completes (03_migrate_data.sql)
-- 
-- Why this is needed:
--   When copying rows with explicit IDs, PostgreSQL sequences are not updated.
--   The next INSERT without an explicit ID would try to use the sequence's
--   current value, causing a duplicate key error if that ID already exists.
-- 
-- This script resets 63 tables with SERIAL primary keys.
-- 
-- Tables with non-serial PKs (VARCHAR, UUID, composite) don't need this:
--   - jobs, batches, mcp_connectors, agent_tool_grants, mcp_tool_grants
--   - account_briefs, leadership_results, user_settings, explorium_*
--   - webhook_companies, domain_logo_cache
-- ============================================================================

\echo '========================================================================'
\echo 'SEQUENCE RESET: Updating all serial sequences after data migration'
\echo '========================================================================'
\echo ''

-- ============================================================================
-- Level 1 Tables (8 with serial PKs)
-- ============================================================================
\echo 'Level 1 tables...'

SELECT setval(pg_get_serial_sequence('company_playbooks', 'id'), COALESCE(MAX(id), 1)) FROM company_playbooks;
\echo '  ✓ company_playbooks sequence reset'

SELECT setval(pg_get_serial_sequence('demo_leads', 'id'), COALESCE(MAX(id), 1)) FROM demo_leads;
\echo '  ✓ demo_leads sequence reset'

SELECT setval(pg_get_serial_sequence('organisations', 'id'), COALESCE(MAX(id), 1)) FROM organisations;
\echo '  ✓ organisations sequence reset'

SELECT setval(pg_get_serial_sequence('otp_verifications', 'id'), COALESCE(MAX(id), 1)) FROM otp_verifications;
\echo '  ✓ otp_verifications sequence reset'

SELECT setval(pg_get_serial_sequence('person_intel_cache', 'id'), COALESCE(MAX(id), 1)) FROM person_intel_cache;
\echo '  ✓ person_intel_cache sequence reset'

SELECT setval(pg_get_serial_sequence('playbook_kb', 'id'), COALESCE(MAX(id), 1)) FROM playbook_kb;
\echo '  ✓ playbook_kb sequence reset'

SELECT setval(pg_get_serial_sequence('shared_webhook', 'id'), COALESCE(MAX(id), 1)) FROM shared_webhook;
\echo '  ✓ shared_webhook sequence reset'

SELECT setval(pg_get_serial_sequence('suppressions', 'id'), COALESCE(MAX(id), 1)) FROM suppressions;
\echo '  ✓ suppressions sequence reset'

\echo ''

-- ============================================================================
-- Level 2 Tables (2 with serial PKs)
-- ============================================================================
\echo 'Level 2 tables...'

SELECT setval(pg_get_serial_sequence('partners', 'id'), COALESCE(MAX(id), 1)) FROM partners;
\echo '  ✓ partners sequence reset'

SELECT setval(pg_get_serial_sequence('users', 'id'), COALESCE(MAX(id), 1)) FROM users;
\echo '  ✓ users sequence reset'

\echo ''

-- ============================================================================
-- Level 3 Tables (18 with serial PKs)
-- ============================================================================
\echo 'Level 3 tables...'

SELECT setval(pg_get_serial_sequence('apn_sync_runs', 'id'), COALESCE(MAX(id), 1)) FROM apn_sync_runs;
\echo '  ✓ apn_sync_runs sequence reset'

SELECT setval(pg_get_serial_sequence('booking_links', 'id'), COALESCE(MAX(id), 1)) FROM booking_links;
\echo '  ✓ booking_links sequence reset'

SELECT setval(pg_get_serial_sequence('connector_credentials', 'id'), COALESCE(MAX(id), 1)) FROM connector_credentials;
\echo '  ✓ connector_credentials sequence reset'

SELECT setval(pg_get_serial_sequence('crm_tokens', 'id'), COALESCE(MAX(id), 1)) FROM crm_tokens;
\echo '  ✓ crm_tokens sequence reset'

SELECT setval(pg_get_serial_sequence('cxo_settings', 'id'), COALESCE(MAX(id), 1)) FROM cxo_settings;
\echo '  ✓ cxo_settings sequence reset'

SELECT setval(pg_get_serial_sequence('digest_logs', 'id'), COALESCE(MAX(id), 1)) FROM digest_logs;
\echo '  ✓ digest_logs sequence reset'

SELECT setval(pg_get_serial_sequence('explorium_credit_limits', 'id'), COALESCE(MAX(id), 1)) FROM explorium_credit_limits;
\echo '  ✓ explorium_credit_limits sequence reset'

SELECT setval(pg_get_serial_sequence('forecast_syncs', 'id'), COALESCE(MAX(id), 1)) FROM forecast_syncs;
\echo '  ✓ forecast_syncs sequence reset'

SELECT setval(pg_get_serial_sequence('mailbox_watch_state', 'id'), COALESCE(MAX(id), 1)) FROM mailbox_watch_state;
\echo '  ✓ mailbox_watch_state sequence reset'

SELECT setval(pg_get_serial_sequence('metrics_snapshots', 'id'), COALESCE(MAX(id), 1)) FROM metrics_snapshots;
\echo '  ✓ metrics_snapshots sequence reset'

SELECT setval(pg_get_serial_sequence('org_events', 'id'), COALESCE(MAX(id), 1)) FROM org_events;
\echo '  ✓ org_events sequence reset'

SELECT setval(pg_get_serial_sequence('partner_benchmarks', 'id'), COALESCE(MAX(id), 1)) FROM partner_benchmarks;
\echo '  ✓ partner_benchmarks sequence reset'

SELECT setval(pg_get_serial_sequence('partner_connections', 'id'), COALESCE(MAX(id), 1)) FROM partner_connections;
\echo '  ✓ partner_connections sequence reset'

SELECT setval(pg_get_serial_sequence('partner_contacts', 'id'), COALESCE(MAX(id), 1)) FROM partner_contacts;
\echo '  ✓ partner_contacts sequence reset'

SELECT setval(pg_get_serial_sequence('partner_facts', 'id'), COALESCE(MAX(id), 1)) FROM partner_facts;
\echo '  ✓ partner_facts sequence reset'

SELECT setval(pg_get_serial_sequence('partner_readiness', 'id'), COALESCE(MAX(id), 1)) FROM partner_readiness;
\echo '  ✓ partner_readiness sequence reset'

SELECT setval(pg_get_serial_sequence('partner_references', 'id'), COALESCE(MAX(id), 1)) FROM partner_references;
\echo '  ✓ partner_references sequence reset'

SELECT setval(pg_get_serial_sequence('partner_solutions', 'id'), COALESCE(MAX(id), 1)) FROM partner_solutions;
\echo '  ✓ partner_solutions sequence reset'

SELECT setval(pg_get_serial_sequence('partner_targets', 'id'), COALESCE(MAX(id), 1)) FROM partner_targets;
\echo '  ✓ partner_targets sequence reset'

SELECT setval(pg_get_serial_sequence('persona', 'id'), COALESCE(MAX(id), 1)) FROM persona;
\echo '  ✓ persona sequence reset'

SELECT setval(pg_get_serial_sequence('qbr_generations', 'id'), COALESCE(MAX(id), 1)) FROM qbr_generations;
\echo '  ✓ qbr_generations sequence reset'

SELECT setval(pg_get_serial_sequence('search_index', 'id'), COALESCE(MAX(id), 1)) FROM search_index;
\echo '  ✓ search_index sequence reset'

SELECT setval(pg_get_serial_sequence('search_query_log', 'id'), COALESCE(MAX(id), 1)) FROM search_query_log;
\echo '  ✓ search_query_log sequence reset'

SELECT setval(pg_get_serial_sequence('sf_sync_runs', 'id'), COALESCE(MAX(id), 1)) FROM sf_sync_runs;
\echo '  ✓ sf_sync_runs sequence reset'

SELECT setval(pg_get_serial_sequence('user_reference_documents', 'id'), COALESCE(MAX(id), 1)) FROM user_reference_documents;
\echo '  ✓ user_reference_documents sequence reset'

SELECT setval(pg_get_serial_sequence('user_tokens', 'id'), COALESCE(MAX(id), 1)) FROM user_tokens;
\echo '  ✓ user_tokens sequence reset'

SELECT setval(pg_get_serial_sequence('zoho_sync_runs', 'id'), COALESCE(MAX(id), 1)) FROM zoho_sync_runs;
\echo '  ✓ zoho_sync_runs sequence reset'

\echo ''

-- ============================================================================
-- Level 4 Tables (0 with serial PKs)
-- ============================================================================
-- jobs.id is VARCHAR, no sequence to reset
\echo 'Level 4 tables: jobs uses VARCHAR PK, no sequence needed'
\echo ''

-- ============================================================================
-- Level 5 Tables (28 with serial PKs)
-- ============================================================================
\echo 'Level 5 tables...'

SELECT setval(pg_get_serial_sequence('account_brief_history', 'id'), COALESCE(MAX(id), 1)) FROM account_brief_history;
\echo '  ✓ account_brief_history sequence reset'

SELECT setval(pg_get_serial_sequence('account_channel_context', 'id'), COALESCE(MAX(id), 1)) FROM account_channel_context;
\echo '  ✓ account_channel_context sequence reset'

SELECT setval(pg_get_serial_sequence('account_drive_folders', 'id'), COALESCE(MAX(id), 1)) FROM account_drive_folders;
\echo '  ✓ account_drive_folders sequence reset'

SELECT setval(pg_get_serial_sequence('account_notes', 'id'), COALESCE(MAX(id), 1)) FROM account_notes;
\echo '  ✓ account_notes sequence reset'

SELECT setval(pg_get_serial_sequence('account_route_assessments', 'id'), COALESCE(MAX(id), 1)) FROM account_route_assessments;
\echo '  ✓ account_route_assessments sequence reset'

SELECT setval(pg_get_serial_sequence('agent_metrics', 'id'), COALESCE(MAX(id), 1)) FROM agent_metrics;
\echo '  ✓ agent_metrics sequence reset'

SELECT setval(pg_get_serial_sequence('ai_feedback_signals', 'id'), COALESCE(MAX(id), 1)) FROM ai_feedback_signals;
\echo '  ✓ ai_feedback_signals sequence reset'

SELECT setval(pg_get_serial_sequence('alerts', 'id'), COALESCE(MAX(id), 1)) FROM alerts;
\echo '  ✓ alerts sequence reset'

SELECT setval(pg_get_serial_sequence('apn_opportunities', 'id'), COALESCE(MAX(id), 1)) FROM apn_opportunities;
\echo '  ✓ apn_opportunities sequence reset'

SELECT setval(pg_get_serial_sequence('atrisk_checks', 'id'), COALESCE(MAX(id), 1)) FROM atrisk_checks;
\echo '  ✓ atrisk_checks sequence reset'

SELECT setval(pg_get_serial_sequence('campaign_attributions', 'id'), COALESCE(MAX(id), 1)) FROM campaign_attributions;
\echo '  ✓ campaign_attributions sequence reset'

SELECT setval(pg_get_serial_sequence('leader_extras', 'id'), COALESCE(MAX(id), 1)) FROM leader_extras;
\echo '  ✓ leader_extras sequence reset'

SELECT setval(pg_get_serial_sequence('mailbox_owner_companies', 'id'), COALESCE(MAX(id), 1)) FROM mailbox_owner_companies;
\echo '  ✓ mailbox_owner_companies sequence reset'

SELECT setval(pg_get_serial_sequence('news_events', 'id'), COALESCE(MAX(id), 1)) FROM news_events;
\echo '  ✓ news_events sequence reset'

SELECT setval(pg_get_serial_sequence('partner_engagement_cases', 'id'), COALESCE(MAX(id), 1)) FROM partner_engagement_cases;
\echo '  ✓ partner_engagement_cases sequence reset'

SELECT setval(pg_get_serial_sequence('playbook_variants', 'id'), COALESCE(MAX(id), 1)) FROM playbook_variants;
\echo '  ✓ playbook_variants sequence reset'

SELECT setval(pg_get_serial_sequence('presentations', 'id'), COALESCE(MAX(id), 1)) FROM presentations;
\echo '  ✓ presentations sequence reset'

SELECT setval(pg_get_serial_sequence('relationship_bridges', 'id'), COALESCE(MAX(id), 1)) FROM relationship_bridges;
\echo '  ✓ relationship_bridges sequence reset'

SELECT setval(pg_get_serial_sequence('results', 'id'), COALESCE(MAX(id), 1)) FROM results;
\echo '  ✓ results sequence reset'

SELECT setval(pg_get_serial_sequence('sequence_enrollments', 'id'), COALESCE(MAX(id), 1)) FROM sequence_enrollments;
\echo '  ✓ sequence_enrollments sequence reset'

SELECT setval(pg_get_serial_sequence('sf_accounts', 'id'), COALESCE(MAX(id), 1)) FROM sf_accounts;
\echo '  ✓ sf_accounts sequence reset'

SELECT setval(pg_get_serial_sequence('sf_deals', 'id'), COALESCE(MAX(id), 1)) FROM sf_deals;
\echo '  ✓ sf_deals sequence reset'

SELECT setval(pg_get_serial_sequence('sf_leads', 'id'), COALESCE(MAX(id), 1)) FROM sf_leads;
\echo '  ✓ sf_leads sequence reset'

SELECT setval(pg_get_serial_sequence('team_notifications', 'id'), COALESCE(MAX(id), 1)) FROM team_notifications;
\echo '  ✓ team_notifications sequence reset'

SELECT setval(pg_get_serial_sequence('zoho_accounts', 'id'), COALESCE(MAX(id), 1)) FROM zoho_accounts;
\echo '  ✓ zoho_accounts sequence reset'

SELECT setval(pg_get_serial_sequence('zoho_deals', 'id'), COALESCE(MAX(id), 1)) FROM zoho_deals;
\echo '  ✓ zoho_deals sequence reset'

SELECT setval(pg_get_serial_sequence('zoho_leads', 'id'), COALESCE(MAX(id), 1)) FROM zoho_leads;
\echo '  ✓ zoho_leads sequence reset'

\echo ''

-- ============================================================================
-- Level 6 Tables (4 with serial PKs)
-- ============================================================================
\echo 'Level 6 tables...'

SELECT setval(pg_get_serial_sequence('event_invitations', 'id'), COALESCE(MAX(id), 1)) FROM event_invitations;
\echo '  ✓ event_invitations sequence reset'

SELECT setval(pg_get_serial_sequence('sequence_steps', 'id'), COALESCE(MAX(id), 1)) FROM sequence_steps;
\echo '  ✓ sequence_steps sequence reset'

SELECT setval(pg_get_serial_sequence('team_notification_comments', 'id'), COALESCE(MAX(id), 1)) FROM team_notification_comments;
\echo '  ✓ team_notification_comments sequence reset'

SELECT setval(pg_get_serial_sequence('team_notification_reactions', 'id'), COALESCE(MAX(id), 1)) FROM team_notification_reactions;
\echo '  ✓ team_notification_reactions sequence reset'

\echo ''

-- ============================================================================
-- Target-Only Tables (3 with serial PKs that start empty)
-- ============================================================================
\echo 'Target-only tables (empty, but setting sequences for safety)...'

SELECT setval(pg_get_serial_sequence('alliance_alerts', 'id'), COALESCE(MAX(id), 1), false) FROM alliance_alerts;
\echo '  ✓ alliance_alerts sequence initialized'

SELECT setval(pg_get_serial_sequence('alliance_insights', 'id'), COALESCE(MAX(id), 1), false) FROM alliance_insights;
\echo '  ✓ alliance_insights sequence initialized'

SELECT setval(pg_get_serial_sequence('background_tasks', 'id'), COALESCE(MAX(id), 1), false) FROM background_tasks;
\echo '  ✓ background_tasks sequence initialized'

SELECT setval(pg_get_serial_sequence('co_sell_readiness_ai', 'id'), COALESCE(MAX(id), 1), false) FROM co_sell_readiness_ai;
\echo '  ✓ co_sell_readiness_ai sequence initialized'

SELECT setval(pg_get_serial_sequence('co_sell_rooms', 'id'), COALESCE(MAX(id), 1), false) FROM co_sell_rooms;
\echo '  ✓ co_sell_rooms sequence initialized'

SELECT setval(pg_get_serial_sequence('microsoft_referrals', 'id'), COALESCE(MAX(id), 1), false) FROM microsoft_referrals;
\echo '  ✓ microsoft_referrals sequence initialized'

SELECT setval(pg_get_serial_sequence('partner_account_overlaps', 'id'), COALESCE(MAX(id), 1), false) FROM partner_account_overlaps;
\echo '  ✓ partner_account_overlaps sequence initialized'

SELECT setval(pg_get_serial_sequence('partner_engagement_events', 'id'), COALESCE(MAX(id), 1), false) FROM partner_engagement_events;
\echo '  ✓ partner_engagement_events sequence initialized'

SELECT setval(pg_get_serial_sequence('partner_matches', 'id'), COALESCE(MAX(id), 1), false) FROM partner_matches;
\echo '  ✓ partner_matches sequence initialized'

\echo ''

-- ============================================================================
-- Summary and Verification
-- ============================================================================
\echo '========================================================================'
\echo 'SEQUENCE RESET COMPLETE'
\echo '========================================================================'
\echo ''
\echo 'Sequences reset: 63 tables (60 with data + 9 target-only)'
\echo ''
\echo 'Verification: Check sequence values'
\echo ''

-- Show sample of sequence current values
WITH sequence_check AS (
    SELECT 
        'organisations' as table_name,
        currval(pg_get_serial_sequence('organisations', 'id')) as current_val,
        (SELECT MAX(id) FROM organisations) as max_id
    UNION ALL
    SELECT 
        'users' as table_name,
        currval(pg_get_serial_sequence('users', 'id')) as current_val,
        (SELECT MAX(id) FROM users) as max_id
    UNION ALL
    SELECT 
        'partners' as table_name,
        currval(pg_get_serial_sequence('partners', 'id')) as current_val,
        (SELECT MAX(id) FROM partners) as max_id
    UNION ALL
    SELECT 
        'jobs' as table_name,
        NULL as current_val,  -- VARCHAR PK, no sequence
        NULL as max_id
    UNION ALL
    SELECT 
        'sequence_enrollments' as table_name,
        currval(pg_get_serial_sequence('sequence_enrollments', 'id')) as current_val,
        (SELECT MAX(id) FROM sequence_enrollments) as max_id
)
SELECT 
    table_name,
    COALESCE(current_val::TEXT, 'N/A (non-serial PK)') as sequence_value,
    COALESCE(max_id::TEXT, 'N/A') as max_row_id,
    CASE 
        WHEN current_val IS NULL THEN '✓ No sequence (expected)'
        WHEN current_val >= max_id THEN '✓ Sequence OK'
        ELSE '✗ Sequence too low!'
    END as status
FROM sequence_check
ORDER BY table_name;

\echo ''
\echo 'All sequences should show "Sequence OK" or "No sequence"'
\echo ''
\echo '========================================================================'
\echo 'Next steps:'
\echo '  1. Test insert on a few tables to verify sequences work'
\echo '  2. Run post-migration validation: 05_post_validation.sql'
\echo '  3. Set alembic_version to microservices head'
\echo '========================================================================'
\echo ''

-- ============================================================================
-- Quick Insert Test (Optional)
-- ============================================================================
-- Uncomment to test that sequences work correctly:
/*
\echo 'Testing sequence with sample insert...'

BEGIN;

-- Test insert into organisations (should use next sequence value)
INSERT INTO organisations (name, domain, created_at) 
VALUES ('TEST_ORG_DELETE_ME', 'test.example.com', NOW());

\echo 'Test insert successful! Rolling back...'
ROLLBACK;

\echo '✓ Sequence test passed (rolled back)'
*/
