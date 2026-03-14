# GitHub Copilot Instructions

**Dynamic Context Loading**: Automatically load project-specific instructions based on project type.

## Quick Start

1. **Detect project type**: Run `./.github/scripts/detect-project-type.sh` OR check these files:
   - Next.js: `package.json` with "next"
   - Python: `requirements.txt`, `pyproject.toml`, `setup.py`
   - C++: `CMakeLists.txt`, `Makefile`, `*.cpp`
   - Rust: `Cargo.toml`
   - Go: `go.mod`

2. **Load instructions**: Based on detected type, read ONE file:

| Type | File to Read |
|------|--------------|
| nextjs | `.github/copilot-instructions.nextjs.md` |
| python | `.github/copilot-instructions.python.md` |
| cpp | `.github/copilot-instructions.cpp.md` |
| rust | `.github/copilot-instructions.rust.md` |
| go | `.github/copilot-instructions.go.md` |

3. **AI workflows/skills**: If user mentions "skill", "workflow", or "automation", also read:
   - `.github/copilot-instructions.ai.md`

## That's it!

Keep loaded instructions in memory for the session. Re-detect only if switching project types.
