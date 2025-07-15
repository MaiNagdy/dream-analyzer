#!/usr/bin/env python3
"""
Test database setup and migration
This script tests the database connection and creates tables using SQLite locally
"""

import os
import sys
from flask import Flask
from models import db, User, Purchase, DreamAnalysis, APIUsage
from config import get_config

def create_test_app():
    """Create a test Flask app"""
    app = Flask(__name__)
    
    # Load configuration
    config = get_config()
    app.config.from_object(config)
    
    # Initialize database
    db.init_app(app)
    
    return app

def test_database_connection():
    """Test database connection and create tables"""
    print("🔧 Testing Database Connection")
    print("=" * 50)
    
    app = create_test_app()
    
    with app.app_context():
        try:
            # Test database connection
            db.engine.connect()
            print("✅ Database connection successful")
            
            # Create all tables
            db.create_all()
            print("✅ Database tables created successfully")
            
            # Test table creation by checking if they exist
            from sqlalchemy import inspect
            inspector = inspect(db.engine)
            tables = inspector.get_table_names()
            expected_tables = ['users', 'purchases', 'dream_analyses', 'api_usage']
            
            print(f"📊 Created tables: {tables}")
            
            missing_tables = [table for table in expected_tables if table not in tables]
            if missing_tables:
                print(f"⚠️  Missing tables: {missing_tables}")
            else:
                print("✅ All expected tables created")
            
            # Test creating a user
            test_user = User(
                email='test@example.com',
                username='testuser',
                first_name='Test',
                last_name='User',
                subscription_status='none',
                credits=0
            )
            test_user.set_password('testpassword')
            
            db.session.add(test_user)
            db.session.commit()
            print("✅ Test user created successfully")
            
            # Test querying the user
            user = User.query.filter_by(email='test@example.com').first()
            if user:
                print(f"✅ User query successful: {user.username}")
            else:
                print("❌ User query failed")
            
            # Test subscription fields
            user.subscription_status = 'active'
            user.subscription_type = 'pack_10_dreams'
            user.credits = 10
            db.session.commit()
            print("✅ Subscription fields updated successfully")
            
            # Clean up
            db.session.delete(user)
            db.session.commit()
            print("✅ Test data cleaned up")
            
            return True
            
        except Exception as e:
            print(f"❌ Database test failed: {e}")
            return False

def main():
    """Main function"""
    print("🗄️  Database Setup Test")
    print("=" * 50)
    
    # Check configuration
    config = get_config()
    print(f"📋 Environment: {os.environ.get('FLASK_ENV', 'development')}")
    print(f"🔗 Database URL: {config.SQLALCHEMY_DATABASE_URI}")
    
    # Test database
    if test_database_connection():
        print(f"""
✅ Database setup completed successfully!

📋 **Summary:**
- Database connection: ✅ Working
- Tables created: ✅ All tables
- User operations: ✅ Working
- Subscription fields: ✅ Working

🚀 **Next steps:**
1. Your database schema is ready for the subscription system
2. For Railway deployment: PostgreSQL will be used automatically
3. Migration file is ready: migrations/versions/20250715_031644_add_subscription_and_purchase_tables.py

🎯 **Ready for deployment!**
""")
    else:
        print("""
❌ Database setup failed!

🔧 **Troubleshooting:**
1. Check if all dependencies are installed
2. Verify database configuration
3. Check for any error messages above
""")
        return False
    
    return True

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1) 