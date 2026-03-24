# Reliability Engineering

Uptime targets, monitoring, incident response, and error budgets.

<!-- Filled during scaffolding by DevOps/SRE agent -->

## SLA & Uptime Target

- Target uptime: {%}
- Error budget: {% per month}
- RTO (Recovery Time Objective): {time}
- RPO (Recovery Point Objective): {time}

## Monitoring & Alerting

### Key Metrics

| Metric | Alert Threshold | Owner |
|--------|-----------------|-------|
| {Metric} | {threshold} | {on-call} |

### Alert Routing

```
{Tool} → {Slack channel} → {Escalation}
```

## Incident Response

### Severity Levels

- **Critical**: {definition} → Response: {time}
- **High**: {definition} → Response: {time}
- **Medium**: {definition} → Response: {time}

### On-Call Rotation

- {Team/Person A}: {dates}
- {Team/Person B}: {dates}

### Runbooks

<!-- Links to step-by-step incident response procedures -->

## Error Budget Spending

<!-- How we track and manage error budget consumption -->

## Disaster Recovery

### Backup Strategy

- Frequency: {interval}
- Retention: {duration}
- Test restores: {frequency}

### Failover Procedures

<!-- RTO/RPO targets and how we achieve them -->
