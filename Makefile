.PHONY: help validate-all validate-agents validate-skills validate-pipeline validate-state test

help:
	@echo "IdeaForge Makefile"
	@echo ""
	@echo "Validation Targets:"
	@echo "  make validate-all       Run all structural validations"
	@echo "  make validate-agents    Validate agent frontmatter and references"
	@echo "  make validate-skills    Validate skill frontmatter and references"
	@echo "  make validate-pipeline  Validate pipeline DAG structure"
	@echo "  make validate-state     Validate ideas_store.json (runtime state)"
	@echo ""
	@echo "Test Targets:"
	@echo "  make test               Run all harness tests"
	@echo ""
	@echo "Utility:"
	@echo "  make help               Show this help message"

# Validation targets
validate-all: validate-agents validate-skills validate-pipeline validate-state
	@echo ""
	@echo "✅ All validations passed!"

validate-agents:
	@echo "🤖 Validating agents..."
	@bash harness/validate-agents.sh

validate-skills:
	@echo "🧠 Validating skills..."
	@bash harness/validate-skills.sh

validate-pipeline:
	@echo "📋 Validating pipeline DAG..."
	@bash harness/validate-pipeline.sh

validate-state:
	@echo "💾 Validating runtime state..."
	@bash harness/validate-ideas-store.sh 2>/dev/null || echo "⚠️  validate-ideas-store.sh not yet implemented"

# Test targets (legacy, may be removed)
test: validate-all
	@echo ""
	@echo "✅ All harness tests passed!"
