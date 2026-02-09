# Usage Examples - Meta Ads MCP Server

Once the MCP server is installed, here are some examples of what your team can ask Claude:

## 📊 Basic Queries

### View all ad accounts
```
Show me all my Meta ad accounts
```

Claude will call `get_ad_accounts` and show you all available accounts with their IDs.

### List active campaigns
```
List all active campaigns for account 123456789
```

```
Which campaigns are paused in my main account?
```

### View specific campaign details
```
Give me information about campaign ID 23851234567890
```

## 📈 Performance Analysis

### Weekly report
```
Give me the performance of all campaigns from last week 
for account 123456789 (from 2024-02-01 to 2024-02-07)
```

Claude will show you:
- Impressions
- Clicks
- CTR
- CPC
- Total spend
- Conversions

### Compare periods
```
Compare my campaign performance from January vs February for account 123456789
```

Claude will make two calls (one for each month) and give you a comparative analysis.

### Top campaigns by metric
```
What are the top 5 campaigns by CTR from last month in account 123456789?
```

### Budget analysis
```
Show me how much I spent on each campaign this month and which has the best ROI
```

## 📱 Instagram Insights

### Basic metrics
```
Show me reach and impressions metrics for my Instagram account 17841401234567890
```

### Follower growth
```
How many new followers did my Instagram account get this week?
```

### Engagement
```
Give me Instagram engagement metrics from last month
```

## 📄 Facebook Pages

### Page insights
```
Show me my Facebook page 123456789 statistics
```

### Compare pages
```
Compare the performance of my two Facebook pages
```

## 🎯 Detailed Analysis

### Performance by ad set
```
Give me adset-level performance for account 123456789 
from 2024-02-01 to 2024-02-07
```

### Individual ad analysis
```
Show me metrics for each individual ad in campaign X
```

### Best performing creatives
```
Which creatives have the best CTR in my active campaigns?
```

## 📊 Custom Reports

### Executive report
```
Generate an executive report with:
- Total spend summary
- Top 3 campaigns by performance
- Optimization recommendations
For account 123456789 from last month
```

### Efficiency report
```
Analyze my campaign efficiency and tell me:
- Which have the lowest CPC
- Which have the best conversion rate
- Which are over/under budget
```

### Trends
```
Show me CTR and CPC trends for my campaigns 
over the last 3 months (January, February, March)
```

## 🔍 Troubleshooting and Auditing

### Identify issues
```
Review my active campaigns and identify:
- Campaigns with low CTR
- Campaigns with high CPC
- Underperforming campaigns
```

### Account audit
```
Audit my ad account 123456789 and give me recommendations
```

### Budgets
```
Which campaigns are close to exhausting their daily budget?
```

## 💡 Advanced Tips

### Multi-account analysis
```
Compare the performance of my 3 ad accounts 
and tell me which is getting the best results
```

### Correlations
```
Analyze if there's a correlation between spend and conversions 
in my campaigns from last quarter
```

### Simple forecasting
```
Based on last month's performance, 
estimate how much I'll spend this month if I keep the same campaigns
```

## 🎨 Response Formatting

You can ask Claude to format responses however you prefer:

```
Give me the report in table format
```

```
Generate a summary in bullet points
```

```
Create a CSV with the data so I can import it to Excel
```

```
Make a visualization of the data with ASCII charts
```

## ⚠️ Important Notes

### Always specify:
1. **Account ID**: Your ad account ID
2. **Date range**: Start and end (YYYY-MM-DD format)
3. **Level**: Campaign, adset, or ad (if you want specific detail)

### Complete example:
```
For account 123456789, show me campaign-level performance 
from 2024-02-01 to 2024-02-07, ordered by best CTR
```

## 🔄 Common Workflows

### Workflow 1: Automated Weekly Report
```
1. Show me last week's performance
2. Compare it with the previous week
3. Give me 3 optimization recommendations
```

### Workflow 2: Pre-Meeting Analysis
```
1. Summary of all active accounts
2. Top 5 campaigns by conversions
3. Budget spent vs projected
4. Issues requiring attention
```

### Workflow 3: Campaign Optimization
```
1. Analyze campaign X from the last 14 days
2. Compare with similar campaigns
3. Identify what's working and what's not
4. Suggest specific changes
```

## 🤝 Team Collaboration

Since the whole team has access to the same MCP server, they can:

- **Standardize reports**: Everyone uses the same queries
- **Share insights**: "Use the same query I used to see X"
- **Create workflows**: Document best queries for common cases
- **Cross-audits**: Review other members' accounts

## 📝 Query Templates

Create templates the team can reuse:

### Template: Monthly Report
```
For account [ACCOUNT_ID], generate a report for the month of [MONTH]
including metrics from all campaigns, comparison with previous month,
and top insights
```

### Template: Quick Check
```
Current status of account [ACCOUNT_ID]: 
active campaigns, today's spend, and alerts
```

---

**Need more specific examples for your use case?** 
Just ask Claude and it will help you formulate the right query.