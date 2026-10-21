-- ============================================================================
-- DATA MIGRATION SCRIPT
-- ============================================================================
-- Purpose: Copy data from staging schema to new database (dev schema structure)
-- Run on: NEW (target) database with dblink to staging
-- When: AFTER schema is created and pre-validation passes
-- 
-- This script copies 79 tables from staging to new database:
--   - 75 tables: copied as-is (all columns match)
--   - 4 tables: copied with column mapping (some columns dropped/added)
--   - 9 tables: skipped (target-only, no source data)
--   - 13 tables: skipped (source-only, no target table)
-- 
-- Load order follows 6 dependency levels to respect foreign keys.
-- 
-- Prerequisites:
--   1. PostgreSQL dblink extension
--   2. Staging database accessible from new server
--   3. Environment variables set (see connection setup below)
-- ============================================================================

\echo '========================================================================'
\echo 'DATA MIGRATION: Staging → New Database (Dev Schema)'
\echo '========================================================================'
\echo ''

-- ============================================================================
-- Setup: Enable dblink extension
-- ============================================================================
\echo 'Setting up dblink connection...'
CREATE EXTENSION IF NOT EXISTS dblink;

-- ============================================================================
-- Connection Configuration
-- ============================================================================
-- Replace these with your actual connection details, or use environment variables
-- Format: hostaddr=X.X.X.X port=5432 dbname=staging user=myuser password=mypass
-- 
-- SECURITY: For production, use .pgpass file instead of hardcoding passwords
-- ============================================================================

\set staging_conn 'hostaddr=STAGING_HOST port=5432 dbname=STAGING_DB user=STAGING_USER password=STAGING_PASSWORD'

-- Test connection
\echo 'Testing connection to staging database...'
SELECT dblink_connect('staging', :'staging_conn');

-- Verify connection
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dblink('staging', 'SELECT 1') AS t(result int)) THEN
        RAISE EXCEPTION 'Failed to connect to staging database';
    END IF;
    RAISE NOTICE '✓ Connected to staging database successfully';
END $$;

\echo ''
\echo 'Starting data migration in 6 dependency levels...'
\echo ''

-- ============================================================================
-- LEVEL 1: Tables with no foreign key dependencies (11 tables)
-- ============================================================================
\echo '========================================================================'
\echo 'LEVEL 1: Loading 11 tables (no FK dependencies)'
\echo '========================================================================'
\echo ''

-- agent_tool_grants
\echo 'Loading agent_tool_grants...'
INSERT INTO agent_tool_grants
SELECT * FROM dblink('staging', 'SELECT * FROM agent_tool_grants') AS t(
    id VARCHAR(255),
    agent_id VARCHAR(255),
    tool_name VARCHAR(255),
    granted_at TIMESTAMP,
    granted_by VARCHAR(255)
);
\echo '  ✓ agent_tool_grants loaded'

-- company_playbooks
\echo 'Loading company_playbooks...'
INSERT INTO company_playbooks
SELECT * FROM dblink('staging', 'SELECT * FROM company_playbooks') AS t(
    id SERIAL,
    name VARCHAR(255),
    description TEXT,
    content JSONB,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
\echo '  ✓ company_playbooks loaded'

-- demo_leads
\echo 'Loading demo_leads...'
INSERT INTO demo_leads
SELECT * FROM dblink('staging', 'SELECT * FROM demo_leads') AS t(
    id SERIAL,
    email VARCHAR(255),
    company_name VARCHAR(255),
    created_at TIMESTAMP
);
\echo '  ✓ demo_leads loaded'

-- domain_logo_cache
\echo 'Loading domain_logo_cache...'
INSERT INTO domain_logo_cache
SELECT * FROM dblink('staging', 'SELECT * FROM domain_logo_cache') AS t(
    domain VARCHAR(255),
    logo_url TEXT,
    cached_at TIMESTAMP
);
\echo '  ✓ domain_logo_cache loaded'

-- mcp_connectors
\echo 'Loading mcp_connectors...'
INSERT INTO mcp_connectors
SELECT * FROM dblink('staging', 'SELECT * FROM mcp_connectors') AS t(
    id VARCHAR(255),
    name VARCHAR(255),
    config JSONB,
    created_at TIMESTAMP
);
\echo '  ✓ mcp_connectors loaded'

-- organisations
\echo 'Loading organisations...'
INSERT INTO organisations
SELECT * FROM dblink('staging', 'SELECT * FROM organisations') AS t(
    id SERIAL,
    name VARCHAR(255),
    domain VARCHAR(255),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
\echo '  ✓ organisations loaded'

-- otp_verifications
\echo 'Loading otp_verifications...'
INSERT INTO otp_verifications
SELECT * FROM dblink('staging', 'SELECT * FROM otp_verifications') AS t(
    id SERIAL,
    email VARCHAR(255),
    otp_code VARCHAR(10),
    expires_at TIMESTAMP,
    verified BOOLEAN,
    created_at TIMESTAMP
);
\echo '  ✓ otp_verifications loaded'

-- person_intel_cache
\echo 'Loading person_intel_cache...'
INSERT INTO person_intel_cache
SELECT * FROM dblink('staging', 'SELECT * FROM person_intel_cache') AS t(
    id SERIAL,
    email VARCHAR(255),
    intel_data JSONB,
    cached_at TIMESTAMP
);
\echo '  ✓ person_intel_cache loaded'

-- playbook_kb
\echo 'Loading playbook_kb...'
INSERT INTO playbook_kb
SELECT * FROM dblink('staging', 'SELECT * FROM playbook_kb') AS t(
    id SERIAL,
    title VARCHAR(255),
    content TEXT,
    category VARCHAR(100),
    created_at TIMESTAMP
);
\echo '  ✓ playbook_kb loaded'

-- shared_webhook
\echo 'Loading shared_webhook...'
INSERT INTO shared_webhook
SELECT * FROM dblink('staging', 'SELECT * FROM shared_webhook') AS t(
    id SERIAL,
    url TEXT,
    secret VARCHAR(255),
    active BOOLEAN,
    created_at TIMESTAMP
);
\echo '  ✓ shared_webhook loaded'

-- suppressions
\echo 'Loading suppressions...'
INSERT INTO suppressions
SELECT * FROM dblink('staging', 'SELECT * FROM suppressions') AS t(
    id SERIAL,
    email VARCHAR(255),
    reason VARCHAR(255),
    suppressed_at TIMESTAMP
);
\echo '  ✓ suppressions loaded'

\echo ''
\echo '✓ Level 1 complete: 11 tables loaded'
\echo ''

-- ============================================================================
-- LEVEL 2: Tables depending on Level 1 (4 tables)
-- ============================================================================
\echo '========================================================================'
\echo 'LEVEL 2: Loading 4 tables (depend on Level 1)'
\echo '========================================================================'
\echo ''

-- explorium_organisation_credit_limits
\echo 'Loading explorium_organisation_credit_limits...'
INSERT INTO explorium_organisation_credit_limits
SELECT * FROM dblink('staging', 'SELECT * FROM explorium_organisation_credit_limits') AS t(
    organization_id INTEGER,
    credit_limit INTEGER,
    updated_at TIMESTAMP
);
\echo '  ✓ explorium_organisation_credit_limits loaded'

-- mcp_tool_grants
\echo 'Loading mcp_tool_grants...'
INSERT INTO mcp_tool_grants
SELECT * FROM dblink('staging', 'SELECT * FROM mcp_tool_grants') AS t(
    id SERIAL,
    connector_id VARCHAR(255),
    tool_name VARCHAR(255),
    granted_at TIMESTAMP
);
\echo '  ✓ mcp_tool_grants loaded'

-- partners
\echo 'Loading partners...'
INSERT INTO partners
SELECT * FROM dblink('staging', 'SELECT * FROM partners') AS t(
    id SERIAL,
    organisation_id INTEGER,
    name VARCHAR(255),
    type VARCHAR(100),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
\echo '  ✓ partners loaded'

-- users
\echo 'Loading users...'
INSERT INTO users
SELECT * FROM dblink('staging', 'SELECT * FROM users') AS t(
    id SERIAL,
    email VARCHAR(255),
    organization_id INTEGER,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    role VARCHAR(100),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
\echo '  ✓ users loaded'

\echo ''
\echo '✓ Level 2 complete: 4 tables loaded'
\echo ''

-- ============================================================================
-- LEVEL 3: Tables depending on Levels 1-2 (23 tables)
-- ============================================================================
\echo '========================================================================'
\echo 'LEVEL 3: Loading 23 tables (depend on Levels 1-2)'
\echo '========================================================================'
\echo ''

-- apn_sync_runs
\echo 'Loading apn_sync_runs...'
INSERT INTO apn_sync_runs
SELECT * FROM dblink('staging', 'SELECT * FROM apn_sync_runs') AS t(
    id SERIAL,
    organisation_id INTEGER,
    user_id INTEGER,
    sync_status VARCHAR(50),
    started_at TIMESTAMP,
    completed_at TIMESTAMP
);
\echo '  ✓ apn_sync_runs loaded'

-- batches
\echo 'Loading batches...'
INSERT INTO batches
SELECT * FROM dblink('staging', 'SELECT * FROM batches') AS t(
    id VARCHAR(255),
    user_id INTEGER,
    name VARCHAR(255),
    status VARCHAR(50),
    created_at TIMESTAMP
);
\echo '  ✓ batches loaded'

-- booking_links
\echo 'Loading booking_links...'
INSERT INTO booking_links
SELECT * FROM dblink('staging', 'SELECT * FROM booking_links') AS t(
    id SERIAL,
    user_id INTEGER,
    link_url TEXT,
    active BOOLEAN,
    created_at TIMESTAMP
);
\echo '  ✓ booking_links loaded'

-- connector_credentials
\echo 'Loading connector_credentials...'
INSERT INTO connector_credentials
SELECT * FROM dblink('staging', 'SELECT * FROM connector_credentials') AS t(
    id SERIAL,
    user_id INTEGER,
    connector_type VARCHAR(100),
    credentials JSONB,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
\echo '  ✓ connector_credentials loaded'

-- crm_tokens
\echo 'Loading crm_tokens...'
INSERT INTO crm_tokens
SELECT * FROM dblink('staging', 'SELECT * FROM crm_tokens') AS t(
    id SERIAL,
    user_id INTEGER,
    crm_type VARCHAR(50),
    access_token TEXT,
    refresh_token TEXT,
    expires_at TIMESTAMP,
    created_at TIMESTAMP
);
\echo '  ✓ crm_tokens loaded'

-- cxo_settings
\echo 'Loading cxo_settings...'
INSERT INTO cxo_settings
SELECT * FROM dblink('staging', 'SELECT * FROM cxo_settings') AS t(
    id SERIAL,
    user_id INTEGER,
    settings JSONB,
    updated_at TIMESTAMP
);
\echo '  ✓ cxo_settings loaded'

-- digest_logs
\echo 'Loading digest_logs...'
INSERT INTO digest_logs
SELECT * FROM dblink('staging', 'SELECT * FROM digest_logs') AS t(
    id SERIAL,
    user_id INTEGER,
    digest_type VARCHAR(100),
    sent_at TIMESTAMP,
    opened_at TIMESTAMP
);
\echo '  ✓ digest_logs loaded'

-- explorium_credit_limits
\echo 'Loading explorium_credit_limits...'
INSERT INTO explorium_credit_limits
SELECT * FROM dblink('staging', 'SELECT * FROM explorium_credit_limits') AS t(
    id SERIAL,
    user_id INTEGER,
    organization_id INTEGER,
    credit_limit INTEGER,
    updated_at TIMESTAMP
);
\echo '  ✓ explorium_credit_limits loaded'

-- forecast_syncs
\echo 'Loading forecast_syncs...'
INSERT INTO forecast_syncs
SELECT * FROM dblink('staging', 'SELECT * FROM forecast_syncs') AS t(
    id SERIAL,
    user_id INTEGER,
    sync_status VARCHAR(50),
    synced_at TIMESTAMP
);
\echo '  ✓ forecast_syncs loaded'

-- mailbox_watch_state
\echo 'Loading mailbox_watch_state...'
INSERT INTO mailbox_watch_state
SELECT * FROM dblink('staging', 'SELECT * FROM mailbox_watch_state') AS t(
    id SERIAL,
    user_id INTEGER,
    watch_token VARCHAR(255),
    expiry TIMESTAMP,
    created_at TIMESTAMP
);
\echo '  ✓ mailbox_watch_state loaded'

-- metrics_snapshots
\echo 'Loading metrics_snapshots...'
INSERT INTO metrics_snapshots
SELECT * FROM dblink('staging', 'SELECT * FROM metrics_snapshots') AS t(
    id SERIAL,
    user_id INTEGER,
    snapshot_date DATE,
    metrics JSONB,
    created_at TIMESTAMP
);
\echo '  ✓ metrics_snapshots loaded'

-- org_events
\echo 'Loading org_events...'
INSERT INTO org_events
SELECT * FROM dblink('staging', 'SELECT * FROM org_events') AS t(
    id SERIAL,
    organisation_id INTEGER,
    partner_id INTEGER,
    owner_user_id INTEGER,
    event_type VARCHAR(100),
    event_data JSONB,
    occurred_at TIMESTAMP
);
\echo '  ✓ org_events loaded'

-- partner_benchmarks
\echo 'Loading partner_benchmarks...'
INSERT INTO partner_benchmarks
SELECT * FROM dblink('staging', 'SELECT * FROM partner_benchmarks') AS t(
    id SERIAL,
    organisation_id INTEGER,
    partner_id INTEGER,
    metric_name VARCHAR(255),
    metric_value NUMERIC,
    benchmark_date DATE
);
\echo '  ✓ partner_benchmarks loaded'

-- partner_connections
\echo 'Loading partner_connections...'
INSERT INTO partner_connections
SELECT * FROM dblink('staging', 'SELECT * FROM partner_connections') AS t(
    id SERIAL,
    organisation_id INTEGER,
    partner_id INTEGER,
    created_by_user_id INTEGER,
    connection_status VARCHAR(50),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
\echo '  ✓ partner_connections loaded'

-- partner_contacts
\echo 'Loading partner_contacts...'
INSERT INTO partner_contacts
SELECT * FROM dblink('staging', 'SELECT * FROM partner_contacts') AS t(
    id SERIAL,
    organisation_id INTEGER,
    partner_id INTEGER,
    email VARCHAR(255),
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    role VARCHAR(100),
    created_at TIMESTAMP
);
\echo '  ✓ partner_contacts loaded'

-- partner_facts
\echo 'Loading partner_facts...'
INSERT INTO partner_facts
SELECT * FROM dblink('staging', 'SELECT * FROM partner_facts') AS t(
    id SERIAL,
    organisation_id INTEGER,
    partner_id INTEGER,
    updated_by_user_id INTEGER,
    fact_type VARCHAR(100),
    fact_value TEXT,
    updated_at TIMESTAMP
);
\echo '  ✓ partner_facts loaded'

-- partner_readiness
\echo 'Loading partner_readiness...'
INSERT INTO partner_readiness
SELECT * FROM dblink('staging', 'SELECT * FROM partner_readiness') AS t(
    id SERIAL,
    organisation_id INTEGER,
    partner_id INTEGER,
    readiness_score NUMERIC,
    assessed_at TIMESTAMP
);
\echo '  ✓ partner_readiness loaded'

-- partner_references
\echo 'Loading partner_references...'
INSERT INTO partner_references
SELECT * FROM dblink('staging', 'SELECT * FROM partner_references') AS t(
    id SERIAL,
    organisation_id INTEGER,
    partner_id INTEGER,
    reference_text TEXT,
    created_at TIMESTAMP
);
\echo '  ✓ partner_references loaded'

-- partner_solutions
\echo 'Loading partner_solutions...'
INSERT INTO partner_solutions
SELECT * FROM dblink('staging', 'SELECT * FROM partner_solutions') AS t(
    id SERIAL,
    organisation_id INTEGER,
    partner_id INTEGER,
    solution_name VARCHAR(255),
    description TEXT,
    created_at TIMESTAMP
);
\echo '  ✓ partner_solutions loaded'

-- partner_targets
\echo 'Loading partner_targets...'
INSERT INTO partner_targets
SELECT * FROM dblink('staging', 'SELECT * FROM partner_targets') AS t(
    id SERIAL,
    organisation_id INTEGER,
    partner_id INTEGER,
    target_type VARCHAR(100),
    target_value NUMERIC,
    target_date DATE
);
\echo '  ✓ partner_targets loaded'

-- persona
\echo 'Loading persona...'
INSERT INTO persona
SELECT * FROM dblink('staging', 'SELECT * FROM persona') AS t(
    id SERIAL,
    user_id INTEGER,
    persona_type VARCHAR(100),
    persona_data JSONB,
    created_at TIMESTAMP
);
\echo '  ✓ persona loaded'

-- qbr_generations
\echo 'Loading qbr_generations...'
INSERT INTO qbr_generations
SELECT * FROM dblink('staging', 'SELECT * FROM qbr_generations') AS t(
    id SERIAL,
    user_id INTEGER,
    qbr_data JSONB,
    generated_at TIMESTAMP
);
\echo '  ✓ qbr_generations loaded'

-- search_index
\echo 'Loading search_index...'
INSERT INTO search_index
SELECT * FROM dblink('staging', 'SELECT * FROM search_index') AS t(
    id SERIAL,
    user_id INTEGER,
    entity_type VARCHAR(100),
    entity_id VARCHAR(255),
    search_vector TSVECTOR,
    indexed_at TIMESTAMP
);
\echo '  ✓ search_index loaded'

-- search_query_log
\echo 'Loading search_query_log...'
INSERT INTO search_query_log
SELECT * FROM dblink('staging', 'SELECT * FROM search_query_log') AS t(
    id SERIAL,
    user_id INTEGER,
    query_text TEXT,
    results_count INTEGER,
    queried_at TIMESTAMP
);
\echo '  ✓ search_query_log loaded'

-- sf_sync_runs
\echo 'Loading sf_sync_runs...'
INSERT INTO sf_sync_runs
SELECT * FROM dblink('staging', 'SELECT * FROM sf_sync_runs') AS t(
    id SERIAL,
    user_id INTEGER,
    sync_status VARCHAR(50),
    started_at TIMESTAMP,
    completed_at TIMESTAMP
);
\echo '  ✓ sf_sync_runs loaded'

-- user_reference_documents
\echo 'Loading user_reference_documents...'
INSERT INTO user_reference_documents
SELECT * FROM dblink('staging', 'SELECT * FROM user_reference_documents') AS t(
    id SERIAL,
    user_id INTEGER,
    document_name VARCHAR(255),
    document_url TEXT,
    created_at TIMESTAMP
);
\echo '  ✓ user_reference_documents loaded'

-- user_settings
\echo 'Loading user_settings...'
INSERT INTO user_settings
SELECT * FROM dblink('staging', 'SELECT * FROM user_settings') AS t(
    user_id INTEGER,
    settings JSONB,
    updated_at TIMESTAMP
);
\echo '  ✓ user_settings loaded'

-- user_tokens
\echo 'Loading user_tokens...'
INSERT INTO user_tokens
SELECT * FROM dblink('staging', 'SELECT * FROM user_tokens') AS t(
    id SERIAL,
    user_id INTEGER,
    token VARCHAR(255),
    token_type VARCHAR(50),
    expires_at TIMESTAMP,
    created_at TIMESTAMP
);
\echo '  ✓ user_tokens loaded'

-- zoho_sync_runs
\echo 'Loading zoho_sync_runs...'
INSERT INTO zoho_sync_runs
SELECT * FROM dblink('staging', 'SELECT * FROM zoho_sync_runs') AS t(
    id SERIAL,
    user_id INTEGER,
    sync_status VARCHAR(50),
    started_at TIMESTAMP,
    completed_at TIMESTAMP
);
\echo '  ✓ zoho_sync_runs loaded'

\echo ''
\echo '✓ Level 3 complete: 23 tables loaded'
\echo ''

-- ============================================================================
-- LEVEL 4: jobs table (1 table)
-- ============================================================================
\echo '========================================================================'
\echo 'LEVEL 4: Loading jobs table'
\echo '========================================================================'
\echo ''

-- jobs
\echo 'Loading jobs...'
INSERT INTO jobs
SELECT * FROM dblink('staging', 'SELECT * FROM jobs') AS t(
    id VARCHAR(255),
    user_id INTEGER,
    batch_id VARCHAR(255),
    job_type VARCHAR(100),
    status VARCHAR(50),
    job_data JSONB,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
\echo '  ✓ jobs loaded'

\echo ''
\echo '✓ Level 4 complete: 1 table loaded'
\echo ''

-- ============================================================================
-- LEVEL 5: Tables depending on Levels 1-4 (28 tables, 4 with column changes)
-- ============================================================================
\echo '========================================================================'
\echo 'LEVEL 5: Loading 28 tables (depend on Levels 1-4)'
\echo '========================================================================'
\echo ''

-- account_brief_history
\echo 'Loading account_brief_history...'
INSERT INTO account_brief_history
SELECT * FROM dblink('staging', 'SELECT * FROM account_brief_history') AS t(
    id SERIAL,
    job_id VARCHAR(255),
    brief_version INTEGER,
    brief_data JSONB,
    created_at TIMESTAMP
);
\echo '  ✓ account_brief_history loaded'

-- account_briefs
\echo 'Loading account_briefs...'
INSERT INTO account_briefs
SELECT * FROM dblink('staging', 'SELECT * FROM account_briefs') AS t(
    job_id VARCHAR(255),
    brief_text TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
\echo '  ✓ account_briefs loaded'

-- account_channel_context
\echo 'Loading account_channel_context...'
INSERT INTO account_channel_context
SELECT * FROM dblink('staging', 'SELECT * FROM account_channel_context') AS t(
    id SERIAL,
    job_id VARCHAR(255),
    user_id INTEGER,
    channel_type VARCHAR(100),
    context_data JSONB,
    created_at TIMESTAMP
);
\echo '  ✓ account_channel_context loaded'

-- account_drive_folders
\echo 'Loading account_drive_folders...'
INSERT INTO account_drive_folders
SELECT * FROM dblink('staging', 'SELECT * FROM account_drive_folders') AS t(
    id SERIAL,
    job_id VARCHAR(255),
    user_id INTEGER,
    folder_id VARCHAR(255),
    folder_name VARCHAR(255),
    created_at TIMESTAMP
);
\echo '  ✓ account_drive_folders loaded'

-- account_notes
\echo 'Loading account_notes...'
INSERT INTO account_notes
SELECT * FROM dblink('staging', 'SELECT * FROM account_notes') AS t(
    id SERIAL,
    job_id VARCHAR(255),
    user_id INTEGER,
    note_text TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
\echo '  ✓ account_notes loaded'

-- account_route_assessments
\echo 'Loading account_route_assessments...'
INSERT INTO account_route_assessments
SELECT * FROM dblink('staging', 'SELECT * FROM account_route_assessments') AS t(
    id SERIAL,
    job_id VARCHAR(255),
    organisation_id INTEGER,
    assessment_data JSONB,
    assessed_at TIMESTAMP
);
\echo '  ✓ account_route_assessments loaded'

-- agent_metrics
\echo 'Loading agent_metrics...'
INSERT INTO agent_metrics
SELECT * FROM dblink('staging', 'SELECT * FROM agent_metrics') AS t(
    id SERIAL,
    job_id VARCHAR(255),
    metric_name VARCHAR(255),
    metric_value NUMERIC,
    recorded_at TIMESTAMP
);
\echo '  ✓ agent_metrics loaded'

-- ai_feedback_signals
\echo 'Loading ai_feedback_signals...'
INSERT INTO ai_feedback_signals
SELECT * FROM dblink('staging', 'SELECT * FROM ai_feedback_signals') AS t(
    id SERIAL,
    job_id VARCHAR(255),
    user_id INTEGER,
    signal_type VARCHAR(100),
    signal_value TEXT,
    created_at TIMESTAMP
);
\echo '  ✓ ai_feedback_signals loaded'

-- alerts
\echo 'Loading alerts...'
INSERT INTO alerts
SELECT * FROM dblink('staging', 'SELECT * FROM alerts') AS t(
    id SERIAL,
    job_id VARCHAR(255),
    user_id INTEGER,
    alert_type VARCHAR(100),
    alert_message TEXT,
    created_at TIMESTAMP,
    acknowledged_at TIMESTAMP
);
\echo '  ✓ alerts loaded'

-- apn_opportunities (WITH COLUMN CHANGES - drops summary_json)
\echo 'Loading apn_opportunities (with column changes)...'
INSERT INTO apn_opportunities (id, organisation_id, user_id, source_job_id, opportunity_name, opportunity_value, stage, created_at, updated_at)
SELECT id, organisation_id, user_id, source_job_id, opportunity_name, opportunity_value, stage, created_at, updated_at
FROM dblink('staging', 'SELECT id, organisation_id, user_id, source_job_id, opportunity_name, opportunity_value, stage, created_at, updated_at FROM apn_opportunities') AS t(
    id SERIAL,
    organisation_id INTEGER,
    user_id INTEGER,
    source_job_id VARCHAR(255),
    opportunity_name VARCHAR(255),
    opportunity_value NUMERIC,
    stage VARCHAR(100),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
\echo '  ✓ apn_opportunities loaded (summary_json column dropped)'

-- atrisk_checks
\echo 'Loading atrisk_checks...'
INSERT INTO atrisk_checks
SELECT * FROM dblink('staging', 'SELECT * FROM atrisk_checks') AS t(
    id SERIAL,
    job_id VARCHAR(255),
    user_id INTEGER,
    check_result JSONB,
    checked_at TIMESTAMP
);
\echo '  ✓ atrisk_checks loaded'

-- campaign_attributions
\echo 'Loading campaign_attributions...'
INSERT INTO campaign_attributions
SELECT * FROM dblink('staging', 'SELECT * FROM campaign_attributions') AS t(
    id SERIAL,
    job_id VARCHAR(255),
    user_id INTEGER,
    campaign_name VARCHAR(255),
    attribution_data JSONB,
    created_at TIMESTAMP
);
\echo '  ✓ campaign_attributions loaded'

-- leader_extras
\echo 'Loading leader_extras...'
INSERT INTO leader_extras
SELECT * FROM dblink('staging', 'SELECT * FROM leader_extras') AS t(
    id SERIAL,
    job_id VARCHAR(255),
    extra_data JSONB,
    created_at TIMESTAMP
);
\echo '  ✓ leader_extras loaded'

-- leadership_results
\echo 'Loading leadership_results...'
INSERT INTO leadership_results
SELECT * FROM dblink('staging', 'SELECT * FROM leadership_results') AS t(
    job_id VARCHAR(255),
    result_data JSONB,
    created_at TIMESTAMP
);
\echo '  ✓ leadership_results loaded'

-- mailbox_owner_companies
\echo 'Loading mailbox_owner_companies...'
INSERT INTO mailbox_owner_companies
SELECT * FROM dblink('staging', 'SELECT * FROM mailbox_owner_companies') AS t(
    id SERIAL,
    job_id VARCHAR(255),
    user_id INTEGER,
    company_domain VARCHAR(255),
    created_at TIMESTAMP
);
\echo '  ✓ mailbox_owner_companies loaded'

-- news_events
\echo 'Loading news_events...'
INSERT INTO news_events
SELECT * FROM dblink('staging', 'SELECT * FROM news_events') AS t(
    id SERIAL,
    job_id VARCHAR(255),
    event_title VARCHAR(255),
    event_url TEXT,
    published_at TIMESTAMP,
    created_at TIMESTAMP
);
\echo '  ✓ news_events loaded'

-- partner_engagement_cases (WITH COLUMN CHANGES - adds 2 nullable columns)
\echo 'Loading partner_engagement_cases (with column changes)...'
INSERT INTO partner_engagement_cases (id, organisation_id, partner_id, primary_contact_id, owner_user_id, job_id, case_status, case_data, created_at, updated_at)
SELECT id, organisation_id, partner_id, primary_contact_id, owner_user_id, job_id, case_status, case_data, created_at, updated_at
FROM dblink('staging', 'SELECT id, organisation_id, partner_id, primary_contact_id, owner_user_id, job_id, case_status, case_data, created_at, updated_at FROM partner_engagement_cases') AS t(
    id SERIAL,
    organisation_id INTEGER,
    partner_id INTEGER,
    primary_contact_id INTEGER,
    owner_user_id INTEGER,
    job_id VARCHAR(255),
    case_status VARCHAR(100),
    case_data JSONB,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
\echo '  ✓ partner_engagement_cases loaded (partner_assisted_amount and feedback_score set to NULL)'

-- playbook_variants
\echo 'Loading playbook_variants...'
INSERT INTO playbook_variants
SELECT * FROM dblink('staging', 'SELECT * FROM playbook_variants') AS t(
    id SERIAL,
    job_id VARCHAR(255),
    variant_name VARCHAR(255),
    variant_data JSONB,
    created_at TIMESTAMP
);
\echo '  ✓ playbook_variants loaded'

-- presentations
\echo 'Loading presentations...'
INSERT INTO presentations
SELECT * FROM dblink('staging', 'SELECT * FROM presentations') AS t(
    id SERIAL,
    job_id VARCHAR(255),
    user_id INTEGER,
    presentation_url TEXT,
    created_at TIMESTAMP
);
\echo '  ✓ presentations loaded'

-- relationship_bridges
\echo 'Loading relationship_bridges...'
INSERT INTO relationship_bridges
SELECT * FROM dblink('staging', 'SELECT * FROM relationship_bridges') AS t(
    id SERIAL,
    job_id VARCHAR(255),
    organisation_id INTEGER,
    bridge_data JSONB,
    created_at TIMESTAMP
);
\echo '  ✓ relationship_bridges loaded'

-- results
\echo 'Loading results...'
INSERT INTO results
SELECT * FROM dblink('staging', 'SELECT * FROM results') AS t(
    id SERIAL,
    job_id VARCHAR(255),
    result_type VARCHAR(100),
    result_data JSONB,
    created_at TIMESTAMP
);
\echo '  ✓ results loaded'

-- sequence_enrollments (WITH COLUMN CHANGES - drops 6 columns)
\echo 'Loading sequence_enrollments (with column changes)...'
INSERT INTO sequence_enrollments (id, job_id, user_id, sequence_id, enrollment_status, enrolled_at, completed_at, created_at, updated_at)
SELECT id, job_id, user_id, sequence_id, enrollment_status, enrolled_at, completed_at, created_at, updated_at
FROM dblink('staging', 'SELECT id, job_id, user_id, sequence_id, enrollment_status, enrolled_at, completed_at, created_at, updated_at FROM sequence_enrollments') AS t(
    id SERIAL,
    job_id VARCHAR(255),
    user_id INTEGER,
    sequence_id VARCHAR(255),
    enrollment_status VARCHAR(50),
    enrolled_at TIMESTAMP,
    completed_at TIMESTAMP,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
\echo '  ✓ sequence_enrollments loaded (dropped: cc_emails, chain_status, last_regenerated_at, last_replan_at, last_reply_at, last_sent_at)'

-- sf_accounts
\echo 'Loading sf_accounts...'
INSERT INTO sf_accounts
SELECT * FROM dblink('staging', 'SELECT * FROM sf_accounts') AS t(
    id SERIAL,
    job_id VARCHAR(255),
    user_id INTEGER,
    promoted_job_id VARCHAR(255),
    sf_account_id VARCHAR(255),
    account_name VARCHAR(255),
    synced_at TIMESTAMP
);
\echo '  ✓ sf_accounts loaded'

-- sf_deals
\echo 'Loading sf_deals...'
INSERT INTO sf_deals
SELECT * FROM dblink('staging', 'SELECT * FROM sf_deals') AS t(
    id SERIAL,
    job_id VARCHAR(255),
    user_id INTEGER,
    promoted_job_id VARCHAR(255),
    sf_deal_id VARCHAR(255),
    deal_name VARCHAR(255),
    deal_amount NUMERIC,
    synced_at TIMESTAMP
);
\echo '  ✓ sf_deals loaded'

-- sf_leads
\echo 'Loading sf_leads...'
INSERT INTO sf_leads
SELECT * FROM dblink('staging', 'SELECT * FROM sf_leads') AS t(
    id SERIAL,
    job_id VARCHAR(255),
    user_id INTEGER,
    promoted_job_id VARCHAR(255),
    sf_lead_id VARCHAR(255),
    lead_email VARCHAR(255),
    synced_at TIMESTAMP
);
\echo '  ✓ sf_leads loaded'

-- team_notifications
\echo 'Loading team_notifications...'
INSERT INTO team_notifications
SELECT * FROM dblink('staging', 'SELECT * FROM team_notifications') AS t(
    id SERIAL,
    job_id VARCHAR(255),
    actor_user_id INTEGER,
    recipient_user_id INTEGER,
    notification_type VARCHAR(100),
    notification_data JSONB,
    read_at TIMESTAMP,
    created_at TIMESTAMP
);
\echo '  ✓ team_notifications loaded'

-- webhook_companies
\echo 'Loading webhook_companies...'
INSERT INTO webhook_companies
SELECT * FROM dblink('staging', 'SELECT * FROM webhook_companies') AS t(
    job_id VARCHAR(255),
    company_domain VARCHAR(255),
    webhook_data JSONB,
    created_at TIMESTAMP
);
\echo '  ✓ webhook_companies loaded'

-- zoho_accounts
\echo 'Loading zoho_accounts...'
INSERT INTO zoho_accounts
SELECT * FROM dblink('staging', 'SELECT * FROM zoho_accounts') AS t(
    id SERIAL,
    job_id VARCHAR(255),
    user_id INTEGER,
    promoted_job_id VARCHAR(255),
    zoho_account_id VARCHAR(255),
    account_name VARCHAR(255),
    synced_at TIMESTAMP
);
\echo '  ✓ zoho_accounts loaded'

-- zoho_deals
\echo 'Loading zoho_deals...'
INSERT INTO zoho_deals
SELECT * FROM dblink('staging', 'SELECT * FROM zoho_deals') AS t(
    id SERIAL,
    job_id VARCHAR(255),
    user_id INTEGER,
    promoted_job_id VARCHAR(255),
    zoho_deal_id VARCHAR(255),
    deal_name VARCHAR(255),
    deal_amount NUMERIC,
    synced_at TIMESTAMP
);
\echo '  ✓ zoho_deals loaded'

-- zoho_leads
\echo 'Loading zoho_leads...'
INSERT INTO zoho_leads
SELECT * FROM dblink('staging', 'SELECT * FROM zoho_leads') AS t(
    id SERIAL,
    job_id VARCHAR(255),
    user_id INTEGER,
    promoted_job_id VARCHAR(255),
    zoho_lead_id VARCHAR(255),
    lead_email VARCHAR(255),
    synced_at TIMESTAMP
);
\echo '  ✓ zoho_leads loaded'

\echo ''
\echo '✓ Level 5 complete: 28 tables loaded (4 with column changes)'
\echo ''

-- ============================================================================
-- LEVEL 6: Tables depending on Levels 1-5 (4 tables)
-- ============================================================================
\echo '========================================================================'
\echo 'LEVEL 6: Loading 4 tables (depend on Levels 1-5)'
\echo '========================================================================'
\echo ''

-- event_invitations
\echo 'Loading event_invitations...'
INSERT INTO event_invitations
SELECT * FROM dblink('staging', 'SELECT * FROM event_invitations') AS t(
    id SERIAL,
    event_id INTEGER,
    sequence_enrollment_id INTEGER,
    organisation_id INTEGER,
    job_id VARCHAR(255),
    invitation_status VARCHAR(50),
    sent_at TIMESTAMP,
    responded_at TIMESTAMP
);
\echo '  ✓ event_invitations loaded'

-- sequence_steps (WITH COLUMN CHANGES - drops 2 columns)
\echo 'Loading sequence_steps (with column changes)...'
INSERT INTO sequence_steps (id, enrollment_id, step_order, step_type, step_content, scheduled_at, sent_at, created_at)
SELECT id, enrollment_id, step_order, step_type, step_content, scheduled_at, sent_at, created_at
FROM dblink('staging', 'SELECT id, enrollment_id, step_order, step_type, step_content, scheduled_at, sent_at, created_at FROM sequence_steps') AS t(
    id SERIAL,
    enrollment_id INTEGER,
    step_order INTEGER,
    step_type VARCHAR(50),
    step_content TEXT,
    scheduled_at TIMESTAMP,
    sent_at TIMESTAMP,
    created_at TIMESTAMP
);
\echo '  ✓ sequence_steps loaded (dropped: generation_reason, user_edited)'

-- team_notification_comments
\echo 'Loading team_notification_comments...'
INSERT INTO team_notification_comments
SELECT * FROM dblink('staging', 'SELECT * FROM team_notification_comments') AS t(
    id SERIAL,
    notification_id INTEGER,
    user_id INTEGER,
    comment_text TEXT,
    created_at TIMESTAMP
);
\echo '  ✓ team_notification_comments loaded'

-- team_notification_reactions
\echo 'Loading team_notification_reactions...'
INSERT INTO team_notification_reactions
SELECT * FROM dblink('staging', 'SELECT * FROM team_notification_reactions') AS t(
    id SERIAL,
    notification_id INTEGER,
    user_id INTEGER,
    reaction_type VARCHAR(50),
    created_at TIMESTAMP
);
\echo '  ✓ team_notification_reactions loaded'

\echo ''
\echo '✓ Level 6 complete: 4 tables loaded (1 with column changes)'
\echo ''

-- ============================================================================
-- Cleanup: Disconnect from staging
-- ============================================================================
SELECT dblink_disconnect('staging');

\echo ''
\echo '========================================================================'
\echo 'DATA MIGRATION COMPLETE'
\echo '========================================================================'
\echo ''
\echo 'Summary:'
\echo '  ✓ Level 1: 11 tables loaded'
\echo '  ✓ Level 2: 4 tables loaded'
\echo '  ✓ Level 3: 23 tables loaded'
\echo '  ✓ Level 4: 1 table loaded'
\echo '  ✓ Level 5: 28 tables loaded (4 with column changes)'
\echo '  ✓ Level 6: 4 tables loaded (1 with column changes)'
\echo '  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
\echo '  TOTAL: 71 tables migrated'
\echo ''
\echo 'Column changes applied:'
\echo '  • apn_opportunities: Dropped summary_json'
\echo '  • partner_engagement_cases: Added partner_assisted_amount, feedback_score (NULL)'
\echo '  • sequence_enrollments: Dropped 6 columns'
\echo '  • sequence_steps: Dropped generation_reason, user_edited'
\echo ''
\echo 'Tables NOT migrated:'
\echo '  • 9 target-only tables (start empty)'
\echo '  • 13 source-only tables (no target)'
\echo ''
\echo 'Next steps:'
\echo '  1. Run sequence reset: 04_reset_sequences.sql'
\echo '  2. Run validation: 05_post_validation.sql'
\echo '  3. Set alembic_version to microservices head'
\echo '  4. Run make alembic-check'
\echo ''
\echo '========================================================================'
