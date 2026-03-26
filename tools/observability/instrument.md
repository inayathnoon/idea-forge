# Application Instrumentation Guide

This guide explains how to instrument your application to send logs, metrics, and traces to the local observability stack (Loki, Prometheus, Jaeger).

## Prerequisites

Start the observability stack:

```bash
docker compose -f tools/observability/docker-compose.yml up -d
bash tools/observability/query.sh health  # verify all services are ready
```

## Node.js / Express

### Install packages

```bash
npm install --save \
  @opentelemetry/sdk-node \
  @opentelemetry/api \
  @opentelemetry/auto-instrumentations-node \
  @opentelemetry/sdk-trace-node \
  @opentelemetry/exporter-trace-otlp-http \
  @opentelemetry/sdk-metrics \
  @opentelemetry/exporter-metrics-otlp-http \
  @opentelemetry/resources \
  @opentelemetry/semantic-conventions
```

### Add to app startup (BEFORE all other imports)

Create `instrumentation.js`:

```javascript
const { NodeSDK } = require('@opentelemetry/sdk-node');
const { OTLPTraceExporter } = require('@opentelemetry/exporter-trace-otlp-http');
const { OTLPMetricExporter } = require('@opentelemetry/exporter-metrics-otlp-http');
const { PeriodicExportingMetricReader } = require('@opentelemetry/sdk-metrics');
const { getNodeAutoInstrumentations } = require('@opentelemetry/auto-instrumentations-node');
const { Resource } = require('@opentelemetry/resources');
const { SemanticResourceAttributes } = require('@opentelemetry/semantic-conventions');

const sdk = new NodeSDK({
  resource: new Resource({
    [SemanticResourceAttributes.SERVICE_NAME]: 'myapp',
    [SemanticResourceAttributes.SERVICE_VERSION]: '1.0.0',
  }),
  traceExporter: new OTLPTraceExporter({
    url: 'http://localhost:4318/v1/traces',
  }),
  metricReader: new PeriodicExportingMetricReader(
    new OTLPMetricExporter({
      url: 'http://localhost:4318/v1/metrics',
    })
  ),
  instrumentations: [getNodeAutoInstrumentations()],
});

sdk.start();

console.log('OpenTelemetry initialized');

process.on('SIGTERM', () => {
  sdk.shutdown()
    .then(() => process.exit(0))
    .catch((err) => console.error('SDK shutdown error:', err));
});
```

In `package.json`, update start script:

```json
{
  "scripts": {
    "start": "node -r ./instrumentation.js index.js"
  }
}
```

### Verify

Run your app:

```bash
npm start
```

Check that traces/metrics appear:

```bash
bash tools/observability/query.sh traces 'myapp'
bash tools/observability/query.sh metrics 'http_request_duration_seconds_count'
```

## Python / FastAPI

### Install packages

```bash
pip install opentelemetry-sdk opentelemetry-exporter-otlp opentelemetry-instrumentation-fastapi
```

### Add to app initialization

```python
from opentelemetry import trace, metrics
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import SimpleSpanProcessor
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.exporter.otlp.proto.http.metric_exporter import OTLPMetricExporter
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.sdk.resources import Resource

# Create resource
resource = Resource.create({
    "service.name": "myapp",
    "service.version": "1.0.0",
})

# Traces
trace_exporter = OTLPSpanExporter(
    endpoint="http://localhost:4318/v1/traces",
)
trace_provider = TracerProvider(resource=resource)
trace_provider.add_span_processor(SimpleSpanProcessor(trace_exporter))
trace.set_tracer_provider(trace_provider)

# Metrics
metric_exporter = OTLPMetricExporter(
    endpoint="http://localhost:4318/v1/metrics"
)
metric_reader = PeriodicExportingMetricReader(metric_exporter)
metrics_provider = MeterProvider(resource=resource, metric_readers=[metric_reader])
metrics.set_meter_provider(metrics_provider)

# Instrument FastAPI
from fastapi import FastAPI
app = FastAPI()
FastAPIInstrumentor.instrument_app(app)
```

### Verify

Run your app:

```bash
python main.py
```

Check that traces/metrics appear:

```bash
bash tools/observability/query.sh traces 'myapp'
bash tools/observability/query.sh metrics 'process_runtime_go_goroutines' # or python equivalent
```

## Querying the Stack

### Logs (LogQL)

```bash
# All errors
bash tools/observability/query.sh logs '{level="error"}'

# Last 10 minutes
bash tools/observability/query.sh logs '{level="error"}' --last 10m

# Specific service
bash tools/observability/query.sh logs '{service="myapp"}'
```

### Metrics (PromQL)

```bash
# HTTP request count
bash tools/observability/query.sh metrics 'http_requests_total'

# Request duration
bash tools/observability/query.sh metrics 'http_request_duration_seconds'

# Memory usage
bash tools/observability/query.sh metrics 'process_resident_memory_bytes'
```

### Traces (Jaeger)

```bash
# View all traces for a service
bash tools/observability/query.sh traces 'myapp'

# Open UI
open http://localhost:16686
```

## Integration with Symphony Executor

The executor automatically queries the stack during validation (Step 6):

```bash
bash tools/observability/query.sh health       # check stack running
bash tools/observability/query.sh logs '{level="error"}' --last 1m  # check for errors
bash tools/observability/query.sh metrics 'http_request_duration_seconds'  # check performance
```

## Troubleshooting

### Stack not running

```bash
docker compose -f tools/observability/docker-compose.yml up -d
bash tools/observability/query.sh health
```

### No data appearing

- Verify app is sending to `http://localhost:4318/v1/traces` and `/v1/metrics`
- Check docker logs: `docker logs symphony-vector`
- Verify service name matches (e.g., "myapp")

### Docker permission denied

```bash
# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```
