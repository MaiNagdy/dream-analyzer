#!/usr/bin/env python3
import sys
import os
from app import create_app, db

def main():
    """Main function to start the server"""
    try:
        print("📦 Starting App...")
        app = create_app()

        # Create database tables if they don't exist
        with app.app_context():
            db.create_all()
            print("✅ Database is ready.")

        # Get port from environment variable for cloud deployment
        port = int(os.environ.get('PORT', 5000))
        debug = os.environ.get('FLASK_ENV', 'development') == 'development'
        
        print(f"🚀 Starting Server on port {port}...")
        if debug:
            print("🌐 Available at: http://localhost:5000")
        print("⚡ Press Ctrl+C to stop the server")
        
        # Use debug=False for production
        app.run(host='0.0.0.0', port=port, debug=debug)

    except Exception as e:
        print(f"❌ Failed to start server: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == '__main__':
    main() 