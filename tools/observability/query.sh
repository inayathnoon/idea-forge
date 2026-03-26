#!/bin/bash

# Observability Stack Query Tool
# Agent CLI to query Loki (logs), Prometheus (metrics), and Jaeger (traces)
# Usage:
#   ./query.sh health
#   ./query.sh logs '{level="error"}' --last 5m
#   ./query.sh metrics 'http_request_duration_seconds_count'
#   ./query.sh traces 'myapp'

set -e

# Config
LOKI_URL="http://localhost:3100"
PROMETHEUS_URL="http://localhost:9090"
JAEGER_URL="http://localhost:16686"
JAEGER_API="http://localhost:14268"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper: convert duration to seconds
duration_to_seconds() {
  local dur=$1
  case $dur in
    *m) echo $((${dur%m} * 60)) ;;
    *h) echo $((${dur%h} * 3600)) ;;
    *s) echo ${dur%s} ;;
    *d) echo $((${dur%d} * 86400)) ;;
    *)  echo 300 ;; # default 5m
  esac
}

# Health check
health() {
  echo "==================================================================="
  echo "🏥 Observability Stack Health"
  echo "==================================================================="

  local loki_status="DOWN"
  local prometheus_status="DOWN"
  local jaeger_status="DOWN"

  if curl -sf "$LOKI_URL/ready" > /dev/null 2>&1; then
    loki_status="OK"
  fi

  if curl -sf "$PROMETHEUS_URL/-/ready" > /dev/null 2>&1; then
    prometheus_status="OK"
  fi

  if curl -sf "$JAEGER_API" > /dev/null 2>&1; then
    jaeger_status="OK"
  fi

  # Print status
  echo "Loki (logs)        : $loki_status [$LOKI_URL]"
  echo "Prometheus (metrics): $prometheus_status [$PROMETHEUS_URL]"
  echo "Jaeger (traces)    : $jaeger_status [$JAEGER_URL]"
  echo ""

  # Overall status
  if [[ "$loki_status" == "OK" && "$prometheus_status" == "OK" && "$jaeger_status" == "OK" ]]; then
    echo -e "${GREEN}✅ All services healthy${NC}"
    echo "==================================================================="
    return 0
  else
    echo -e "${RED}❌ Some services down${NC}"
    echo "Start stack: docker compose -f tools/observability/docker-compose.yml up -d"
    echo "==================================================================="
    return 1
  fi
}

# Query logs via LogQL
query_logs() {
  local logql=$1
  local last_duration=${2:-5m}
  local last_seconds=$(duration_to_seconds "$last_duration")
  local now=$(date +%s)
  local start=$((now - last_seconds))

  echo "==================================================================="
  echo "📝 Loki Query: $logql"
  echo "   Duration: $last_duration"
  echo "==================================================================="

  # Convert to nanoseconds (Loki uses ns)
  local start_ns=$((start * 1000000000))
  local end_ns=$((now * 1000000000))

  local response=$(curl -s "$LOKI_URL/loki/api/v1/query_range" \
    --data-urlencode "query=$logql" \
    --data-urlencode "start=$start_ns" \
    --data-urlencode "end=$end_ns" \
    --data-urlencode "limit=100")

  # Parse and pretty-print
  if echo "$response" | jq -e '.data.result[0]' > /dev/null 2>&1; then
    echo "$response" | jq '.data.result[] | {labels, values: .values[-5:]}'
    echo ""
  else
    echo "No results found"
    echo ""
  fi
}

# Query metrics via PromQL
query_metrics() {
  local promql=$1

  echo "==================================================================="
  echo "📊 Prometheus Query: $promql"
  echo "==================================================================="

  local response=$(curl -s "$PROMETHEUS_URL/api/v1/query" \
    --data-urlencode "query=$promql")

  # Parse and pretty-print
  if echo "$response" | jq -e '.data.result[0]' > /dev/null 2>&1; then
    echo "$response" | jq '.data.result[] | {metric, value}'
    echo ""
  else
    echo "No results found"
    echo ""
  fi
}

# Query traces via Jaeger
query_traces() {
  local service=$1

  echo "==================================================================="
  echo "🔍 Jaeger Traces: $service"
  echo "   UI: $JAEGER_URL"
  echo "==================================================================="

  local response=$(curl -s "$JAEGER_API/api/traces?service=$service&limit=10")

  # Parse and pretty-print
  if echo "$response" | jq -e '.data[0]' > /dev/null 2>&1; then
    local count=$(echo "$response" | jq '.data | length')
    echo "Found $count traces:"
    echo "$response" | jq '.data[] | {traceID, duration, spans: (.spans | length)}'
    echo ""
  else
    echo "No traces found for service: $service"
    echo ""
  fi
}

# Main
case "${1:-help}" in
  health)
    health
    ;;
  logs)
    if [ $# -lt 2 ]; then
      echo "Usage: $0 logs <logql> [--last <duration>]"
      exit 1
    fi
    query_logs "$2" "${4:-5m}"
    ;;
  metrics)
    if [ $# -lt 2 ]; then
      echo "Usage: $0 metrics <promql>"
      exit 1
    fi
    query_metrics "$2"
    ;;
  traces)
    if [ $# -lt 2 ]; then
      echo "Usage: $0 traces <service>"
      exit 1
    fi
    query_traces "$2"
    ;;
  *)
    echo "Symphony Observability Stack Query Tool"
    echo ""
    echo "Commands:"
    echo "  health                              Check stack health"
    echo "  logs <logql> [--last <duration>]    Query logs with LogQL"
    echo "  metrics <promql>                    Query metrics with PromQL"
    echo "  traces <service>                    Query traces by service"
    echo ""
    echo "Examples:"
    echo "  $0 health"
    echo "  $0 logs '{level=\"error\"}' --last 5m"
    echo "  $0 metrics 'http_request_duration_seconds_count'"
    echo "  $0 traces 'myapp'"
    echo ""
    exit 1
    ;;
esac
