# Quick Start Guide - Meta Ads MCP Server

Get up and running with Meta Ads data in Claude in 5 minutes.

## ⚡ 5-Minute Setup

### Step 1: Download Files (30 seconds)
Download or clone this repository to your computer.

### Step 2: Install Python Dependencies (1 minute)
```bash
cd meta-mcp-server
pip install -r requirements.txt
```

### Step 3: Get Your Meta Token (2 minutes)
1. Go to: https://developers.facebook.com/tools/explorer/
2. Select your app (or create one if needed)
3. Click "Generate Access Token"
4. Grant permissions: `ads_read`, `business_management`, `pages_read_engagement`, `instagram_basic`
5. Copy the token

### Step 4: Configure Token (30 seconds)
Create a `.env` file in the project folder:
```bash
echo "META_ACCESS_TOKEN=paste_your_token_here" > .env
```

### Step 5: Test Connection (30 seconds)
```bash
python test_connection.py
```

If you see ✅ marks, you're good to go!

### Step 6: Add to Claude Desktop (30 seconds)

**Mac:** Edit `~/Library/Application Support/Claude/claude_desktop_config.json`  
**Windows:** Edit `%APPDATA%\Claude\claude_desktop_config.json`

Add this (replace the path with your actual folder path):
```json
{
  "mcpServers": {
    "meta-ads": {
      "command": "python",
      "args": ["/Users/yourname/meta-mcp-server/meta_ads_mcp.py"],
      "env": {
        "META_ACCESS_TOKEN": "your_token_here"
      }
    }
  }
}
```

### Step 7: Restart Claude (10 seconds)
Completely quit Claude Desktop and reopen it.

### Step 8: Test It! (10 seconds)
Open Claude and ask:
```
Show me my Meta ad accounts
```

## 🎉 You're Done!

Now you can ask Claude anything about your Meta advertising data.

## 💡 Try These First

### Get Your Account IDs
```
List all my ad accounts with their IDs
```

### See Recent Performance
```
Show me campaign performance for account 123456789 from last week
```

### Compare Campaigns
```
Which of my campaigns has the best CTR this month?
```

## 📚 Next Steps

- **Learn more queries**: Check [USAGE_EXAMPLES.md](USAGE_EXAMPLES.md)
- **Detailed setup**: See [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md)
- **Troubleshooting**: Review the Troubleshooting section in README.md

## ⚠️ Important Notes

### Token Expiration
- **Temporary tokens** expire in 1 hour
- **Long-lived tokens** last 60 days
- **System User tokens** don't expire (recommended for teams)

To get a long-lived token, use the Graph API to exchange your short-lived token:
```bash
curl "https://graph.facebook.com/v21.0/oauth/access_token?grant_type=fb_exchange_token&client_id=YOUR_APP_ID&client_secret=YOUR_APP_SECRET&fb_exchange_token=SHORT_LIVED_TOKEN"
```

### Finding Your Account ID
Your ad account ID is in the Ads Manager URL:
```
https://business.facebook.com/adsmanager/manage/campaigns?act=123456789
                                                            ^^^^^^^^^^
                                                            This is your ID
```

Use just the numbers (123456789), not the full "act_123456789".

### Required Permissions
Make sure your token has at least:
- ✅ `ads_read` - Read ad data
- ✅ `business_management` - Access accounts
- ✅ `pages_read_engagement` - Facebook pages (optional)
- ✅ `instagram_basic` - Instagram data (optional)

## 🆘 Quick Troubleshooting

### "META_ACCESS_TOKEN not configured"
→ Check your `.env` file exists and has the token

### "Invalid OAuth access token"
→ Your token expired - generate a new one

### Claude doesn't see the server
→ Make sure you used the **full absolute path** in the config file
→ Restart Claude Desktop completely (quit, don't just close window)

### "Insufficient permissions"
→ Go back to Graph API Explorer and add missing permissions
→ Generate a new token after adding permissions

## 🎓 Training Your Team

### Share This Checklist:
- [ ] Python installed (3.10+)
- [ ] Claude Desktop installed
- [ ] Downloaded meta-mcp-server files
- [ ] Generated Meta token
- [ ] Created .env file with token
- [ ] Ran test_connection.py (saw ✅)
- [ ] Updated claude_desktop_config.json
- [ ] Restarted Claude Desktop
- [ ] Successfully queried ad accounts

### First Team Meeting:
1. Everyone completes setup (15 min)
2. Demo basic queries (5 min)
3. Share account IDs team needs (5 min)
4. Practice common queries together (10 min)

## 📞 Getting Help

1. **Run the test script**: `python test_connection.py`
2. **Check Claude logs**: 
   - Mac: `~/Library/Logs/Claude/`
   - Windows: `%APPDATA%\Claude\logs\`
3. **Review full docs**: See INSTALLATION_GUIDE.md

---

**Time to first query: 5 minutes ⚡**  
**Questions resolved: Hundreds per day 📊**  
**Manual exports avoided: Countless 🎉**