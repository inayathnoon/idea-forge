# System Architecture

High-level design of the system: components, responsibilities, data flow, and key decisions.

<!-- Filled by arch-writer agent during planning phase -->

## System Overview

### Vision

<!-- What is this system trying to achieve? What problem does it solve at scale? -->

### Core Components

<!-- Major subsystems and their responsibilities -->

```
┌─────────────────────────────────┐
│     {User Interface}            │
│     {Framework/Technology}      │
└──────────────┬──────────────────┘
               │
┌──────────────▼──────────────────┐
│     {API/Service Layer}         │
│     {Technology}                │
└──────────────┬──────────────────┘
               │
┌──────────────▼──────────────────┐
│     {Data/Storage Layer}        │
│     {Database Technology}       │
└─────────────────────────────────┘
```

## Component Details

### {Component Name}

**Responsibility:**
<!-- What does this component do? Why does it exist? -->

**Technology:**
<!-- Programming language, framework, libraries -->

**External Dependencies:**
<!-- What does it depend on? -->

**Key Files:**
```
src/{component}/
├── index.ts
├── types.ts
├── service.ts
└── tests/
```

## Data Model

### Core Entities

<!-- Database schema / data structures -->

```
User
├── id: UUID
├── email: String
├── created_at: DateTime
└── ...

Project
├── id: UUID
├── owner_id: FK(User)
├── name: String
└── ...
```

See [docs/generated/db-schema.md](docs/generated/db-schema.md) for full schema.

## API Surface

### Key Endpoints

<!-- REST/GraphQL/gRPC endpoints and their purposes -->

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/users` | GET | List users |
| `/api/users` | POST | Create user |
| `/api/projects/{id}` | GET | Get project |

## External Services & Integrations

<!-- Third-party services, APIs, SaaS tools -->

| Service | Purpose | Authentication |
|---------|---------|----------------|
| {Service} | {Purpose} | {Auth method} |

## Deployment & Infrastructure

### Production Environment

- **Hosting:** {Cloud provider or self-hosted}
- **Container Runtime:** {Docker / K8s / Lambda / etc.}
- **Database:** {Managed or self-hosted}
- **Caching:** {Redis / Memcached / etc.}

### CI/CD Pipeline

<!-- How code flows from commit to production -->

```
Git Push → {CI Server} → Tests → Build → Deploy to {Env}
```

## Scaling & Performance

### Bottlenecks & Solutions

| Potential Bottleneck | Current Approach | Future Plan |
|---------------------|------------------|-------------|
| {Bottleneck} | {Solution} | {Roadmap} |

### Caching Strategy

<!-- Where do we cache? How is invalidation handled? -->

### Database Optimization

<!-- Indexing strategy, query optimization, sharding plans -->

## Security Architecture

See [docs/SECURITY.md](docs/SECURITY.md) for detailed security model, auth strategy, and threat model.

### Trust Boundaries

<!-- Where do we trust data? Where do we validate? -->

## Monitoring & Observability

See [docs/RELIABILITY.md](docs/RELIABILITY.md) for detailed monitoring, alerting, and incident response.

### Key Metrics

<!-- Latency, throughput, error rate, resource utilization -->

## Testing Strategy

### Test Pyramid

```
      /\         E2E Tests (slow, UI-focused)
     /  \
    /────\       Integration Tests (API-focused)
   /      \
  /────────\     Unit Tests (fast, isolated)
 /          \
```

## Decisions & Trade-offs

See [docs/design-docs/](docs/design-docs/) for detailed decision records explaining the "why" behind each architectural choice.

### Key Decisions

- **Why {Technology} instead of {Alternative}?** → See [docs/design-docs/...](docs/design-docs/)
- **Why {Pattern} instead of {Alternative}?** → See [docs/design-docs/...](docs/design-docs/)

## Future Architecture Changes

<!-- Planned refactoring, migrations, or major rewrites -->

See [docs/PLANS.md](docs/PLANS.md) and [docs/exec-plans/](docs/exec-plans/) for detailed roadmap.
