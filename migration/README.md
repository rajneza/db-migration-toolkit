# Database Migration

Migrate staging → new dev server (93 tables, all columns preserved, 2 FK constraints dropped).

---

## 🐍 Automated Python Migration (Recommended)

### Quick Start

```bash
# 1. Install dependencies
pip install -r requirements.txt

# 2. Configure .env file
cp .env.example .env
nano .env  # Edit with your database details

# 3. Test connection (dry run)
python migrate.py --dry-run

# 4. Run migration
python migrate.py

# 5. Validate only (after migration)
python migrate.py --validate-only
```

### Python Script Features

✅ **Automated**: Runs all 10 steps automatically  
✅ **Progress tracking**: Shows timing for each step  
✅ **Error handling**: Stops on first failure  
✅ **Dry run**: Test without making changes  
✅ **Resume**: Continue from any step  
✅ **Validation**: Built-in data validation  

### Python Script Usage

```bash
# Full migration
python migrate.py

# Dry run (preview)
python migrate.py --dry-run

# Run specific step
python migrate.py --step 5

# Continue from step N
python migrate.py --from-step 5

# Validate only
python migrate.py --validate-only

# Help
python migrate.py --help
```

### Steps (Automated)

0. Backup staging database
1. Test connections
2. Setup schema (101 tables)
3. Add missing columns
4. Migrate 13 extra tables
5. Migrate 80 main tables
6. Reset sequences
7. Post-validation
8. Drop FK constraints
9. Data validation

---

## 📋 Manual SQL Execution (Alternative)

If you prefer manual execution, follow these steps:

---

## 🚀 Step-by-Step Execution

### Step 1: Configure Connection

```bash
# Copy and edit connection details
cp .env.example .env
nano .env  # or your editor

# Fill in:
STAGING_HOST=your-staging-host
STAGING_PORT=5432
STAGING_DB=your-staging-database
STAGING_USER=your-staging-user
STAGING_PASSWORD=your-staging-password

DEV_HOST=your-new-dev-host
DEV_PORT=5432
DEV_DB=your-new-dev-database
DEV_USER=your-new-dev-user
DEV_PASSWORD=your-new-dev-password
```

### Step 2: Backup Staging (CRITICAL!)

```bash
# Create full backup
pg_dump -h $STAGING_HOST -U $STAGING_USER -d $STAGING_DB \
  -Fc -f staging_backup_$(date +%Y%m%d_%H%M%S).dump

# Verify backup was created
ls -lh staging_backup_*.dump
```

### Step 3: Create Schema on New Server

```bash
# Creates all 101 tables (88 dev + 13 staging)
psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -f scripts/02_setup_schema.sql

# Check: Should show 101+ tables created
# Look for "✓ Expected 101+ tables" in output
```

### Step 4: Add Missing Columns

```bash
# Adds 10 columns to 3 tables
psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -f scripts/02b_add_missing_columns.sql

# Check: Should show columns added successfully
```

### Step 5: Migrate Data

⚠️ **IMPORTANT**: `03_migrate_data.sql` needs to be updated first!

**Option A - Manual Update** (Add 13 tables to script)
```bash
# Edit the script and add migrations for:
# datasets, dataset_rows, dataset_history
# outreach_sequences, outreach_enrollments, outreach_steps, outreach_reply_log
# vault_documents, vault_chunks
# sequence_replies, llm_calls, run_stats, usage

# Then run:
psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -f scripts/03_migrate_data.sql
```

**Option B - Simple Copy** (If tables are small)
```bash
# Use pg_dump + psql for 13 tables
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

# Then run main migration for 80 tables
psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -f scripts/03_migrate_data.sql
```

### Step 6: Reset Sequences

```bash
# Reset all sequence values to MAX(id) + 1
psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -f scripts/04_reset_sequences.sql

# Check: Should show sequences updated
```

### Step 7: Post-Migration Validation

```bash
# Run basic validation checks
psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -f scripts/05_post_validation.sql

# Check: Look for any FAIL messages
```

### Step 8: Drop FK Constraints

```bash
# Drop 2 FK constraints (allows orphaned data)
psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -f scripts/06_drop_fk_constraints.sql

# Check: Should show "FK constraint dropped" messages
```

### Step 9: Validate Data Match

```bash
# Compare row counts between staging and dev
psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -f scripts/07_data_validation.sql

# Check output:
# - All tables should show "✓ MATCH"
# - Orphaned data: ~156 total (expected)
```

---

## ✅ Success Criteria

After Step 9, you should see:

- ✓ **93 tables** with matching row counts
- ✓ **8 dev-only tables** are empty
- ✓ **~156 orphaned enrollments** exist (90 job_id + 66 user_id)
- ✓ **Total difference: 0** in summary

---

## 🔍 Quick Validation Commands

```bash
# Check table count
psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -c \
  "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';"
# Expected: 101

# Check total rows in key tables
psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -c \
  "SELECT 
    (SELECT COUNT(*) FROM organisations) as orgs,
    (SELECT COUNT(*) FROM users) as users,
    (SELECT COUNT(*) FROM jobs) as jobs,
    (SELECT COUNT(*) FROM sequence_enrollments) as enrollments;"

# Check orphaned data
psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -c \
  "SELECT 
    (SELECT COUNT(*) FROM sequence_enrollments WHERE job_id NOT IN (SELECT id FROM jobs)) as orphaned_jobs,
    (SELECT COUNT(*) FROM sequence_enrollments WHERE user_id NOT IN (SELECT id FROM users)) as orphaned_users;"
# Expected: ~90 and ~66
```

---

## 📋 Troubleshooting

### Migration fails at Step 5
- Check dblink extension is installed
- Verify staging connection string in script
- Check network connectivity to staging

### Row counts don't match
- Re-run migration for mismatched tables
- Check for errors in migration logs
- Verify no writes happened to staging during migration

### Orphaned data count is different
- This is OK if counts are close (±10)
- Data may have changed during migration
- Verify FKs were dropped successfully

---

## Files

```
migration/
├── README.md                          ← This file
├── .env.example                       ← Connection config
├── new_server_schema_combined.sql     ← Complete schema (101 tables)
└── scripts/
    ├── 02_setup_schema.sql            ← Create tables
    ├── 02b_add_missing_columns.sql    ← Add 10 columns
    ├── 03_migrate_data.sql            ← Migrate data (⚠️ needs update)
    ├── 04_reset_sequences.sql         ← Reset sequences
    ├── 05_post_validation.sql         ← Validate
    ├── 06_drop_fk_constraints.sql     ← Drop 2 FKs
    └── 07_data_validation.sql         ← Validate row counts
```

## Key Points

- **Tables**: 93 staging → 101 dev (88 dev + 13 from staging)
- **Columns**: All preserved (no data loss)
- **FK Constraints**: 2 dropped after migration (allows 156 orphaned enrollments)
- **Orphaned data**: 90 job_id + 66 user_id (intentional)

## Configuration

Copy `.env.example` to `.env` and fill in connection details.

## Notes

- `03_migrate_data.sql` needs update to include 13 additional tables
- `07_data_validation.sql` compares row counts between staging and dev
- Application must handle orphaned sequence_enrollments gracefully

## Validation Details

The validation script checks:
- **Row counts**: Compares all 93 migrated tables
- **Match percentage**: Shows % of data migrated successfully
- **Dev-only tables**: Confirms 8 tables are empty
- **Orphaned data**: Verifies expected orphans exist (~156)

Expected results:
- ✓ 93 tables match row counts
- ✓ 8 dev-only tables are empty
- ✓ ~156 orphaned enrollments (intentional)
