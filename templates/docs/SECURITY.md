# Security Posture

Authentication, authorization, data handling, threat model, and compliance.

<!-- Filled during scaffolding by security or architecture agent -->

## Authentication & Authorization

### Auth Model

<!-- OAuth2, JWT, Sessions, API keys — which and why? -->

### User Roles & Permissions

| Role | Permissions | Use Case |
|------|-------------|----------|
| {Role} | | |

## Data Handling

### Sensitive Data Classification

- **Public**: {examples}
- **Internal**: {examples}
- **Confidential**: {examples}

### Storage & Encryption

- In-transit: {protocol}
- At-rest: {encryption}
- Keys: {management strategy}

## Threat Model

### Assets

<!-- What are we protecting? -->

### Threat Actors

<!-- Who might attack? Why? -->

### Attack Vectors

| Vector | Mitigation | Owner |
|--------|-----------|-------|
| {Attack} | | |

## Compliance & Privacy

### Standards

- GDPR: {compliance status}
- CCPA: {compliance status}
- Industry-specific: {standards}

### Data Retention

<!-- How long do we keep data? What's the deletion policy? -->

## Security Checklist

### Development

- [ ] Dependency scanning enabled
- [ ] SAST/code scanning enabled
- [ ] Secrets not committed
- [ ] Input validation on all user inputs

### Deployment

- [ ] Security headers configured
- [ ] HTTPS enforced
- [ ] Rate limiting enabled
- [ ] WAF rules in place

### Monitoring

- [ ] Failed auth attempts logged
- [ ] Suspicious activity alerts
- [ ] Regular security audits scheduled
