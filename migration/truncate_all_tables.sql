-- ============================================================================
-- TRUNCATE ALL TABLES - CLEAN SLATE FOR MIGRATION
-- ============================================================================
-- Purpose: Remove all data from all tables to prepare for fresh migration
-- WARNING: This deletes ALL data! Use carefully!
-- ============================================================================

\echo '========================================================================'
\echo 'TRUNCATE ALL TABLES - PREPARING FOR FRESH MIGRATION'
\echo '========================================================================'
\echo ''
\echo 'WARNING: This will delete all data from all tables!'
\echo 'Press Ctrl+C within 5 seconds to cancel...'
\echo ''

-- Wait 5 seconds
SELECT pg_sleep(5);

\echo 'Proceeding with truncation...'
\echo ''

-- Truncate all tables in correct order (to avoid FK issues)
-- CASCADE will automatically truncate dependent tables

-- First, disable triggers temporarily to avoid FK issues
SET session_replication_role = replica;

\echo 'Truncating all tables...'

TRUNCATE TABLE 
  account_brief_history, account_briefs, account_channel_context,
  account_drive_folders, account_notes, account_route_assessments,
  agent_metrics, agent_tool_grants, ai_feedback_signals,
  alembic_version, alerts, apn_opportunities, apn_sync_runs,
  atrisk_checks, batches, booking_links, campaign_attributions,
  company_playbooks, connector_credentials, crm_tokens,
  cxo_settings, demo_leads, digest_logs, domain_logo_cache,
  event_invitations, explorium_credit_limits,
  explorium_organisation_credit_limits, forecast_syncs, jobs,
  leader_extras, leadership_results, mailbox_owner_companies,
  mailbox_watch_state, mcp_connectors, mcp_tool_grants,
  metrics_snapshots, news_events, org_events, organisations,
  otp_verifications, partner_benchmarks, partner_connections,
  partner_contacts, partner_engagement_cases, partner_facts,
  partner_readiness, partner_references, partner_solutions,
  partner_targets, partners, person_intel_cache, persona,
  playbook_kb, playbook_variants, presentations, qbr_generations,
  relationship_bridges, results, search_query_log,
  sequence_enrollments, sequence_steps, sf_accounts, sf_deals,
  sf_leads, sf_sync_runs, shared_webhook, suppressions,
  team_notification_comments, team_notification_reactions,
  team_notifications, user_reference_documents, user_settings,
  user_tokens, users, webhook_companies, zoho_accounts,
  zoho_deals, zoho_leads, zoho_sync_runs,
  datasets, dataset_rows, dataset_history,
  outreach_sequences, outreach_enrollments, outreach_steps,
  outreach_reply_log, vault_documents, vault_chunks,
  sequence_replies, llm_calls, run_stats, usage
CASCADE;

-- Re-enable triggers
SET session_replication_role = DEFAULT;

\echo ''
\echo '========================================================================'
\echo 'VERIFICATION - Checking row counts'
\echo '========================================================================'
\echo ''

-- Check a few key tables
SELECT 'organisations' as table_name, COUNT(*) as row_count FROM organisations
UNION ALL SELECT 'users', COUNT(*) FROM users
UNION ALL SELECT 'jobs', COUNT(*) FROM jobs
UNION ALL SELECT 'batches', COUNT(*) FROM batches;

\echo ''
\echo '========================================================================'
\echo 'TRUNCATION COMPLETE'
\echo '========================================================================'
\echo ''
\echo 'All tables are now empty and ready for fresh migration.'
\echo ''
\echo 'Next step:'
\echo '  python3 migrate_data_python.py'
\echo ''
