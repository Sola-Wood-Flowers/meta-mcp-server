"""
Connection test script to verify Meta Graph API connection
Run this script BEFORE configuring the MCP in Claude Desktop
"""

import os
import httpx
import json
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

META_ACCESS_TOKEN = os.getenv("META_ACCESS_TOKEN", "")
META_API_VERSION = "v21.0"
BASE_URL = f"https://graph.facebook.com/{META_API_VERSION}"

def test_token():
    """Verifies the access token is valid"""
    print("🔍 Verifying access token...\n")
    
    if not META_ACCESS_TOKEN:
        print("❌ Error: META_ACCESS_TOKEN not found")
        print("   Please create a .env file with your token\n")
        return False
    
    try:
        response = httpx.get(
            f"{BASE_URL}/me",
            params={"access_token": META_ACCESS_TOKEN}
        )
        
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Token is valid!")
            print(f"   User: {data.get('name', 'N/A')}")
            print(f"   ID: {data.get('id', 'N/A')}\n")
            return True
        else:
            print(f"❌ Token is invalid or expired")
            print(f"   Error code: {response.status_code}")
            print(f"   Message: {response.text}\n")
            return False
            
    except Exception as e:
        print(f"❌ Connection error: {str(e)}\n")
        return False


def test_permissions():
    """Verifies token permissions"""
    print("🔍 Checking permissions...\n")
    
    try:
        response = httpx.get(
            f"{BASE_URL}/me/permissions",
            params={"access_token": META_ACCESS_TOKEN}
        )
        
        if response.status_code == 200:
            data = response.json()
            granted_permissions = [
                p["permission"] for p in data.get("data", []) 
                if p.get("status") == "granted"
            ]
            
            required_permissions = [
                "ads_read",
                "business_management",
                "pages_read_engagement",
                "instagram_basic"
            ]
            
            print("✅ Granted permissions:")
            for perm in granted_permissions:
                symbol = "✓" if perm in required_permissions else "•"
                print(f"   {symbol} {perm}")
            
            missing = [p for p in required_permissions if p not in granted_permissions]
            if missing:
                print("\n⚠️  Missing permissions (recommended):")
                for perm in missing:
                    print(f"   ✗ {perm}")
            
            print()
            return True
            
    except Exception as e:
        print(f"❌ Could not verify permissions: {str(e)}\n")
        return False


def test_ad_accounts():
    """Attempts to get ad accounts"""
    print("🔍 Getting ad accounts...\n")
    
    try:
        response = httpx.get(
            f"{BASE_URL}/me/adaccounts",
            params={
                "access_token": META_ACCESS_TOKEN,
                "fields": "id,name,account_status,currency"
            }
        )
        
        if response.status_code == 200:
            data = response.json()
            accounts = data.get("data", [])
            
            if accounts:
                print(f"✅ Found {len(accounts)} ad account(s):\n")
                for acc in accounts:
                    print(f"   📊 {acc.get('name', 'No name')}")
                    print(f"      ID: {acc.get('id', 'N/A')}")
                    print(f"      Status: {acc.get('account_status', 'N/A')}")
                    print(f"      Currency: {acc.get('currency', 'N/A')}\n")
                return True
            else:
                print("⚠️  No ad accounts found")
                print("   Make sure you have access to Ad Accounts in Business Manager\n")
                return False
        else:
            print(f"❌ Error getting accounts: {response.status_code}")
            print(f"   {response.text}\n")
            return False
            
    except Exception as e:
        print(f"❌ Error: {str(e)}\n")
        return False


def test_instagram_accounts():
    """Attempts to get Instagram accounts"""
    print("🔍 Getting Instagram accounts...\n")
    
    try:
        response = httpx.get(
            f"{BASE_URL}/me/accounts",
            params={
                "access_token": META_ACCESS_TOKEN,
                "fields": "id,name,instagram_business_account"
            }
        )
        
        if response.status_code == 200:
            data = response.json()
            pages = data.get("data", [])
            
            ig_accounts = [
                p for p in pages 
                if p.get("instagram_business_account")
            ]
            
            if ig_accounts:
                print(f"✅ Found {len(ig_accounts)} Instagram account(s):\n")
                for page in ig_accounts:
                    ig_id = page.get("instagram_business_account", {}).get("id")
                    print(f"   📷 Page: {page.get('name', 'No name')}")
                    print(f"      Instagram ID: {ig_id}\n")
                return True
            else:
                print("⚠️  No connected Instagram Business accounts found")
                print("   To use Instagram Insights, connect a Business account\n")
                return False
                
    except Exception as e:
        print(f"❌ Error: {str(e)}\n")
        return False


def main():
    """Runs all tests"""
    print("=" * 60)
    print("META ADS MCP SERVER - CONNECTION TEST")
    print("=" * 60)
    print()
    
    results = []
    
    # Test 1: Token
    results.append(("Valid token", test_token()))
    
    # Test 2: Permissions
    if results[0][1]:
        results.append(("Permissions", test_permissions()))
    
    # Test 3: Ad Accounts
    if results[0][1]:
        results.append(("Ad Accounts", test_ad_accounts()))
    
    # Test 4: Instagram
    if results[0][1]:
        results.append(("Instagram Accounts", test_instagram_accounts()))
    
    # Summary
    print("=" * 60)
    print("TEST SUMMARY")
    print("=" * 60)
    for test_name, passed in results:
        status = "✅ PASSED" if passed else "❌ FAILED"
        print(f"{status} - {test_name}")
    
    print()
    
    all_passed = all(r[1] for r in results[:3])  # Token, permissions and ad accounts
    
    if all_passed:
        print("🎉 Great! The server is ready to use")
        print("   You can now configure it in Claude Desktop\n")
        return True
    else:
        print("⚠️  There are some issues to resolve")
        print("   Check the errors above before continuing\n")
        return False


if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)