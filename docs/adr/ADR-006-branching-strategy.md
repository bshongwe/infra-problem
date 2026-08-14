# ADR-006: Create devops-assessment Branch for Infrastructure Solution

**Status**: Accepted  
**Date**: 2024-08-14  
**Deciders**: DevOps Assessment Team

## Context

The repository has two branches:
- `master`: Doesn't work (broken)
- `develop`: Working application code

We need to add infrastructure code (Docker, Terraform, docs) without modifying the working application code. The question is: where should this infrastructure code live?

Options:
1. Add directly to `develop` branch
2. Create a new branch from `develop`
3. Fork the repository
4. Create a separate infrastructure repository

## Decision

We will create a new branch called **`devops-assessment`** from `develop`:

```
develop (baseline - working app code)
    └── devops-assessment (our solution - infrastructure + docs)
```

### Rationale
- Preserves original `develop` branch untouched
- Clear separation between application code and infrastructure
- Easy to review infrastructure changes separately
- Can be merged or rebased if needed
- Follows GitFlow-like branching model

## Consequences

### Positive
- **Clean separation**: Application code vs infrastructure code
- **Easy review**: PR shows only infrastructure changes
- **Non-invasive**: Doesn't modify client's working code
- **Reversible**: Can delete branch without affecting develop
- **Clear ownership**: DevOps solution is distinct from app code
- **Portable**: Can cherry-pick or rebase as needed

### Negative
- **Branch overhead**: Need to maintain two branches
- **Sync issues**: If develop advances, may need to rebase
- **Confusion**: Need to explain branch structure to users
- **Merge complexity**: If changes need to go to develop, requires merge

## Branch Naming

**Why `devops-assessment`?**
- Descriptive of purpose (DevOps work for assessment)
- Professional and clear
- Easy to understand in GitHub UI
- Follows convention: `<purpose>-<project>`

**Alternatives considered:**
- `devops` - too generic
- `infrastructure` - unclear it's for assessment
- `solution` - vague
- `assessment` - could be confused with code assessment

## Workflow

### For Evaluators
```bash
git clone https://github.com/melio-consulting/infra-problem.git
cd infra-problem
git checkout devops-assessment
```

### For Our Team
```bash
git checkout develop                    # Start from working code
git checkout -b devops-assessment       # Create solution branch
# Add infrastructure code
git commit -m "Add DevOps solution"
git push -u origin devops-assessment    # Push to remote
```

### If develop advances
```bash
git checkout devops-assessment
git rebase develop                      # Rebase on latest develop
# Resolve any conflicts
git push --force-with-lease             # Update remote
```

## Directory Structure on devops-assessment

```
infra-problem/
├── (original develop files)
│   ├── quotes/
│   ├── newsfeed/
│   ├── front-end/
│   └── common-utils/
├── (new infrastructure files)
│   ├── docker-compose.yml
│   ├── Dockerfiles
│   ├── infra/ (Terraform)
│   ├── docs/ (documentation)
│   └── build.sh
└── README.md (updated)
```

## Git Configuration

```bash
# Show all branches
git branch -a

# Switch between branches
git checkout develop        # Working app code
git checkout devops-assessment  # Infrastructure solution
```

## Related Decisions
- ADR-001: Docker for consistency (implemented on this branch)
- ADR-002: Terraform for IaC (implemented on this branch)
- ADR-003: DigitalOcean (implemented on this branch)

## Notes

- The `master` branch is ignored (doesn't work)
- `develop` is the canonical source for application code
- `devops-assessment` contains our complete solution
- All infrastructure code, docs, and ADRs on this branch
