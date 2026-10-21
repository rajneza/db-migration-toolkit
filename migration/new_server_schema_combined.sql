-- ====================================================================
-- COMBINED NEW SERVER SCHEMA
-- ====================================================================
-- Source 1: dev_schema_backup.sql (88 tables)
-- Source 2: staging_schema_backup.sql (13 additional tables)
-- Total: 101 tables
-- Generated: 2026-10-16
-- ====================================================================

-- ====================================================================
-- PART 1: DEV SCHEMA (88 TABLES)
-- ====================================================================

--
-- PostgreSQL database dump
--

\restrict CuUM64AM9lxIGz2Jd5J8mIe6qp1BwkVj8WpDe1JbTCHTMryHw6oSdf1lHY26eJg

-- Dumped from database version 17.9
-- Dumped by pg_dump version 17.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET search_path = public, pg_catalog;
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: mailbox_owner_channel_hint; Type: TYPE; Schema: dev; Owner: postgres
--

CREATE TYPE mailbox_owner_channel_hint AS ENUM (
    'gmail',
    'teams',
    'both'
);


ALTER TYPE mailbox_owner_channel_hint OWNER TO postgres;

--
-- Name: mailbox_owner_slot; Type: TYPE; Schema: dev; Owner: postgres
--

CREATE TYPE mailbox_owner_slot AS ENUM (
    'primary',
    'secondary'
);


ALTER TYPE mailbox_owner_slot OWNER TO postgres;

--
-- Name: mailbox_watch_channel; Type: TYPE; Schema: dev; Owner: postgres
--

CREATE TYPE mailbox_watch_channel AS ENUM (
    'gmail',
    'teams'
);


ALTER TYPE mailbox_watch_channel OWNER TO postgres;

--
-- Name: mailbox_watch_status; Type: TYPE; Schema: dev; Owner: postgres
--

CREATE TYPE mailbox_watch_status AS ENUM (
    'active',
    'expired',
    'error',
    'disconnected'
);


ALTER TYPE mailbox_watch_status OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: account_brief_history; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE account_brief_history (
    id integer NOT NULL,
    job_id character varying(255) NOT NULL,
    fit integer,
    intent integer,
    heat_tier character varying(50),
    heat_score numeric(4,2),
    quadrant character varying(50),
    persona_version integer,
    captured_at timestamp without time zone
);


ALTER TABLE account_brief_history OWNER TO postgres;

--
-- Name: account_brief_history_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE account_brief_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE account_brief_history_id_seq OWNER TO postgres;

--
-- Name: account_brief_history_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE account_brief_history_id_seq OWNED BY account_brief_history.id;


--
-- Name: account_briefs; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE account_briefs (
    job_id character varying(255) NOT NULL,
    brief_json text,
    status character varying(50),
    heat_tier character varying(50),
    heat_score numeric(4,2),
    fit integer,
    intent integer,
    persona_version integer,
    override_json text,
    generated_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE account_briefs OWNER TO postgres;

--
-- Name: account_channel_context; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE account_channel_context (
    id integer NOT NULL,
    job_id character varying(255) NOT NULL,
    user_id integer NOT NULL,
    channel character varying(20) NOT NULL,
    has_history boolean DEFAULT false NOT NULL,
    thread_count integer DEFAULT 0 NOT NULL,
    message_count integer DEFAULT 0 NOT NULL,
    participant_count integer DEFAULT 0 NOT NULL,
    first_activity_at timestamp with time zone,
    last_activity_at timestamp with time zone,
    matched_on jsonb,
    external_refs jsonb,
    summary text,
    status character varying(20) DEFAULT 'ok'::character varying NOT NULL,
    error_note text,
    computed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE account_channel_context OWNER TO postgres;

--
-- Name: account_channel_context_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE account_channel_context_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE account_channel_context_id_seq OWNER TO postgres;

--
-- Name: account_channel_context_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE account_channel_context_id_seq OWNED BY account_channel_context.id;


--
-- Name: account_drive_folders; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE account_drive_folders (
    id integer NOT NULL,
    user_id integer NOT NULL,
    job_id character varying(255) NOT NULL,
    folder_id character varying(255) NOT NULL,
    folder_url text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE account_drive_folders OWNER TO postgres;

--
-- Name: account_drive_folders_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE account_drive_folders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE account_drive_folders_id_seq OWNER TO postgres;

--
-- Name: account_drive_folders_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE account_drive_folders_id_seq OWNED BY account_drive_folders.id;


--
-- Name: account_notes; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE account_notes (
    id integer NOT NULL,
    job_id character varying(255) NOT NULL,
    user_id integer NOT NULL,
    content text NOT NULL,
    is_activity boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL
);


ALTER TABLE account_notes OWNER TO postgres;

--
-- Name: account_notes_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE account_notes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE account_notes_id_seq OWNER TO postgres;

--
-- Name: account_notes_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE account_notes_id_seq OWNED BY account_notes.id;


--
-- Name: account_route_assessments; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE account_route_assessments (
    id integer NOT NULL,
    organisation_id integer NOT NULL,
    job_id character varying(255) NOT NULL,
    routes jsonb NOT NULL,
    recommended_route character varying(64),
    inputs_hash character varying(64),
    generated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE account_route_assessments OWNER TO postgres;

--
-- Name: account_route_assessments_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE account_route_assessments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE account_route_assessments_id_seq OWNER TO postgres;

--
-- Name: account_route_assessments_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE account_route_assessments_id_seq OWNED BY account_route_assessments.id;


--
-- Name: agent_metrics; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE agent_metrics (
    id integer NOT NULL,
    job_id character varying(255),
    agent_name character varying(100) NOT NULL,
    started_at timestamp without time zone NOT NULL,
    completed_at timestamp without time zone,
    status character varying(50) DEFAULT 'running'::character varying NOT NULL,
    error_message text,
    execution_duration_seconds integer,
    llm_input_tokens integer DEFAULT 0,
    llm_output_tokens integer DEFAULT 0,
    llm_cache_read_tokens integer DEFAULT 0,
    llm_cache_write_tokens integer DEFAULT 0,
    llm_total_tokens integer DEFAULT 0,
    tavily_search_count integer DEFAULT 0,
    serper_search_count integer DEFAULT 0,
    apify_actor_count integer DEFAULT 0,
    predictleads_call_count integer DEFAULT 0,
    exa_search_count integer DEFAULT 0,
    github_api_count integer DEFAULT 0,
    mcp_tool_call_count integer DEFAULT 0,
    model_id character varying(255),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE agent_metrics OWNER TO postgres;

--
-- Name: agent_metrics_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE agent_metrics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE agent_metrics_id_seq OWNER TO postgres;

--
-- Name: agent_metrics_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE agent_metrics_id_seq OWNED BY agent_metrics.id;


--
-- Name: agent_metrics_summary; Type: VIEW; Schema: dev; Owner: postgres
--

CREATE VIEW agent_metrics_summary AS
 SELECT agent_name,
    count(*) AS total_executions,
    sum(
        CASE
            WHEN ((status)::text = 'completed'::text) THEN 1
            ELSE 0
        END) AS successful_executions,
    sum(
        CASE
            WHEN ((status)::text = 'error'::text) THEN 1
            ELSE 0
        END) AS failed_executions,
    round(((100.0 * (sum(
        CASE
            WHEN ((status)::text = 'completed'::text) THEN 1
            ELSE 0
        END))::numeric) / (count(*))::numeric), 2) AS success_rate,
    sum(llm_total_tokens) AS total_tokens,
    round(avg(llm_total_tokens), 0) AS avg_tokens_per_execution,
    max(llm_total_tokens) AS max_tokens_per_execution,
    sum(tavily_search_count) AS total_tavily_calls,
    sum(serper_search_count) AS total_serper_calls,
    sum(apify_actor_count) AS total_apify_calls,
    sum(predictleads_call_count) AS total_predictleads_calls,
    sum(exa_search_count) AS total_exa_calls,
    sum(github_api_count) AS total_github_calls,
    sum(mcp_tool_call_count) AS total_mcp_calls,
    round(avg(execution_duration_seconds), 1) AS avg_duration_seconds,
    max(execution_duration_seconds) AS max_duration_seconds,
    min(created_at) AS first_execution,
    max(created_at) AS last_execution
   FROM agent_metrics
  GROUP BY agent_name;


ALTER VIEW agent_metrics_summary OWNER TO postgres;

--
-- Name: agent_tool_grants; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE agent_tool_grants (
    id uuid NOT NULL,
    user_id integer NOT NULL,
    connector_kind character varying(16) NOT NULL,
    connector_key character varying(64) NOT NULL,
    tool_name character varying(256) NOT NULL,
    auto_approve boolean NOT NULL,
    tool_hash character varying(64) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE agent_tool_grants OWNER TO postgres;

--
-- Name: ai_feedback_signals; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE ai_feedback_signals (
    id integer NOT NULL,
    company_scope character varying(255),
    user_id integer,
    job_id character varying(255),
    signal_type character varying(50) NOT NULL,
    payload text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE ai_feedback_signals OWNER TO postgres;

--
-- Name: ai_feedback_signals_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE ai_feedback_signals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ai_feedback_signals_id_seq OWNER TO postgres;

--
-- Name: ai_feedback_signals_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE ai_feedback_signals_id_seq OWNED BY ai_feedback_signals.id;


--
-- Name: alembic_version; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE alembic_version OWNER TO postgres;

--
-- Name: alerts; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE alerts (
    id integer NOT NULL,
    job_id character varying(255),
    user_id integer NOT NULL,
    trigger_type character varying(100) NOT NULL,
    message text NOT NULL,
    seen boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL
);


ALTER TABLE alerts OWNER TO postgres;

--
-- Name: alerts_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE alerts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE alerts_id_seq OWNER TO postgres;

--
-- Name: alerts_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE alerts_id_seq OWNED BY alerts.id;


--
-- Name: alliance_alerts; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE alliance_alerts (
    id integer NOT NULL,
    organisation_id integer NOT NULL,
    alert_type character varying(32) NOT NULL,
    case_id integer,
    partner_id integer,
    title character varying(256) NOT NULL,
    description text,
    context jsonb,
    severity character varying(16) DEFAULT 'medium'::character varying NOT NULL,
    status character varying(16) DEFAULT 'active'::character varying NOT NULL,
    due_at timestamp without time zone,
    acknowledged_at timestamp without time zone,
    resolved_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE alliance_alerts OWNER TO postgres;

--
-- Name: alliance_alerts_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE alliance_alerts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE alliance_alerts_id_seq OWNER TO postgres;

--
-- Name: alliance_alerts_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE alliance_alerts_id_seq OWNED BY alliance_alerts.id;


--
-- Name: alliance_insights; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE alliance_insights (
    id integer NOT NULL,
    organisation_id integer NOT NULL,
    surface character varying(64) NOT NULL,
    facts jsonb NOT NULL,
    facts_hash character(64) NOT NULL,
    content jsonb,
    status character varying(16) NOT NULL,
    started_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    error character varying(500),
    model_id character varying(255) NOT NULL,
    prompt_version character varying(32) NOT NULL,
    generated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE alliance_insights OWNER TO postgres;

--
-- Name: alliance_insights_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE alliance_insights_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE alliance_insights_id_seq OWNER TO postgres;

--
-- Name: alliance_insights_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE alliance_insights_id_seq OWNED BY alliance_insights.id;


--
-- Name: apn_opportunities; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE apn_opportunities (
    id integer NOT NULL,
    user_id integer NOT NULL,
    opportunity_id character varying(32) NOT NULL,
    catalog character varying(16) NOT NULL,
    partner_opportunity_identifier character varying(64),
    company_name character varying(512),
    stage character varying(128),
    review_status character varying(64),
    target_close_date date,
    primary_need text,
    opportunity_type character varying(64),
    origin character varying(64),
    raw_json jsonb NOT NULL,
    source_job_id character varying(255),
    aws_created_at timestamp without time zone,
    aws_modified_at timestamp without time zone,
    synced_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    organisation_id integer,
    summary_fetched_at timestamp without time zone
);


ALTER TABLE apn_opportunities OWNER TO postgres;

--
-- Name: apn_opportunities_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE apn_opportunities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE apn_opportunities_id_seq OWNER TO postgres;

--
-- Name: apn_opportunities_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE apn_opportunities_id_seq OWNED BY apn_opportunities.id;


--
-- Name: apn_sync_runs; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE apn_sync_runs (
    id integer NOT NULL,
    user_id integer NOT NULL,
    catalog character varying(16) NOT NULL,
    started_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    finished_at timestamp without time zone,
    opportunities_synced integer DEFAULT 0,
    error text,
    organisation_id integer
);


ALTER TABLE apn_sync_runs OWNER TO postgres;

--
-- Name: apn_sync_runs_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE apn_sync_runs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE apn_sync_runs_id_seq OWNER TO postgres;

--
-- Name: apn_sync_runs_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE apn_sync_runs_id_seq OWNED BY apn_sync_runs.id;


--
-- Name: atrisk_checks; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE atrisk_checks (
    id integer NOT NULL,
    job_id character varying(255) NOT NULL,
    user_id integer NOT NULL,
    checked_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    triggered_rules jsonb NOT NULL,
    overall_risk_score numeric(5,2),
    resolved_at timestamp without time zone,
    resolution_notes text,
    notified_at timestamp without time zone,
    notification_sent boolean DEFAULT false
);


ALTER TABLE atrisk_checks OWNER TO postgres;

--
-- Name: atrisk_checks_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE atrisk_checks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE atrisk_checks_id_seq OWNER TO postgres;

--
-- Name: atrisk_checks_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE atrisk_checks_id_seq OWNED BY atrisk_checks.id;


--
-- Name: batches; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE batches (
    id character varying(255) NOT NULL,
    status character varying(50) DEFAULT 'running'::character varying NOT NULL,
    total_jobs integer NOT NULL,
    completed_jobs integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    user_id integer,
    name character varying(255)
);


ALTER TABLE batches OWNER TO postgres;

--
-- Name: booking_links; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE booking_links (
    id integer NOT NULL,
    user_id integer NOT NULL,
    slug character varying(100) NOT NULL,
    title character varying(255),
    duration_minutes integer DEFAULT 30 NOT NULL,
    description text,
    business_hours_start integer DEFAULT 9 NOT NULL,
    business_hours_end integer DEFAULT 17 NOT NULL,
    timezone character varying(64) DEFAULT 'UTC'::character varying NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE booking_links OWNER TO postgres;

--
-- Name: booking_links_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE booking_links_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE booking_links_id_seq OWNER TO postgres;

--
-- Name: booking_links_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE booking_links_id_seq OWNED BY booking_links.id;


--
-- Name: campaign_attributions; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE campaign_attributions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    job_id character varying(255) NOT NULL,
    utm_source character varying(255),
    utm_medium character varying(255),
    utm_campaign character varying(255),
    converted_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE campaign_attributions OWNER TO postgres;

--
-- Name: campaign_attributions_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE campaign_attributions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE campaign_attributions_id_seq OWNER TO postgres;

--
-- Name: campaign_attributions_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE campaign_attributions_id_seq OWNED BY campaign_attributions.id;


--
-- Name: co_sell_readiness_ai; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE co_sell_readiness_ai (
    id integer NOT NULL,
    organisation_id integer NOT NULL,
    partner_id integer NOT NULL,
    job_id character varying(255),
    score integer,
    confidence numeric(3,2),
    readiness_summary text,
    dimensions jsonb,
    evidence jsonb,
    gaps jsonb,
    recommended_actions jsonb,
    next_best_action text,
    status character varying(50) NOT NULL,
    error text,
    generated_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL
);


ALTER TABLE co_sell_readiness_ai OWNER TO postgres;

--
-- Name: co_sell_readiness_ai_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE co_sell_readiness_ai_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE co_sell_readiness_ai_id_seq OWNER TO postgres;

--
-- Name: co_sell_readiness_ai_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE co_sell_readiness_ai_id_seq OWNED BY co_sell_readiness_ai.id;


--
-- Name: co_sell_rooms; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE co_sell_rooms (
    id integer NOT NULL,
    organisation_id integer NOT NULL,
    case_id integer NOT NULL,
    customer_objective text,
    joint_value_prop text,
    stakeholders jsonb,
    actions jsonb,
    next_customer_commitment text,
    commercial_route character varying(64),
    risks jsonb,
    agreed_next_step text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_activity_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE co_sell_rooms OWNER TO postgres;

--
-- Name: co_sell_rooms_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE co_sell_rooms_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE co_sell_rooms_id_seq OWNER TO postgres;

--
-- Name: co_sell_rooms_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE co_sell_rooms_id_seq OWNED BY co_sell_rooms.id;


--
-- Name: company_playbooks; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE company_playbooks (
    id integer NOT NULL,
    company_name character varying(255) NOT NULL,
    playbook_data text NOT NULL,
    version character varying(50),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE company_playbooks OWNER TO postgres;

--
-- Name: company_playbooks_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE company_playbooks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE company_playbooks_id_seq OWNER TO postgres;

--
-- Name: company_playbooks_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE company_playbooks_id_seq OWNED BY company_playbooks.id;


--
-- Name: connector_credentials; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE connector_credentials (
    id integer NOT NULL,
    user_id integer NOT NULL,
    connector_type character varying(50) NOT NULL,
    access_token text NOT NULL,
    refresh_token text,
    token_expires_at timestamp without time zone,
    scopes text,
    email character varying(255),
    is_active boolean DEFAULT true,
    last_sync_at timestamp without time zone,
    last_error text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    api_domain character varying(255),
    accounts_domain character varying(255),
    zoho_org_id character varying(64),
    apn_role_arn character varying(2048),
    apn_external_id character varying(255),
    apn_catalog character varying(16),
    apn_aws_account_id character varying(20),
    apn_region character varying(32)
);


ALTER TABLE connector_credentials OWNER TO postgres;

--
-- Name: connector_credentials_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE connector_credentials_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE connector_credentials_id_seq OWNER TO postgres;

--
-- Name: connector_credentials_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE connector_credentials_id_seq OWNED BY connector_credentials.id;


--
-- Name: crm_tokens; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE crm_tokens (
    id integer NOT NULL,
    user_id integer NOT NULL,
    crm_type character varying(50) NOT NULL,
    access_token text NOT NULL,
    refresh_token text,
    expires_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE crm_tokens OWNER TO postgres;

--
-- Name: crm_tokens_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE crm_tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE crm_tokens_id_seq OWNER TO postgres;

--
-- Name: crm_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE crm_tokens_id_seq OWNED BY crm_tokens.id;


--
-- Name: cxo_settings; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE cxo_settings (
    id integer NOT NULL,
    user_id integer NOT NULL,
    digest_enabled boolean DEFAULT false,
    forecast_sync_enabled boolean DEFAULT false,
    metrics_tracking_enabled boolean DEFAULT false,
    atrisk_monitoring_enabled boolean DEFAULT false,
    digest_schedule character varying(50),
    digest_custom_cron character varying(100),
    digest_chat_webhook_url text,
    digest_include_won boolean DEFAULT true,
    digest_include_lost boolean DEFAULT true,
    digest_include_stalled boolean DEFAULT true,
    forecast_sheet_id character varying(255),
    forecast_sync_schedule character varying(50) DEFAULT 'daily'::character varying,
    forecast_consolidate_sheet_id character varying(255),
    atrisk_rules jsonb DEFAULT '[]'::jsonb,
    atrisk_sheet_id character varying(255),
    metrics_sources jsonb DEFAULT '["gmail", "calendar", "sequences"]'::jsonb,
    user_role character varying(50) DEFAULT 'rep'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE cxo_settings OWNER TO postgres;

--
-- Name: cxo_settings_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE cxo_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE cxo_settings_id_seq OWNER TO postgres;

--
-- Name: cxo_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE cxo_settings_id_seq OWNED BY cxo_settings.id;


--
-- Name: daily_metrics_summary; Type: VIEW; Schema: dev; Owner: postgres
--

CREATE VIEW daily_metrics_summary AS
 SELECT date(created_at) AS date,
    agent_name,
    count(*) AS executions,
    sum(
        CASE
            WHEN ((status)::text = 'completed'::text) THEN 1
            ELSE 0
        END) AS successful,
    sum(
        CASE
            WHEN ((status)::text = 'error'::text) THEN 1
            ELSE 0
        END) AS failed,
    sum(llm_total_tokens) AS total_tokens,
    sum(llm_input_tokens) AS input_tokens,
    sum(llm_output_tokens) AS output_tokens,
    sum(tavily_search_count) AS tavily_calls,
    sum(serper_search_count) AS serper_calls,
    sum(apify_actor_count) AS apify_calls,
    sum(predictleads_call_count) AS predictleads_calls
   FROM agent_metrics
  GROUP BY (date(created_at)), agent_name
  ORDER BY (date(created_at)) DESC, agent_name;


ALTER VIEW daily_metrics_summary OWNER TO postgres;

--
-- Name: demo_leads; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE demo_leads (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    company character varying(255),
    phone character varying(50),
    source character varying(255),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE demo_leads OWNER TO postgres;

--
-- Name: demo_leads_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE demo_leads_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE demo_leads_id_seq OWNER TO postgres;

--
-- Name: demo_leads_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE demo_leads_id_seq OWNED BY demo_leads.id;


--
-- Name: digest_logs; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE digest_logs (
    id integer NOT NULL,
    user_id integer NOT NULL,
    sent_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    digest_type character varying(50) NOT NULL,
    chat_space_id character varying(255),
    won_count integer DEFAULT 0,
    lost_count integer DEFAULT 0,
    stalled_count integer DEFAULT 0,
    content_snapshot text,
    status character varying(50) DEFAULT 'sent'::character varying,
    error_message text
);


ALTER TABLE digest_logs OWNER TO postgres;

--
-- Name: digest_logs_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE digest_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE digest_logs_id_seq OWNER TO postgres;

--
-- Name: digest_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE digest_logs_id_seq OWNED BY digest_logs.id;


--
-- Name: domain_logo_cache; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE domain_logo_cache (
    domain character varying(255) NOT NULL,
    logo_url text,
    fetched_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE domain_logo_cache OWNER TO postgres;

--
-- Name: event_invitations; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE event_invitations (
    id integer NOT NULL,
    event_id integer NOT NULL,
    job_id character varying(255) NOT NULL,
    organisation_id integer NOT NULL,
    invitee_type character varying(16) NOT NULL,
    invitee_ref jsonb,
    sequence_enrollment_id integer,
    status character varying(16),
    sent_at timestamp without time zone,
    responded_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT event_invitations_invitee_type_check CHECK (((invitee_type)::text = ANY ((ARRAY['customer'::character varying, 'partner'::character varying])::text[])))
);


ALTER TABLE event_invitations OWNER TO postgres;

--
-- Name: event_invitations_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE event_invitations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE event_invitations_id_seq OWNER TO postgres;

--
-- Name: event_invitations_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE event_invitations_id_seq OWNED BY event_invitations.id;


--
-- Name: explorium_credit_limits; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE explorium_credit_limits (
    user_id integer NOT NULL,
    credit_limit integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    credits_used integer DEFAULT 0 NOT NULL,
    organization_id integer,
    is_override boolean DEFAULT false NOT NULL,
    CONSTRAINT explorium_credit_limit_nonnegative CHECK ((credit_limit >= 0)),
    CONSTRAINT explorium_credit_used_nonnegative CHECK ((credits_used >= 0))
);


ALTER TABLE explorium_credit_limits OWNER TO postgres;

--
-- Name: explorium_organisation_credit_limits; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE explorium_organisation_credit_limits (
    organization_id integer NOT NULL,
    credit_limit integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT explorium_org_credit_limit_nonnegative CHECK ((credit_limit >= 0))
);


ALTER TABLE explorium_organisation_credit_limits OWNER TO postgres;

--
-- Name: forecast_syncs; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE forecast_syncs (
    id integer NOT NULL,
    user_id integer NOT NULL,
    sheet_id character varying(255) NOT NULL,
    synced_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deal_count integer DEFAULT 0,
    status character varying(50) DEFAULT 'success'::character varying,
    error_message text,
    sync_duration_ms integer
);


ALTER TABLE forecast_syncs OWNER TO postgres;

--
-- Name: forecast_syncs_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE forecast_syncs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE forecast_syncs_id_seq OWNER TO postgres;

--
-- Name: forecast_syncs_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE forecast_syncs_id_seq OWNED BY forecast_syncs.id;


--
-- Name: jobs; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE jobs (
    id character varying(255) NOT NULL,
    company_name character varying(255) NOT NULL,
    domain character varying(255),
    country character varying(255),
    batch_id character varying(255),
    status character varying(50) DEFAULT 'running'::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    priority_score numeric(5,2),
    priority_tier character varying(50),
    priority_data text,
    priority_calculated_at timestamp without time zone,
    user_id integer,
    stage character varying(50) DEFAULT 'researched'::character varying,
    watched boolean DEFAULT false,
    estimated_deal_size numeric(14,2),
    closed_at timestamp without time zone,
    company_summary text,
    company_summary_persona_id character varying(255),
    company_summary_calculated_at timestamp without time zone,
    alliance_manager_name character varying(255),
    alliance_manager_email character varying(255),
    partners_in_play text,
    predictleads_follow_status character varying(50),
    verification_meta text,
    source character varying(50),
    linkedin_url character varying(500),
    priority_status character varying(20),
    queue_priority integer DEFAULT 0 NOT NULL
);


ALTER TABLE jobs OWNER TO postgres;

--
-- Name: job_metrics_summary; Type: VIEW; Schema: dev; Owner: postgres
--

CREATE VIEW job_metrics_summary AS
 SELECT j.id AS job_id,
    j.company_name,
    j.domain,
    j.status AS job_status,
    j.created_at AS job_created_at,
    count(am.id) AS total_agents_run,
    sum(
        CASE
            WHEN ((am.status)::text = 'completed'::text) THEN 1
            ELSE 0
        END) AS agents_completed,
    sum(
        CASE
            WHEN ((am.status)::text = 'error'::text) THEN 1
            ELSE 0
        END) AS agents_failed,
    sum(am.llm_total_tokens) AS total_tokens,
    sum(am.llm_input_tokens) AS total_input_tokens,
    sum(am.llm_output_tokens) AS total_output_tokens,
    sum(
        CASE
            WHEN ((am.agent_name)::text = 'finance'::text) THEN am.llm_total_tokens
            ELSE 0
        END) AS finance_tokens,
    sum(
        CASE
            WHEN ((am.agent_name)::text = 'techstack'::text) THEN am.llm_total_tokens
            ELSE 0
        END) AS techstack_tokens,
    sum(
        CASE
            WHEN ((am.agent_name)::text = 'linkedin'::text) THEN am.llm_total_tokens
            ELSE 0
        END) AS linkedin_tokens,
    sum(
        CASE
            WHEN ((am.agent_name)::text = 'competition'::text) THEN am.llm_total_tokens
            ELSE 0
        END) AS competition_tokens,
    sum(
        CASE
            WHEN ((am.agent_name)::text = 'persona'::text) THEN am.llm_total_tokens
            ELSE 0
        END) AS persona_tokens,
    sum(
        CASE
            WHEN ((am.agent_name)::text = 'playbooks'::text) THEN am.llm_total_tokens
            ELSE 0
        END) AS playbooks_tokens,
    sum(am.tavily_search_count) AS total_tavily_calls,
    sum(am.serper_search_count) AS total_serper_calls,
    sum(am.apify_actor_count) AS total_apify_calls,
    sum(am.predictleads_call_count) AS total_predictleads_calls,
    sum(am.exa_search_count) AS total_exa_calls,
    sum(am.github_api_count) AS total_github_calls,
    max(am.completed_at) AS last_agent_completed,
    sum(am.execution_duration_seconds) AS total_execution_seconds
   FROM (jobs j
     LEFT JOIN agent_metrics am ON (((j.id)::text = (am.job_id)::text)))
  GROUP BY j.id, j.company_name, j.domain, j.status, j.created_at;


ALTER VIEW job_metrics_summary OWNER TO postgres;

--
-- Name: leader_extras; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE leader_extras (
    id integer NOT NULL,
    job_id character varying(255) NOT NULL,
    leader_key character varying(255) NOT NULL,
    name character varying(255),
    rating smallint,
    custom_angle text,
    upcoming_events text,
    youtube_links text,
    enriched_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE leader_extras OWNER TO postgres;

--
-- Name: leader_extras_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE leader_extras_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE leader_extras_id_seq OWNER TO postgres;

--
-- Name: leader_extras_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE leader_extras_id_seq OWNED BY leader_extras.id;


--
-- Name: leadership_results; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE leadership_results (
    job_id character varying(255) NOT NULL,
    org_tree text,
    status character varying(50) DEFAULT 'pending'::character varying NOT NULL,
    error text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE leadership_results OWNER TO postgres;

--
-- Name: mailbox_owner_companies; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE mailbox_owner_companies (
    id integer NOT NULL,
    user_id integer NOT NULL,
    job_id character varying(255) NOT NULL,
    domain text NOT NULL,
    company_name text NOT NULL,
    slot mailbox_owner_slot NOT NULL,
    channel_hint mailbox_owner_channel_hint DEFAULT 'both'::mailbox_owner_channel_hint NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE mailbox_owner_companies OWNER TO postgres;

--
-- Name: mailbox_owner_companies_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE mailbox_owner_companies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mailbox_owner_companies_id_seq OWNER TO postgres;

--
-- Name: mailbox_owner_companies_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE mailbox_owner_companies_id_seq OWNED BY mailbox_owner_companies.id;


--
-- Name: mailbox_watch_state; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE mailbox_watch_state (
    id integer NOT NULL,
    user_id integer NOT NULL,
    channel mailbox_watch_channel NOT NULL,
    resource_id text NOT NULL,
    subscription_id text,
    last_history_id text,
    expires_at timestamp with time zone NOT NULL,
    status mailbox_watch_status DEFAULT 'active'::mailbox_watch_status NOT NULL,
    last_error text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE mailbox_watch_state OWNER TO postgres;

--
-- Name: mailbox_watch_state_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE mailbox_watch_state_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mailbox_watch_state_id_seq OWNER TO postgres;

--
-- Name: mailbox_watch_state_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE mailbox_watch_state_id_seq OWNED BY mailbox_watch_state.id;


--
-- Name: mcp_connectors; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE mcp_connectors (
    id uuid NOT NULL,
    user_id integer NOT NULL,
    name character varying(120) NOT NULL,
    slug character varying(64) NOT NULL,
    endpoint_url character varying(2048) NOT NULL,
    resource_uri character varying(2048) NOT NULL,
    auth_mode character varying(16) DEFAULT 'oauth'::character varying NOT NULL,
    status character varying(24) DEFAULT 'pending_auth'::character varying NOT NULL,
    status_detail text,
    static_token text,
    static_header_name character varying(64),
    oauth_issuer character varying(2048),
    oauth_client_id character varying(512),
    oauth_client_secret text,
    oauth_scopes text,
    access_token text,
    refresh_token text,
    token_expires_at timestamp with time zone,
    server_info jsonb,
    server_capabilities jsonb,
    tool_catalog jsonb,
    catalog_fingerprint character varying(64),
    consented_fingerprint character varying(64),
    tool_count integer,
    last_connected_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    oauth_redirect_uri character varying(2048)
);


ALTER TABLE mcp_connectors OWNER TO postgres;

--
-- Name: mcp_tool_grants; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE mcp_tool_grants (
    id uuid NOT NULL,
    connector_id uuid NOT NULL,
    tool_name character varying(256) NOT NULL,
    auto_approve boolean DEFAULT false NOT NULL,
    tool_hash character varying(64) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE mcp_tool_grants OWNER TO postgres;

--
-- Name: metrics_snapshots; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE metrics_snapshots (
    id integer NOT NULL,
    user_id integer NOT NULL,
    snapshot_date date NOT NULL,
    emails_sent integer DEFAULT 0,
    emails_replied integer DEFAULT 0,
    reply_rate numeric(5,4),
    meetings_scheduled integer DEFAULT 0,
    meetings_accepted integer DEFAULT 0,
    meetings_declined integer DEFAULT 0,
    acceptance_rate numeric(5,4),
    gmail_emails_sent integer DEFAULT 0,
    sequence_emails_sent integer DEFAULT 0,
    manual_emails_sent integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE metrics_snapshots OWNER TO postgres;

--
-- Name: metrics_snapshots_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE metrics_snapshots_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE metrics_snapshots_id_seq OWNER TO postgres;

--
-- Name: metrics_snapshots_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE metrics_snapshots_id_seq OWNED BY metrics_snapshots.id;


--
-- Name: microsoft_referrals; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE microsoft_referrals (
    id integer NOT NULL,
    organisation_id integer NOT NULL,
    partner_id integer NOT NULL,
    external_referral_id character varying(255) NOT NULL,
    status character varying(32) NOT NULL,
    customer_name character varying(255) NOT NULL,
    problem_description text,
    solution_areas jsonb,
    raw_data jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    synced_at timestamp without time zone
);


ALTER TABLE microsoft_referrals OWNER TO postgres;

--
-- Name: microsoft_referrals_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE microsoft_referrals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE microsoft_referrals_id_seq OWNER TO postgres;

--
-- Name: microsoft_referrals_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE microsoft_referrals_id_seq OWNED BY microsoft_referrals.id;


--
-- Name: news_events; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE news_events (
    id integer NOT NULL,
    job_id character varying(255) NOT NULL,
    company_name character varying(255) NOT NULL,
    event_type character varying(100) NOT NULL,
    event_data text NOT NULL,
    source character varying(100) DEFAULT 'theirstack'::character varying NOT NULL,
    received_at timestamp without time zone NOT NULL
);


ALTER TABLE news_events OWNER TO postgres;

--
-- Name: news_events_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE news_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE news_events_id_seq OWNER TO postgres;

--
-- Name: news_events_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE news_events_id_seq OWNED BY news_events.id;


--
-- Name: org_events; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE org_events (
    id integer NOT NULL,
    organisation_id integer NOT NULL,
    name character varying(255) NOT NULL,
    type character varying(16) NOT NULL,
    partner_id integer,
    starts_at timestamp without time zone NOT NULL,
    ends_at timestamp without time zone,
    location text,
    city character varying(128),
    country character varying(2),
    industries jsonb,
    registration_url text,
    invite_capacity integer,
    owner_user_id integer,
    meta jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT org_events_type_check CHECK (((type)::text = ANY ((ARRAY['own'::character varying, 'partner'::character varying, 'industry'::character varying])::text[])))
);


ALTER TABLE org_events OWNER TO postgres;

--
-- Name: org_events_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE org_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE org_events_id_seq OWNER TO postgres;

--
-- Name: org_events_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE org_events_id_seq OWNED BY org_events.id;


--
-- Name: organisations; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE organisations (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    plan character varying(100) DEFAULT 'Standard Plan'::character varying,
    token_budget integer,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    max_users smallint DEFAULT 3 NOT NULL,
    domain_key character varying(255),
    status character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    enabled_features jsonb DEFAULT '["accounts", "research", "playbooks"]'::jsonb NOT NULL,
    playbook_features_configured boolean DEFAULT false NOT NULL
);


ALTER TABLE organisations OWNER TO postgres;

--
-- Name: organisations_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE organisations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE organisations_id_seq OWNER TO postgres;

--
-- Name: organisations_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE organisations_id_seq OWNED BY organisations.id;


--
-- Name: otp_verifications; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE otp_verifications (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    otp_hash character varying(255) NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    is_used boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE otp_verifications OWNER TO postgres;

--
-- Name: otp_verifications_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE otp_verifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE otp_verifications_id_seq OWNER TO postgres;

--
-- Name: otp_verifications_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE otp_verifications_id_seq OWNED BY otp_verifications.id;


--
-- Name: partner_account_overlaps; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE partner_account_overlaps (
    id integer NOT NULL,
    organisation_id integer NOT NULL,
    partner_id integer NOT NULL,
    job_id character varying(255),
    our_status character varying(16) NOT NULL,
    partner_status character varying(16) NOT NULL,
    our_owner_user_id integer,
    partner_owner_contact_id integer,
    owner_confidence integer DEFAULT 50 NOT NULL,
    last_verified_at timestamp without time zone,
    source character varying(16) NOT NULL,
    share_scope jsonb DEFAULT '{"visibility": "full", "hidden_fields": [], "shared_fields": [], "mutual_approval": false}'::jsonb NOT NULL,
    joint_use_case text,
    recommended_action text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT partner_account_overlaps_confidence_check CHECK (((owner_confidence >= 0) AND (owner_confidence <= 100))),
    CONSTRAINT partner_account_overlaps_our_status_check CHECK (((our_status)::text = ANY ((ARRAY['prospect'::character varying, 'active'::character varying, 'won'::character varying, 'lost'::character varying])::text[]))),
    CONSTRAINT partner_account_overlaps_partner_status_check CHECK (((partner_status)::text = ANY ((ARRAY['prospect'::character varying, 'pipeline'::character varying, 'won'::character varying])::text[]))),
    CONSTRAINT partner_account_overlaps_source_check CHECK (((source)::text = ANY ((ARRAY['csv'::character varying, 'crm'::character varying, 'partner_crm'::character varying, 'crossbeam'::character varying, 'inferred'::character varying])::text[])))
);


ALTER TABLE partner_account_overlaps OWNER TO postgres;

--
-- Name: partner_account_overlaps_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE partner_account_overlaps_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE partner_account_overlaps_id_seq OWNER TO postgres;

--
-- Name: partner_account_overlaps_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE partner_account_overlaps_id_seq OWNED BY partner_account_overlaps.id;


--
-- Name: partner_benchmarks; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE partner_benchmarks (
    id integer NOT NULL,
    partner_id integer NOT NULL,
    organisation_id integer NOT NULL,
    competitor_name character varying(255) NOT NULL,
    dimension character varying(32) NOT NULL,
    value jsonb,
    evidence jsonb,
    captured_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT partner_benchmarks_dimension_check CHECK (((dimension)::text = ANY ((ARRAY['marketplace_presence'::character varying, 'public_competencies'::character varying, 'joint_announcements'::character varying, 'case_studies'::character varying, 'awards'::character varying, 'co_sell_references'::character varying, 'regional_activity'::character varying])::text[])))
);


ALTER TABLE partner_benchmarks OWNER TO postgres;

--
-- Name: partner_benchmarks_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE partner_benchmarks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE partner_benchmarks_id_seq OWNER TO postgres;

--
-- Name: partner_benchmarks_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE partner_benchmarks_id_seq OWNED BY partner_benchmarks.id;


--
-- Name: partner_connections; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE partner_connections (
    id integer NOT NULL,
    partner_id integer NOT NULL,
    organisation_id integer NOT NULL,
    connector_type character varying(32) NOT NULL,
    role_arn character varying(2048),
    external_id character varying(64),
    aws_account_id character varying(20),
    catalog character varying(16),
    region character varying(32),
    access_token text,
    refresh_token text,
    token_expires_at timestamp without time zone,
    scopes text,
    is_active boolean DEFAULT true NOT NULL,
    last_sync_at timestamp without time zone,
    last_error text,
    created_by_user_id integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb,
    CONSTRAINT partner_connections_connector_type_check CHECK (((connector_type)::text = ANY ((ARRAY['apn_selling'::character varying, 'apn_account'::character varying, 'apn_benefits'::character varying, 'apn_channel'::character varying, 'apn_agent_mcp'::character varying, 'aws_marketplace'::character varying, 'ms_partner_center'::character varying, 'gcp_producer'::character varying])::text[])))
);


ALTER TABLE partner_connections OWNER TO postgres;

--
-- Name: partner_connections_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE partner_connections_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE partner_connections_id_seq OWNER TO postgres;

--
-- Name: partner_connections_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE partner_connections_id_seq OWNED BY partner_connections.id;


--
-- Name: partner_contacts; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE partner_contacts (
    id integer NOT NULL,
    partner_id integer NOT NULL,
    organisation_id integer NOT NULL,
    name character varying(255),
    email character varying(255) NOT NULL,
    title character varying(255),
    role character varying(32),
    territory character varying(128),
    industries jsonb,
    source character varying(32),
    last_touch_at timestamp without time zone,
    responsiveness numeric(4,3),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE partner_contacts OWNER TO postgres;

--
-- Name: partner_contacts_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE partner_contacts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE partner_contacts_id_seq OWNER TO postgres;

--
-- Name: partner_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE partner_contacts_id_seq OWNED BY partner_contacts.id;


--
-- Name: partner_engagement_cases; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE partner_engagement_cases (
    id integer NOT NULL,
    organisation_id integer NOT NULL,
    job_id character varying(255) NOT NULL,
    partner_id integer NOT NULL,
    owner_user_id integer,
    state character varying(32) DEFAULT 'identified'::character varying NOT NULL,
    engagement_type character varying(16) DEFAULT 'visibility'::character varying NOT NULL,
    primary_contact_id integer,
    cc_contact_ids jsonb,
    customer_contact_ref jsonb,
    external_opportunity_ref character varying(256),
    co_sell_motion character varying(32),
    involvement_type character varying(64),
    aws_quality_score integer,
    aws_quality_trend character varying(16),
    aws_engagement_score integer,
    engagement_case jsonb,
    reciprocal_value jsonb,
    outcome character varying(32),
    outcome_reason text,
    opened_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_transition_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    partner_assisted_amount numeric(15,2),
    feedback_score integer,
    CONSTRAINT feedback_score_range CHECK (((feedback_score IS NULL) OR ((feedback_score >= 0) AND (feedback_score <= 5)))),
    CONSTRAINT partner_engagement_cases_state_check CHECK (((state)::text = ANY ((ARRAY['identified'::character varying, 'route_selected'::character varying, 'am_discovery'::character varying, 'first_touch_sent'::character varying, 'follow_up_1'::character varying, 'follow_up_2'::character varying, 'partner_engaged'::character varying, 'joint_meeting'::character varying, 'co_sell_registered'::character varying, 'partner_assisted_win'::character varying, 'lost'::character varying, 'no_response'::character varying, 'customer_contact_found'::character varying, 're_engaged_with_evidence'::character varying, 'alt_route_recommended'::character varying])::text[]))),
    CONSTRAINT partner_engagement_cases_type_check CHECK (((engagement_type)::text = ANY ((ARRAY['visibility'::character varying, 'co_sell'::character varying, 'prospecting'::character varying])::text[])))
);


ALTER TABLE partner_engagement_cases OWNER TO postgres;

--
-- Name: partner_engagement_cases_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE partner_engagement_cases_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE partner_engagement_cases_id_seq OWNER TO postgres;

--
-- Name: partner_engagement_cases_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE partner_engagement_cases_id_seq OWNED BY partner_engagement_cases.id;


--
-- Name: partner_engagement_events; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE partner_engagement_events (
    id integer NOT NULL,
    case_id integer NOT NULL,
    organisation_id integer NOT NULL,
    event_type character varying(32) NOT NULL,
    payload jsonb,
    actor_user_id integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE partner_engagement_events OWNER TO postgres;

--
-- Name: partner_engagement_events_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE partner_engagement_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE partner_engagement_events_id_seq OWNER TO postgres;

--
-- Name: partner_engagement_events_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE partner_engagement_events_id_seq OWNED BY partner_engagement_events.id;


--
-- Name: partner_facts; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE partner_facts (
    id integer NOT NULL,
    partner_id integer NOT NULL,
    organisation_id integer NOT NULL,
    fact_key character varying(48) NOT NULL,
    source character varying(8) NOT NULL,
    value jsonb,
    evidence jsonb,
    updated_by_user_id integer,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT partner_facts_source_check CHECK (((source)::text = ANY ((ARRAY['api'::character varying, 'seller'::character varying])::text[])))
);


ALTER TABLE partner_facts OWNER TO postgres;

--
-- Name: partner_facts_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE partner_facts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE partner_facts_id_seq OWNER TO postgres;

--
-- Name: partner_facts_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE partner_facts_id_seq OWNED BY partner_facts.id;


--
-- Name: partner_matches; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE partner_matches (
    id integer NOT NULL,
    organisation_id integer NOT NULL,
    isv_partner_id integer NOT NULL,
    reseller_partner_id integer NOT NULL,
    job_id character varying(255) NOT NULL,
    gap_filled character varying(32) NOT NULL,
    score integer NOT NULL,
    rationale text NOT NULL,
    evidence jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT partner_matches_score_check CHECK (((score >= 0) AND (score <= 100)))
);


ALTER TABLE partner_matches OWNER TO postgres;

--
-- Name: partner_matches_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE partner_matches_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE partner_matches_id_seq OWNER TO postgres;

--
-- Name: partner_matches_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE partner_matches_id_seq OWNED BY partner_matches.id;


--
-- Name: partner_readiness; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE partner_readiness (
    id integer NOT NULL,
    partner_id integer NOT NULL,
    organisation_id integer NOT NULL,
    dimension character varying(48) NOT NULL,
    value jsonb,
    target jsonb,
    score smallint,
    evidence jsonb,
    source character varying(16) NOT NULL,
    captured_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT partner_readiness_score_range_check CHECK (((score IS NULL) OR ((score >= 0) AND (score <= 100)))),
    CONSTRAINT partner_readiness_source_check CHECK (((source)::text = ANY ((ARRAY['api'::character varying, 'seller'::character varying, 'inferred'::character varying])::text[])))
);


ALTER TABLE partner_readiness OWNER TO postgres;

--
-- Name: partner_readiness_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE partner_readiness_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE partner_readiness_id_seq OWNER TO postgres;

--
-- Name: partner_readiness_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE partner_readiness_id_seq OWNED BY partner_readiness.id;


--
-- Name: partner_references; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE partner_references (
    id integer NOT NULL,
    organisation_id integer NOT NULL,
    partner_id integer,
    kind character varying(32) NOT NULL,
    customer_name character varying(255),
    industry character varying(128),
    use_case character varying(128),
    solution_area character varying(128),
    products jsonb,
    region character varying(64),
    url text,
    summary text,
    is_public boolean DEFAULT false NOT NULL,
    source character varying(16) NOT NULL,
    source_ref jsonb,
    meta jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT partner_references_kind_check CHECK (((kind)::text = ANY ((ARRAY['case_study'::character varying, 'joint_pr'::character varying, 'award'::character varying, 'customer_reference'::character varying, 'event'::character varying])::text[]))),
    CONSTRAINT partner_references_source_check CHECK (((source)::text = ANY ((ARRAY['manual'::character varying, 'reference_document'::character varying, 'web'::character varying])::text[])))
);


ALTER TABLE partner_references OWNER TO postgres;

--
-- Name: partner_references_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE partner_references_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE partner_references_id_seq OWNER TO postgres;

--
-- Name: partner_references_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE partner_references_id_seq OWNED BY partner_references.id;


--
-- Name: partner_solutions; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE partner_solutions (
    id integer NOT NULL,
    partner_id integer NOT NULL,
    organisation_id integer NOT NULL,
    external_id character varying(128) NOT NULL,
    name character varying(255),
    type character varying(32) NOT NULL,
    status character varying(32),
    raw_json jsonb,
    synced_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT partner_solutions_type_check CHECK (((type)::text = ANY ((ARRAY['partner_solution'::character varying, 'marketplace_product'::character varying, 'private_offer'::character varying])::text[])))
);


ALTER TABLE partner_solutions OWNER TO postgres;

--
-- Name: partner_solutions_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE partner_solutions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE partner_solutions_id_seq OWNER TO postgres;

--
-- Name: partner_solutions_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE partner_solutions_id_seq OWNED BY partner_solutions.id;


--
-- Name: partner_targets; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE partner_targets (
    id integer NOT NULL,
    partner_id integer NOT NULL,
    organisation_id integer NOT NULL,
    agreement_type character varying(16) NOT NULL,
    period character varying(32) DEFAULT ''::character varying NOT NULL,
    external_id character varying(128) DEFAULT ''::character varying NOT NULL,
    name character varying(255),
    status character varying(16) DEFAULT 'not_started'::character varying NOT NULL,
    starts_on date,
    ends_on date,
    goal jsonb,
    progress jsonb,
    currency character varying(3),
    funding_total numeric(14,2),
    funding_remaining numeric(14,2),
    note text,
    source character varying(8) NOT NULL,
    captured_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT partner_targets_agreement_type_check CHECK (((agreement_type)::text = ANY ((ARRAY['sca'::character varying, 'aca'::character varying, 'ppa'::character varying, 'mdf'::character varying, 'benefit'::character varying, 'other'::character varying])::text[]))),
    CONSTRAINT partner_targets_source_check CHECK (((source)::text = ANY ((ARRAY['api'::character varying, 'seller'::character varying])::text[]))),
    CONSTRAINT partner_targets_status_check CHECK (((status)::text = ANY ((ARRAY['not_started'::character varying, 'negotiating'::character varying, 'signed'::character varying, 'active'::character varying, 'expired'::character varying])::text[])))
);


ALTER TABLE partner_targets OWNER TO postgres;

--
-- Name: partner_targets_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE partner_targets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE partner_targets_id_seq OWNER TO postgres;

--
-- Name: partner_targets_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE partner_targets_id_seq OWNED BY partner_targets.id;


--
-- Name: partners; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE partners (
    id integer NOT NULL,
    organisation_id integer NOT NULL,
    partner_type character varying(32) NOT NULL,
    name character varying(255) NOT NULL,
    slug character varying(64) NOT NULL,
    tier character varying(64),
    status character varying(32),
    contact_policy jsonb,
    meta jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT partners_partner_type_check CHECK (((partner_type)::text = ANY ((ARRAY['hyperscaler'::character varying, 'gsi'::character varying, 'distributor'::character varying, 'reseller'::character varying, 'channel'::character varying, 'tech_partner'::character varying, 'investor'::character varying, 'isv'::character varying])::text[])))
);


ALTER TABLE partners OWNER TO postgres;

--
-- Name: partners_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE partners_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE partners_id_seq OWNER TO postgres;

--
-- Name: partners_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE partners_id_seq OWNED BY partners.id;


--
-- Name: person_intel_cache; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE person_intel_cache (
    id integer NOT NULL,
    company_name character varying(255) NOT NULL,
    role character varying(255) NOT NULL,
    result_json text NOT NULL,
    references_json text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE person_intel_cache OWNER TO postgres;

--
-- Name: person_intel_cache_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE person_intel_cache_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE person_intel_cache_id_seq OWNER TO postgres;

--
-- Name: person_intel_cache_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE person_intel_cache_id_seq OWNED BY person_intel_cache.id;


--
-- Name: persona; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE persona (
    id character varying(255) NOT NULL,
    company_name character varying(255) NOT NULL,
    company_domain character varying(255),
    user_name character varying(255),
    user_role character varying(255),
    solutions text,
    icp text,
    value_prop text,
    status character varying(50) DEFAULT 'pending'::character varying NOT NULL,
    profile_json text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer,
    signal_prefs text,
    dealbreakers text,
    persona_version integer DEFAULT 1,
    company_details text,
    buyer_personas text
);


ALTER TABLE persona OWNER TO postgres;

--
-- Name: playbook_kb; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE playbook_kb (
    id integer NOT NULL,
    kind character varying(32) NOT NULL,
    title character varying(255) NOT NULL,
    trigger character varying(64),
    persona character varying(64),
    priority character varying(16),
    body text NOT NULL,
    meta jsonb,
    source character varying(64) DEFAULT 'lavender_v1'::character varying NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE playbook_kb OWNER TO postgres;

--
-- Name: playbook_kb_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE playbook_kb_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE playbook_kb_id_seq OWNER TO postgres;

--
-- Name: playbook_kb_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE playbook_kb_id_seq OWNED BY playbook_kb.id;


--
-- Name: playbook_variants; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE playbook_variants (
    id integer NOT NULL,
    job_id character varying(255) NOT NULL,
    playbook_type character varying(100) NOT NULL,
    variant_name character varying(255) NOT NULL,
    custom_solution text,
    custom_features text,
    custom_target_personas text,
    playbook_data text NOT NULL,
    summary_data text,
    is_default boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    contacts_status character varying(50),
    contacts_data text,
    buying_intent_data text,
    buying_intent_calculated_at timestamp without time zone,
    ai_generated_targeting_text text,
    uploaded_file_name text,
    uploaded_file_summary text
);


ALTER TABLE playbook_variants OWNER TO postgres;

--
-- Name: playbook_variants_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE playbook_variants_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE playbook_variants_id_seq OWNER TO postgres;

--
-- Name: playbook_variants_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE playbook_variants_id_seq OWNED BY playbook_variants.id;


--
-- Name: presentations; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE presentations (
    id integer NOT NULL,
    user_id integer NOT NULL,
    job_id character varying(255),
    presentation_type character varying(50) NOT NULL,
    title text,
    drive_file_id character varying(255),
    drive_url text,
    slides_url text,
    slide_count integer,
    status character varying(50) DEFAULT 'completed'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE presentations OWNER TO postgres;

--
-- Name: presentations_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE presentations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE presentations_id_seq OWNER TO postgres;

--
-- Name: presentations_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE presentations_id_seq OWNED BY presentations.id;


--
-- Name: qbr_generations; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE qbr_generations (
    id integer NOT NULL,
    user_id integer NOT NULL,
    quarter character varying(10) NOT NULL,
    drive_file_id character varying(255) NOT NULL,
    drive_file_url text NOT NULL,
    slides_url text,
    generated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    reviewed_status character varying(50) DEFAULT 'draft'::character varying,
    deal_count integer DEFAULT 0,
    total_pipeline_value numeric(14,2)
);


ALTER TABLE qbr_generations OWNER TO postgres;

--
-- Name: qbr_generations_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE qbr_generations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE qbr_generations_id_seq OWNER TO postgres;

--
-- Name: qbr_generations_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE qbr_generations_id_seq OWNED BY qbr_generations.id;


--
-- Name: relationship_bridges; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE relationship_bridges (
    id integer NOT NULL,
    job_id character varying(255) NOT NULL,
    organisation_id integer NOT NULL,
    bridge_type character varying(32) NOT NULL,
    via_entity character varying(255) NOT NULL,
    our_side_ref jsonb,
    their_side_ref jsonb,
    strength character varying(16) NOT NULL,
    evidence jsonb,
    source character varying(32),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT relationship_bridges_strength_check CHECK (((strength)::text = ANY ((ARRAY['strong'::character varying, 'medium'::character varying, 'weak'::character varying])::text[]))),
    CONSTRAINT relationship_bridges_type_check CHECK (((bridge_type)::text = ANY ((ARRAY['shared_investor'::character varying, 'board_member'::character varying, 'advisor'::character varying, 'existing_customer'::character varying, 'common_exec'::character varying, 'colleague'::character varying, 'partner'::character varying])::text[])))
);


ALTER TABLE relationship_bridges OWNER TO postgres;

--
-- Name: relationship_bridges_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE relationship_bridges_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE relationship_bridges_id_seq OWNER TO postgres;

--
-- Name: relationship_bridges_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE relationship_bridges_id_seq OWNED BY relationship_bridges.id;


--
-- Name: results; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE results (
    id integer NOT NULL,
    job_id character varying(255) NOT NULL,
    tool_name character varying(100) NOT NULL,
    status character varying(50) DEFAULT 'pending'::character varying NOT NULL,
    progress text,
    result_json text,
    s3_key character varying(500),
    completed_at timestamp without time zone
);


ALTER TABLE results OWNER TO postgres;

--
-- Name: results_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE results_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE results_id_seq OWNER TO postgres;

--
-- Name: results_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE results_id_seq OWNED BY results.id;


--
-- Name: search_index; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE search_index (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    object_type character varying(32) NOT NULL,
    object_id character varying(255) NOT NULL,
    title text NOT NULL,
    body text NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    tsv tsvector GENERATED ALWAYS AS ((setweight(to_tsvector('english'::regconfig, COALESCE(title, ''::text)), 'A'::"char") || setweight(to_tsvector('english'::regconfig, COALESCE(body, ''::text)), 'B'::"char"))) STORED,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    embedding staging.vector(1024)
);


ALTER TABLE search_index OWNER TO postgres;

--
-- Name: search_index_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE search_index_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE search_index_id_seq OWNER TO postgres;

--
-- Name: search_index_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE search_index_id_seq OWNED BY search_index.id;


--
-- Name: search_query_log; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE search_query_log (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    query text NOT NULL,
    lane smallint NOT NULL,
    classifier_confidence real,
    latency_ms integer,
    sources_used jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE search_query_log OWNER TO postgres;

--
-- Name: search_query_log_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE search_query_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE search_query_log_id_seq OWNER TO postgres;

--
-- Name: search_query_log_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE search_query_log_id_seq OWNED BY search_query_log.id;


--
-- Name: sequence_enrollments; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE sequence_enrollments (
    id integer NOT NULL,
    user_id integer NOT NULL,
    job_id character varying(255) NOT NULL,
    contact_name character varying(255) NOT NULL,
    contact_email character varying(255) NOT NULL,
    template character varying(50) NOT NULL,
    status character varying(50) DEFAULT 'active'::character varying NOT NULL,
    gmail_thread_id character varying(255),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    trigger_source text DEFAULT 'manual'::text
);


ALTER TABLE sequence_enrollments OWNER TO postgres;

--
-- Name: sequence_enrollments_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE sequence_enrollments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE sequence_enrollments_id_seq OWNER TO postgres;

--
-- Name: sequence_enrollments_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE sequence_enrollments_id_seq OWNED BY sequence_enrollments.id;


--
-- Name: sequence_steps; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE sequence_steps (
    id integer NOT NULL,
    enrollment_id integer NOT NULL,
    step_number integer NOT NULL,
    due_at timestamp without time zone NOT NULL,
    status character varying(50) DEFAULT 'scheduled'::character varying NOT NULL,
    draft_subject text,
    draft_body text,
    sent_subject text,
    sent_body text,
    gmail_message_id character varying(255),
    sent_at timestamp without time zone,
    error_message text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE sequence_steps OWNER TO postgres;

--
-- Name: sequence_steps_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE sequence_steps_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE sequence_steps_id_seq OWNER TO postgres;

--
-- Name: sequence_steps_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE sequence_steps_id_seq OWNED BY sequence_steps.id;


--
-- Name: sf_accounts; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE sf_accounts (
    id integer NOT NULL,
    user_id integer NOT NULL,
    sf_id character varying(64) NOT NULL,
    name character varying(512),
    industry character varying(255),
    website character varying(512),
    phone character varying(64),
    annual_revenue numeric,
    employees integer,
    billing_city character varying(255),
    billing_country character varying(255),
    description text,
    raw_json jsonb NOT NULL,
    promoted_job_id character varying(255),
    sf_created_at timestamp without time zone,
    sf_modified_at timestamp without time zone,
    synced_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE sf_accounts OWNER TO postgres;

--
-- Name: sf_accounts_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE sf_accounts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE sf_accounts_id_seq OWNER TO postgres;

--
-- Name: sf_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE sf_accounts_id_seq OWNED BY sf_accounts.id;


--
-- Name: sf_deals; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE sf_deals (
    id integer NOT NULL,
    user_id integer NOT NULL,
    sf_id character varying(64) NOT NULL,
    deal_name character varying(512),
    account_sf_id character varying(64),
    account_name character varying(512),
    stage character varying(255),
    deal_type character varying(255),
    amount numeric,
    probability numeric,
    expected_revenue numeric,
    closing_date date,
    lead_source character varying(255),
    owner_name character varying(255),
    description text,
    raw_json jsonb NOT NULL,
    promoted_job_id character varying(255),
    sf_created_at timestamp without time zone,
    sf_modified_at timestamp without time zone,
    synced_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE sf_deals OWNER TO postgres;

--
-- Name: sf_deals_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE sf_deals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE sf_deals_id_seq OWNER TO postgres;

--
-- Name: sf_deals_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE sf_deals_id_seq OWNED BY sf_deals.id;


--
-- Name: sf_leads; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE sf_leads (
    id integer NOT NULL,
    user_id integer NOT NULL,
    sf_id character varying(64) NOT NULL,
    full_name character varying(512),
    email character varying(255),
    phone character varying(64),
    company character varying(512),
    title character varying(255),
    lead_source character varying(255),
    lead_status character varying(255),
    industry character varying(255),
    website character varying(512),
    country character varying(255),
    description text,
    raw_json jsonb NOT NULL,
    promoted_job_id character varying(255),
    sf_created_at timestamp without time zone,
    sf_modified_at timestamp without time zone,
    synced_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE sf_leads OWNER TO postgres;

--
-- Name: sf_leads_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE sf_leads_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE sf_leads_id_seq OWNER TO postgres;

--
-- Name: sf_leads_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE sf_leads_id_seq OWNED BY sf_leads.id;


--
-- Name: sf_sync_runs; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE sf_sync_runs (
    id integer NOT NULL,
    user_id integer NOT NULL,
    record_type character varying(32) NOT NULL,
    record_count integer DEFAULT 0 NOT NULL,
    status character varying(32) NOT NULL,
    error text,
    started_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    finished_at timestamp without time zone
);


ALTER TABLE sf_sync_runs OWNER TO postgres;

--
-- Name: sf_sync_runs_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE sf_sync_runs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE sf_sync_runs_id_seq OWNER TO postgres;

--
-- Name: sf_sync_runs_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE sf_sync_runs_id_seq OWNED BY sf_sync_runs.id;


--
-- Name: shared_webhook; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE shared_webhook (
    id integer NOT NULL,
    theirstack_search_id character varying(100) NOT NULL,
    theirstack_webhook_id character varying(100) NOT NULL,
    webhook_url text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    CONSTRAINT shared_webhook_id_check CHECK ((id = 1))
);


ALTER TABLE shared_webhook OWNER TO postgres;

--
-- Name: suppressions; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE suppressions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    email_norm character varying(320) NOT NULL,
    reason character varying(32) NOT NULL,
    source character varying(64),
    evidence_json jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    notes text
);


ALTER TABLE suppressions OWNER TO postgres;

--
-- Name: suppressions_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE suppressions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suppressions_id_seq OWNER TO postgres;

--
-- Name: suppressions_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE suppressions_id_seq OWNED BY suppressions.id;


--
-- Name: team_notification_comments; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE team_notification_comments (
    id integer NOT NULL,
    notification_id integer NOT NULL,
    user_id integer NOT NULL,
    body text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE team_notification_comments OWNER TO postgres;

--
-- Name: team_notification_comments_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE team_notification_comments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE team_notification_comments_id_seq OWNER TO postgres;

--
-- Name: team_notification_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE team_notification_comments_id_seq OWNED BY team_notification_comments.id;


--
-- Name: team_notification_reactions; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE team_notification_reactions (
    id integer NOT NULL,
    notification_id integer NOT NULL,
    user_id integer NOT NULL,
    reaction character varying(20) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT team_notification_reactions_reaction_check CHECK (((reaction)::text = ANY ((ARRAY['cheer'::character varying, 'learn'::character varying, 'replicate'::character varying])::text[])))
);


ALTER TABLE team_notification_reactions OWNER TO postgres;

--
-- Name: team_notification_reactions_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE team_notification_reactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE team_notification_reactions_id_seq OWNER TO postgres;

--
-- Name: team_notification_reactions_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE team_notification_reactions_id_seq OWNED BY team_notification_reactions.id;


--
-- Name: team_notifications; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE team_notifications (
    id integer NOT NULL,
    actor_user_id integer NOT NULL,
    recipient_user_id integer NOT NULL,
    job_id character varying(255) NOT NULL,
    company_name character varying(255) NOT NULL,
    outcome character varying(20) NOT NULL,
    deal_size numeric(14,2),
    summary text,
    seen boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT team_notifications_outcome_check CHECK (((outcome)::text = ANY ((ARRAY['won'::character varying, 'lost'::character varying, 'gmail_connect_req'::character varying])::text[])))
);


ALTER TABLE team_notifications OWNER TO postgres;

--
-- Name: team_notifications_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE team_notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE team_notifications_id_seq OWNER TO postgres;

--
-- Name: team_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE team_notifications_id_seq OWNED BY team_notifications.id;


--
-- Name: user_reference_documents; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE user_reference_documents (
    id character varying(36) NOT NULL,
    user_id integer NOT NULL,
    file_name character varying(255) NOT NULL,
    mime_type character varying(255),
    file_size integer NOT NULL,
    extracted_text text NOT NULL,
    summary text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE user_reference_documents OWNER TO postgres;

--
-- Name: user_settings; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE user_settings (
    user_id integer NOT NULL,
    key character varying(128) NOT NULL,
    value text,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE user_settings OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    cognito_sub character varying(255),
    name character varying(255),
    role character varying(100),
    company character varying(255),
    is_verified boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    company_website character varying(255),
    email_notifications boolean DEFAULT true,
    default_country character varying(100),
    onboarding_completed boolean DEFAULT false,
    organization_id integer,
    research_budget smallint DEFAULT '20'::smallint NOT NULL,
    feature_overrides jsonb,
    avatar_url character varying(2048)
);


ALTER TABLE users OWNER TO postgres;

--
-- Name: user_token_analytics; Type: VIEW; Schema: dev; Owner: postgres
--

CREATE VIEW user_token_analytics AS
 SELECT u.id AS user_id,
    u.email,
    u.research_budget,
    COALESCE(sum(am.llm_total_tokens), (0)::bigint) AS total_tokens_consumed,
    COALESCE(sum(am.llm_input_tokens), (0)::bigint) AS total_input_tokens,
    COALESCE(sum(am.llm_output_tokens), (0)::bigint) AS total_output_tokens,
    COALESCE(sum(
        CASE
            WHEN ((am.agent_name)::text = 'finance'::text) THEN am.llm_total_tokens
            ELSE NULL::integer
        END), (0)::bigint) AS research_finance_tokens,
    COALESCE(sum(
        CASE
            WHEN ((am.agent_name)::text = 'techstack'::text) THEN am.llm_total_tokens
            ELSE NULL::integer
        END), (0)::bigint) AS research_techstack_tokens,
    COALESCE(sum(
        CASE
            WHEN ((am.agent_name)::text = 'linkedin'::text) THEN am.llm_total_tokens
            ELSE NULL::integer
        END), (0)::bigint) AS research_linkedin_tokens,
    COALESCE(sum(
        CASE
            WHEN ((am.agent_name)::text = 'competition'::text) THEN am.llm_total_tokens
            ELSE NULL::integer
        END), (0)::bigint) AS research_competition_tokens,
    COALESCE(sum(
        CASE
            WHEN ((am.agent_name)::text = 'google_ai'::text) THEN am.llm_total_tokens
            ELSE NULL::integer
        END), (0)::bigint) AS research_google_ai_tokens,
    COALESCE(sum(
        CASE
            WHEN ((am.agent_name)::text = ANY ((ARRAY['finance'::character varying, 'techstack'::character varying, 'linkedin'::character varying, 'competition'::character varying, 'google_ai'::character varying])::text[])) THEN am.llm_total_tokens
            ELSE NULL::integer
        END), (0)::bigint) AS research_total_tokens,
    COALESCE(sum(
        CASE
            WHEN ((am.agent_name)::text = 'playbook_cxo'::text) THEN am.llm_total_tokens
            ELSE NULL::integer
        END), (0)::bigint) AS playbook_cxo_tokens,
    COALESCE(sum(
        CASE
            WHEN ((am.agent_name)::text = 'playbook_marketing'::text) THEN am.llm_total_tokens
            ELSE NULL::integer
        END), (0)::bigint) AS playbook_marketing_tokens,
    COALESCE(sum(
        CASE
            WHEN ((am.agent_name)::text = 'playbook_field_sales'::text) THEN am.llm_total_tokens
            ELSE NULL::integer
        END), (0)::bigint) AS playbook_field_sales_tokens,
    COALESCE(sum(
        CASE
            WHEN ((am.agent_name)::text = 'playbook_isr'::text) THEN am.llm_total_tokens
            ELSE NULL::integer
        END), (0)::bigint) AS playbook_isr_tokens,
    COALESCE(sum(
        CASE
            WHEN ((am.agent_name)::text = 'playbook_gap_analysis'::text) THEN am.llm_total_tokens
            ELSE NULL::integer
        END), (0)::bigint) AS playbook_gap_analysis_tokens,
    COALESCE(sum(
        CASE
            WHEN ((am.agent_name)::text = 'playbook_alliance'::text) THEN am.llm_total_tokens
            ELSE NULL::integer
        END), (0)::bigint) AS playbook_alliance_tokens,
    COALESCE(sum(
        CASE
            WHEN ((am.agent_name)::text ~~ 'playbook_%'::text) THEN am.llm_total_tokens
            ELSE NULL::integer
        END), (0)::bigint) AS playbook_total_tokens,
    COALESCE(sum(
        CASE
            WHEN ((j.source)::text = 'discovery'::text) THEN am.llm_total_tokens
            ELSE NULL::integer
        END), (0)::bigint) AS discovery_total_tokens,
    COALESCE(sum(
        CASE
            WHEN ((am.agent_name)::text = 'search_agent'::text) THEN am.llm_total_tokens
            ELSE NULL::integer
        END), (0)::bigint) AS search_agent_total_tokens,
    COALESCE(sum(
        CASE
            WHEN ((am.agent_name)::text = 'prioritization'::text) THEN am.llm_total_tokens
            ELSE NULL::integer
        END), (0)::bigint) AS prioritization_tokens,
    COALESCE(sum(
        CASE
            WHEN ((am.agent_name)::text ~~ '%analyst'::text) THEN am.llm_total_tokens
            ELSE NULL::integer
        END), (0)::bigint) AS analyst_tokens,
    COALESCE(sum(
        CASE
            WHEN ((am.agent_name)::text ~~ '%deep_%'::text) THEN am.llm_total_tokens
            ELSE NULL::integer
        END), (0)::bigint) AS deep_research_tokens,
    count(DISTINCT
        CASE
            WHEN ((am.agent_name)::text = ANY ((ARRAY['finance'::character varying, 'techstack'::character varying, 'linkedin'::character varying, 'competition'::character varying, 'google_ai'::character varying])::text[])) THEN j.id
            ELSE NULL::character varying
        END) AS research_jobs_count,
    count(DISTINCT
        CASE
            WHEN ((j.source)::text = 'discovery'::text) THEN j.id
            ELSE NULL::character varying
        END) AS discovery_jobs_count,
    count(DISTINCT j.id) AS total_jobs,
    COALESCE(sum(am.llm_cache_read_tokens), (0)::bigint) AS total_cache_read_tokens,
    COALESCE(sum(am.llm_cache_write_tokens), (0)::bigint) AS total_cache_write_tokens,
    max(am.created_at) AS last_agent_run,
    count(DISTINCT am.id) AS total_agent_runs
   FROM ((users u
     LEFT JOIN jobs j ON ((u.id = j.user_id)))
     LEFT JOIN agent_metrics am ON (((j.id)::text = (am.job_id)::text)))
  GROUP BY u.id, u.email, u.research_budget
  ORDER BY COALESCE(sum(am.llm_total_tokens), (0)::bigint) DESC;


ALTER VIEW user_token_analytics OWNER TO postgres;

--
-- Name: user_tokens; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE user_tokens (
    id integer NOT NULL,
    user_id integer NOT NULL,
    token text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    expires_at timestamp without time zone NOT NULL
);


ALTER TABLE user_tokens OWNER TO postgres;

--
-- Name: user_tokens_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE user_tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE user_tokens_id_seq OWNER TO postgres;

--
-- Name: user_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE user_tokens_id_seq OWNED BY user_tokens.id;


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: webhook_companies; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE webhook_companies (
    job_id character varying(255) NOT NULL,
    company_name character varying(255) NOT NULL,
    domain character varying(255),
    added_at timestamp without time zone NOT NULL
);


ALTER TABLE webhook_companies OWNER TO postgres;

--
-- Name: zoho_accounts; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE zoho_accounts (
    id integer NOT NULL,
    user_id integer NOT NULL,
    zoho_id character varying(64) NOT NULL,
    account_name character varying(512),
    industry character varying(255),
    website character varying(512),
    phone character varying(64),
    annual_revenue numeric,
    employees integer,
    billing_city character varying(255),
    billing_country character varying(255),
    description text,
    raw_json jsonb NOT NULL,
    promoted_job_id character varying(255),
    zoho_created_at timestamp without time zone,
    zoho_modified_at timestamp without time zone,
    synced_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    owner_name character varying(255),
    owner_email character varying(320),
    secondary_owner_name character varying(255),
    secondary_owner_email character varying(320),
    account_number character varying(255),
    account_type character varying(255),
    account_site character varying(512)
);


ALTER TABLE zoho_accounts OWNER TO postgres;

--
-- Name: zoho_accounts_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE zoho_accounts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE zoho_accounts_id_seq OWNER TO postgres;

--
-- Name: zoho_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE zoho_accounts_id_seq OWNED BY zoho_accounts.id;


--
-- Name: zoho_deals; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE zoho_deals (
    id integer NOT NULL,
    user_id integer NOT NULL,
    zoho_id character varying(64) NOT NULL,
    deal_name character varying(512),
    account_zoho_id character varying(64),
    account_name character varying(512),
    stage character varying(255),
    deal_type character varying(255),
    amount numeric,
    probability numeric,
    expected_revenue numeric,
    closing_date date,
    lead_source character varying(255),
    owner_name character varying(255),
    description text,
    raw_json jsonb NOT NULL,
    promoted_job_id character varying(255),
    zoho_created_at timestamp without time zone,
    zoho_modified_at timestamp without time zone,
    synced_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    owner_email character varying(320),
    secondary_owner_name character varying(255),
    secondary_owner_email character varying(320)
);


ALTER TABLE zoho_deals OWNER TO postgres;

--
-- Name: zoho_deals_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE zoho_deals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE zoho_deals_id_seq OWNER TO postgres;

--
-- Name: zoho_deals_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE zoho_deals_id_seq OWNED BY zoho_deals.id;


--
-- Name: zoho_leads; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE zoho_leads (
    id integer NOT NULL,
    user_id integer NOT NULL,
    zoho_id character varying(64) NOT NULL,
    full_name character varying(512),
    email character varying(255),
    phone character varying(64),
    company character varying(512),
    title character varying(255),
    lead_source character varying(255),
    lead_status character varying(255),
    industry character varying(255),
    website character varying(512),
    country character varying(255),
    description text,
    raw_json jsonb NOT NULL,
    promoted_job_id character varying(255),
    zoho_created_at timestamp without time zone,
    zoho_modified_at timestamp without time zone,
    synced_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE zoho_leads OWNER TO postgres;

--
-- Name: zoho_leads_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE zoho_leads_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE zoho_leads_id_seq OWNER TO postgres;

--
-- Name: zoho_leads_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE zoho_leads_id_seq OWNED BY zoho_leads.id;


--
-- Name: zoho_sync_runs; Type: TABLE; Schema: dev; Owner: postgres
--

CREATE TABLE zoho_sync_runs (
    id integer NOT NULL,
    user_id integer NOT NULL,
    record_type character varying(32) NOT NULL,
    record_count integer DEFAULT 0 NOT NULL,
    status character varying(32) NOT NULL,
    error text,
    started_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    finished_at timestamp without time zone
);


ALTER TABLE zoho_sync_runs OWNER TO postgres;

--
-- Name: zoho_sync_runs_id_seq; Type: SEQUENCE; Schema: dev; Owner: postgres
--

CREATE SEQUENCE zoho_sync_runs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE zoho_sync_runs_id_seq OWNER TO postgres;

--
-- Name: zoho_sync_runs_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: postgres
--

ALTER SEQUENCE zoho_sync_runs_id_seq OWNED BY zoho_sync_runs.id;


--
-- Name: account_brief_history id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY account_brief_history ALTER COLUMN id SET DEFAULT nextval('account_brief_history_id_seq'::regclass);


--
-- Name: account_channel_context id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY account_channel_context ALTER COLUMN id SET DEFAULT nextval('account_channel_context_id_seq'::regclass);


--
-- Name: account_drive_folders id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY account_drive_folders ALTER COLUMN id SET DEFAULT nextval('account_drive_folders_id_seq'::regclass);


--
-- Name: account_notes id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY account_notes ALTER COLUMN id SET DEFAULT nextval('account_notes_id_seq'::regclass);


--
-- Name: account_route_assessments id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY account_route_assessments ALTER COLUMN id SET DEFAULT nextval('account_route_assessments_id_seq'::regclass);


--
-- Name: agent_metrics id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY agent_metrics ALTER COLUMN id SET DEFAULT nextval('agent_metrics_id_seq'::regclass);


--
-- Name: ai_feedback_signals id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY ai_feedback_signals ALTER COLUMN id SET DEFAULT nextval('ai_feedback_signals_id_seq'::regclass);


--
-- Name: alerts id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY alerts ALTER COLUMN id SET DEFAULT nextval('alerts_id_seq'::regclass);


--
-- Name: alliance_alerts id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY alliance_alerts ALTER COLUMN id SET DEFAULT nextval('alliance_alerts_id_seq'::regclass);


--
-- Name: alliance_insights id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY alliance_insights ALTER COLUMN id SET DEFAULT nextval('alliance_insights_id_seq'::regclass);


--
-- Name: apn_opportunities id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY apn_opportunities ALTER COLUMN id SET DEFAULT nextval('apn_opportunities_id_seq'::regclass);


--
-- Name: apn_sync_runs id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY apn_sync_runs ALTER COLUMN id SET DEFAULT nextval('apn_sync_runs_id_seq'::regclass);


--
-- Name: atrisk_checks id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY atrisk_checks ALTER COLUMN id SET DEFAULT nextval('atrisk_checks_id_seq'::regclass);


--
-- Name: booking_links id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY booking_links ALTER COLUMN id SET DEFAULT nextval('booking_links_id_seq'::regclass);


--
-- Name: campaign_attributions id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY campaign_attributions ALTER COLUMN id SET DEFAULT nextval('campaign_attributions_id_seq'::regclass);


--
-- Name: co_sell_readiness_ai id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY co_sell_readiness_ai ALTER COLUMN id SET DEFAULT nextval('co_sell_readiness_ai_id_seq'::regclass);


--
-- Name: co_sell_rooms id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY co_sell_rooms ALTER COLUMN id SET DEFAULT nextval('co_sell_rooms_id_seq'::regclass);


--
-- Name: company_playbooks id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY company_playbooks ALTER COLUMN id SET DEFAULT nextval('company_playbooks_id_seq'::regclass);


--
-- Name: connector_credentials id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY connector_credentials ALTER COLUMN id SET DEFAULT nextval('connector_credentials_id_seq'::regclass);


--
-- Name: crm_tokens id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY crm_tokens ALTER COLUMN id SET DEFAULT nextval('crm_tokens_id_seq'::regclass);


--
-- Name: cxo_settings id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY cxo_settings ALTER COLUMN id SET DEFAULT nextval('cxo_settings_id_seq'::regclass);


--
-- Name: demo_leads id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY demo_leads ALTER COLUMN id SET DEFAULT nextval('demo_leads_id_seq'::regclass);


--
-- Name: digest_logs id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY digest_logs ALTER COLUMN id SET DEFAULT nextval('digest_logs_id_seq'::regclass);


--
-- Name: event_invitations id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY event_invitations ALTER COLUMN id SET DEFAULT nextval('event_invitations_id_seq'::regclass);


--
-- Name: forecast_syncs id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY forecast_syncs ALTER COLUMN id SET DEFAULT nextval('forecast_syncs_id_seq'::regclass);


--
-- Name: leader_extras id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY leader_extras ALTER COLUMN id SET DEFAULT nextval('leader_extras_id_seq'::regclass);


--
-- Name: mailbox_owner_companies id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY mailbox_owner_companies ALTER COLUMN id SET DEFAULT nextval('mailbox_owner_companies_id_seq'::regclass);


--
-- Name: mailbox_watch_state id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY mailbox_watch_state ALTER COLUMN id SET DEFAULT nextval('mailbox_watch_state_id_seq'::regclass);


--
-- Name: metrics_snapshots id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY metrics_snapshots ALTER COLUMN id SET DEFAULT nextval('metrics_snapshots_id_seq'::regclass);


--
-- Name: microsoft_referrals id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY microsoft_referrals ALTER COLUMN id SET DEFAULT nextval('microsoft_referrals_id_seq'::regclass);


--
-- Name: news_events id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY news_events ALTER COLUMN id SET DEFAULT nextval('news_events_id_seq'::regclass);


--
-- Name: org_events id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY org_events ALTER COLUMN id SET DEFAULT nextval('org_events_id_seq'::regclass);


--
-- Name: organisations id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY organisations ALTER COLUMN id SET DEFAULT nextval('organisations_id_seq'::regclass);


--
-- Name: otp_verifications id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY otp_verifications ALTER COLUMN id SET DEFAULT nextval('otp_verifications_id_seq'::regclass);


--
-- Name: partner_account_overlaps id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_account_overlaps ALTER COLUMN id SET DEFAULT nextval('partner_account_overlaps_id_seq'::regclass);


--
-- Name: partner_benchmarks id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_benchmarks ALTER COLUMN id SET DEFAULT nextval('partner_benchmarks_id_seq'::regclass);


--
-- Name: partner_connections id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_connections ALTER COLUMN id SET DEFAULT nextval('partner_connections_id_seq'::regclass);


--
-- Name: partner_contacts id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_contacts ALTER COLUMN id SET DEFAULT nextval('partner_contacts_id_seq'::regclass);


--
-- Name: partner_engagement_cases id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_engagement_cases ALTER COLUMN id SET DEFAULT nextval('partner_engagement_cases_id_seq'::regclass);


--
-- Name: partner_engagement_events id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_engagement_events ALTER COLUMN id SET DEFAULT nextval('partner_engagement_events_id_seq'::regclass);


--
-- Name: partner_facts id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_facts ALTER COLUMN id SET DEFAULT nextval('partner_facts_id_seq'::regclass);


--
-- Name: partner_matches id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_matches ALTER COLUMN id SET DEFAULT nextval('partner_matches_id_seq'::regclass);


--
-- Name: partner_readiness id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_readiness ALTER COLUMN id SET DEFAULT nextval('partner_readiness_id_seq'::regclass);


--
-- Name: partner_references id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_references ALTER COLUMN id SET DEFAULT nextval('partner_references_id_seq'::regclass);


--
-- Name: partner_solutions id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_solutions ALTER COLUMN id SET DEFAULT nextval('partner_solutions_id_seq'::regclass);


--
-- Name: partner_targets id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_targets ALTER COLUMN id SET DEFAULT nextval('partner_targets_id_seq'::regclass);


--
-- Name: partners id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partners ALTER COLUMN id SET DEFAULT nextval('partners_id_seq'::regclass);


--
-- Name: person_intel_cache id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY person_intel_cache ALTER COLUMN id SET DEFAULT nextval('person_intel_cache_id_seq'::regclass);


--
-- Name: playbook_kb id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY playbook_kb ALTER COLUMN id SET DEFAULT nextval('playbook_kb_id_seq'::regclass);


--
-- Name: playbook_variants id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY playbook_variants ALTER COLUMN id SET DEFAULT nextval('playbook_variants_id_seq'::regclass);


--
-- Name: presentations id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY presentations ALTER COLUMN id SET DEFAULT nextval('presentations_id_seq'::regclass);


--
-- Name: qbr_generations id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY qbr_generations ALTER COLUMN id SET DEFAULT nextval('qbr_generations_id_seq'::regclass);


--
-- Name: relationship_bridges id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY relationship_bridges ALTER COLUMN id SET DEFAULT nextval('relationship_bridges_id_seq'::regclass);


--
-- Name: results id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY results ALTER COLUMN id SET DEFAULT nextval('results_id_seq'::regclass);


--
-- Name: search_index id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY search_index ALTER COLUMN id SET DEFAULT nextval('search_index_id_seq'::regclass);


--
-- Name: search_query_log id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY search_query_log ALTER COLUMN id SET DEFAULT nextval('search_query_log_id_seq'::regclass);


--
-- Name: sequence_enrollments id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY sequence_enrollments ALTER COLUMN id SET DEFAULT nextval('sequence_enrollments_id_seq'::regclass);


--
-- Name: sequence_steps id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY sequence_steps ALTER COLUMN id SET DEFAULT nextval('sequence_steps_id_seq'::regclass);


--
-- Name: sf_accounts id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY sf_accounts ALTER COLUMN id SET DEFAULT nextval('sf_accounts_id_seq'::regclass);


--
-- Name: sf_deals id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY sf_deals ALTER COLUMN id SET DEFAULT nextval('sf_deals_id_seq'::regclass);


--
-- Name: sf_leads id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY sf_leads ALTER COLUMN id SET DEFAULT nextval('sf_leads_id_seq'::regclass);


--
-- Name: sf_sync_runs id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY sf_sync_runs ALTER COLUMN id SET DEFAULT nextval('sf_sync_runs_id_seq'::regclass);


--
-- Name: suppressions id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY suppressions ALTER COLUMN id SET DEFAULT nextval('suppressions_id_seq'::regclass);


--
-- Name: team_notification_comments id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY team_notification_comments ALTER COLUMN id SET DEFAULT nextval('team_notification_comments_id_seq'::regclass);


--
-- Name: team_notification_reactions id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY team_notification_reactions ALTER COLUMN id SET DEFAULT nextval('team_notification_reactions_id_seq'::regclass);


--
-- Name: team_notifications id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY team_notifications ALTER COLUMN id SET DEFAULT nextval('team_notifications_id_seq'::regclass);


--
-- Name: user_tokens id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY user_tokens ALTER COLUMN id SET DEFAULT nextval('user_tokens_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: zoho_accounts id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY zoho_accounts ALTER COLUMN id SET DEFAULT nextval('zoho_accounts_id_seq'::regclass);


--
-- Name: zoho_deals id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY zoho_deals ALTER COLUMN id SET DEFAULT nextval('zoho_deals_id_seq'::regclass);


--
-- Name: zoho_leads id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY zoho_leads ALTER COLUMN id SET DEFAULT nextval('zoho_leads_id_seq'::regclass);


--
-- Name: zoho_sync_runs id; Type: DEFAULT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY zoho_sync_runs ALTER COLUMN id SET DEFAULT nextval('zoho_sync_runs_id_seq'::regclass);


--
-- Name: account_brief_history account_brief_history_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY account_brief_history
    ADD CONSTRAINT account_brief_history_pkey PRIMARY KEY (id);


--
-- Name: account_briefs account_briefs_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY account_briefs
    ADD CONSTRAINT account_briefs_pkey PRIMARY KEY (job_id);


--
-- Name: account_channel_context account_channel_context_job_id_channel_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY account_channel_context
    ADD CONSTRAINT account_channel_context_job_id_channel_key UNIQUE (job_id, channel);


--
-- Name: account_channel_context account_channel_context_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY account_channel_context
    ADD CONSTRAINT account_channel_context_pkey PRIMARY KEY (id);


--
-- Name: account_drive_folders account_drive_folders_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY account_drive_folders
    ADD CONSTRAINT account_drive_folders_pkey PRIMARY KEY (id);


--
-- Name: account_drive_folders account_drive_folders_user_id_job_id_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY account_drive_folders
    ADD CONSTRAINT account_drive_folders_user_id_job_id_key UNIQUE (user_id, job_id);


--
-- Name: account_notes account_notes_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY account_notes
    ADD CONSTRAINT account_notes_pkey PRIMARY KEY (id);


--
-- Name: account_route_assessments account_route_assessments_job_inputs_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY account_route_assessments
    ADD CONSTRAINT account_route_assessments_job_inputs_key UNIQUE (job_id, inputs_hash);


--
-- Name: account_route_assessments account_route_assessments_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY account_route_assessments
    ADD CONSTRAINT account_route_assessments_pkey PRIMARY KEY (id);


--
-- Name: agent_metrics agent_metrics_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY agent_metrics
    ADD CONSTRAINT agent_metrics_pkey PRIMARY KEY (id);


--
-- Name: agent_tool_grants agent_tool_grants_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY agent_tool_grants
    ADD CONSTRAINT agent_tool_grants_pkey PRIMARY KEY (id);


--
-- Name: ai_feedback_signals ai_feedback_signals_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY ai_feedback_signals
    ADD CONSTRAINT ai_feedback_signals_pkey PRIMARY KEY (id);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: alerts alerts_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY alerts
    ADD CONSTRAINT alerts_pkey PRIMARY KEY (id);


--
-- Name: alliance_alerts alliance_alerts_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY alliance_alerts
    ADD CONSTRAINT alliance_alerts_pkey PRIMARY KEY (id);


--
-- Name: alliance_insights alliance_insights_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY alliance_insights
    ADD CONSTRAINT alliance_insights_pkey PRIMARY KEY (id);


--
-- Name: apn_opportunities apn_opportunities_org_catalog_opportunity_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY apn_opportunities
    ADD CONSTRAINT apn_opportunities_org_catalog_opportunity_key UNIQUE (organisation_id, catalog, opportunity_id);


--
-- Name: apn_opportunities apn_opportunities_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY apn_opportunities
    ADD CONSTRAINT apn_opportunities_pkey PRIMARY KEY (id);


--
-- Name: apn_sync_runs apn_sync_runs_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY apn_sync_runs
    ADD CONSTRAINT apn_sync_runs_pkey PRIMARY KEY (id);


--
-- Name: atrisk_checks atrisk_checks_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY atrisk_checks
    ADD CONSTRAINT atrisk_checks_pkey PRIMARY KEY (id);


--
-- Name: batches batches_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY batches
    ADD CONSTRAINT batches_pkey PRIMARY KEY (id);


--
-- Name: booking_links booking_links_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY booking_links
    ADD CONSTRAINT booking_links_pkey PRIMARY KEY (id);


--
-- Name: booking_links booking_links_slug_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY booking_links
    ADD CONSTRAINT booking_links_slug_key UNIQUE (slug);


--
-- Name: booking_links booking_links_user_id_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY booking_links
    ADD CONSTRAINT booking_links_user_id_key UNIQUE (user_id);


--
-- Name: campaign_attributions campaign_attributions_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY campaign_attributions
    ADD CONSTRAINT campaign_attributions_pkey PRIMARY KEY (id);


--
-- Name: co_sell_rooms co_sell_rooms_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY co_sell_rooms
    ADD CONSTRAINT co_sell_rooms_pkey PRIMARY KEY (id);


--
-- Name: company_playbooks company_playbooks_company_name_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY company_playbooks
    ADD CONSTRAINT company_playbooks_company_name_key UNIQUE (company_name);


--
-- Name: company_playbooks company_playbooks_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY company_playbooks
    ADD CONSTRAINT company_playbooks_pkey PRIMARY KEY (id);


--
-- Name: connector_credentials connector_credentials_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY connector_credentials
    ADD CONSTRAINT connector_credentials_pkey PRIMARY KEY (id);


--
-- Name: connector_credentials connector_credentials_user_id_connector_type_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY connector_credentials
    ADD CONSTRAINT connector_credentials_user_id_connector_type_key UNIQUE (user_id, connector_type);


--
-- Name: crm_tokens crm_tokens_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY crm_tokens
    ADD CONSTRAINT crm_tokens_pkey PRIMARY KEY (id);


--
-- Name: crm_tokens crm_tokens_user_id_crm_type_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY crm_tokens
    ADD CONSTRAINT crm_tokens_user_id_crm_type_key UNIQUE (user_id, crm_type);


--
-- Name: cxo_settings cxo_settings_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY cxo_settings
    ADD CONSTRAINT cxo_settings_pkey PRIMARY KEY (id);


--
-- Name: cxo_settings cxo_settings_user_id_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY cxo_settings
    ADD CONSTRAINT cxo_settings_user_id_key UNIQUE (user_id);


--
-- Name: demo_leads demo_leads_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY demo_leads
    ADD CONSTRAINT demo_leads_pkey PRIMARY KEY (id);


--
-- Name: digest_logs digest_logs_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY digest_logs
    ADD CONSTRAINT digest_logs_pkey PRIMARY KEY (id);


--
-- Name: domain_logo_cache domain_logo_cache_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY domain_logo_cache
    ADD CONSTRAINT domain_logo_cache_pkey PRIMARY KEY (domain);


--
-- Name: event_invitations event_invitations_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY event_invitations
    ADD CONSTRAINT event_invitations_pkey PRIMARY KEY (id);


--
-- Name: explorium_credit_limits explorium_credit_limits_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY explorium_credit_limits
    ADD CONSTRAINT explorium_credit_limits_pkey PRIMARY KEY (user_id);


--
-- Name: explorium_organisation_credit_limits explorium_organisation_credit_limits_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY explorium_organisation_credit_limits
    ADD CONSTRAINT explorium_organisation_credit_limits_pkey PRIMARY KEY (organization_id);


--
-- Name: forecast_syncs forecast_syncs_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY forecast_syncs
    ADD CONSTRAINT forecast_syncs_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: leader_extras leader_extras_job_id_leader_key_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY leader_extras
    ADD CONSTRAINT leader_extras_job_id_leader_key_key UNIQUE (job_id, leader_key);


--
-- Name: leader_extras leader_extras_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY leader_extras
    ADD CONSTRAINT leader_extras_pkey PRIMARY KEY (id);


--
-- Name: leadership_results leadership_results_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY leadership_results
    ADD CONSTRAINT leadership_results_pkey PRIMARY KEY (job_id);


--
-- Name: mailbox_owner_companies mailbox_owner_companies_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY mailbox_owner_companies
    ADD CONSTRAINT mailbox_owner_companies_pkey PRIMARY KEY (id);


--
-- Name: mailbox_owner_companies mailbox_owner_companies_user_job_domain_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY mailbox_owner_companies
    ADD CONSTRAINT mailbox_owner_companies_user_job_domain_key UNIQUE (user_id, job_id, domain);


--
-- Name: mailbox_watch_state mailbox_watch_state_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY mailbox_watch_state
    ADD CONSTRAINT mailbox_watch_state_pkey PRIMARY KEY (id);


--
-- Name: mailbox_watch_state mailbox_watch_state_user_channel_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY mailbox_watch_state
    ADD CONSTRAINT mailbox_watch_state_user_channel_key UNIQUE (user_id, channel);


--
-- Name: mcp_connectors mcp_connectors_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY mcp_connectors
    ADD CONSTRAINT mcp_connectors_pkey PRIMARY KEY (id);


--
-- Name: mcp_tool_grants mcp_tool_grants_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY mcp_tool_grants
    ADD CONSTRAINT mcp_tool_grants_pkey PRIMARY KEY (id);


--
-- Name: metrics_snapshots metrics_snapshots_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY metrics_snapshots
    ADD CONSTRAINT metrics_snapshots_pkey PRIMARY KEY (id);


--
-- Name: metrics_snapshots metrics_snapshots_user_id_snapshot_date_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY metrics_snapshots
    ADD CONSTRAINT metrics_snapshots_user_id_snapshot_date_key UNIQUE (user_id, snapshot_date);


--
-- Name: microsoft_referrals microsoft_referrals_org_partner_external_id_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY microsoft_referrals
    ADD CONSTRAINT microsoft_referrals_org_partner_external_id_key UNIQUE (organisation_id, partner_id, external_referral_id);


--
-- Name: microsoft_referrals microsoft_referrals_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY microsoft_referrals
    ADD CONSTRAINT microsoft_referrals_pkey PRIMARY KEY (id);


--
-- Name: news_events news_events_job_id_event_type_received_at_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY news_events
    ADD CONSTRAINT news_events_job_id_event_type_received_at_key UNIQUE (job_id, event_type, received_at);


--
-- Name: news_events news_events_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY news_events
    ADD CONSTRAINT news_events_pkey PRIMARY KEY (id);


--
-- Name: org_events org_events_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY org_events
    ADD CONSTRAINT org_events_pkey PRIMARY KEY (id);


--
-- Name: organisations organisations_domain_key_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY organisations
    ADD CONSTRAINT organisations_domain_key_key UNIQUE (domain_key);


--
-- Name: organisations organisations_name_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY organisations
    ADD CONSTRAINT organisations_name_key UNIQUE (name);


--
-- Name: organisations organisations_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY organisations
    ADD CONSTRAINT organisations_pkey PRIMARY KEY (id);


--
-- Name: otp_verifications otp_verifications_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY otp_verifications
    ADD CONSTRAINT otp_verifications_pkey PRIMARY KEY (id);


--
-- Name: partner_account_overlaps partner_account_overlaps_org_partner_job_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_account_overlaps
    ADD CONSTRAINT partner_account_overlaps_org_partner_job_key UNIQUE (organisation_id, partner_id, job_id);


--
-- Name: partner_account_overlaps partner_account_overlaps_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_account_overlaps
    ADD CONSTRAINT partner_account_overlaps_pkey PRIMARY KEY (id);


--
-- Name: partner_benchmarks partner_benchmarks_partner_competitor_dimension_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_benchmarks
    ADD CONSTRAINT partner_benchmarks_partner_competitor_dimension_key UNIQUE (partner_id, competitor_name, dimension);


--
-- Name: partner_benchmarks partner_benchmarks_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_benchmarks
    ADD CONSTRAINT partner_benchmarks_pkey PRIMARY KEY (id);


--
-- Name: partner_connections partner_connections_org_partner_connector_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_connections
    ADD CONSTRAINT partner_connections_org_partner_connector_key UNIQUE (organisation_id, partner_id, connector_type);


--
-- Name: partner_connections partner_connections_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_connections
    ADD CONSTRAINT partner_connections_pkey PRIMARY KEY (id);


--
-- Name: partner_contacts partner_contacts_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_contacts
    ADD CONSTRAINT partner_contacts_pkey PRIMARY KEY (id);


--
-- Name: partner_engagement_cases partner_engagement_cases_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_engagement_cases
    ADD CONSTRAINT partner_engagement_cases_pkey PRIMARY KEY (id);


--
-- Name: partner_engagement_events partner_engagement_events_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_engagement_events
    ADD CONSTRAINT partner_engagement_events_pkey PRIMARY KEY (id);


--
-- Name: partner_facts partner_facts_partner_key_source_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_facts
    ADD CONSTRAINT partner_facts_partner_key_source_key UNIQUE (partner_id, fact_key, source);


--
-- Name: partner_facts partner_facts_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_facts
    ADD CONSTRAINT partner_facts_pkey PRIMARY KEY (id);


--
-- Name: partner_matches partner_matches_org_isv_reseller_job_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_matches
    ADD CONSTRAINT partner_matches_org_isv_reseller_job_key UNIQUE (organisation_id, isv_partner_id, reseller_partner_id, job_id);


--
-- Name: partner_matches partner_matches_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_matches
    ADD CONSTRAINT partner_matches_pkey PRIMARY KEY (id);


--
-- Name: partner_readiness partner_readiness_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_readiness
    ADD CONSTRAINT partner_readiness_pkey PRIMARY KEY (id);


--
-- Name: partner_references partner_references_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_references
    ADD CONSTRAINT partner_references_pkey PRIMARY KEY (id);


--
-- Name: partner_solutions partner_solutions_partner_type_external_id_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_solutions
    ADD CONSTRAINT partner_solutions_partner_type_external_id_key UNIQUE (partner_id, type, external_id);


--
-- Name: partner_solutions partner_solutions_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_solutions
    ADD CONSTRAINT partner_solutions_pkey PRIMARY KEY (id);


--
-- Name: partner_targets partner_targets_partner_type_period_ext_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_targets
    ADD CONSTRAINT partner_targets_partner_type_period_ext_key UNIQUE (partner_id, agreement_type, period, external_id);


--
-- Name: partner_targets partner_targets_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_targets
    ADD CONSTRAINT partner_targets_pkey PRIMARY KEY (id);


--
-- Name: partners partners_organisation_id_slug_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partners
    ADD CONSTRAINT partners_organisation_id_slug_key UNIQUE (organisation_id, slug);


--
-- Name: partners partners_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partners
    ADD CONSTRAINT partners_pkey PRIMARY KEY (id);


--
-- Name: person_intel_cache person_intel_cache_company_name_role_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY person_intel_cache
    ADD CONSTRAINT person_intel_cache_company_name_role_key UNIQUE (company_name, role);


--
-- Name: person_intel_cache person_intel_cache_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY person_intel_cache
    ADD CONSTRAINT person_intel_cache_pkey PRIMARY KEY (id);


--
-- Name: persona persona_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY persona
    ADD CONSTRAINT persona_pkey PRIMARY KEY (id);


--
-- Name: co_sell_readiness_ai pk_co_sell_readiness_ai; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY co_sell_readiness_ai
    ADD CONSTRAINT pk_co_sell_readiness_ai PRIMARY KEY (id);


--
-- Name: playbook_kb playbook_kb_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY playbook_kb
    ADD CONSTRAINT playbook_kb_pkey PRIMARY KEY (id);


--
-- Name: playbook_variants playbook_variants_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY playbook_variants
    ADD CONSTRAINT playbook_variants_pkey PRIMARY KEY (id);


--
-- Name: presentations presentations_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY presentations
    ADD CONSTRAINT presentations_pkey PRIMARY KEY (id);


--
-- Name: qbr_generations qbr_generations_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY qbr_generations
    ADD CONSTRAINT qbr_generations_pkey PRIMARY KEY (id);


--
-- Name: relationship_bridges relationship_bridges_job_type_entity_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY relationship_bridges
    ADD CONSTRAINT relationship_bridges_job_type_entity_key UNIQUE (job_id, bridge_type, via_entity);


--
-- Name: relationship_bridges relationship_bridges_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY relationship_bridges
    ADD CONSTRAINT relationship_bridges_pkey PRIMARY KEY (id);


--
-- Name: results results_job_id_tool_name_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY results
    ADD CONSTRAINT results_job_id_tool_name_key UNIQUE (job_id, tool_name);


--
-- Name: results results_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY results
    ADD CONSTRAINT results_pkey PRIMARY KEY (id);


--
-- Name: search_index search_index_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY search_index
    ADD CONSTRAINT search_index_pkey PRIMARY KEY (id);


--
-- Name: search_index search_index_user_id_object_type_object_id_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY search_index
    ADD CONSTRAINT search_index_user_id_object_type_object_id_key UNIQUE (user_id, object_type, object_id);


--
-- Name: search_query_log search_query_log_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY search_query_log
    ADD CONSTRAINT search_query_log_pkey PRIMARY KEY (id);


--
-- Name: sequence_enrollments sequence_enrollments_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY sequence_enrollments
    ADD CONSTRAINT sequence_enrollments_pkey PRIMARY KEY (id);


--
-- Name: sequence_steps sequence_steps_enrollment_id_step_number_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY sequence_steps
    ADD CONSTRAINT sequence_steps_enrollment_id_step_number_key UNIQUE (enrollment_id, step_number);


--
-- Name: sequence_steps sequence_steps_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY sequence_steps
    ADD CONSTRAINT sequence_steps_pkey PRIMARY KEY (id);


--
-- Name: sf_accounts sf_accounts_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY sf_accounts
    ADD CONSTRAINT sf_accounts_pkey PRIMARY KEY (id);


--
-- Name: sf_accounts sf_accounts_user_id_sf_id_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY sf_accounts
    ADD CONSTRAINT sf_accounts_user_id_sf_id_key UNIQUE (user_id, sf_id);


--
-- Name: sf_deals sf_deals_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY sf_deals
    ADD CONSTRAINT sf_deals_pkey PRIMARY KEY (id);


--
-- Name: sf_deals sf_deals_user_id_sf_id_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY sf_deals
    ADD CONSTRAINT sf_deals_user_id_sf_id_key UNIQUE (user_id, sf_id);


--
-- Name: sf_leads sf_leads_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY sf_leads
    ADD CONSTRAINT sf_leads_pkey PRIMARY KEY (id);


--
-- Name: sf_leads sf_leads_user_id_sf_id_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY sf_leads
    ADD CONSTRAINT sf_leads_user_id_sf_id_key UNIQUE (user_id, sf_id);


--
-- Name: sf_sync_runs sf_sync_runs_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY sf_sync_runs
    ADD CONSTRAINT sf_sync_runs_pkey PRIMARY KEY (id);


--
-- Name: shared_webhook shared_webhook_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY shared_webhook
    ADD CONSTRAINT shared_webhook_pkey PRIMARY KEY (id);


--
-- Name: suppressions suppressions_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY suppressions
    ADD CONSTRAINT suppressions_pkey PRIMARY KEY (id);


--
-- Name: suppressions suppressions_user_id_email_norm_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY suppressions
    ADD CONSTRAINT suppressions_user_id_email_norm_key UNIQUE (user_id, email_norm);


--
-- Name: team_notification_comments team_notification_comments_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY team_notification_comments
    ADD CONSTRAINT team_notification_comments_pkey PRIMARY KEY (id);


--
-- Name: team_notification_reactions team_notification_reactions_notification_id_user_id_reactio_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY team_notification_reactions
    ADD CONSTRAINT team_notification_reactions_notification_id_user_id_reactio_key UNIQUE (notification_id, user_id, reaction);


--
-- Name: team_notification_reactions team_notification_reactions_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY team_notification_reactions
    ADD CONSTRAINT team_notification_reactions_pkey PRIMARY KEY (id);


--
-- Name: team_notifications team_notifications_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY team_notifications
    ADD CONSTRAINT team_notifications_pkey PRIMARY KEY (id);


--
-- Name: agent_tool_grants uq_agent_tool_grants_user_kind_key_tool; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY agent_tool_grants
    ADD CONSTRAINT uq_agent_tool_grants_user_kind_key_tool UNIQUE (user_id, connector_kind, connector_key, tool_name);


--
-- Name: alliance_insights uq_alliance_insights_org_surface_hash; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY alliance_insights
    ADD CONSTRAINT uq_alliance_insights_org_surface_hash UNIQUE (organisation_id, surface, facts_hash);


--
-- Name: mcp_connectors uq_mcp_connectors_user_slug; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY mcp_connectors
    ADD CONSTRAINT uq_mcp_connectors_user_slug UNIQUE (user_id, slug);


--
-- Name: mcp_tool_grants uq_mcp_tool_grants_connector_tool; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY mcp_tool_grants
    ADD CONSTRAINT uq_mcp_tool_grants_connector_tool UNIQUE (connector_id, tool_name);


--
-- Name: user_reference_documents user_reference_documents_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY user_reference_documents
    ADD CONSTRAINT user_reference_documents_pkey PRIMARY KEY (id);


--
-- Name: user_settings user_settings_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY user_settings
    ADD CONSTRAINT user_settings_pkey PRIMARY KEY (user_id, key);


--
-- Name: user_tokens user_tokens_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY user_tokens
    ADD CONSTRAINT user_tokens_pkey PRIMARY KEY (id);


--
-- Name: user_tokens user_tokens_token_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY user_tokens
    ADD CONSTRAINT user_tokens_token_key UNIQUE (token);


--
-- Name: users users_cognito_sub_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_cognito_sub_key UNIQUE (cognito_sub);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: webhook_companies webhook_companies_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY webhook_companies
    ADD CONSTRAINT webhook_companies_pkey PRIMARY KEY (job_id);


--
-- Name: zoho_accounts zoho_accounts_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY zoho_accounts
    ADD CONSTRAINT zoho_accounts_pkey PRIMARY KEY (id);


--
-- Name: zoho_accounts zoho_accounts_user_id_zoho_id_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY zoho_accounts
    ADD CONSTRAINT zoho_accounts_user_id_zoho_id_key UNIQUE (user_id, zoho_id);


--
-- Name: zoho_deals zoho_deals_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY zoho_deals
    ADD CONSTRAINT zoho_deals_pkey PRIMARY KEY (id);


--
-- Name: zoho_deals zoho_deals_user_id_zoho_id_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY zoho_deals
    ADD CONSTRAINT zoho_deals_user_id_zoho_id_key UNIQUE (user_id, zoho_id);


--
-- Name: zoho_leads zoho_leads_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY zoho_leads
    ADD CONSTRAINT zoho_leads_pkey PRIMARY KEY (id);


--
-- Name: zoho_leads zoho_leads_user_id_zoho_id_key; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY zoho_leads
    ADD CONSTRAINT zoho_leads_user_id_zoho_id_key UNIQUE (user_id, zoho_id);


--
-- Name: zoho_sync_runs zoho_sync_runs_pkey; Type: CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY zoho_sync_runs
    ADD CONSTRAINT zoho_sync_runs_pkey PRIMARY KEY (id);


--
-- Name: apn_opportunities_user_catalog_opportunity_orgless_key; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE UNIQUE INDEX apn_opportunities_user_catalog_opportunity_orgless_key ON apn_opportunities USING btree (user_id, catalog, opportunity_id) WHERE (organisation_id IS NULL);


--
-- Name: idx_account_channel_context_job; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_account_channel_context_job ON account_channel_context USING btree (job_id);


--
-- Name: idx_account_channel_context_user; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_account_channel_context_user ON account_channel_context USING btree (user_id);


--
-- Name: idx_account_notes_job_id; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_account_notes_job_id ON account_notes USING btree (job_id);


--
-- Name: idx_account_route_assessments_inputs_hash; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_account_route_assessments_inputs_hash ON account_route_assessments USING btree (inputs_hash);


--
-- Name: idx_account_route_assessments_job; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_account_route_assessments_job ON account_route_assessments USING btree (job_id);


--
-- Name: idx_account_route_assessments_org; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_account_route_assessments_org ON account_route_assessments USING btree (organisation_id);


--
-- Name: idx_agent_metrics_agent_name; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_agent_metrics_agent_name ON agent_metrics USING btree (agent_name);


--
-- Name: idx_agent_metrics_created_at; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_agent_metrics_created_at ON agent_metrics USING btree (created_at);


--
-- Name: idx_agent_metrics_job_agent; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_agent_metrics_job_agent ON agent_metrics USING btree (job_id, agent_name);


--
-- Name: idx_agent_metrics_job_id; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_agent_metrics_job_id ON agent_metrics USING btree (job_id);


--
-- Name: idx_agent_metrics_status; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_agent_metrics_status ON agent_metrics USING btree (status);


--
-- Name: idx_ai_feedback_signals_company; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_ai_feedback_signals_company ON ai_feedback_signals USING btree (company_scope, created_at DESC);


--
-- Name: idx_ai_feedback_signals_user; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_ai_feedback_signals_user ON ai_feedback_signals USING btree (user_id);


--
-- Name: idx_alerts_user_seen; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_alerts_user_seen ON alerts USING btree (user_id, seen);


--
-- Name: idx_alliance_alerts_case; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_alliance_alerts_case ON alliance_alerts USING btree (case_id);


--
-- Name: idx_alliance_alerts_org; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_alliance_alerts_org ON alliance_alerts USING btree (organisation_id);


--
-- Name: idx_alliance_alerts_status; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_alliance_alerts_status ON alliance_alerts USING btree (status);


--
-- Name: idx_alliance_alerts_type; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_alliance_alerts_type ON alliance_alerts USING btree (alert_type);


--
-- Name: idx_alliance_insights_org_surface; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_alliance_insights_org_surface ON alliance_insights USING btree (organisation_id, surface);


--
-- Name: idx_alliance_insights_status; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_alliance_insights_status ON alliance_insights USING btree (organisation_id, surface, status);


--
-- Name: idx_apn_opportunities_organisation; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_apn_opportunities_organisation ON apn_opportunities USING btree (organisation_id);


--
-- Name: idx_apn_opportunities_source_job; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_apn_opportunities_source_job ON apn_opportunities USING btree (source_job_id);


--
-- Name: idx_apn_opportunities_user; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_apn_opportunities_user ON apn_opportunities USING btree (user_id);


--
-- Name: idx_apn_sync_runs_organisation; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_apn_sync_runs_organisation ON apn_sync_runs USING btree (organisation_id);


--
-- Name: idx_apn_sync_runs_user; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_apn_sync_runs_user ON apn_sync_runs USING btree (user_id, catalog, started_at DESC);


--
-- Name: idx_atrisk_unresolved; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_atrisk_unresolved ON atrisk_checks USING btree (user_id, resolved_at) WHERE (resolved_at IS NULL);


--
-- Name: idx_booking_links_slug; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_booking_links_slug ON booking_links USING btree (slug);


--
-- Name: idx_co_sell_readiness_generated; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_co_sell_readiness_generated ON co_sell_readiness_ai USING btree (organisation_id, generated_at);


--
-- Name: idx_co_sell_readiness_job; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_co_sell_readiness_job ON co_sell_readiness_ai USING btree (job_id);


--
-- Name: idx_co_sell_readiness_org_partner; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_co_sell_readiness_org_partner ON co_sell_readiness_ai USING btree (organisation_id, partner_id);


--
-- Name: idx_co_sell_rooms_case; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_co_sell_rooms_case ON co_sell_rooms USING btree (case_id);


--
-- Name: idx_co_sell_rooms_organisation; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_co_sell_rooms_organisation ON co_sell_rooms USING btree (organisation_id);


--
-- Name: idx_company_playbooks_name; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_company_playbooks_name ON company_playbooks USING btree (company_name);


--
-- Name: idx_connector_credentials_user; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_connector_credentials_user ON connector_credentials USING btree (user_id);


--
-- Name: idx_crm_tokens_user; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_crm_tokens_user ON crm_tokens USING btree (user_id);


--
-- Name: idx_demo_leads_created_at; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_demo_leads_created_at ON demo_leads USING btree (created_at);


--
-- Name: idx_demo_leads_email; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_demo_leads_email ON demo_leads USING btree (email);


--
-- Name: idx_event_invitations_event; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_event_invitations_event ON event_invitations USING btree (event_id);


--
-- Name: idx_event_invitations_job; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_event_invitations_job ON event_invitations USING btree (job_id);


--
-- Name: idx_jobs_company_name; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_jobs_company_name ON jobs USING btree (company_name);


--
-- Name: idx_jobs_status; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_jobs_status ON jobs USING btree (status);


--
-- Name: idx_jobs_user_created; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_jobs_user_created ON jobs USING btree (user_id, created_at DESC);


--
-- Name: idx_jobs_user_id; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_jobs_user_id ON jobs USING btree (user_id);


--
-- Name: idx_leader_extras_job; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_leader_extras_job ON leader_extras USING btree (job_id);


--
-- Name: idx_mailbox_owner_companies_user; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_mailbox_owner_companies_user ON mailbox_owner_companies USING btree (user_id);


--
-- Name: idx_mailbox_watch_state_expiry; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_mailbox_watch_state_expiry ON mailbox_watch_state USING btree (expires_at);


--
-- Name: idx_microsoft_referrals_organisation; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_microsoft_referrals_organisation ON microsoft_referrals USING btree (organisation_id);


--
-- Name: idx_microsoft_referrals_partner; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_microsoft_referrals_partner ON microsoft_referrals USING btree (partner_id);


--
-- Name: idx_microsoft_referrals_status; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_microsoft_referrals_status ON microsoft_referrals USING btree (status);


--
-- Name: idx_news_company; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_news_company ON news_events USING btree (company_name);


--
-- Name: idx_news_job_id; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_news_job_id ON news_events USING btree (job_id);


--
-- Name: idx_news_received_at; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_news_received_at ON news_events USING btree (received_at DESC);


--
-- Name: idx_org_events_org_starts; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_org_events_org_starts ON org_events USING btree (organisation_id, starts_at);


--
-- Name: idx_partner_account_overlaps_job; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_partner_account_overlaps_job ON partner_account_overlaps USING btree (job_id);


--
-- Name: idx_partner_account_overlaps_organisation; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_partner_account_overlaps_organisation ON partner_account_overlaps USING btree (organisation_id);


--
-- Name: idx_partner_account_overlaps_partner; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_partner_account_overlaps_partner ON partner_account_overlaps USING btree (partner_id);


--
-- Name: idx_partner_account_overlaps_status; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_partner_account_overlaps_status ON partner_account_overlaps USING btree (organisation_id, our_status, partner_status);


--
-- Name: idx_partner_benchmarks_organisation; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_partner_benchmarks_organisation ON partner_benchmarks USING btree (organisation_id);


--
-- Name: idx_partner_benchmarks_partner; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_partner_benchmarks_partner ON partner_benchmarks USING btree (partner_id);


--
-- Name: idx_partner_connections_active; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_partner_connections_active ON partner_connections USING btree (connector_type, is_active);


--
-- Name: idx_partner_connections_organisation; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_partner_connections_organisation ON partner_connections USING btree (organisation_id);


--
-- Name: idx_partner_connections_partner; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_partner_connections_partner ON partner_connections USING btree (partner_id);


--
-- Name: idx_partner_contacts_organisation; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_partner_contacts_organisation ON partner_contacts USING btree (organisation_id);


--
-- Name: idx_partner_contacts_partner_role; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_partner_contacts_partner_role ON partner_contacts USING btree (partner_id, role);


--
-- Name: idx_partner_engagement_cases_job; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_partner_engagement_cases_job ON partner_engagement_cases USING btree (job_id);


--
-- Name: idx_partner_engagement_cases_org_partner; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_partner_engagement_cases_org_partner ON partner_engagement_cases USING btree (organisation_id, partner_id);


--
-- Name: idx_partner_engagement_cases_owner; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_partner_engagement_cases_owner ON partner_engagement_cases USING btree (owner_user_id);


--
-- Name: idx_partner_engagement_cases_state; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_partner_engagement_cases_state ON partner_engagement_cases USING btree (state);


--
-- Name: idx_partner_engagement_events_case; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_partner_engagement_events_case ON partner_engagement_events USING btree (case_id, created_at);


--
-- Name: idx_partner_engagement_events_org; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_partner_engagement_events_org ON partner_engagement_events USING btree (organisation_id);


--
-- Name: idx_partner_facts_organisation; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_partner_facts_organisation ON partner_facts USING btree (organisation_id);


--
-- Name: idx_partner_facts_partner; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_partner_facts_partner ON partner_facts USING btree (partner_id);


--
-- Name: idx_partner_matches_isv; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_partner_matches_isv ON partner_matches USING btree (isv_partner_id);


--
-- Name: idx_partner_matches_job; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_partner_matches_job ON partner_matches USING btree (job_id);


--
-- Name: idx_partner_matches_organisation; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_partner_matches_organisation ON partner_matches USING btree (organisation_id);


--
-- Name: idx_partner_matches_reseller; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_partner_matches_reseller ON partner_matches USING btree (reseller_partner_id);


--
-- Name: idx_partner_matches_score; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_partner_matches_score ON partner_matches USING btree (organisation_id, job_id, score);


--
-- Name: idx_partner_readiness_organisation; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_partner_readiness_organisation ON partner_readiness USING btree (organisation_id);


--
-- Name: idx_partner_readiness_partner_dimension; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_partner_readiness_partner_dimension ON partner_readiness USING btree (partner_id, dimension, captured_at DESC);


--
-- Name: idx_partner_references_org_industry; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_partner_references_org_industry ON partner_references USING btree (organisation_id, industry);


--
-- Name: idx_partner_references_org_use_case; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_partner_references_org_use_case ON partner_references USING btree (organisation_id, use_case);


--
-- Name: idx_partner_references_partner; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_partner_references_partner ON partner_references USING btree (partner_id);


--
-- Name: idx_partner_solutions_organisation; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_partner_solutions_organisation ON partner_solutions USING btree (organisation_id);


--
-- Name: idx_partner_solutions_partner; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_partner_solutions_partner ON partner_solutions USING btree (partner_id);


--
-- Name: idx_partner_targets_organisation; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_partner_targets_organisation ON partner_targets USING btree (organisation_id);


--
-- Name: idx_partner_targets_partner; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_partner_targets_partner ON partner_targets USING btree (partner_id);


--
-- Name: idx_partners_organisation; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_partners_organisation ON partners USING btree (organisation_id);


--
-- Name: idx_partners_organisation_type; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_partners_organisation_type ON partners USING btree (organisation_id, partner_type);


--
-- Name: idx_person_intel_company_role; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_person_intel_company_role ON person_intel_cache USING btree (company_name, role);


--
-- Name: idx_persona_user; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_persona_user ON persona USING btree (user_id, updated_at DESC);


--
-- Name: idx_playbook_kb_kind; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_playbook_kb_kind ON playbook_kb USING btree (kind);


--
-- Name: idx_playbook_kb_persona; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_playbook_kb_persona ON playbook_kb USING btree (persona);


--
-- Name: idx_playbook_kb_trigger; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_playbook_kb_trigger ON playbook_kb USING btree (trigger);


--
-- Name: idx_playbook_variants_job_type; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_playbook_variants_job_type ON playbook_variants USING btree (job_id, playbook_type);


--
-- Name: idx_relationship_bridges_job; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_relationship_bridges_job ON relationship_bridges USING btree (job_id);


--
-- Name: idx_relationship_bridges_organisation; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_relationship_bridges_organisation ON relationship_bridges USING btree (organisation_id);


--
-- Name: idx_results_job_tool; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_results_job_tool ON results USING btree (job_id, tool_name);


--
-- Name: idx_seq_enroll_active_unique; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE UNIQUE INDEX idx_seq_enroll_active_unique ON sequence_enrollments USING btree (user_id, job_id, contact_email) WHERE ((status)::text = 'active'::text);


--
-- Name: idx_seq_enroll_user; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_seq_enroll_user ON sequence_enrollments USING btree (user_id);


--
-- Name: idx_seq_steps_due; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_seq_steps_due ON sequence_steps USING btree (status, due_at);


--
-- Name: idx_seq_steps_enrollment; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_seq_steps_enrollment ON sequence_steps USING btree (enrollment_id);


--
-- Name: idx_sf_accounts_promoted; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_sf_accounts_promoted ON sf_accounts USING btree (promoted_job_id);


--
-- Name: idx_sf_accounts_user; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_sf_accounts_user ON sf_accounts USING btree (user_id);


--
-- Name: idx_sf_deals_account; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_sf_deals_account ON sf_deals USING btree (user_id, account_sf_id);


--
-- Name: idx_sf_deals_promoted; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_sf_deals_promoted ON sf_deals USING btree (promoted_job_id);


--
-- Name: idx_sf_deals_stage; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_sf_deals_stage ON sf_deals USING btree (user_id, stage);


--
-- Name: idx_sf_deals_user; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_sf_deals_user ON sf_deals USING btree (user_id);


--
-- Name: idx_sf_leads_promoted; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_sf_leads_promoted ON sf_leads USING btree (promoted_job_id);


--
-- Name: idx_sf_leads_status; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_sf_leads_status ON sf_leads USING btree (user_id, lead_status);


--
-- Name: idx_sf_leads_user; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_sf_leads_user ON sf_leads USING btree (user_id);


--
-- Name: idx_sf_sync_runs_user; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_sf_sync_runs_user ON sf_sync_runs USING btree (user_id, record_type, started_at DESC);


--
-- Name: idx_si_emb; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_si_emb ON search_index USING hnsw (embedding staging.vector_cosine_ops);


--
-- Name: idx_si_meta; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_si_meta ON search_index USING gin (metadata jsonb_path_ops);


--
-- Name: idx_si_trgm; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_si_trgm ON search_index USING gin (title public.gin_trgm_ops);


--
-- Name: idx_si_tsv; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_si_tsv ON search_index USING gin (tsv);


--
-- Name: idx_si_user; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_si_user ON search_index USING btree (user_id, object_type);


--
-- Name: idx_sql_user_time; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_sql_user_time ON search_query_log USING btree (user_id, created_at DESC);


--
-- Name: idx_suppressions_user_email; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_suppressions_user_email ON suppressions USING btree (user_id, email_norm);


--
-- Name: idx_team_notification_comments_notif; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_team_notification_comments_notif ON team_notification_comments USING btree (notification_id, created_at);


--
-- Name: idx_team_notifications_recipient_seen; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_team_notifications_recipient_seen ON team_notifications USING btree (recipient_user_id, seen, created_at DESC);


--
-- Name: idx_user_reference_documents_user_id; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_user_reference_documents_user_id ON user_reference_documents USING btree (user_id);


--
-- Name: idx_user_tokens_token; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_user_tokens_token ON user_tokens USING btree (token);


--
-- Name: idx_user_tokens_user_id; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_user_tokens_user_id ON user_tokens USING btree (user_id);


--
-- Name: idx_users_cognito_sub; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_users_cognito_sub ON users USING btree (cognito_sub);


--
-- Name: idx_webhook_companies_job_id; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_webhook_companies_job_id ON webhook_companies USING btree (job_id);


--
-- Name: idx_zoho_accounts_promoted; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_zoho_accounts_promoted ON zoho_accounts USING btree (promoted_job_id);


--
-- Name: idx_zoho_accounts_user; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_zoho_accounts_user ON zoho_accounts USING btree (user_id);


--
-- Name: idx_zoho_deals_account; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_zoho_deals_account ON zoho_deals USING btree (user_id, account_zoho_id);


--
-- Name: idx_zoho_deals_promoted; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_zoho_deals_promoted ON zoho_deals USING btree (promoted_job_id);


--
-- Name: idx_zoho_deals_stage; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_zoho_deals_stage ON zoho_deals USING btree (user_id, stage);


--
-- Name: idx_zoho_deals_user; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_zoho_deals_user ON zoho_deals USING btree (user_id);


--
-- Name: idx_zoho_leads_promoted; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_zoho_leads_promoted ON zoho_leads USING btree (promoted_job_id);


--
-- Name: idx_zoho_leads_status; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_zoho_leads_status ON zoho_leads USING btree (user_id, lead_status);


--
-- Name: idx_zoho_leads_user; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_zoho_leads_user ON zoho_leads USING btree (user_id);


--
-- Name: idx_zoho_sync_runs_user; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX idx_zoho_sync_runs_user ON zoho_sync_runs USING btree (user_id, record_type, started_at DESC);


--
-- Name: ix_account_brief_history_job_captured; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX ix_account_brief_history_job_captured ON account_brief_history USING btree (job_id, captured_at);


--
-- Name: ix_agent_tool_grants_user_id; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX ix_agent_tool_grants_user_id ON agent_tool_grants USING btree (user_id);


--
-- Name: ix_mcp_connectors_user_id; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX ix_mcp_connectors_user_id ON mcp_connectors USING btree (user_id);


--
-- Name: ix_mcp_connectors_user_status; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE INDEX ix_mcp_connectors_user_status ON mcp_connectors USING btree (user_id, status);


--
-- Name: partner_contacts_partner_email_key; Type: INDEX; Schema: dev; Owner: postgres
--

CREATE UNIQUE INDEX partner_contacts_partner_email_key ON partner_contacts USING btree (partner_id, lower((email)::text));


--
-- Name: account_brief_history account_brief_history_job_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY account_brief_history
    ADD CONSTRAINT account_brief_history_job_id_fkey FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE;


--
-- Name: account_briefs account_briefs_job_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY account_briefs
    ADD CONSTRAINT account_briefs_job_id_fkey FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE;


--
-- Name: account_channel_context account_channel_context_job_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY account_channel_context
    ADD CONSTRAINT account_channel_context_job_id_fkey FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE;


--
-- Name: account_channel_context account_channel_context_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY account_channel_context
    ADD CONSTRAINT account_channel_context_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: account_drive_folders account_drive_folders_job_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY account_drive_folders
    ADD CONSTRAINT account_drive_folders_job_id_fkey FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE;


--
-- Name: account_drive_folders account_drive_folders_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY account_drive_folders
    ADD CONSTRAINT account_drive_folders_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: account_notes account_notes_job_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY account_notes
    ADD CONSTRAINT account_notes_job_id_fkey FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE;


--
-- Name: account_notes account_notes_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY account_notes
    ADD CONSTRAINT account_notes_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: account_route_assessments account_route_assessments_job_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY account_route_assessments
    ADD CONSTRAINT account_route_assessments_job_id_fkey FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE;


--
-- Name: account_route_assessments account_route_assessments_organisation_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY account_route_assessments
    ADD CONSTRAINT account_route_assessments_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisations(id) ON DELETE CASCADE;


--
-- Name: agent_metrics agent_metrics_job_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY agent_metrics
    ADD CONSTRAINT agent_metrics_job_id_fkey FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE;


--
-- Name: ai_feedback_signals ai_feedback_signals_job_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY ai_feedback_signals
    ADD CONSTRAINT ai_feedback_signals_job_id_fkey FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE SET NULL;


--
-- Name: ai_feedback_signals ai_feedback_signals_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY ai_feedback_signals
    ADD CONSTRAINT ai_feedback_signals_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- Name: alerts alerts_job_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY alerts
    ADD CONSTRAINT alerts_job_id_fkey FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE;


--
-- Name: alerts alerts_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY alerts
    ADD CONSTRAINT alerts_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: alliance_insights alliance_insights_organisation_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY alliance_insights
    ADD CONSTRAINT alliance_insights_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisations(id) ON DELETE CASCADE;


--
-- Name: apn_opportunities apn_opportunities_organisation_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY apn_opportunities
    ADD CONSTRAINT apn_opportunities_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisations(id) ON DELETE CASCADE;


--
-- Name: apn_opportunities apn_opportunities_source_job_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY apn_opportunities
    ADD CONSTRAINT apn_opportunities_source_job_id_fkey FOREIGN KEY (source_job_id) REFERENCES jobs(id) ON DELETE SET NULL;


--
-- Name: apn_opportunities apn_opportunities_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY apn_opportunities
    ADD CONSTRAINT apn_opportunities_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: apn_sync_runs apn_sync_runs_organisation_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY apn_sync_runs
    ADD CONSTRAINT apn_sync_runs_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisations(id) ON DELETE CASCADE;


--
-- Name: apn_sync_runs apn_sync_runs_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY apn_sync_runs
    ADD CONSTRAINT apn_sync_runs_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: atrisk_checks atrisk_checks_job_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY atrisk_checks
    ADD CONSTRAINT atrisk_checks_job_id_fkey FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE;


--
-- Name: atrisk_checks atrisk_checks_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY atrisk_checks
    ADD CONSTRAINT atrisk_checks_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: batches batches_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY batches
    ADD CONSTRAINT batches_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: booking_links booking_links_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY booking_links
    ADD CONSTRAINT booking_links_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: campaign_attributions campaign_attributions_job_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY campaign_attributions
    ADD CONSTRAINT campaign_attributions_job_id_fkey FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE;


--
-- Name: campaign_attributions campaign_attributions_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY campaign_attributions
    ADD CONSTRAINT campaign_attributions_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: connector_credentials connector_credentials_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY connector_credentials
    ADD CONSTRAINT connector_credentials_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: crm_tokens crm_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY crm_tokens
    ADD CONSTRAINT crm_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: cxo_settings cxo_settings_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY cxo_settings
    ADD CONSTRAINT cxo_settings_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: digest_logs digest_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY digest_logs
    ADD CONSTRAINT digest_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: event_invitations event_invitations_event_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY event_invitations
    ADD CONSTRAINT event_invitations_event_id_fkey FOREIGN KEY (event_id) REFERENCES org_events(id) ON DELETE CASCADE;


--
-- Name: event_invitations event_invitations_job_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY event_invitations
    ADD CONSTRAINT event_invitations_job_id_fkey FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE;


--
-- Name: event_invitations event_invitations_organisation_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY event_invitations
    ADD CONSTRAINT event_invitations_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisations(id) ON DELETE CASCADE;


--
-- Name: event_invitations event_invitations_sequence_enrollment_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY event_invitations
    ADD CONSTRAINT event_invitations_sequence_enrollment_id_fkey FOREIGN KEY (sequence_enrollment_id) REFERENCES sequence_enrollments(id) ON DELETE SET NULL;


--
-- Name: explorium_credit_limits explorium_credit_limits_organization_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY explorium_credit_limits
    ADD CONSTRAINT explorium_credit_limits_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES organisations(id) ON DELETE SET NULL;


--
-- Name: explorium_credit_limits explorium_credit_limits_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY explorium_credit_limits
    ADD CONSTRAINT explorium_credit_limits_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: explorium_organisation_credit_limits explorium_organisation_credit_limits_organization_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY explorium_organisation_credit_limits
    ADD CONSTRAINT explorium_organisation_credit_limits_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES organisations(id) ON DELETE CASCADE;


--
-- Name: alliance_alerts fk_alliance_alerts_case; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY alliance_alerts
    ADD CONSTRAINT fk_alliance_alerts_case FOREIGN KEY (case_id) REFERENCES partner_engagement_cases(id) ON DELETE CASCADE;


--
-- Name: alliance_alerts fk_alliance_alerts_organisation; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY alliance_alerts
    ADD CONSTRAINT fk_alliance_alerts_organisation FOREIGN KEY (organisation_id) REFERENCES organisations(id) ON DELETE CASCADE;


--
-- Name: alliance_alerts fk_alliance_alerts_partner; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY alliance_alerts
    ADD CONSTRAINT fk_alliance_alerts_partner FOREIGN KEY (partner_id) REFERENCES partners(id) ON DELETE CASCADE;


--
-- Name: co_sell_readiness_ai fk_co_sell_readiness_ai_job; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY co_sell_readiness_ai
    ADD CONSTRAINT fk_co_sell_readiness_ai_job FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE;


--
-- Name: co_sell_readiness_ai fk_co_sell_readiness_ai_organisation; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY co_sell_readiness_ai
    ADD CONSTRAINT fk_co_sell_readiness_ai_organisation FOREIGN KEY (organisation_id) REFERENCES organisations(id) ON DELETE CASCADE;


--
-- Name: co_sell_readiness_ai fk_co_sell_readiness_ai_partner; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY co_sell_readiness_ai
    ADD CONSTRAINT fk_co_sell_readiness_ai_partner FOREIGN KEY (partner_id) REFERENCES partners(id) ON DELETE CASCADE;


--
-- Name: co_sell_rooms fk_co_sell_rooms_case; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY co_sell_rooms
    ADD CONSTRAINT fk_co_sell_rooms_case FOREIGN KEY (case_id) REFERENCES partner_engagement_cases(id) ON DELETE CASCADE;


--
-- Name: co_sell_rooms fk_co_sell_rooms_organisation; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY co_sell_rooms
    ADD CONSTRAINT fk_co_sell_rooms_organisation FOREIGN KEY (organisation_id) REFERENCES organisations(id) ON DELETE CASCADE;


--
-- Name: microsoft_referrals fk_microsoft_referrals_organisation; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY microsoft_referrals
    ADD CONSTRAINT fk_microsoft_referrals_organisation FOREIGN KEY (organisation_id) REFERENCES organisations(id) ON DELETE CASCADE;


--
-- Name: microsoft_referrals fk_microsoft_referrals_partner; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY microsoft_referrals
    ADD CONSTRAINT fk_microsoft_referrals_partner FOREIGN KEY (partner_id) REFERENCES partners(id) ON DELETE CASCADE;


--
-- Name: partner_account_overlaps fk_partner_account_overlaps_job; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_account_overlaps
    ADD CONSTRAINT fk_partner_account_overlaps_job FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE;


--
-- Name: partner_account_overlaps fk_partner_account_overlaps_organisation; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_account_overlaps
    ADD CONSTRAINT fk_partner_account_overlaps_organisation FOREIGN KEY (organisation_id) REFERENCES organisations(id) ON DELETE CASCADE;


--
-- Name: partner_account_overlaps fk_partner_account_overlaps_owner; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_account_overlaps
    ADD CONSTRAINT fk_partner_account_overlaps_owner FOREIGN KEY (our_owner_user_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- Name: partner_account_overlaps fk_partner_account_overlaps_partner; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_account_overlaps
    ADD CONSTRAINT fk_partner_account_overlaps_partner FOREIGN KEY (partner_id) REFERENCES partners(id) ON DELETE CASCADE;


--
-- Name: partner_account_overlaps fk_partner_account_overlaps_partner_contact; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_account_overlaps
    ADD CONSTRAINT fk_partner_account_overlaps_partner_contact FOREIGN KEY (partner_owner_contact_id) REFERENCES partner_contacts(id) ON DELETE SET NULL;


--
-- Name: partner_matches fk_partner_matches_isv; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_matches
    ADD CONSTRAINT fk_partner_matches_isv FOREIGN KEY (isv_partner_id) REFERENCES partners(id) ON DELETE CASCADE;


--
-- Name: partner_matches fk_partner_matches_job; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_matches
    ADD CONSTRAINT fk_partner_matches_job FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE;


--
-- Name: partner_matches fk_partner_matches_organisation; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_matches
    ADD CONSTRAINT fk_partner_matches_organisation FOREIGN KEY (organisation_id) REFERENCES organisations(id) ON DELETE CASCADE;


--
-- Name: partner_matches fk_partner_matches_reseller; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_matches
    ADD CONSTRAINT fk_partner_matches_reseller FOREIGN KEY (reseller_partner_id) REFERENCES partners(id) ON DELETE CASCADE;


--
-- Name: forecast_syncs forecast_syncs_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY forecast_syncs
    ADD CONSTRAINT forecast_syncs_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: jobs jobs_batch_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT jobs_batch_id_fkey FOREIGN KEY (batch_id) REFERENCES batches(id);


--
-- Name: jobs jobs_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT jobs_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: leader_extras leader_extras_job_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY leader_extras
    ADD CONSTRAINT leader_extras_job_id_fkey FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE;


--
-- Name: leadership_results leadership_results_job_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY leadership_results
    ADD CONSTRAINT leadership_results_job_id_fkey FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE;


--
-- Name: mailbox_owner_companies mailbox_owner_companies_job_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY mailbox_owner_companies
    ADD CONSTRAINT mailbox_owner_companies_job_id_fkey FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE;


--
-- Name: mailbox_owner_companies mailbox_owner_companies_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY mailbox_owner_companies
    ADD CONSTRAINT mailbox_owner_companies_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: mailbox_watch_state mailbox_watch_state_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY mailbox_watch_state
    ADD CONSTRAINT mailbox_watch_state_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: mcp_tool_grants mcp_tool_grants_connector_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY mcp_tool_grants
    ADD CONSTRAINT mcp_tool_grants_connector_id_fkey FOREIGN KEY (connector_id) REFERENCES mcp_connectors(id) ON DELETE CASCADE;


--
-- Name: metrics_snapshots metrics_snapshots_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY metrics_snapshots
    ADD CONSTRAINT metrics_snapshots_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: news_events news_events_job_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY news_events
    ADD CONSTRAINT news_events_job_id_fkey FOREIGN KEY (job_id) REFERENCES jobs(id);


--
-- Name: org_events org_events_organisation_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY org_events
    ADD CONSTRAINT org_events_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisations(id) ON DELETE CASCADE;


--
-- Name: org_events org_events_owner_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY org_events
    ADD CONSTRAINT org_events_owner_user_id_fkey FOREIGN KEY (owner_user_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- Name: org_events org_events_partner_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY org_events
    ADD CONSTRAINT org_events_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES partners(id) ON DELETE SET NULL;


--
-- Name: partner_benchmarks partner_benchmarks_organisation_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_benchmarks
    ADD CONSTRAINT partner_benchmarks_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisations(id) ON DELETE CASCADE;


--
-- Name: partner_benchmarks partner_benchmarks_partner_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_benchmarks
    ADD CONSTRAINT partner_benchmarks_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES partners(id) ON DELETE CASCADE;


--
-- Name: partner_connections partner_connections_created_by_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_connections
    ADD CONSTRAINT partner_connections_created_by_user_id_fkey FOREIGN KEY (created_by_user_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- Name: partner_connections partner_connections_organisation_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_connections
    ADD CONSTRAINT partner_connections_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisations(id) ON DELETE CASCADE;


--
-- Name: partner_connections partner_connections_partner_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_connections
    ADD CONSTRAINT partner_connections_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES partners(id) ON DELETE CASCADE;


--
-- Name: partner_contacts partner_contacts_organisation_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_contacts
    ADD CONSTRAINT partner_contacts_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisations(id) ON DELETE CASCADE;


--
-- Name: partner_contacts partner_contacts_partner_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_contacts
    ADD CONSTRAINT partner_contacts_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES partners(id) ON DELETE CASCADE;


--
-- Name: partner_engagement_cases partner_engagement_cases_job_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_engagement_cases
    ADD CONSTRAINT partner_engagement_cases_job_id_fkey FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE;


--
-- Name: partner_engagement_cases partner_engagement_cases_organisation_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_engagement_cases
    ADD CONSTRAINT partner_engagement_cases_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisations(id) ON DELETE CASCADE;


--
-- Name: partner_engagement_cases partner_engagement_cases_owner_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_engagement_cases
    ADD CONSTRAINT partner_engagement_cases_owner_user_id_fkey FOREIGN KEY (owner_user_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- Name: partner_engagement_cases partner_engagement_cases_partner_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_engagement_cases
    ADD CONSTRAINT partner_engagement_cases_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES partners(id) ON DELETE CASCADE;


--
-- Name: partner_engagement_cases partner_engagement_cases_primary_contact_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_engagement_cases
    ADD CONSTRAINT partner_engagement_cases_primary_contact_id_fkey FOREIGN KEY (primary_contact_id) REFERENCES partner_contacts(id) ON DELETE SET NULL;


--
-- Name: partner_engagement_events partner_engagement_events_actor_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_engagement_events
    ADD CONSTRAINT partner_engagement_events_actor_user_id_fkey FOREIGN KEY (actor_user_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- Name: partner_engagement_events partner_engagement_events_case_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_engagement_events
    ADD CONSTRAINT partner_engagement_events_case_id_fkey FOREIGN KEY (case_id) REFERENCES partner_engagement_cases(id) ON DELETE CASCADE;


--
-- Name: partner_engagement_events partner_engagement_events_organisation_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_engagement_events
    ADD CONSTRAINT partner_engagement_events_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisations(id) ON DELETE CASCADE;


--
-- Name: partner_facts partner_facts_organisation_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_facts
    ADD CONSTRAINT partner_facts_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisations(id) ON DELETE CASCADE;


--
-- Name: partner_facts partner_facts_partner_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_facts
    ADD CONSTRAINT partner_facts_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES partners(id) ON DELETE CASCADE;


--
-- Name: partner_facts partner_facts_updated_by_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_facts
    ADD CONSTRAINT partner_facts_updated_by_user_id_fkey FOREIGN KEY (updated_by_user_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- Name: partner_readiness partner_readiness_organisation_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_readiness
    ADD CONSTRAINT partner_readiness_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisations(id) ON DELETE CASCADE;


--
-- Name: partner_readiness partner_readiness_partner_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_readiness
    ADD CONSTRAINT partner_readiness_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES partners(id) ON DELETE CASCADE;


--
-- Name: partner_references partner_references_organisation_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_references
    ADD CONSTRAINT partner_references_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisations(id) ON DELETE CASCADE;


--
-- Name: partner_references partner_references_partner_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_references
    ADD CONSTRAINT partner_references_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES partners(id) ON DELETE SET NULL;


--
-- Name: partner_solutions partner_solutions_organisation_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_solutions
    ADD CONSTRAINT partner_solutions_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisations(id) ON DELETE CASCADE;


--
-- Name: partner_solutions partner_solutions_partner_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_solutions
    ADD CONSTRAINT partner_solutions_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES partners(id) ON DELETE CASCADE;


--
-- Name: partner_targets partner_targets_organisation_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_targets
    ADD CONSTRAINT partner_targets_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisations(id) ON DELETE CASCADE;


--
-- Name: partner_targets partner_targets_partner_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partner_targets
    ADD CONSTRAINT partner_targets_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES partners(id) ON DELETE CASCADE;


--
-- Name: partners partners_organisation_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY partners
    ADD CONSTRAINT partners_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisations(id) ON DELETE CASCADE;


--
-- Name: persona persona_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY persona
    ADD CONSTRAINT persona_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: playbook_variants playbook_variants_job_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY playbook_variants
    ADD CONSTRAINT playbook_variants_job_id_fkey FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE;


--
-- Name: presentations presentations_job_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY presentations
    ADD CONSTRAINT presentations_job_id_fkey FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE SET NULL;


--
-- Name: presentations presentations_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY presentations
    ADD CONSTRAINT presentations_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: qbr_generations qbr_generations_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY qbr_generations
    ADD CONSTRAINT qbr_generations_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: relationship_bridges relationship_bridges_job_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY relationship_bridges
    ADD CONSTRAINT relationship_bridges_job_id_fkey FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE;


--
-- Name: relationship_bridges relationship_bridges_organisation_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY relationship_bridges
    ADD CONSTRAINT relationship_bridges_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisations(id) ON DELETE CASCADE;


--
-- Name: results results_job_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY results
    ADD CONSTRAINT results_job_id_fkey FOREIGN KEY (job_id) REFERENCES jobs(id);


--
-- Name: search_index search_index_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY search_index
    ADD CONSTRAINT search_index_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: search_query_log search_query_log_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY search_query_log
    ADD CONSTRAINT search_query_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: sequence_enrollments sequence_enrollments_job_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY sequence_enrollments
    ADD CONSTRAINT sequence_enrollments_job_id_fkey FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE;


--
-- Name: sequence_enrollments sequence_enrollments_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY sequence_enrollments
    ADD CONSTRAINT sequence_enrollments_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: sequence_steps sequence_steps_enrollment_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY sequence_steps
    ADD CONSTRAINT sequence_steps_enrollment_id_fkey FOREIGN KEY (enrollment_id) REFERENCES sequence_enrollments(id) ON DELETE CASCADE;


--
-- Name: sf_accounts sf_accounts_promoted_job_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY sf_accounts
    ADD CONSTRAINT sf_accounts_promoted_job_id_fkey FOREIGN KEY (promoted_job_id) REFERENCES jobs(id) ON DELETE SET NULL;


--
-- Name: sf_accounts sf_accounts_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY sf_accounts
    ADD CONSTRAINT sf_accounts_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: sf_deals sf_deals_promoted_job_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY sf_deals
    ADD CONSTRAINT sf_deals_promoted_job_id_fkey FOREIGN KEY (promoted_job_id) REFERENCES jobs(id) ON DELETE SET NULL;


--
-- Name: sf_deals sf_deals_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY sf_deals
    ADD CONSTRAINT sf_deals_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: sf_leads sf_leads_promoted_job_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY sf_leads
    ADD CONSTRAINT sf_leads_promoted_job_id_fkey FOREIGN KEY (promoted_job_id) REFERENCES jobs(id) ON DELETE SET NULL;


--
-- Name: sf_leads sf_leads_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY sf_leads
    ADD CONSTRAINT sf_leads_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: sf_sync_runs sf_sync_runs_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY sf_sync_runs
    ADD CONSTRAINT sf_sync_runs_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: team_notification_comments team_notification_comments_notification_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY team_notification_comments
    ADD CONSTRAINT team_notification_comments_notification_id_fkey FOREIGN KEY (notification_id) REFERENCES team_notifications(id) ON DELETE CASCADE;


--
-- Name: team_notification_comments team_notification_comments_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY team_notification_comments
    ADD CONSTRAINT team_notification_comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: team_notification_reactions team_notification_reactions_notification_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY team_notification_reactions
    ADD CONSTRAINT team_notification_reactions_notification_id_fkey FOREIGN KEY (notification_id) REFERENCES team_notifications(id) ON DELETE CASCADE;


--
-- Name: team_notification_reactions team_notification_reactions_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY team_notification_reactions
    ADD CONSTRAINT team_notification_reactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: team_notifications team_notifications_actor_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY team_notifications
    ADD CONSTRAINT team_notifications_actor_user_id_fkey FOREIGN KEY (actor_user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: team_notifications team_notifications_job_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY team_notifications
    ADD CONSTRAINT team_notifications_job_id_fkey FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE;


--
-- Name: team_notifications team_notifications_recipient_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY team_notifications
    ADD CONSTRAINT team_notifications_recipient_user_id_fkey FOREIGN KEY (recipient_user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: user_reference_documents user_reference_documents_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY user_reference_documents
    ADD CONSTRAINT user_reference_documents_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: user_settings user_settings_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY user_settings
    ADD CONSTRAINT user_settings_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: user_tokens user_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY user_tokens
    ADD CONSTRAINT user_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: users users_organization_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES organisations(id);


--
-- Name: webhook_companies webhook_companies_job_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY webhook_companies
    ADD CONSTRAINT webhook_companies_job_id_fkey FOREIGN KEY (job_id) REFERENCES jobs(id);


--
-- Name: zoho_accounts zoho_accounts_promoted_job_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY zoho_accounts
    ADD CONSTRAINT zoho_accounts_promoted_job_id_fkey FOREIGN KEY (promoted_job_id) REFERENCES jobs(id) ON DELETE SET NULL;


--
-- Name: zoho_accounts zoho_accounts_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY zoho_accounts
    ADD CONSTRAINT zoho_accounts_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: zoho_deals zoho_deals_promoted_job_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY zoho_deals
    ADD CONSTRAINT zoho_deals_promoted_job_id_fkey FOREIGN KEY (promoted_job_id) REFERENCES jobs(id) ON DELETE SET NULL;


--
-- Name: zoho_deals zoho_deals_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY zoho_deals
    ADD CONSTRAINT zoho_deals_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: zoho_leads zoho_leads_promoted_job_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY zoho_leads
    ADD CONSTRAINT zoho_leads_promoted_job_id_fkey FOREIGN KEY (promoted_job_id) REFERENCES jobs(id) ON DELETE SET NULL;


--
-- Name: zoho_leads zoho_leads_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY zoho_leads
    ADD CONSTRAINT zoho_leads_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: zoho_sync_runs zoho_sync_runs_user_id_fkey; Type: FK CONSTRAINT; Schema: dev; Owner: postgres
--

ALTER TABLE ONLY zoho_sync_runs
    ADD CONSTRAINT zoho_sync_runs_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict CuUM64AM9lxIGz2Jd5J8mIe6qp1BwkVj8WpDe1JbTCHTMryHw6oSdf1lHY26eJg




-- ====================================================================
-- PART 2: ADDITIONAL TABLES FROM STAGING (13 TABLES)
-- ====================================================================
-- These tables exist in staging but not in dev
-- Added to preserve all data during migration
-- ====================================================================


-- Table: datasets
CREATE TABLE datasets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    owner_id character varying(64) NOT NULL,
    name character varying(255) NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    status character varying(32) DEFAULT 'paused'::character varying NOT NULL,
    last_status_error text,
    visibility character varying(16) DEFAULT 'private'::character varying NOT NULL,
    seed_key character varying(255),
    refresh_cadence character varying(16) DEFAULT 'manual'::character varying NOT NULL,
    refresh_enabled boolean DEFAULT false NOT NULL,
    next_refresh_at timestamp with time zone,
    last_refresh_at timestamp with time zone,
    last_refresh_started_at timestamp with time zone,
    last_refresh_run_id character varying(255),
    row_count integer DEFAULT 0 NOT NULL,
    columns jsonb DEFAULT '[]'::jsonb NOT NULL,
    retrieval_strategy character varying(32),
    source_hint text,
    source_category character varying(32),
    icp text,
    lead_threshold integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    icp_spec jsonb,
    personas jsonb,
    intake_mode character varying(16) DEFAULT 'discover'::character varying,
    target_accounts jsonb
);

-- Constraints for datasets
ALTER TABLE datasets OWNER TO postgres;
ALTER TABLE ONLY datasets
    ADD CONSTRAINT datasets_pkey PRIMARY KEY (id);
ALTER TABLE ONLY datasets
    ADD CONSTRAINT datasets_seed_key_key UNIQUE (seed_key);

-- Indexes for datasets
CREATE INDEX ix_datasets_owner_id ON datasets USING btree (owner_id);
CREATE INDEX ix_datasets_refresh_due ON datasets USING btree (refresh_enabled, next_refresh_at);
CREATE INDEX ix_datasets_visibility_created ON datasets USING btree (visibility, created_at);


-- Table: dataset_rows
CREATE TABLE dataset_rows (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    dataset_id uuid NOT NULL,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    sources text[],
    row_summary text,
    how_found text,
    update_status character varying(16),
    confidence_score integer,
    signal_bundle jsonb,
    why_now text,
    lead_status character varying(16),
    icp_fit character varying(16),
    icp_reason text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

-- Constraints for dataset_rows
ALTER TABLE dataset_rows OWNER TO postgres;
ALTER TABLE ONLY dataset_rows
    ADD CONSTRAINT dataset_rows_pkey PRIMARY KEY (id);
ALTER TABLE ONLY dataset_rows
    ADD CONSTRAINT dataset_rows_dataset_id_fkey FOREIGN KEY (dataset_id) REFERENCES datasets(id) ON DELETE CASCADE;

-- Indexes for dataset_rows
CREATE INDEX ix_dataset_rows_dataset ON dataset_rows USING btree (dataset_id);
CREATE INDEX ix_dataset_rows_dataset_confidence ON dataset_rows USING btree (dataset_id, confidence_score DESC);
CREATE INDEX ix_dataset_rows_dataset_status ON dataset_rows USING btree (dataset_id, update_status);


-- Table: dataset_history
CREATE TABLE dataset_history (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    dataset_row_id uuid NOT NULL,
    column_name character varying(255) NOT NULL,
    old_value text DEFAULT ''::text NOT NULL,
    new_value text DEFAULT ''::text NOT NULL,
    changed_at timestamp with time zone DEFAULT now() NOT NULL
);

-- Constraints for dataset_history
ALTER TABLE dataset_history OWNER TO postgres;
ALTER TABLE ONLY dataset_history
    ADD CONSTRAINT dataset_history_pkey PRIMARY KEY (id);
ALTER TABLE ONLY dataset_history
    ADD CONSTRAINT dataset_history_dataset_row_id_fkey FOREIGN KEY (dataset_row_id) REFERENCES dataset_rows(id) ON DELETE CASCADE;

-- Indexes for dataset_history
CREATE INDEX ix_dataset_history_row ON dataset_history USING btree (dataset_row_id);


-- Table: outreach_sequences
CREATE TABLE outreach_sequences (
    id integer NOT NULL,
    user_id integer NOT NULL,
    name text NOT NULL,
    description text,
    steps jsonb DEFAULT '[]'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);

-- Constraints for outreach_sequences
ALTER TABLE outreach_sequences OWNER TO postgres;
ALTER TABLE ONLY outreach_sequences ALTER COLUMN id SET DEFAULT nextval('outreach_sequences_id_seq'::regclass);
ALTER TABLE ONLY outreach_sequences
    ADD CONSTRAINT outreach_sequences_pkey PRIMARY KEY (id);


-- Table: outreach_enrollments
CREATE TABLE outreach_enrollments (
    id integer NOT NULL,
    user_id integer NOT NULL,
    job_id text,
    sequence_id integer,
    contact_name text NOT NULL,
    contact_email text NOT NULL,
    contact_linkedin_url text,
    status text DEFAULT 'active'::text NOT NULL,
    gmail_thread_id text,
    started_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- Constraints for outreach_enrollments
ALTER TABLE outreach_enrollments OWNER TO postgres;
ALTER TABLE ONLY outreach_enrollments ALTER COLUMN id SET DEFAULT nextval('outreach_enrollments_id_seq'::regclass);
ALTER TABLE ONLY outreach_enrollments
    ADD CONSTRAINT outreach_enrollments_pkey PRIMARY KEY (id);
ALTER TABLE ONLY outreach_enrollments
    ADD CONSTRAINT outreach_enrollments_sequence_id_fkey FOREIGN KEY (sequence_id) REFERENCES outreach_sequences(id);

-- Indexes for outreach_enrollments
CREATE UNIQUE INDEX idx_outreach_enroll_active ON outreach_enrollments USING btree (user_id, contact_email) WHERE (status = 'active'::text);


-- Table: outreach_steps
CREATE TABLE outreach_steps (
    id integer NOT NULL,
    enrollment_id integer,
    step_number integer NOT NULL,
    channel text DEFAULT 'email'::text NOT NULL,
    due_at timestamp with time zone NOT NULL,
    status text DEFAULT 'scheduled'::text NOT NULL,
    draft_subject text,
    draft_body text,
    sent_subject text,
    sent_body text,
    sent_at timestamp with time zone,
    provider_message_id text,
    error_msg text,
    created_at timestamp with time zone DEFAULT now()
);

-- Constraints for outreach_steps
ALTER TABLE outreach_steps OWNER TO postgres;
ALTER TABLE ONLY outreach_steps ALTER COLUMN id SET DEFAULT nextval('outreach_steps_id_seq'::regclass);
ALTER TABLE ONLY outreach_steps
    ADD CONSTRAINT outreach_steps_pkey PRIMARY KEY (id);
ALTER TABLE ONLY outreach_steps
    ADD CONSTRAINT outreach_steps_enrollment_id_fkey FOREIGN KEY (enrollment_id) REFERENCES outreach_enrollments(id) ON DELETE CASCADE;


-- Table: outreach_reply_log
CREATE TABLE outreach_reply_log (
    id integer NOT NULL,
    enrollment_id integer,
    gmail_message_id text,
    detected_at timestamp with time zone DEFAULT now(),
    snippet text
);

-- Constraints for outreach_reply_log
ALTER TABLE outreach_reply_log OWNER TO postgres;
ALTER TABLE ONLY outreach_reply_log ALTER COLUMN id SET DEFAULT nextval('outreach_reply_log_id_seq'::regclass);
ALTER TABLE ONLY outreach_reply_log
    ADD CONSTRAINT outreach_reply_log_pkey PRIMARY KEY (id);
ALTER TABLE ONLY outreach_reply_log
    ADD CONSTRAINT outreach_reply_log_enrollment_id_fkey FOREIGN KEY (enrollment_id) REFERENCES outreach_enrollments(id) ON DELETE CASCADE;


-- Table: vault_documents
CREATE TABLE vault_documents (
    id integer NOT NULL,
    user_id integer NOT NULL,
    title character varying(500) NOT NULL,
    file_type character varying(20) NOT NULL,
    source_type character varying(50) DEFAULT 'manual'::character varying,
    s3_key character varying(1000) NOT NULL,
    byte_size integer,
    chunk_count integer DEFAULT 0,
    status character varying(20) DEFAULT 'pending'::character varying,
    error text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT vault_documents_file_type_check CHECK (((file_type)::text = ANY ((ARRAY['pdf'::character varying, 'docx'::character varying, 'txt'::character varying, 'md'::character varying, 'csv'::character varying, 'xlsx'::character varying, 'xls'::character varying])::text[]))),
    CONSTRAINT vault_documents_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'ready'::character varying, 'failed'::character varying])::text[])))
);

-- Constraints for vault_documents
ALTER TABLE vault_documents OWNER TO postgres;
ALTER TABLE ONLY vault_documents ALTER COLUMN id SET DEFAULT nextval('vault_documents_id_seq'::regclass);
ALTER TABLE ONLY vault_documents
    ADD CONSTRAINT vault_documents_pkey PRIMARY KEY (id);
ALTER TABLE ONLY vault_documents
    ADD CONSTRAINT vault_documents_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- Indexes for vault_documents
CREATE INDEX idx_vault_documents_user ON vault_documents USING btree (user_id, created_at DESC);


-- Table: vault_chunks
CREATE TABLE vault_chunks (
    id integer NOT NULL,
    document_id integer NOT NULL,
    user_id integer NOT NULL,
    chunk_index integer NOT NULL,
    text text NOT NULL,
    embedding bytea NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Constraints for vault_chunks
ALTER TABLE vault_chunks OWNER TO postgres;
ALTER TABLE ONLY vault_chunks ALTER COLUMN id SET DEFAULT nextval('vault_chunks_id_seq'::regclass);
ALTER TABLE ONLY vault_chunks
    ADD CONSTRAINT vault_chunks_pkey PRIMARY KEY (id);
ALTER TABLE ONLY vault_chunks
    ADD CONSTRAINT vault_chunks_document_id_fkey FOREIGN KEY (document_id) REFERENCES vault_documents(id) ON DELETE CASCADE;
ALTER TABLE ONLY vault_chunks
    ADD CONSTRAINT vault_chunks_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- Indexes for vault_chunks
CREATE INDEX idx_vault_chunks_doc ON vault_chunks USING btree (document_id);
CREATE INDEX idx_vault_chunks_user ON vault_chunks USING btree (user_id);


-- Table: sequence_replies
CREATE TABLE sequence_replies (
    id integer NOT NULL,
    enrollment_id integer NOT NULL,
    gmail_message_id character varying(255) NOT NULL,
    from_email character varying(255) NOT NULL,
    subject character varying(512),
    body text,
    received_at timestamp without time zone NOT NULL,
    ai_summary text,
    classification character varying(30) DEFAULT 'unknown'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Constraints for sequence_replies
ALTER TABLE sequence_replies OWNER TO postgres;
ALTER TABLE ONLY sequence_replies ALTER COLUMN id SET DEFAULT nextval('sequence_replies_id_seq'::regclass);
ALTER TABLE ONLY sequence_replies
    ADD CONSTRAINT sequence_replies_gmail_message_id_key UNIQUE (gmail_message_id);
ALTER TABLE ONLY sequence_replies
    ADD CONSTRAINT sequence_replies_pkey PRIMARY KEY (id);
ALTER TABLE ONLY sequence_replies
    ADD CONSTRAINT sequence_replies_enrollment_id_fkey FOREIGN KEY (enrollment_id) REFERENCES sequence_enrollments(id) ON DELETE CASCADE;

-- Indexes for sequence_replies
CREATE INDEX idx_seq_replies_enrollment ON sequence_replies USING btree (enrollment_id);


-- Table: llm_calls
CREATE TABLE llm_calls (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    workflow_run_id character varying(255),
    dataset_id uuid,
    user_id character varying(64),
    purpose character varying(32) NOT NULL,
    model_id character varying(255) NOT NULL,
    input_tokens integer DEFAULT 0 NOT NULL,
    output_tokens integer DEFAULT 0 NOT NULL,
    cache_read_input_tokens integer DEFAULT 0 NOT NULL,
    cache_write_input_tokens integer DEFAULT 0 NOT NULL,
    duration_ms integer DEFAULT 0 NOT NULL,
    called_at timestamp with time zone DEFAULT now() NOT NULL
);

-- Constraints for llm_calls
ALTER TABLE llm_calls OWNER TO postgres;
ALTER TABLE ONLY llm_calls
    ADD CONSTRAINT llm_calls_pkey PRIMARY KEY (id);

-- Indexes for llm_calls
CREATE INDEX ix_llm_calls_called_at ON llm_calls USING btree (called_at);
CREATE INDEX ix_llm_calls_dataset ON llm_calls USING btree (dataset_id);
CREATE INDEX ix_llm_calls_user_purpose ON llm_calls USING btree (user_id, purpose);
CREATE INDEX ix_llm_calls_workflow_run ON llm_calls USING btree (workflow_run_id);


-- Table: run_stats
CREATE TABLE run_stats (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    workflow_run_id character varying(255) NOT NULL,
    dataset_id uuid NOT NULL,
    user_id character varying(64) NOT NULL,
    started_at timestamp with time zone NOT NULL,
    finished_at timestamp with time zone NOT NULL,
    duration_ms integer DEFAULT 0 NOT NULL,
    search_calls integer DEFAULT 0 NOT NULL,
    fetch_calls integer DEFAULT 0 NOT NULL,
    investigate_calls integer DEFAULT 0 NOT NULL,
    rows_inserted integer DEFAULT 0 NOT NULL,
    rows_updated integer DEFAULT 0 NOT NULL,
    tokens_input integer DEFAULT 0 NOT NULL,
    tokens_output integer DEFAULT 0 NOT NULL,
    orchestrator_tokens_input integer DEFAULT 0 NOT NULL,
    orchestrator_tokens_output integer DEFAULT 0 NOT NULL,
    orchestrator_steps integer DEFAULT 0 NOT NULL,
    investigate_tokens_input integer DEFAULT 0 NOT NULL,
    investigate_tokens_output integer DEFAULT 0 NOT NULL,
    investigate_steps integer DEFAULT 0 NOT NULL,
    investigate_runs integer DEFAULT 0 NOT NULL,
    status character varying(16) DEFAULT 'success'::character varying NOT NULL,
    error text,
    is_benchmark boolean DEFAULT false NOT NULL,
    workflow_type character varying(16) DEFAULT 'populate'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

-- Constraints for run_stats
ALTER TABLE run_stats OWNER TO postgres;
ALTER TABLE ONLY run_stats
    ADD CONSTRAINT run_stats_pkey PRIMARY KEY (id);

-- Indexes for run_stats
CREATE INDEX ix_run_stats_dataset_id ON run_stats USING btree (dataset_id);
CREATE INDEX ix_run_stats_user_id ON run_stats USING btree (user_id);
CREATE INDEX ix_run_stats_workflow_run_id ON run_stats USING btree (workflow_run_id);


-- Table: usage
CREATE TABLE usage (
    user_id character varying(64) NOT NULL,
    rows_consumed integer DEFAULT 0 NOT NULL,
    period_start timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

-- Constraints for usage
ALTER TABLE usage OWNER TO postgres;
ALTER TABLE ONLY usage
    ADD CONSTRAINT usage_pkey PRIMARY KEY (user_id);


-- ====================================================================
-- SCHEMA COMPLETE
-- Total tables: 101 (88 from dev + 13 from staging)
-- ====================================================================