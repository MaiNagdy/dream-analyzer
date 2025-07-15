#!/usr/bin/env python3
"""
Run database migrations on Railway PostgreSQL
This script can be executed via Railway CLI or terminal
"""

import os
import sys
from flask import Flask
from flask_migrate import upgrade
from config import get_config
from models import db

def run_migrations():
    """Run database migrations"""
    print("🔧 Running Database Migrations...")
    print("=" * 50)
    
    # Create Flask app
    app = Flask(__name__)
    
    # Load production config
    os.environ['FLASK_ENV'] = 'production'
    config = get_config()
    app.config.from_object(config)
    
    # Initialize database
    db.init_app(app)
    
    with app.app_context():
        try:
            # Check database connection
            db.engine.connect()
            print("✅ Database connection successful")
            print(f"🔗 Database URL: {app.config['SQLALCHEMY_DATABASE_URI'][:50]}...")
            
            # Run migrations
            print("🚀 Running flask db upgrade...")
            upgrade()
            print("✅ Database migrations completed successfully!")
            
            # Verify tables were created
            from sqlalchemy import inspect
            inspector = inspect(db.engine)
            tables = inspector.get_table_names()
            
            expected_tables = ['users', 'purchases', 'dream_analyses', 'api_usage', 'user_sessions']
            print(f"📊 Tables in database: {tables}")
            
            missing_tables = [table for table in expected_tables if table not in tables]
            if missing_tables:
                print(f"⚠️  Missing tables: {missing_tables}")
                return False
            else:
                print("✅ All expected tables are present!")
            
            return True
            
        except Exception as e:
            print(f"❌ Migration failed: {e}")
            import traceback
            traceback.print_exc()
            return False

if __name__ == '__main__':
    success = run_migrations()
    if success:
        print("""
🎉 **Migration Completed Successfully!**

✅ PostgreSQL database is ready
✅ All subscription tables created
✅ Your dream analyzer app is ready to use!

🚀 **Next steps:**
1. Test your API: https://dream-analyzer-production-9fd5.up.railway.app/api/health
2. Update Flutter app with Railway URL
3. Test subscription flow

Your subscription system is now live! 🌟
""")
    else:
        print("""
❌ **Migration Failed!**

🔧 **Troubleshooting:**
1. Check DATABASE_URL environment variable
2. Verify PostgreSQL service is running
3. Check Railway logs for errors
""")
        sys.exit(1) 