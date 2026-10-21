# Database Migration Toolkit

Automated PostgreSQL database migration from staging schema to new dev server.

## 🎯 Purpose

Migrate 93 tables from staging schema to a new dev server with:
- ✅ All columns preserved
- ✅ All data including orphaned records
- ✅ 13 additional staging-only tables
- ✅ Automated Python script
- ❌ 2 FK constraints dropped (intentionally)

---

## 📁 Project Structure

```
Ripent/
└── migration/
    ├── migrate.py                 # Main automation script
    ├── .env.example              # Configuration template
    ├── requirements.txt          # Python dependencies
    ├── README.md                 # Detailed documentation
    ├── QUICKSTART.md             # 5-minute setup guide
    ├── EXECUTION_CHECKLIST.md    # Printable checklist
    ├── new_server_schema_combined.sql  # Complete schema (101 tables)
    └── scripts/
        ├── 02_setup_schema.sql
        ├── 02b_add_missing_columns.sql
        ├── 03_migrate_data.sql
        ├── 04_reset_sequences.sql
        ├── 05_post_validation.sql
        ├── 06_drop_fk_constraints.sql
        └── 07_data_validation.sql
```

---

## 🚀 Quick Start

```bash
cd migration

# 1. Install dependencies
pip install -r requirements.txt

# 2. Configure .env
cp .env.example .env
# Edit .env with your staging and dev endpoints

# 3. Test (dry run)
python migrate.py --dry-run

# 4. Run migration
python migrate.py
```

---

## ✨ Features

- 🐍 **Python automation** - Fully automated 10-step migration
- 📊 **Progress tracking** - Real-time progress and timing
- 🔄 **Resume support** - Continue from any step
- 🧪 **Dry run mode** - Test without making changes
- 💾 **Auto backup** - Creates staging backup before migration
- ✅ **Data validation** - Compares row counts after migration
- 🎨 **Colored output** - Easy to read logs

---

## 📋 Migration Steps

The script automatically runs these steps:

0. **Backup** - Create staging database backup
1. **Test connections** - Verify connectivity
2. **Setup schema** - Create 101 tables
3. **Add columns** - Add 10 missing columns
4. **Migrate extra tables** - Copy 13 staging-only tables
5. **Migrate main tables** - Copy remaining 80 tables
6. **Reset sequences** - Update sequence values
7. **Post-validation** - Run validation checks
8. **Drop FK constraints** - Remove 2 constraints
9. **Data validation** - Compare row counts

---

## 📖 Documentation

- **[migration/README.md](migration/README.md)** - Complete documentation
- **[migration/QUICKSTART.md](migration/QUICKSTART.md)** - Quick setup guide
- **[migration/EXECUTION_CHECKLIST.md](migration/EXECUTION_CHECKLIST.md)** - Step-by-step checklist

---

## 🔧 Requirements

- Python 3.7+
- PostgreSQL client tools (psql, pg_dump)
- Network access to both staging and dev servers
- Python packages: `python-dotenv`, `psycopg2-binary`

---

## ⚙️ Configuration

Edit `.env` with your database endpoints:

```env
# Staging (source)
STAGING_HOST=your-staging-host.com
STAGING_DB=staging_database
STAGING_USER=postgres
STAGING_PASSWORD=your-password

# Dev (target - new server)
DEV_HOST=your-new-dev-host.com
DEV_DB=dev_database
DEV_USER=postgres
DEV_PASSWORD=your-password
```

---

## 📊 What Gets Migrated

| Item | Count | Notes |
|------|-------|-------|
| Total tables | 101 | 88 dev + 13 staging-only |
| Migrated tables | 93 | All data preserved |
| Dev-only tables | 8 | Remain empty |
| Missing columns | 10 | Added automatically |
| Dropped FK constraints | 2 | Allows orphaned data |
| Orphaned records | ~156 | Intentionally kept |

---

## ⏱️ Timeline

| Phase | Duration |
|-------|----------|
| Setup | 5 min |
| Backup | 10-30 min |
| Migration | 30-120 min |
| Validation | 5-10 min |
| **Total** | **1-3 hours** |

---

## 📝 Usage Examples

```bash
# Full migration
python migrate.py

# Dry run (test without changes)
python migrate.py --dry-run

# Run specific step
python migrate.py --step 5

# Continue from step 5
python migrate.py --from-step 5

# Validate only
python migrate.py --validate-only

# Show help
python migrate.py --help
```

---

## ✅ Success Criteria

After migration:
- ✓ 93 tables show "✓ MATCH" in validation
- ✓ 8 dev-only tables are empty
- ✓ ~156 orphaned enrollments exist (expected)
- ✓ Total row difference: 0

---

## 🛠️ Troubleshooting

### Connection fails
```bash
# Test connections
psql -h $STAGING_HOST -U $STAGING_USER -d $STAGING_DB -c "SELECT 1;"
psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -c "SELECT 1;"
```

### Migration interrupted
```bash
# Continue from step N
python migrate.py --from-step 5
```

### Need to re-validate
```bash
python migrate.py --validate-only
```

---

## 📄 License

MIT License - Feel free to use and modify for your needs.

---

## 🤝 Contributing

Issues and pull requests are welcome!

---

## 📧 Support

For questions or issues, please open a GitHub issue.

---

**Ready to migrate?** Start with: `cd migration && python migrate.py --dry-run`
