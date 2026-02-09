# Installation Guide: Meta Ads MCP Server

This MCP server allows your entire team to query Meta Ads (Facebook/Instagram) data directly from Claude.

## 📋 Prerequisites

- Python 3.10 or higher
- Access to Meta Business Manager
- Meta Graph API access token
- Claude Desktop installed

## 🚀 Step-by-Step Installation

### 1. Set Up the Project

```bash
# Create project folder
mkdir meta-mcp-server
cd meta-mcp-server

# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate
# On Mac/Linux:
source venv/bin/activate
```

### 2. Install Dependencies

Create a `requirements.txt` file:

```txt
mcp>=0.9.0
httpx>=0.27.0
python-dotenv>=1.0.0
```

Install dependencies:

```bash
pip install -r requirements.txt
```

### 3. Get Meta Token

#### Option A: Development Token (Temporary - 1 hour)
1. Go to https://developers.facebook.com/tools/explorer/
2. Select your app
3. Under "User or Page", select "User Token"
4. Add permissions: `ads_read`, `business_management`, `pages_read_engagement`, `instagram_basic`, `instagram_manage_insights`
5. Click "Generate Access Token"
6. **Important**: This token expires in 1 hour

#### Option B: Long-Lived Token (Recommended - 60 days)
1. Get a temporary token (Option A)
2. Use the Graph API to extend it:

```bash
curl -i -X GET "https://graph.facebook.com/v21.0/oauth/access_token?grant_type=fb_exchange_token&client_id=YOUR_APP_ID&client_secret=YOUR_APP_SECRET&fb_exchange_token=TEMPORARY_TOKEN"
```

#### Option C: System User Token (Permanent - Recommended for production)
1. Go to Business Settings → Users → System Users
2. Create a System User
3. Assign permissions and generate token
4. This token doesn't expire

### 4. Configure Environment Variables

Create a `.env` file in the project root:

```env
META_ACCESS_TOKEN=your_token_here
```

**⚠️ IMPORTANT**: Never commit the `.env` file to Git. Add it to `.gitignore`:

```bash
echo ".env" >> .gitignore
```

### 5. Configure Claude Desktop

#### On Mac:
Edit: `~/Library/Application Support/Claude/claude_desktop_config.json`

#### On Windows:
Edit: `%APPDATA%\Claude\claude_desktop_config.json`

Add this configuration:

```json
{
  "mcpServers": {
    "meta-ads": {
      "command": "python",
      "args": ["/full/path/to/meta-mcp-server/meta_ads_mcp.py"],
      "env": {
        "META_ACCESS_TOKEN": "your_token_here"
      }
    }
  }
}
```

**Replace** `/full/path/to/` with the actual path where you saved the server.

### 6. Restart Claude Desktop

Completely close Claude Desktop and reopen it.

## ✅ Verify Installation

Once Claude Desktop is restarted, open a new conversation and ask:

```
Can you list my Meta ad accounts?
```

If everything is configured correctly, Claude should be able to access your data.

## 📊 Usage Examples

Once installed, your team can ask Claude things like:

### Query Accounts
```
Show me all my Meta ad accounts
```

### View Active Campaigns
```
List all active campaigns for account 123456789
```

### Generate Reports
```
Give me the performance of all campaigns from last week 
for account 123456789 (from 2024-01-01 to 2024-01-07)
```

### Instagram Insights
```
Show me Instagram metrics for ID 17841401234567890
```

### Comparative Analysis
```
Compare the CTR of all campaigns from last month
```

## 🔧 Troubleshooting

### Error: "META_ACCESS_TOKEN not configured"
- Verify the token is in the `.env` file or Claude Desktop config
- Make sure the path to the `.env` file is correct

### Error: "Invalid OAuth access token"
- Your token may have expired (temporary tokens last 1 hour)
- Generate a new token or use a long-lived token

### Error: "Insufficient permissions"
- Your token needs more permissions
- Go to Graph API Explorer and add: `ads_read`, `business_management`

### Claude doesn't recognize the server
- Verify the path in `claude_desktop_config.json` is absolute and correct
- Completely restart Claude Desktop
- Check logs at:
  - Mac: `~/Library/Logs/Claude/`
  - Windows: `%APPDATA%\Claude\logs\`

## 🔐 Security

### For the Team
1. **Never share tokens**: Each member must generate their own token
2. **Use System Users**: For production environments, use System Users in Business Manager
3. **Minimum permissions**: Only grant necessary permissions
4. **Token rotation**: Renew tokens periodically

### Recommended Team Architecture

**Option 1: Individual Installation**
- Each member installs the server on their machine
- Everyone uses their own token
- ✅ More secure
- ❌ Requires per-person setup

**Option 2: Centralized Server**
- A central server runs the MCP
- Entire team connects remotely
- ✅ Single setup
- ❌ Requires infrastructure

## 📝 Required IDs

To use the server you'll need these IDs:

### Account ID (Ad Account)
- Go to Ads Manager
- Look at the URL: `https://business.facebook.com/adsmanager/manage/campaigns?act=123456789`
- Your Account ID is: `123456789` (without the `act_`)

### Instagram Business Account ID
- Go to Instagram Insights
- Or use the `get_ad_accounts` tool which also lists connected Instagram accounts

### Facebook Page ID
- Go to your Facebook page
- Settings → About → Page ID

## 🆘 Support

If you have issues:
1. Check Claude Desktop logs
2. Verify permissions configuration in Meta
3. Make sure the token hasn't expired
4. Review Meta Graph API documentation: https://developers.facebook.com/docs/graph-api

## 📚 Additional Resources

- [Meta Graph API Documentation](https://developers.facebook.com/docs/graph-api)
- [Meta Marketing API](https://developers.facebook.com/docs/marketing-apis)
- [MCP Documentation](https://modelcontextprotocol.io)

---

**Version**: 1.0.0  
**Last updated**: February 2026