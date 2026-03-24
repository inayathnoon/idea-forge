# ARCHITECTURE Specification

System Architecture — how the product is built, not what it does.

## Required Sections

1. **Components** (diagram + list)
   - Major architectural pieces
   - Responsibilities of each
   - How they communicate
   - External dependencies

2. **Data Flow** (diagrams + descriptions)
   - How data moves through the system
   - Request → response cycle
   - Database schema sketch (if relevant)
   - State management approach

3. **Technology Choices** (1-2 sentences per choice)
   - Frontend technology & why
   - Backend technology & why
   - Database & why
   - Infrastructure & why
   - **Key**: justify each choice, don't just list

4. **Key Design Decisions** (3-5 decisions)
   - What was the choice? (A vs B)
   - Why did we pick A?
   - What trade-offs did we accept?
   - When might we revisit?

5. **Scalability & Performance** (brief)
   - Any known bottlenecks?
   - How will it scale to 10x users?
   - Performance assumptions (page load time, response time, etc.)

6. **Security Considerations** (brief)
   - User data protection
   - Authentication & authorization approach
   - Known risks

7. **Deployment & Operations** (brief)
   - How does it get deployed?
   - Monitoring & alerting
   - Backup & recovery

## Quality Criteria

- ✅ A junior engineer could understand the system from this
- ✅ Every choice is justified, not just listed
- ✅ Diagrams are clear and labeled
- ✅ Data flows are explicit
- ✅ Trade-offs are acknowledged
- ✅ No hand-waving ("we'll optimize later")

## Common Pitfalls

- ❌ Lists of technologies without justification
- ❌ Design decisions that aren't actually decisions (no alternatives considered)
- ❌ Ignoring data flow ("just assume it works")
- ❌ Treating ARCHITECTURE as infrastructure setup guide
- ❌ Over-engineering for scale that won't happen
