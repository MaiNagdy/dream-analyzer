import requests
import json

# Configuration
BASE_URL = "http://localhost:5000"
TEST_USER = {
    "email_or_username": "test@example.com",  # Change to your test user
    "password": "password123"                 # Change to your test password
}

def test_auth_flow():
    print("Testing authentication flow...")
    
    # Step 1: Login to get token
    print("\n1. Logging in...")
    login_response = requests.post(
        f"{BASE_URL}/api/auth/login",
        headers={"Content-Type": "application/json"},
        data=json.dumps(TEST_USER)
    )
    
    if login_response.status_code != 200:
        print(f"❌ Login failed: {login_response.status_code}")
        print(login_response.text)
        return
    
    login_data = login_response.json()
    access_token = login_data.get("access_token")
    
    if not access_token:
        print("❌ No access token in response")
        print(login_data)
        return
    
    print(f"✅ Login successful, got token: {access_token[:10]}...")
    
    # Step 2: Test health endpoint (no auth required)
    print("\n2. Testing health endpoint...")
    health_response = requests.get(f"{BASE_URL}/api/health")
    
    if health_response.status_code != 200:
        print(f"❌ Health check failed: {health_response.status_code}")
    else:
        print("✅ Health check successful")
    
    # Step 3: Test profile endpoint (auth required)
    print("\n3. Testing profile endpoint (with auth)...")
    profile_response = requests.get(
        f"{BASE_URL}/api/auth/profile",
        headers={
            "Authorization": f"Bearer {access_token}",
            "Content-Type": "application/json"
        }
    )
    
    if profile_response.status_code != 200:
        print(f"❌ Profile check failed: {profile_response.status_code}")
        print(profile_response.text)
    else:
        print("✅ Profile check successful")
    
    # Step 4: Test dream analysis endpoint (auth required)
    print("\n4. Testing dream analysis endpoint...")
    dream_data = {
        "dreamText": "I was flying over mountains and oceans."
    }
    
    dream_response = requests.post(
        f"{BASE_URL}/api/dreams/analyze",
        headers={
            "Authorization": f"Bearer {access_token}",
            "Content-Type": "application/json"
        },
        data=json.dumps(dream_data)
    )
    
    if dream_response.status_code != 200:
        print(f"❌ Dream analysis failed: {dream_response.status_code}")
        print(dream_response.text)
    else:
        print("✅ Dream analysis successful")
        print("Response preview:")
        response_data = dream_response.json()
        print(f"- Dream ID: {response_data.get('dream_id')}")
        print(f"- Analysis starts with: {response_data.get('analysis', '')[:50]}...")

if __name__ == "__main__":
    test_auth_flow() 