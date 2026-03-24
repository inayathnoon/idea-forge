---
name: web-research
description: Structured web research with search → fetch → extract → cite pipeline. Used by researcher agent to find competitors, validation signals, market data with proper sourcing.
metadata:
  inputs:
    - query: string (search query, e.g., "best ecommerce platforms 2026")
    - max_results: integer (how many sources to review, default 5)
    - focus_areas: array (what to extract, e.g., ["competitors", "pricing", "user reviews"])
  outputs:
    - findings: object (structured research findings)
    - sources: array (list of sources with URLs)
    - confidence: string (high/medium/low based on search freshness)
  side_effects: []
  called_by:
    - researcher-4
---

# Web Research Skill

Structured web research with proper sourcing and attribution.

## Purpose

- **Find validation**: Do competitors exist? Is there demand?
- **Inform scope**: What features are table-stakes vs differentiation?
- **Cite sources**: Every claim has a reference URL for credibility

## Process

### Step 1: Search
Use WebSearch tool with targeted query. Return top 5-10 results.

```
Query: "ecommerce platforms india 2026"
Results: [url1, url2, url3, ...]
```

### Step 2: Fetch & Read
For each top 3-5 results, fetch and extract relevant sections.

```
URL: https://example.com/best-ecommerce-2026
Fetch: ✅
Extract: [pricing info, features, user count, reviews]
```

### Step 3: Extract & Synthesize
Organize findings by topic:
- **Competitors**: [name, features, pricing, user base]
- **Market signals**: [growth rate, investment, trends]
- **Validation**: [user reviews, success stories, pain points]

### Step 4: Cite
Every finding includes source URL and publication date.

```
"Shopify dominates Indian ecommerce market (50% SMB share)"
  — Forrester Report, Dec 2025
  — https://...
```

## Output Format

```json
{
  "research_topic": "ecommerce platforms for India",
  "findings": {
    "competitors": [
      {
        "name": "Shopify",
        "market_share": "50% among SMBs",
        "pricing": "$29-299/mo",
        "strengths": ["Easy setup", "Payment integrations"],
        "weaknesses": ["High transaction fees"],
        "source": "https://...",
        "date": "2025-12-01"
      }
    ],
    "market_trends": [
      {
        "trend": "UPI payment adoption",
        "relevance": "Reduces payment friction for Indian users",
        "source": "https://...",
        "date": "2026-02-01"
      }
    ],
    "validation_signals": [
      {
        "signal": "Growing SMB ecommerce adoption",
        "data": "45% of Indian SMBs now sell online",
        "source": "https://...",
        "date": "2025-11-01"
      }
    ]
  },
  "sources": [
    {
      "url": "https://...",
      "title": "2026 Ecommerce Landscape",
      "date": "2025-12-01",
      "relevance": "Market sizing, competitors"
    }
  ],
  "confidence": "high",
  "notes": "Fresh data from reputable sources, published within last 3 months"
}
```

## Quality Criteria

- ✅ Every claim has a source URL + date
- ✅ Sources are recent (< 3 months old for market trends)
- ✅ Multiple sources for major claims (>1 source)
- ✅ Distinguish facts ("Shopify is $29/mo") from opinions ("best platform")
- ✅ No made-up data — if you can't find it, say so
- ✅ Relevance is clear ("why does this matter for our idea?")

## Fallback Strategies

**If search returns few results:**
- Broaden query: "ecommerce platforms india" → "ecommerce india"
- Search for adjacent topics: "small business tools india" instead of specific platform
- Flag: "Limited search results for this topic — market may be very niche"

**If sources are old (>6 months):**
- Flag: "Most recent data is from {date}, market may have changed"
- Still cite, but note freshness concern

**If data conflicts between sources:**
- Report both findings: "Source A says X, Source B says Y"
- Cite both and note discrepancy

## Example Usage

Called by researcher-4 to find competitors:

```bash
web-research \
  --query "CBSE learning apps india 2025-2026" \
  --max-results 5 \
  --focus-areas ["competitors", "user reviews", "pricing"]
```

Returns structured findings on:
- Existing CBSE learning platforms
- Pricing models they use
- User satisfaction signals
- Features that matter to parents

## Tools Used

- WebSearch (find sources)
- WebFetch (read source content)
- Tools used internally, not exposed to user
