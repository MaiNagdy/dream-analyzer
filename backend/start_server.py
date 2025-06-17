#!/usr/bin/env python3
import sys
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

        print("🚀 Starting Server on port 5000...")
        print("🌐 Available at: http://localhost:5000")
        print("⚡ Press Ctrl+C to stop the server")
        
        # Running in debug mode is fine now that setup is separate
        app.run(host='0.0.0.0', port=5000, debug=True)

    except Exception as e:
        print(f"❌ Failed to start server: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == '__main__':
    main() 