# Python-Based Data Migration (No dblink)

## Overview

This Python script migrates data directly from staging to dev databases without requiring the PostgreSQL dblink extension.

## Features

✅ **No dblink required** - Direct Python connections to both databases  
✅ **Real-time progress** - See rows/sec speed for each table  
✅ **Batch processing** - Efficient bulk inserts  
✅ **Error resilient** - Continues on table failures  
✅ **Flexible** - Migrate all or specific tables  
✅ **Dry run mode** - Preview before migrating  

---

## Quick Start

### Complete Migration (Recommended)

```bash
cd migration
chmod +x run_migration.sh
./run_migration.sh
```

This runs the complete migration:
1. Tests connections
2. Creates schema (if needed)
3. Migrates all data
4. Resets sequences
5. Drops FK constraints
6. Verifies data

---

## Python Script Usage

### Basic Usage

```bash
# Dry run (preview)
python3 migrate_data_python.py --dry-run

# Migrate all 93 tables
python3 migrate_data_python.py

# Migrate specific tables
python3 migrate_data_python.py --tables users,jobs,organisations

# Custom batch size
python3 migrate_data_python.py --batch-size 500
```

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--tables` | Comma-separated list of tables | All 93 tables |
| `--batch-size` | Rows per insert batch | 1000 |
| `--dry-run` | Preview without copying | False |
| `--skip-empty` | Skip empty tables | True |

---

## Output Example

```
======================================================================
DATA MIGRATION - STAGING TO DEV
======================================================================

[2026-10-21 10:15:30] INFO: Tables to migrate: 93
[2026-10-21 10:15:30] INFO: Batch size: 1,000
[2026-10-21 10:15:31] SUCCESS: ✓ Connected to staging
[2026-10-21 10:15:31] SUCCESS: ✓ Connected to dev

======================================================================
MIGRATING TABLES
======================================================================

[1/93] users
----------------------------------------------------------------------
[2026-10-21 10:15:32] INFO: Migrating users: 3,420 rows
  Progress: 3,420/3,420 (100.0%)
[2026-10-21 10:15:34] SUCCESS:   ✓ Migrated 3,420 rows in 2.3s (1,487 rows/sec)

[2/93] organisations
----------------------------------------------------------------------
[2026-10-21 10:15:34] INFO: Migrating organisations: 1,250 rows
  Progress: 1,250/1,250 (100.0%)
[2026-10-21 10:15:35] SUCCESS:   ✓ Migrated 1,250 rows in 0.8s (1,563 rows/sec)

...

======================================================================
MIGRATION SUMMARY
======================================================================

[2026-10-21 10:45:15] INFO: Total time: 1,785.3s (29.8 minutes)
[2026-10-21 10:45:15] INFO: Tables processed: 93
[2026-10-21 10:45:15] SUCCESS: Successful: 93
[2026-10-21 10:45:15] INFO: Failed: 0
[2026-10-21 10:45:15] INFO: Total rows found: 1,245,678
[2026-10-21 10:45:15] SUCCESS: Rows migrated: 1,245,678

======================================================================

[2026-10-21 10:45:15] SUCCESS: Migration complete! Run validation to verify data.
```

---

## Time Estimates

| Database Size | Rows | Estimated Time |
|---------------|------|----------------|
| Small | < 1M | 5-15 minutes |
| Medium | 1M - 10M | 15-60 minutes |
| Large | 10M+ | 1-3 hours |

**Speed:** ~1,000-2,000 rows/second per table

---

## How It Works

1. **Connects** to both staging and dev databases using psycopg2
2. **Reads** data from `staging.table_name` 
3. **Writes** to `public.table_name` in batches
4. **Handles** column mismatches (uses common columns only)
5. **Reports** progress and errors per table

---

## Requirements

- Python 3.7+
- psycopg2-binary (installed via requirements.txt)
- python-dotenv (installed via requirements.txt)
- Network access to both databases

---

## Configuration

Uses `.env` file for database connections:

```env
STAGING_HOST=your-staging-host
STAGING_PORT=5432
STAGING_DB=staging_database
STAGING_USER=postgres
STAGING_PASSWORD=your-password
STAGING_SCHEMA=staging

DEV_HOST=your-dev-host
DEV_PORT=5432
DEV_DB=dev_database
DEV_USER=postgres
DEV_PASSWORD=your-password
DEV_SCHEMA=public
```

---

## Troubleshooting

### Connection Failed

```bash
# Test staging connection
psql -h $STAGING_HOST -U $STAGING_USER -d $STAGING_DB -c "SELECT 1;"

# Test dev connection
psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -c "SELECT 1;"
```

### Table Not Found

Make sure schema is created first:
```bash
psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -f scripts/02_setup_schema.sql
```

### Slow Performance

Try smaller batch size:
```bash
python3 migrate_data_python.py --batch-size 500
```

### Failed Tables

Check error messages and re-run for specific tables:
```bash
python3 migrate_data_python.py --tables failed_table1,failed_table2
```

---

## Advantages Over dblink

| Feature | Python Script | dblink |
|---------|---------------|--------|
| No extension needed | ✅ | ❌ |
| Real-time progress | ✅ | ❌ |
| Error handling | ✅ per table | ❌ all-or-nothing |
| Flexible batch size | ✅ | ❌ |
| Cross-version support | ✅ | ⚠️ limited |
| Easy debugging | ✅ | ❌ |

---

## Validation

After migration, verify data:

```bash
# Quick check
psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -f check_data_quick.sql

# Full validation (requires dblink OR manual comparison)
# Compare row counts manually
```

---

## Notes

- Tables are migrated sequentially (not parallel)
- Only common columns between staging and dev are migrated
- Empty tables are skipped automatically
- Transaction per table (failed table doesn't rollback others)
- Duplicate key errors are reported but don't stop migration

---

## Support

If you encounter issues:
1. Check `.env` configuration
2. Verify network connectivity to both databases
3. Ensure tables exist in dev (run schema scripts first)
4. Check Python logs for specific errors
5. Try dry run mode first: `--dry-run`
