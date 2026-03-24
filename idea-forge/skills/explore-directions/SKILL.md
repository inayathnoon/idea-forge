---
name: explore-directions
description: Generates 10 distinct directions an idea could take, picks the top 3 most interesting, and identifies the 1 closest to what the user described. Run as a single step.
metadata:
  inputs: []
  outputs: []
  side_effects: []
  called_by:
    - idea-explorer
---

# Explore Directions

Run all three steps in sequence:

## Step 1 — Generate 10 directions
Generate **10 distinct directions** the idea could take. Each = a concrete angle.
Make them distinct, not variations of the same thing.

Examples: "B2B SaaS for small teams", "Consumer app with freemium", "Open-source toolkit"

## Step 2 — Pick top 3
From the 10, choose the **3 most interesting** to highlight. Prioritise directions with strong differentiation, clear monetisation, or unique angles.

## Step 3 — Identify closest
From the 10, pick **1** that is closest to what the user actually described. This becomes the default selected direction. Include it in the top 3 if it isn't already.
