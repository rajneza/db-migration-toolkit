# Migration Execution Checklist

## Pre-Migration

- [ ] Configure `.env` with connection details
- [ ] Test connectivity to staging and dev
- [ ] Backup staging database
- [ ] Verify backup file size and integrity
- [ ] Get downtime approval (if needed)

---

## Execution (Run in order)

### 1. Schema Setup
```bash
psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -f scripts/02_setup_schema.sql
```
**Expected:** 101+ tables created

---

### 2. Add Missing Columns
```bash
psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -f scripts/02b_add_missing_columns.sql
```
**Expected:** 10 columns added to 3 tables

---

### 3. Migrate 13 Extra Tables (Option B)
```bash
pg_dump -h $STAGING_HOST -U $STAGING_USER -d $STAGING_DB \
  -t staging.datasets -t staging.dataset_rows -t staging.dataset_history \
  -t staging.outreach_sequences -t staging.outreach_enrollments \
  -t staging.outreach_steps -t staging.outreach_reply_log \
  -t staging.vault_documents -t staging.vault_chunks \
  -t staging.sequence_replies -t staging.llm_calls \
  -t staging.run_stats -t staging.usage \
  --data-only --no-owner \
  | sed 's/staging\./public./g' \
  | psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB
```
**Expected:** Data copied for 13 tables

---

### 4. Migrate Remaining 80 Tables
```bash
psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -f scripts/03_migrate_data.sql
```
**Expected:** 80 tables migrated

---

### 5. Reset Sequences
```bash
psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -f scripts/04_reset_sequences.sql
```
**Expected:** Sequences updated

---

### 6. Post-Validation
```bash
psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -f scripts/05_post_validation.sql
```
**Expected:** No FAIL messages

---

### 7. Drop FK Constraints
```bash
psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -f scripts/06_drop_fk_constraints.sql
```
**Expected:** 2 FKs dropped

---

### 8. Final Validation
```bash
psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -f scripts/07_data_validation.sql
```
**Expected:** 93 tables match, 8 empty, ~156 orphans

---

## Post-Migration

- [ ] All 93 tables show "✓ MATCH"
- [ ] 8 dev-only tables are empty
- [ ] ~156 orphaned enrollments exist
- [ ] Application smoke test passed
- [ ] DNS/routing updated to new server
- [ ] Monitor application logs
- [ ] Keep staging backup for 30 days

---

## Quick Checks

```bash
# Table count (should be 101)
psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -c \
  "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';"

# Row count for key tables
psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -c \
  "SELECT 
    'organisations' as table, COUNT(*) FROM organisations
    UNION ALL SELECT 'users', COUNT(*) FROM users
    UNION ALL SELECT 'jobs', COUNT(*) FROM jobs;"

# Orphaned data (should be ~90 and ~66)
psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -c \
  "SELECT 
    (SELECT COUNT(*) FROM sequence_enrollments 
     WHERE job_id NOT IN (SELECT id FROM jobs)) as orphaned_by_job,
    (SELECT COUNT(*) FROM sequence_enrollments 
     WHERE user_id NOT IN (SELECT id FROM users)) as orphaned_by_user;"
```

---

## Timeline Estimate

| Step | Time | Notes |
|------|------|-------|
| Backup | 10-30 min | Depends on DB size |
| Schema setup | 2-5 min | Quick |
| Data migration | 30-120 min | Depends on data volume |
| Validation | 5-10 min | Quick checks |
| **Total** | **1-3 hours** | Plus testing |

---

## Rollback Plan

If migration fails:

1. **Stop immediately** - Don't continue with remaining steps
2. **Keep staging untouched** - All data still there
3. **Drop dev database** - Start fresh if needed
4. **Review errors** - Check logs and fix scripts
5. **Retry** - Run from step 1

---

## Support Contacts

- DBA: _________________
- Dev Lead: _________________
- On-Call: _________________

---

**Execution Date:** __________  
**Executed By:** __________  
**Sign-off:** __________
