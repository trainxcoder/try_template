# GitHub Actions Scripts

This directory contains reusable scripts used by GitHub Actions workflows across the organization.

## detect-project-type.sh

A universal script for detecting project types based on characteristic files and patterns.

### Supported Project Types

| Project Type | Detection Criteria | Confidence Level |
|--------------|-------------------|------------------|
| **Next.js** | `package.json` with `"next"` dependency | High |
| **Python** | `requirements.txt`, `setup.py`, `pyproject.toml`, `Pipfile`, or `poetry.lock` | High |
| **C++** | `CMakeLists.txt`, `Makefile`, `meson.build`, or `configure.ac` | High |
| **C++** | `*.cpp`, `*.cc`, `*.cxx`, `*.hpp`, `*.h` files | Medium |
| **Rust** | `Cargo.toml` | High |
| **Go** | `go.mod` | High |

### Usage

#### Basic Usage (Returns project type string)

```bash
# Returns: nextjs, python, cpp, rust, go, or unknown
PROJECT_TYPE=$(./detect-project-type.sh)
echo "Detected: $PROJECT_TYPE"
```

#### Verbose Mode (Prints detailed detection process)

```bash
./detect-project-type.sh --verbose
```

#### GitHub Actions Mode (Writes to GITHUB_OUTPUT and GITHUB_STEP_SUMMARY)

```bash
./detect-project-type.sh --verbose --github-output --github-summary
```

#### JSON Output Mode

```bash
./detect-project-type.sh --json
# Output: {"project_type":"nextjs","confidence":"high","detected_files":["package.json","next in package.json"]}
```

### Command Line Options

| Option | Description |
|--------|-------------|
| `--verbose` | Print detailed detection information to stderr |
| `--github-output` | Write `project-type=<type>` to `$GITHUB_OUTPUT` |
| `--github-summary` | Write formatted summary to `$GITHUB_STEP_SUMMARY` |
| `--json` | Output result in JSON format with confidence and detected files |

### Exit Codes

- `0`: Project type detected successfully
- `1`: Unknown project type (no match found)

### Examples

#### Example 1: Use in shell script

```bash
#!/bin/bash

PROJECT_TYPE=$(./.github/scripts/detect-project-type.sh)

case $PROJECT_TYPE in
  nextjs)
    echo "Running Next.js specific tasks..."
    npm run build
    ;;
  python)
    echo "Running Python specific tasks..."
    python -m pytest
    ;;
  cpp)
    echo "Running C++ specific tasks..."
    cmake --build build
    ;;
  *)
    echo "Unknown project type"
    exit 1
    ;;
esac
```

#### Example 2: Use in GitHub Actions workflow

```yaml
jobs:
  detect:
    runs-on: ubuntu-latest
    outputs:
      project-type: ${{ steps.detect.outputs.project-type }}
    steps:
      - uses: actions/checkout@v4

      - name: Detect project type
        id: detect
        run: |
          ./.github/scripts/detect-project-type.sh --verbose --github-output --github-summary || true

  build-nextjs:
    needs: detect
    if: needs.detect.outputs.project-type == 'nextjs'
    runs-on: ubuntu-latest
    steps:
      - name: Build Next.js app
        run: npm run build
```

#### Example 3: Use in AI/automation tools

```bash
# Get structured JSON output for programmatic processing
RESULT=$(./detect-project-type.sh --json)
PROJECT_TYPE=$(echo $RESULT | jq -r '.project_type')
CONFIDENCE=$(echo $RESULT | jq -r '.confidence')
FILES=$(echo $RESULT | jq -r '.detected_files[]')

echo "Project: $PROJECT_TYPE (Confidence: $CONFIDENCE)"
echo "Detected from: $FILES"
```

#### Example 4: Use in pre-commit hooks

```bash
#!/bin/bash
# .git/hooks/pre-commit

PROJECT_TYPE=$(./.github/scripts/detect-project-type.sh)

case $PROJECT_TYPE in
  nextjs)
    npm run lint
    ;;
  python)
    python -m pylint src/
    ;;
  cpp)
    clang-format -i src/*.cpp
    ;;
esac
```

### Integration with Workflows

This script is currently used by:

1. **[ci-test.yml](../workflows/ci-test.yml)** - Auto-detects project type for CI tests
2. **[daily-checks.yml](../workflows/daily-checks.yml)** - Auto-detects project type for daily dependency checks
3. **[copilot-instructions.md](../copilot-instructions.md)** - Routes AI assistants to correct instruction files

### Adding New Project Types

To add support for a new project type:

1. Edit `detect-project-type.sh`
2. Add detection logic following the existing pattern
3. Update this README with the new project type
4. Create corresponding workflow files (e.g., `ci-tests-<type>.yml`, `daily-checks-<type>.yml`)
5. Create Copilot instructions file (e.g., `copilot-instructions.<type>.md`)
6. Update the routing table in `copilot-instructions.md`
7. Update the main workflows to call the new project-specific workflows

### Best Practices

- **Always use the centralized script** instead of duplicating detection logic
- **Use `--verbose` mode** during development and debugging
- **Use `|| true`** in GitHub Actions to prevent workflow failures on unknown project types
- **Keep detection criteria simple** and based on standard, well-known files
- **Test changes** to the script with all supported project types

### Testing

Test the script locally with different project types:

```bash
# Test in a Next.js project
cd ~/projects/my-nextjs-app
/path/to/detect-project-type.sh --verbose

# Test in a Python project
cd ~/projects/my-python-app
/path/to/detect-project-type.sh --verbose --json

# Test in a C++ project
cd ~/projects/my-cpp-app
/path/to/detect-project-type.sh --verbose
```

### Troubleshooting

**Q: Script returns "unknown" for my project**
- A: Check if your project has the characteristic files listed above
- Use `--verbose` mode to see what the script is checking

**Q: Script fails with "Permission denied"**
- A: Make sure the script is executable: `chmod +x detect-project-type.sh`

**Q: Detection is incorrect**
- A: Check for conflicting files (e.g., having both `package.json` and `requirements.txt`)
- The script prioritizes in this order: Next.js > Python > C++ > Rust > Go

**Q: How do I use this outside of GitHub Actions?**
- A: Simply run the script from any directory. It works standalone without GitHub Actions environment variables.

### Future Enhancements

Potential improvements:

- [ ] Add support for more project types (Java, Ruby, PHP, etc.)
- [ ] Multi-project detection (monorepo support)
- [ ] Configuration file for custom detection rules
- [ ] Machine learning-based detection for edge cases
- [ ] Performance optimization for large repositories
