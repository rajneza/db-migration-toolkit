#!/usr/bin/env python3
"""
Database Migration Script
=========================
Automates migration from staging schema to new dev server.

Usage:
    python migrate.py                    # Run full migration
    python migrate.py --step 3           # Run specific step
    python migrate.py --validate-only    # Only run validation
    python migrate.py --dry-run          # Show what would be done
"""

import os
import sys
import subprocess
import time
from pathlib import Path
from datetime import datetime
from typing import Optional, Tuple
from dotenv import load_dotenv

# ============================================================================
# Configuration
# ============================================================================

class Config:
    """Migration configuration from .env file"""
    
    def __init__(self):
        load_dotenv()
        
        # Staging (source)
        self.staging_host = os.getenv('STAGING_HOST')
        self.staging_port = os.getenv('STAGING_PORT', '5432')
        self.staging_db = os.getenv('STAGING_DB')
        self.staging_user = os.getenv('STAGING_USER')
        self.staging_password = os.getenv('STAGING_PASSWORD')
        self.staging_schema = os.getenv('STAGING_SCHEMA', 'staging')
        
        # Dev (target)
        self.dev_host = os.getenv('DEV_HOST')
        self.dev_port = os.getenv('DEV_PORT', '5432')
        self.dev_db = os.getenv('DEV_DB')
        self.dev_user = os.getenv('DEV_USER')
        self.dev_password = os.getenv('DEV_PASSWORD')
        self.dev_schema = os.getenv('DEV_SCHEMA', 'public')
        
        # Options
        self.create_backup = os.getenv('CREATE_BACKUP', 'true').lower() == 'true'
        self.backup_dir = Path(os.getenv('BACKUP_DIR', './backups'))
        self.skip_validation = os.getenv('SKIP_VALIDATION', 'false').lower() == 'true'
        self.verbose = os.getenv('VERBOSE', 'true').lower() == 'true'
        
    def validate(self) -> Tuple[bool, str]:
        """Validate configuration"""
        required = [
            ('STAGING_HOST', self.staging_host),
            ('STAGING_DB', self.staging_db),
            ('STAGING_USER', self.staging_user),
            ('STAGING_PASSWORD', self.staging_password),
            ('DEV_HOST', self.dev_host),
            ('DEV_DB', self.dev_db),
            ('DEV_USER', self.dev_user),
            ('DEV_PASSWORD', self.dev_password),
        ]
        
        missing = [name for name, value in required if not value]
        if missing:
            return False, f"Missing required config: {', '.join(missing)}"
        
        return True, "Configuration valid"
    
    @property
    def staging_connstr(self) -> str:
        """PostgreSQL connection string for staging"""
        return f"postgresql://{self.staging_user}:{self.staging_password}@{self.staging_host}:{self.staging_port}/{self.staging_db}"
    
    @property
    def dev_connstr(self) -> str:
        """PostgreSQL connection string for dev"""
        return f"postgresql://{self.dev_user}:{self.dev_password}@{self.dev_host}:{self.dev_port}/{self.dev_db}"
    
    @property
    def staging_psql_env(self) -> dict:
        """Environment variables for psql (staging)"""
        return {
            'PGHOST': self.staging_host,
            'PGPORT': self.staging_port,
            'PGDATABASE': self.staging_db,
            'PGUSER': self.staging_user,
            'PGPASSWORD': self.staging_password,
        }
    
    @property
    def dev_psql_env(self) -> dict:
        """Environment variables for psql (dev)"""
        return {
            'PGHOST': self.dev_host,
            'PGPORT': self.dev_port,
            'PGDATABASE': self.dev_db,
            'PGUSER': self.dev_user,
            'PGPASSWORD': self.dev_password,
        }


# ============================================================================
# Utilities
# ============================================================================

class Colors:
    """ANSI color codes"""
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
    END = '\033[0m'


def log(message: str, level: str = 'INFO'):
    """Colored logging"""
    colors = {
        'INFO': Colors.CYAN,
        'SUCCESS': Colors.GREEN,
        'WARNING': Colors.YELLOW,
        'ERROR': Colors.RED,
        'STEP': Colors.BOLD + Colors.BLUE,
    }
    color = colors.get(level, '')
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    print(f"{color}[{timestamp}] {level}: {message}{Colors.END}")


def run_psql(config: Config, sql_file: Path, target: str = 'dev', dry_run: bool = False) -> Tuple[bool, str]:
    """Execute SQL file using psql"""
    if not sql_file.exists():
        return False, f"SQL file not found: {sql_file}"
    
    env = config.dev_psql_env if target == 'dev' else config.staging_psql_env
    env_copy = os.environ.copy()
    env_copy.update(env)
    
    cmd = ['psql', '-f', str(sql_file)]
    
    if dry_run:
        log(f"DRY RUN: Would execute {sql_file.name} on {target}", 'INFO')
        return True, "Dry run - not executed"
    
    log(f"Executing {sql_file.name} on {target} database...", 'INFO')
    
    try:
        result = subprocess.run(
            cmd,
            env=env_copy,
            capture_output=True,
            text=True,
            timeout=3600  # 1 hour timeout
        )
        
        if result.returncode == 0:
            if config.verbose and result.stdout:
                print(result.stdout)
            return True, result.stdout
        else:
            log(f"Error output:\n{result.stderr}", 'ERROR')
            return False, result.stderr
            
    except subprocess.TimeoutExpired:
        return False, "Command timed out after 1 hour"
    except Exception as e:
        return False, str(e)


def run_command(cmd: list, env: dict = None, dry_run: bool = False) -> Tuple[bool, str]:
    """Run shell command"""
    if dry_run:
        log(f"DRY RUN: Would run: {' '.join(cmd)}", 'INFO')
        return True, "Dry run - not executed"
    
    env_copy = os.environ.copy()
    if env:
        env_copy.update(env)
    
    try:
        result = subprocess.run(
            cmd,
            env=env_copy,
            capture_output=True,
            text=True,
            timeout=3600
        )
        return result.returncode == 0, result.stdout if result.returncode == 0 else result.stderr
    except Exception as e:
        return False, str(e)


def test_connection(config: Config, target: str = 'dev') -> bool:
    """Test database connection"""
    env = config.dev_psql_env if target == 'dev' else config.staging_psql_env
    env_copy = os.environ.copy()
    env_copy.update(env)
    
    cmd = ['psql', '-c', 'SELECT 1;']
    
    try:
        result = subprocess.run(cmd, env=env_copy, capture_output=True, timeout=10)
        return result.returncode == 0
    except:
        return False


# ============================================================================
# Migration Steps
# ============================================================================

class MigrationStep:
    """Base class for migration steps"""
    
    def __init__(self, number: int, name: str, description: str):
        self.number = number
        self.name = name
        self.description = description
        self.start_time = None
        self.end_time = None
    
    def execute(self, config: Config, dry_run: bool = False) -> bool:
        """Execute the step"""
        raise NotImplementedError
    
    def duration(self) -> Optional[float]:
        """Get step duration in seconds"""
        if self.start_time and self.end_time:
            return self.end_time - self.start_time
        return None
    
    def print_header(self):
        """Print step header"""
        print("\n" + "="*70)
        log(f"STEP {self.number}: {self.name}", 'STEP')
        log(self.description, 'INFO')
        print("="*70 + "\n")
    
    def run(self, config: Config, dry_run: bool = False) -> bool:
        """Run the step with timing"""
        self.print_header()
        self.start_time = time.time()
        
        success = self.execute(config, dry_run)
        
        self.end_time = time.time()
        duration = self.duration()
        
        if success:
            log(f"✓ Step {self.number} completed in {duration:.1f}s", 'SUCCESS')
        else:
            log(f"✗ Step {self.number} failed after {duration:.1f}s", 'ERROR')
        
        return success


class Step0_Backup(MigrationStep):
    """Create backup of staging database"""
    
    def __init__(self):
        super().__init__(
            0,
            "Backup Staging Database",
            "Create full backup before migration"
        )
    
    def execute(self, config: Config, dry_run: bool = False) -> bool:
        if not config.create_backup:
            log("Backup disabled in config - SKIPPING", 'WARNING')
            return True
        
        # Create backup directory
        config.backup_dir.mkdir(parents=True, exist_ok=True)
        
        # Generate backup filename
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        backup_file = config.backup_dir / f"staging_backup_{timestamp}.dump"
        
        log(f"Creating backup: {backup_file}", 'INFO')
        
        cmd = [
            'pg_dump',
            '-h', config.staging_host,
            '-p', config.staging_port,
            '-U', config.staging_user,
            '-d', config.staging_db,
            '-Fc',  # Custom format
            '-f', str(backup_file)
        ]
        
        success, output = run_command(cmd, config.staging_psql_env, dry_run)
        
        if success and not dry_run:
            size_mb = backup_file.stat().st_size / (1024 * 1024)
            log(f"Backup created: {backup_file.name} ({size_mb:.1f} MB)", 'SUCCESS')
        
        return success


class Step1_TestConnections(MigrationStep):
    """Test database connections"""
    
    def __init__(self):
        super().__init__(
            1,
            "Test Database Connections",
            "Verify connectivity to staging and dev databases"
        )
    
    def execute(self, config: Config, dry_run: bool = False) -> bool:
        if dry_run:
            log("DRY RUN: Would test connections", 'INFO')
            return True
        
        log("Testing staging connection...", 'INFO')
        if not test_connection(config, 'staging'):
            log("✗ Cannot connect to staging database", 'ERROR')
            return False
        log("✓ Staging connection OK", 'SUCCESS')
        
        log("Testing dev connection...", 'INFO')
        if not test_connection(config, 'dev'):
            log("✗ Cannot connect to dev database", 'ERROR')
            return False
        log("✓ Dev connection OK", 'SUCCESS')
        
        return True


class Step2_SetupSchema(MigrationStep):
    """Create schema on dev server"""
    
    def __init__(self):
        super().__init__(
            2,
            "Setup Schema",
            "Create 101 tables on new dev server"
        )
    
    def execute(self, config: Config, dry_run: bool = False) -> bool:
        sql_file = Path('scripts/02_setup_schema.sql')
        success, output = run_psql(config, sql_file, 'dev', dry_run)
        return success


class Step3_AddMissingColumns(MigrationStep):
    """Add missing columns"""
    
    def __init__(self):
        super().__init__(
            3,
            "Add Missing Columns",
            "Add 10 missing columns to 3 tables"
        )
    
    def execute(self, config: Config, dry_run: bool = False) -> bool:
        sql_file = Path('scripts/02b_add_missing_columns.sql')
        success, output = run_psql(config, sql_file, 'dev', dry_run)
        return success


class Step4_MigrateExtraTables(MigrationStep):
    """Migrate 13 staging-only tables"""
    
    def __init__(self):
        super().__init__(
            4,
            "Migrate Extra Tables",
            "Copy 13 staging-only tables using pg_dump"
        )
    
    def execute(self, config: Config, dry_run: bool = False) -> bool:
        tables = [
            'datasets', 'dataset_rows', 'dataset_history',
            'outreach_sequences', 'outreach_enrollments', 'outreach_steps', 'outreach_reply_log',
            'vault_documents', 'vault_chunks',
            'sequence_replies', 'llm_calls', 'run_stats', 'usage'
        ]
        
        log(f"Migrating {len(tables)} tables from staging schema...", 'INFO')
        
        if dry_run:
            log(f"DRY RUN: Would migrate {len(tables)} tables", 'INFO')
            return True
        
        # Build pg_dump command
        table_args = []
        for table in tables:
            table_args.extend(['-t', f'{config.staging_schema}.{table}'])
        
        dump_cmd = [
            'pg_dump',
            '-h', config.staging_host,
            '-p', config.staging_port,
            '-U', config.staging_user,
            '-d', config.staging_db,
            '--data-only',
            '--no-owner',
            '--inserts',  # Use INSERT statements for compatibility
        ] + table_args
        
        # Pipe to psql
        restore_cmd = [
            'psql',
            '-h', config.dev_host,
            '-p', config.dev_port,
            '-U', config.dev_user,
            '-d', config.dev_db,
        ]
        
        try:
            # Run pg_dump
            env_copy = os.environ.copy()
            env_copy.update(config.staging_psql_env)
            
            dump_proc = subprocess.Popen(
                dump_cmd,
                env=env_copy,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            
            # Pipe to psql
            env_copy.update(config.dev_psql_env)
            
            # Replace schema name in SQL
            import re
            sql_data = dump_proc.stdout.read()
            sql_data = re.sub(rf'\b{config.staging_schema}\.', f'{config.dev_schema}.', sql_data)
            
            restore_proc = subprocess.Popen(
                restore_cmd,
                env=env_copy,
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            
            stdout, stderr = restore_proc.communicate(input=sql_data)
            
            if restore_proc.returncode == 0:
                log(f"✓ Migrated {len(tables)} tables", 'SUCCESS')
                return True
            else:
                log(f"Error: {stderr}", 'ERROR')
                return False
                
        except Exception as e:
            log(f"Error during migration: {str(e)}", 'ERROR')
            return False


class Step5_MigrateMainTables(MigrationStep):
    """Migrate remaining 80 tables"""
    
    def __init__(self):
        super().__init__(
            5,
            "Migrate Main Tables",
            "Migrate remaining 80 tables using dblink"
        )
    
    def execute(self, config: Config, dry_run: bool = False) -> bool:
        # First, update the connection string in the SQL file
        sql_file = Path('scripts/03_migrate_data.sql')
        
        if not sql_file.exists():
            log(f"SQL file not found: {sql_file}", 'ERROR')
            return False
        
        # Read SQL file
        sql_content = sql_file.read_text()
        
        # Replace placeholder connection string
        staging_conn = f"hostaddr={config.staging_host} port={config.staging_port} dbname={config.staging_db} user={config.staging_user} password={config.staging_password}"
        
        sql_content = sql_content.replace(
            "hostaddr=STAGING_HOST port=5432 dbname=STAGING_DB user=STAGING_USER password=STAGING_PASSWORD",
            staging_conn
        )
        
        # Write temporary file
        temp_file = Path('scripts/03_migrate_data_temp.sql')
        temp_file.write_text(sql_content)
        
        try:
            success, output = run_psql(config, temp_file, 'dev', dry_run)
            return success
        finally:
            if temp_file.exists() and not dry_run:
                temp_file.unlink()


class Step6_ResetSequences(MigrationStep):
    """Reset PostgreSQL sequences"""
    
    def __init__(self):
        super().__init__(
            6,
            "Reset Sequences",
            "Update sequence values to MAX(id) + 1"
        )
    
    def execute(self, config: Config, dry_run: bool = False) -> bool:
        sql_file = Path('scripts/04_reset_sequences.sql')
        success, output = run_psql(config, sql_file, 'dev', dry_run)
        return success


class Step7_PostValidation(MigrationStep):
    """Run post-migration validation"""
    
    def __init__(self):
        super().__init__(
            7,
            "Post-Migration Validation",
            "Run validation checks"
        )
    
    def execute(self, config: Config, dry_run: bool = False) -> bool:
        sql_file = Path('scripts/05_post_validation.sql')
        success, output = run_psql(config, sql_file, 'dev', dry_run)
        return success


class Step8_DropFKConstraints(MigrationStep):
    """Drop FK constraints"""
    
    def __init__(self):
        super().__init__(
            8,
            "Drop FK Constraints",
            "Drop 2 FK constraints (allows orphaned data)"
        )
    
    def execute(self, config: Config, dry_run: bool = False) -> bool:
        sql_file = Path('scripts/06_drop_fk_constraints.sql')
        success, output = run_psql(config, sql_file, 'dev', dry_run)
        return success


class Step9_DataValidation(MigrationStep):
    """Validate data match"""
    
    def __init__(self):
        super().__init__(
            9,
            "Data Validation",
            "Compare row counts between staging and dev"
        )
    
    def execute(self, config: Config, dry_run: bool = False) -> bool:
        # Update connection string in validation file
        sql_file = Path('scripts/07_data_validation.sql')
        
        if not sql_file.exists():
            log(f"SQL file not found: {sql_file}", 'ERROR')
            return False
        
        sql_content = sql_file.read_text()
        
        # Replace placeholder
        staging_conn = f"hostaddr={config.staging_host} port={config.staging_port} dbname={config.staging_db} user={config.staging_user} password={config.staging_password}"
        
        sql_content = sql_content.replace(
            "hostaddr=STAGING_HOST port=5432 dbname=STAGING_DB user=STAGING_USER password=STAGING_PASSWORD",
            staging_conn
        )
        
        # Write temporary file
        temp_file = Path('scripts/07_data_validation_temp.sql')
        temp_file.write_text(sql_content)
        
        try:
            success, output = run_psql(config, temp_file, 'dev', dry_run)
            return success
        finally:
            if temp_file.exists() and not dry_run:
                temp_file.unlink()


# ============================================================================
# Main Migration Orchestrator
# ============================================================================

class Migration:
    """Migration orchestrator"""
    
    def __init__(self, config: Config):
        self.config = config
        self.steps = [
            Step0_Backup(),
            Step1_TestConnections(),
            Step2_SetupSchema(),
            Step3_AddMissingColumns(),
            Step4_MigrateExtraTables(),
            Step5_MigrateMainTables(),
            Step6_ResetSequences(),
            Step7_PostValidation(),
            Step8_DropFKConstraints(),
            Step9_DataValidation(),
        ]
    
    def run_all(self, dry_run: bool = False, start_step: int = 0) -> bool:
        """Run all migration steps"""
        start_time = time.time()
        
        print("\n" + "="*70)
        print(f"{Colors.BOLD}{Colors.CYAN}DATABASE MIGRATION{Colors.END}")
        print("="*70)
        print(f"Staging: {self.config.staging_host}/{self.config.staging_db}")
        print(f"Dev:     {self.config.dev_host}/{self.config.dev_db}")
        if dry_run:
            print(f"{Colors.YELLOW}MODE: DRY RUN (no changes will be made){Colors.END}")
        print("="*70 + "\n")
        
        # Run steps
        for step in self.steps:
            if step.number < start_step:
                log(f"Skipping step {step.number}", 'INFO')
                continue
            
            success = step.run(self.config, dry_run)
            
            if not success:
                log(f"Migration failed at step {step.number}", 'ERROR')
                return False
            
            # Pause between steps
            if not dry_run and step.number < len(self.steps) - 1:
                time.sleep(1)
        
        # Summary
        total_time = time.time() - start_time
        print("\n" + "="*70)
        log("MIGRATION COMPLETED SUCCESSFULLY!", 'SUCCESS')
        print("="*70)
        log(f"Total time: {total_time:.1f}s ({total_time/60:.1f} minutes)", 'INFO')
        
        for step in self.steps:
            if step.duration():
                print(f"  Step {step.number}: {step.duration():.1f}s - {step.name}")
        
        print("="*70 + "\n")
        
        return True
    
    def run_step(self, step_number: int, dry_run: bool = False) -> bool:
        """Run a specific step"""
        for step in self.steps:
            if step.number == step_number:
                return step.run(self.config, dry_run)
        
        log(f"Step {step_number} not found", 'ERROR')
        return False
    
    def validate_only(self, dry_run: bool = False) -> bool:
        """Run only validation step"""
        return self.run_step(9, dry_run)


# ============================================================================
# CLI
# ============================================================================

def print_usage():
    """Print usage information"""
    print("""
Database Migration Script
=========================

Usage:
    python migrate.py                    # Run full migration
    python migrate.py --step N           # Run specific step (0-9)
    python migrate.py --from-step N      # Start from step N
    python migrate.py --validate-only    # Only run validation
    python migrate.py --dry-run          # Show what would be done
    python migrate.py --help             # Show this help

Steps:
    0: Backup staging database
    1: Test database connections
    2: Setup schema (101 tables)
    3: Add missing columns
    4: Migrate extra 13 tables
    5: Migrate main 80 tables
    6: Reset sequences
    7: Post-migration validation
    8: Drop FK constraints
    9: Data validation

Configuration:
    Copy .env.example to .env and fill in your database details.

Examples:
    python migrate.py --dry-run          # Preview migration
    python migrate.py                    # Run full migration
    python migrate.py --from-step 5      # Continue from step 5
    python migrate.py --validate-only    # Check data after migration
""")


def main():
    """Main entry point"""
    import argparse
    
    parser = argparse.ArgumentParser(description='Database Migration Script', add_help=False)
    parser.add_argument('--step', type=int, help='Run specific step')
    parser.add_argument('--from-step', type=int, default=0, help='Start from step N')
    parser.add_argument('--validate-only', action='store_true', help='Only run validation')
    parser.add_argument('--dry-run', action='store_true', help='Show what would be done')
    parser.add_argument('--help', action='store_true', help='Show help')
    
    args = parser.parse_args()
    
    if args.help:
        print_usage()
        return 0
    
    # Load configuration
    if not Path('.env').exists():
        log(".env file not found! Copy .env.example to .env and configure it.", 'ERROR')
        return 1
    
    config = Config()
    
    # Validate config
    valid, message = config.validate()
    if not valid:
        log(f"Configuration error: {message}", 'ERROR')
        return 1
    
    # Create migration instance
    migration = Migration(config)
    
    # Run requested operation
    try:
        if args.validate_only:
            success = migration.validate_only(args.dry_run)
        elif args.step is not None:
            success = migration.run_step(args.step, args.dry_run)
        else:
            success = migration.run_all(args.dry_run, args.from_step)
        
        return 0 if success else 1
        
    except KeyboardInterrupt:
        log("\nMigration interrupted by user", 'WARNING')
        return 130
    except Exception as e:
        log(f"Unexpected error: {str(e)}", 'ERROR')
        import traceback
        traceback.print_exc()
        return 1


if __name__ == '__main__':
    sys.exit(main())
