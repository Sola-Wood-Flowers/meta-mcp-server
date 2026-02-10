# Meta Ads MCP Server

> Query Meta Ads (Facebook/Instagram) data directly from Claude using the Model Context Protocol (MCP)

## 🎯 Overview

This MCP server enables your entire team to access Meta advertising data through natural language conversations with Claude. No more manual exports, API calls, or complex scripts - just ask Claude what you need to know about your campaigns.

**Key Benefits:**
- ✅ Natural language queries - no coding required
- ✅ Real-time data access from Meta Graph API
- ✅ Team-wide standardization
- ✅ Instant report generation
- ✅ Comparative analysis across campaigns and time periods

## 🚀 Quick Start

### Prerequisites
- Python 3.10+
- Claude Desktop
- Meta Business Manager account
- Meta Graph API access token

### Easy Installation (Recommended)

Run this command in your terminal to set up everything automatically (installs Python, dependencies, and configures Claude):

```bash
curl -fsSL https://raw.githubusercontent.com/Sola-Wood-Flowers/meta-mcp-server/main/install.sh | bash
```

**Note:** You must completely restart Claude Desktop (Cmd+Q) after installation for changes to take effect.

### Manual Installation

1. **Clone or download** this repository
2. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```
3. **Get your Meta token** from [Meta Developers](https://developers.facebook.com/tools/explorer/)
4. **Configure environment:**
   ```bash
   echo "META_ACCESS_TOKEN=your_token_here" > .env
   ```
5. **Test connection:**
   ```bash
   python test_connection.py
   ```
6. **Configure Claude Desktop** (see [Installation Guide](INSTALLATION_GUIDE.md))
7. **Restart Claude** and start querying!

## 📊 What Can You Do?

### Basic Queries
```
Show me all my Meta ad accounts
List active campaigns for account 123456789
What's the performance of campaign X this week?
```

### Analytics
```
Compare my campaigns from January vs February
Which campaigns have the best CTR this month?
Show me Instagram insights for the last 7 days
```

### Reports
```
Generate an executive summary for account 123456789
Audit my campaigns and identify optimization opportunities
Create a weekly performance report
```

See [Usage Examples](USAGE_EXAMPLES.md) for more!

## 🛠️ Available Tools

The server provides 6 tools that Claude can use:

| Tool | Description |
|------|-------------|
| `get_ad_accounts` | Lists all available ad accounts |
| `get_campaigns` | Gets campaigns with optional status filtering |
| `get_campaign_insights` | Retrieves performance metrics for date ranges |
| `get_instagram_insights` | Gets Instagram Business account metrics |
| `get_facebook_page_insights` | Gets Facebook page statistics |
| `get_ad_creative` | Retrieves ad creative details |

## 📁 Project Structure

```
meta-mcp-server/
├── meta_ads_mcp.py           # Main MCP server
├── test_connection.py        # Connection test script
├── requirements.txt          # Python dependencies
├── pyproject.toml           # Package configuration
├── .env                     # Environment variables (create this)
├── .gitignore              # Git ignore file
├── README.md               # This file
├── INSTALLATION_GUIDE.md   # Detailed setup instructions
└── USAGE_EXAMPLES.md       # Query examples and use cases
```

## 🔐 Security Best Practices

### For Individual Team Members
1. **Never share tokens** - each person generates their own
2. **Use long-lived tokens** - avoid hourly token regeneration
3. **Minimum permissions** - only grant what's needed
4. **Regular rotation** - update tokens periodically

### For Teams
- **Option A (Recommended)**: Individual installations with personal tokens
- **Option B**: Centralized server with secure token management

### Required Permissions
Your Meta token needs these permissions:
- `ads_read` - Read ad account data
- `business_management` - Access Business Manager
- `pages_read_engagement` - Read page insights
- `instagram_basic` - Access Instagram data
- `instagram_manage_insights` - Read Instagram insights

## 🆘 Troubleshooting

### Common Issues

**"META_ACCESS_TOKEN not configured"**
- Check your `.env` file exists and contains the token
- Verify the path in Claude Desktop config is correct

**"Invalid OAuth access token"**
- Your token expired (temporary tokens last 1 hour)
- Generate a new token or switch to long-lived tokens

**"Insufficient permissions"**
- Add required permissions in Graph API Explorer
- Regenerate token after adding permissions

**Claude doesn't recognize the server**
- Verify absolute path in `claude_desktop_config.json`
- Restart Claude Desktop completely
- Check logs: `~/Library/Logs/Claude/` (Mac) or `%APPDATA%\Claude\logs\` (Windows)

See [Installation Guide](INSTALLATION_GUIDE.md) for detailed troubleshooting.

## 📚 Documentation

- **[Installation Guide](INSTALLATION_GUIDE.md)** - Complete setup instructions
- **[Usage Examples](USAGE_EXAMPLES.md)** - Query examples and workflows
- [Meta Graph API Docs](https://developers.facebook.com/docs/graph-api)
- [MCP Documentation](https://modelcontextprotocol.io)

## 🤝 Team Usage

### Standardizing Queries
Create a shared document with common queries:
```
Weekly Report: "Show performance for account X from [dates]"
Campaign Check: "List active campaigns with spend > $100/day"
Quick Status: "Account X status and top 3 campaigns"
```

### Sharing Insights
Team members can reference each other's queries:
```
"Use the same analysis Sarah did for Q4 campaigns"
"Run the budget check workflow on my accounts"
```

### Best Practices
- Document frequently used queries
- Create templates for regular reports
- Share optimization findings
- Maintain consistent date formats (YYYY-MM-DD)

## 🔄 Updates and Maintenance

### Updating the Server
```bash
git pull origin main
pip install -r requirements.txt --upgrade
```

### Token Renewal
1. Generate new token in Meta Developers
2. Update `.env` file or Claude Desktop config
3. Restart Claude Desktop

### Adding New Features
The server is built with MCP - adding new tools is straightforward:
1. Add tool definition in `handle_list_tools()`
2. Implement logic in `handle_call_tool()`
3. Test with `test_connection.py`

## 📊 Metrics and Data

### Available Metrics
- **Campaign Level**: impressions, clicks, spend, reach, frequency, CTR, CPC, CPM, conversions
- **Instagram**: follower count, impressions, reach, engagement, profile views
- **Facebook Pages**: page fans, impressions, engaged users, post engagement

### Date Ranges
- Specify custom ranges: `YYYY-MM-DD` format
- Common phrases work: "last week", "this month", "Q1 2024"
- Claude handles date parsing automatically

## 🎓 Training Your Team

### For Non-Technical Users
1. Show them example queries from [Usage Examples](USAGE_EXAMPLES.md)
2. Start with simple queries: "Show my accounts"
3. Build to complex: "Compare campaigns and recommend optimizations"

### For Analysts
- Combine multiple queries in one ask
- Request specific data formats (CSV, tables)
- Use for ad-hoc analysis and exploration

### For Managers
- Regular report generation
- Cross-account comparisons
- Budget tracking and forecasting

## 📝 Changelog

### Version 1.0.0 (February 2026)
- Initial release
- 6 core tools for Meta Ads data
- Instagram and Facebook page insights
- Comprehensive error handling
- Connection testing utilities

## 📄 License

MIT License - see LICENSE file for details

## 🙋 Support

**Issues with Setup?**
1. Run `python test_connection.py` to diagnose
2. Check Claude Desktop logs
3. Verify token permissions in Meta

**Questions?**
- Review [Installation Guide](INSTALLATION_GUIDE.md)
- Check [Usage Examples](USAGE_EXAMPLES.md)
- Consult [Meta Graph API Docs](https://developers.facebook.com/docs/graph-api)

---

**Built with ❤️ for marketing teams who want to spend less time pulling data and more time making decisions.**