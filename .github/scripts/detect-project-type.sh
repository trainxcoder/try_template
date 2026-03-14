#!/bin/bash
# detect-project-type.sh
#
# Reusable script to detect project type based on characteristic files
# Returns: nextjs, python, cpp, or unknown
#
# Usage:
#   ./detect-project-type.sh [--verbose] [--github-output] [--github-summary]
#
# Options:
#   --verbose          : Print detailed detection information
#   --github-output    : Write to $GITHUB_OUTPUT for GitHub Actions
#   --github-summary   : Write to $GITHUB_STEP_SUMMARY for GitHub Actions
#   --json             : Output result in JSON format
#
# Exit codes:
#   0: Project type detected successfully
#   1: Unknown project type
#
# Examples:
#   # Simple usage
#   PROJECT_TYPE=$(./detect-project-type.sh)
#   echo "Detected: $PROJECT_TYPE"
#
#   # In GitHub Actions
#   ./detect-project-type.sh --verbose --github-output --github-summary
#
#   # JSON output
#   ./detect-project-type.sh --json
#   # Output: {"project_type":"nextjs","confidence":"high","detected_files":["package.json"]}

set -euo pipefail

# Parse command line arguments
VERBOSE=false
GITHUB_OUTPUT_MODE=false
GITHUB_SUMMARY_MODE=false
JSON_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose)
            VERBOSE=true
            shift
            ;;
        --github-output)
            GITHUB_OUTPUT_MODE=true
            shift
            ;;
        --github-summary)
            GITHUB_SUMMARY_MODE=true
            shift
            ;;
        --json)
            JSON_MODE=true
            shift
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
done

# Function to print verbose messages
verbose_log() {
    if [ "$VERBOSE" = true ]; then
        echo "$1" >&2
    fi
}

# Function to write to GitHub Output
github_output() {
    if [ "$GITHUB_OUTPUT_MODE" = true ] && [ -n "${GITHUB_OUTPUT:-}" ]; then
        echo "$1" >> "$GITHUB_OUTPUT"
    fi
}

# Function to write to GitHub Step Summary
github_summary() {
    if [ "$GITHUB_SUMMARY_MODE" = true ] && [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
        echo "$1" >> "$GITHUB_STEP_SUMMARY"
    fi
}

# Initialize detection variables
PROJECT_TYPE="unknown"
CONFIDENCE="low"
DETECTED_FILES=()

verbose_log "🔍 Starting project type detection..."

# Check for Next.js project
if [ -f "package.json" ]; then
    DETECTED_FILES+=("package.json")
    verbose_log "  ✓ Found package.json"

    if grep -q '"next"' package.json 2>/dev/null; then
        PROJECT_TYPE="nextjs"
        CONFIDENCE="high"
        DETECTED_FILES+=("next in package.json")
        verbose_log "  ✓ Detected Next.js dependency"
        verbose_log "✅ Detected: Next.js project (high confidence)"

        github_output "project-type=nextjs"
        github_summary "## 🎯 Detected Project Type: Next.js"
        github_summary ""
        github_summary "**Confidence:** High"
        github_summary "**Detected by:** package.json with 'next' dependency"

        if [ "$JSON_MODE" = true ]; then
            echo "{\"project_type\":\"nextjs\",\"confidence\":\"high\",\"detected_files\":[\"package.json\",\"next in package.json\"]}"
        else
            echo "nextjs"
        fi
        exit 0
    fi
fi

# Check for Python project
verbose_log "  Checking for Python project markers..."
PYTHON_MARKERS=()

if [ -f "requirements.txt" ]; then
    PYTHON_MARKERS+=("requirements.txt")
    verbose_log "  ✓ Found requirements.txt"
fi

if [ -f "setup.py" ]; then
    PYTHON_MARKERS+=("setup.py")
    verbose_log "  ✓ Found setup.py"
fi

if [ -f "pyproject.toml" ]; then
    PYTHON_MARKERS+=("pyproject.toml")
    verbose_log "  ✓ Found pyproject.toml"
fi

if [ -f "Pipfile" ]; then
    PYTHON_MARKERS+=("Pipfile")
    verbose_log "  ✓ Found Pipfile"
fi

if [ -f "poetry.lock" ]; then
    PYTHON_MARKERS+=("poetry.lock")
    verbose_log "  ✓ Found poetry.lock"
fi

if [ ${#PYTHON_MARKERS[@]} -gt 0 ]; then
    PROJECT_TYPE="python"
    CONFIDENCE="high"
    DETECTED_FILES+=("${PYTHON_MARKERS[@]}")
    verbose_log "✅ Detected: Python project (high confidence)"

    github_output "project-type=python"
    github_summary "## 🎯 Detected Project Type: Python"
    github_summary ""
    github_summary "**Confidence:** High"
    github_summary "**Detected by:** ${PYTHON_MARKERS[*]}"

    if [ "$JSON_MODE" = true ]; then
        PYTHON_FILES_JSON=$(printf '%s\n' "${PYTHON_MARKERS[@]}" | jq -R . | jq -s .)
        echo "{\"project_type\":\"python\",\"confidence\":\"high\",\"detected_files\":$PYTHON_FILES_JSON}"
    else
        echo "python"
    fi
    exit 0
fi

# Check for C++ project
verbose_log "  Checking for C++ project markers..."
CPP_MARKERS=()

if [ -f "CMakeLists.txt" ]; then
    CPP_MARKERS+=("CMakeLists.txt")
    verbose_log "  ✓ Found CMakeLists.txt"
fi

if [ -f "Makefile" ]; then
    CPP_MARKERS+=("Makefile")
    verbose_log "  ✓ Found Makefile"
fi

if [ -f "meson.build" ]; then
    CPP_MARKERS+=("meson.build")
    verbose_log "  ✓ Found meson.build"
fi

if [ -f "configure.ac" ]; then
    CPP_MARKERS+=("configure.ac")
    verbose_log "  ✓ Found configure.ac (autotools)"
fi

if [ ${#CPP_MARKERS[@]} -gt 0 ]; then
    PROJECT_TYPE="cpp"
    CONFIDENCE="high"
    DETECTED_FILES+=("${CPP_MARKERS[@]}")
    verbose_log "✅ Detected: C++ project (high confidence)"

    github_output "project-type=cpp"
    github_summary "## 🎯 Detected Project Type: C++"
    github_summary ""
    github_summary "**Confidence:** High"
    github_summary "**Detected by:** ${CPP_MARKERS[*]}"

    if [ "$JSON_MODE" = true ]; then
        CPP_FILES_JSON=$(printf '%s\n' "${CPP_MARKERS[@]}" | jq -R . | jq -s .)
        echo "{\"project_type\":\"cpp\",\"confidence\":\"high\",\"detected_files\":$CPP_FILES_JSON}"
    else
        echo "cpp"
    fi
    exit 0
fi

# Check for C++ source files (lower confidence)
verbose_log "  Checking for C++ source files..."
if find . -maxdepth 3 -type f \( -name "*.cpp" -o -name "*.cc" -o -name "*.cxx" -o -name "*.hpp" -o -name "*.h" \) 2>/dev/null | grep -q .; then
    PROJECT_TYPE="cpp"
    CONFIDENCE="medium"
    DETECTED_FILES+=("C++ source files")
    verbose_log "✅ Detected: C++ project by source files (medium confidence)"

    github_output "project-type=cpp"
    github_summary "## 🎯 Detected Project Type: C++"
    github_summary ""
    github_summary "**Confidence:** Medium"
    github_summary "**Detected by:** C++ source files (*.cpp, *.cc, *.cxx, *.hpp, *.h)"
    github_summary ""
    github_summary "⚠️ No build system detected. Consider adding CMakeLists.txt or Makefile."

    if [ "$JSON_MODE" = true ]; then
        echo "{\"project_type\":\"cpp\",\"confidence\":\"medium\",\"detected_files\":[\"*.cpp, *.cc, *.cxx files\"]}"
    else
        echo "cpp"
    fi
    exit 0
fi

# Check for Rust project
verbose_log "  Checking for Rust project markers..."
if [ -f "Cargo.toml" ]; then
    PROJECT_TYPE="rust"
    CONFIDENCE="high"
    DETECTED_FILES+=("Cargo.toml")
    verbose_log "✅ Detected: Rust project (high confidence)"

    github_output "project-type=rust"
    github_summary "## 🎯 Detected Project Type: Rust"
    github_summary ""
    github_summary "**Confidence:** High"
    github_summary "**Detected by:** Cargo.toml"

    if [ "$JSON_MODE" = true ]; then
        echo "{\"project_type\":\"rust\",\"confidence\":\"high\",\"detected_files\":[\"Cargo.toml\"]}"
    else
        echo "rust"
    fi
    exit 0
fi

# Check for Go project
verbose_log "  Checking for Go project markers..."
if [ -f "go.mod" ]; then
    PROJECT_TYPE="go"
    CONFIDENCE="high"
    DETECTED_FILES+=("go.mod")
    verbose_log "✅ Detected: Go project (high confidence)"

    github_output "project-type=go"
    github_summary "## 🎯 Detected Project Type: Go"
    github_summary ""
    github_summary "**Confidence:** High"
    github_summary "**Detected by:** go.mod"

    if [ "$JSON_MODE" = true ]; then
        echo "{\"project_type\":\"go\",\"confidence\":\"high\",\"detected_files\":[\"go.mod\"]}"
    else
        echo "go"
    fi
    exit 0
fi

# Unknown project type
verbose_log "❌ Unknown project type"
github_output "project-type=unknown"
github_summary "## ❌ Unknown Project Type"
github_summary ""
github_summary "Could not detect project type. Supported types:"
github_summary "- **Next.js**: package.json with 'next' dependency"
github_summary "- **Python**: requirements.txt, setup.py, pyproject.toml, Pipfile, or poetry.lock"
github_summary "- **C++**: CMakeLists.txt, Makefile, meson.build, or *.cpp files"
github_summary "- **Rust**: Cargo.toml"
github_summary "- **Go**: go.mod"

if [ "$JSON_MODE" = true ]; then
    echo "{\"project_type\":\"unknown\",\"confidence\":\"none\",\"detected_files\":[]}"
else
    echo "unknown"
fi

exit 1
