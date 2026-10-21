# 🚀 Quick Start Guide

Get your migration running in 5 minutes!

---

## Prerequisites

- Python 3.7+
- PostgreSQL client tools (psql, pg_dump)
- Network access to both staging and dev servers

---

## Installation

```bash
# Navigate to migration folder
cd migration

# Install Python dependencies
pip install -r requirements.txt
```

---

## Configuration

### 1. Copy example config

```bash
cp .env.example .env
```

### 2. Edit .env with your database details

```env
# Staging (Source)
STAGING_HOST=your-staging-host.com
STAGING_PORT=5432
STAGING_DB=staging_database
STAGING_USER=postgres
STAGING_PASSWORD=your-password
STAGING_SCHEMA=staging

# Dev (Target - New Server)
DEV_HOST=your-new-dev-host.com
DEV_PORT=5432
DEV_DB=dev_database
DEV_USER=postgres
DEV_PASSWORD=your-password
DEV_SCHEMA=public
```

---

## Execution

### Option 1: Python Script (Recommended) ⭐

```bash
# Test first (dry run - no changes made)
python migrate.py --dry-run

# Run full migration
python migrate.py
```

**That's it!** The script will:
- Create backup
- Test connections
- Create schema
- Migrate all data
- Validate everything

### Option 2: Manual SQL Execution

```bash
# 1. Backup
pg_dump -h $STAGING_HOST -U $STAGING_USER -d $STAGING_DB -Fc > backup.dump

# 2. Run scripts in order
psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -f scripts/02_setup_schema.sql
psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -f scripts/02b_add_missing_columns.sql
# ... continue with remaining scripts
```

---

## Validation

After migration completes, verify success:

```bash
# Using Python
python migrate.py --validate-only

# Or manually
psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -f scripts/07_data_validation.sql
```

### Success Criteria

✅ All 93 tables show "✓ MATCH"  
✅ 8 dev-only tables are empty  
✅ ~156 orphaned enrollments (expected)  
✅ Total difference: 0  

---

## Troubleshooting

### Connection fails

```bash
# Test staging connection
psql -h $STAGING_HOST -U $STAGING_USER -d $STAGING_DB -c "SELECT 1;"

# Test dev connection
psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -c "SELECT 1;"
```

### Migration fails mid-way

```bash
# Continue from step N
python migrate.py --from-step 5
```

### Need to re-run validation

```bash
python migrate.py --validate-only
```

---

## Timeline

| Phase | Time |
|-------|------|
| Setup | 5 min |
| Backup | 10-30 min |
| Migration | 30-120 min |
| Validation | 5-10 min |
| **Total** | **1-3 hours** |

---

## What Gets Migrated?

✅ **93 tables** from staging → dev  
✅ **All columns** preserved  
✅ **All data** including orphaned records  
✅ **101 tables** total (88 dev + 13 staging-only)  

❌ **2 FK constraints** dropped (allows orphans)  
❌ **8 dev-only tables** remain empty  

---

## Support

Need help? Check:
- `README.md` - Full documentation
- `EXECUTION_CHECKLIST.md` - Step-by-step checklist
- `migrate.py --help` - Script usage

---

## Example Session

```bash
$ python migrate.py --dry-run
[2024-01-15 10:30:00] INFO: DRY RUN MODE
[2024-01-15 10:30:01] STEP: STEP 0: Backup Staging Database
[2024-01-15 10:30:01] INFO: Would create backup...
...
[2024-01-15 10:30:10] SUCCESS: All steps would succeed

$ python migrate.py
[2024-01-15 10:35:00] INFO: Starting migration
[2024-01-15 10:35:00] STEP: STEP 0: Backup Staging Database
[2024-01-15 10:35:00] INFO: Creating backup...
[2024-01-15 10:40:30] SUCCESS: ✓ Step 0 completed in 330.2s
...
[2024-01-15 12:15:45] SUCCESS: MIGRATION COMPLETED SUCCESSFULLY!
[2024-01-15 12:15:45] INFO: Total time: 6045.3s (100.8 minutes)
```

---

**Ready to migrate? Start with:** `python migrate.py --dry-run`
