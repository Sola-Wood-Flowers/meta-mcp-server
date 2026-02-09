"""
Meta Ads MCP Server
MCP Server for querying Meta Ads (Facebook/Instagram) data from Claude
"""

import asyncio
import json
import os
from datetime import datetime, timedelta
from typing import Any
import httpx
from mcp.server.models import InitializationOptions
import mcp.types as types
from mcp.server import NotificationOptions, Server
import mcp.server.stdio

# Configuration
META_ACCESS_TOKEN = os.getenv("META_ACCESS_TOKEN", "")
META_API_VERSION = "v21.0"
BASE_URL = f"https://graph.facebook.com/{META_API_VERSION}"

# Create MCP server
server = Server("meta-ads-server")

# HTTP client
http_client = httpx.AsyncClient()


async def fetch_meta_api(endpoint: str, params: dict) -> dict:
    """Makes requests to Meta Graph API"""
    params["access_token"] = META_ACCESS_TOKEN
    
    try:
        response = await http_client.get(f"{BASE_URL}/{endpoint}", params=params)
        response.raise_for_status()
        return response.json()
    except httpx.HTTPError as e:
        return {"error": str(e), "status": "failed"}


@server.list_tools()
async def handle_list_tools() -> list[types.Tool]:
    """Lists all available tools"""
    return [
        types.Tool(
            name="get_ad_accounts",
            description="Lists all available ad accounts",
            inputSchema={
                "type": "object",
                "properties": {
                    "business_id": {
                        "type": "string",
                        "description": "Business Manager ID (optional)"
                    }
                }
            }
        ),
        types.Tool(
            name="get_campaigns",
            description="Gets list of campaigns from an ad account",
            inputSchema={
                "type": "object",
                "properties": {
                    "account_id": {
                        "type": "string",
                        "description": "Ad account ID (without 'act_' prefix)"
                    },
                    "status": {
                        "type": "string",
                        "description": "Filter by status: ACTIVE, PAUSED, DELETED, ARCHIVED",
                        "enum": ["ACTIVE", "PAUSED", "DELETED", "ARCHIVED"]
                    }
                },
                "required": ["account_id"]
            }
        ),
        types.Tool(
            name="get_campaign_insights",
            description="Gets campaign metrics and performance for a date range",
            inputSchema={
                "type": "object",
                "properties": {
                    "account_id": {
                        "type": "string",
                        "description": "Ad account ID"
                    },
                    "date_start": {
                        "type": "string",
                        "description": "Start date (YYYY-MM-DD)"
                    },
                    "date_end": {
                        "type": "string",
                        "description": "End date (YYYY-MM-DD)"
                    },
                    "level": {
                        "type": "string",
                        "description": "Report level: campaign, adset, ad",
                        "enum": ["campaign", "adset", "ad"],
                        "default": "campaign"
                    }
                },
                "required": ["account_id", "date_start", "date_end"]
            }
        ),
        types.Tool(
            name="get_instagram_insights",
            description="Gets insights from an Instagram Business account",
            inputSchema={
                "type": "object",
                "properties": {
                    "instagram_account_id": {
                        "type": "string",
                        "description": "Instagram Business account ID"
                    },
                    "metrics": {
                        "type": "array",
                        "description": "Metrics to retrieve",
                        "items": {
                            "type": "string",
                            "enum": [
                                "impressions",
                                "reach",
                                "follower_count",
                                "email_contacts",
                                "phone_call_clicks",
                                "profile_views",
                                "website_clicks"
                            ]
                        },
                        "default": ["impressions", "reach", "follower_count"]
                    },
                    "period": {
                        "type": "string",
                        "description": "Time period",
                        "enum": ["day", "week", "days_28", "lifetime"],
                        "default": "day"
                    }
                },
                "required": ["instagram_account_id"]
            }
        ),
        types.Tool(
            name="get_facebook_page_insights",
            description="Gets insights from a Facebook page",
            inputSchema={
                "type": "object",
                "properties": {
                    "page_id": {
                        "type": "string",
                        "description": "Facebook page ID"
                    },
                    "metrics": {
                        "type": "array",
                        "description": "Metrics to retrieve",
                        "items": {
                            "type": "string",
                            "enum": [
                                "page_impressions",
                                "page_engaged_users",
                                "page_fan_adds",
                                "page_fans",
                                "page_views_total",
                                "page_post_engagements"
                            ]
                        },
                        "default": ["page_impressions", "page_fans"]
                    },
                    "period": {
                        "type": "string",
                        "enum": ["day", "week", "days_28"],
                        "default": "day"
                    }
                },
                "required": ["page_id"]
            }
        ),
        types.Tool(
            name="get_ad_creative",
            description="Gets details of an ad's creative content",
            inputSchema={
                "type": "object",
                "properties": {
                    "ad_id": {
                        "type": "string",
                        "description": "Ad ID"
                    }
                },
                "required": ["ad_id"]
            }
        )
    ]


@server.call_tool()
async def handle_call_tool(
    name: str, arguments: dict | None
) -> list[types.TextContent | types.ImageContent | types.EmbeddedResource]:
    """Handles tool calls"""
    
    if not META_ACCESS_TOKEN:
        return [types.TextContent(
            type="text",
            text="Error: META_ACCESS_TOKEN not configured. Please set the environment variable."
        )]
    
    try:
        if name == "get_ad_accounts":
            # Get ad accounts
            endpoint = "me/adaccounts"
            params = {
                "fields": "id,name,account_status,currency,timezone_name,amount_spent"
            }
            data = await fetch_meta_api(endpoint, params)
            
        elif name == "get_campaigns":
            account_id = arguments.get("account_id")
            endpoint = f"act_{account_id}/campaigns"
            params = {
                "fields": "id,name,status,objective,daily_budget,lifetime_budget,created_time,updated_time"
            }
            if arguments.get("status"):
                params["filtering"] = json.dumps([{
                    "field": "status",
                    "operator": "EQUAL",
                    "value": arguments["status"]
                }])
            data = await fetch_meta_api(endpoint, params)
            
        elif name == "get_campaign_insights":
            account_id = arguments.get("account_id")
            date_start = arguments.get("date_start")
            date_end = arguments.get("date_end")
            level = arguments.get("level", "campaign")
            
            endpoint = f"act_{account_id}/insights"
            params = {
                "time_range": json.dumps({
                    "since": date_start,
                    "until": date_end
                }),
                "level": level,
                "fields": "campaign_name,impressions,clicks,spend,reach,frequency,cpc,cpm,ctr,cpp,conversions,cost_per_conversion,actions,action_values"
            }
            data = await fetch_meta_api(endpoint, params)
            
        elif name == "get_instagram_insights":
            instagram_id = arguments.get("instagram_account_id")
            metrics = arguments.get("metrics", ["impressions", "reach", "follower_count"])
            period = arguments.get("period", "day")
            
            endpoint = f"{instagram_id}/insights"
            params = {
                "metric": ",".join(metrics),
                "period": period
            }
            data = await fetch_meta_api(endpoint, params)
            
        elif name == "get_facebook_page_insights":
            page_id = arguments.get("page_id")
            metrics = arguments.get("metrics", ["page_impressions", "page_fans"])
            period = arguments.get("period", "day")
            
            endpoint = f"{page_id}/insights"
            params = {
                "metric": ",".join(metrics),
                "period": period
            }
            data = await fetch_meta_api(endpoint, params)
            
        elif name == "get_ad_creative":
            ad_id = arguments.get("ad_id")
            endpoint = f"{ad_id}"
            params = {
                "fields": "creative{title,body,image_url,link_url,call_to_action_type,object_story_spec}"
            }
            data = await fetch_meta_api(endpoint, params)
            
        else:
            return [types.TextContent(
                type="text",
                text=f"Unknown tool: {name}"
            )]
        
        # Format response
        return [types.TextContent(
            type="text",
            text=json.dumps(data, indent=2, ensure_ascii=False)
        )]
        
    except Exception as e:
        return [types.TextContent(
            type="text",
            text=f"Error executing {name}: {str(e)}"
        )]


async def main():
    """Main entry point"""
    async with mcp.server.stdio.stdio_server() as (read_stream, write_stream):
        await server.run(
            read_stream,
            write_stream,
            InitializationOptions(
                server_name="meta-ads-server",
                server_version="1.0.0",
                capabilities=server.get_capabilities(
                    notification_options=NotificationOptions(),
                    experimental_capabilities={},
                ),
            ),
        )


if __name__ == "__main__":
    asyncio.run(main())