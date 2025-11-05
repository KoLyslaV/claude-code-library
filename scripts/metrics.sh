#!/bin/bash
# metrics.sh - Track library usage and calculate ROI
# Usage: metrics.sh [options]
# Provides insights into library usage patterns and time savings

set -e

VERSION="1.0.0"
METRICS_DIR="$HOME/.claude-library/.metrics"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

usage() {
    cat << EOF
${BLUE}Claude Code Library - Usage Metrics & ROI${NC}
Version: $VERSION

${YELLOW}USAGE:${NC}
  $0 [options]

${YELLOW}OPTIONS:${NC}
  --report         Generate detailed usage report
  --roi            Calculate ROI (time saved)
  --summary        Quick summary (default)
  --reset          Reset all metrics
  --export         Export metrics to JSON
  --help           Show this help

${YELLOW}EXAMPLES:${NC}
  $0                 # Show quick summary
  $0 --report        # Detailed report
  $0 --roi           # ROI calculation
  $0 --export        # Export to JSON

${YELLOW}WHAT IT TRACKS:${NC}
  - Script execution counts
  - Projects created per boilerplate
  - Time saved calculations
  - Usage patterns
  - Most used commands

EOF
    exit 0
}

# Ensure metrics directory exists
init_metrics() {
    mkdir -p "$METRICS_DIR"

    # Initialize metrics file if doesn't exist
    if [ ! -f "$METRICS_DIR/usage.json" ]; then
        cat > "$METRICS_DIR/usage.json" << 'EOF'
{
  "version": "1.0.0",
  "first_use": "",
  "last_use": "",
  "scripts": {
    "init-project": { "count": 0, "time_saved_min": 12.5 },
    "morning-setup": { "count": 0, "time_saved_min": 7.5 },
    "validate-structure": { "count": 0, "time_saved_min": 7.5 },
    "anti-pattern-detector": { "count": 0, "time_saved_min": 45 },
    "feature-workflow": { "count": 0, "time_saved_min": 45 },
    "bug-hunter": { "count": 0, "time_saved_min": 90 },
    "doc-sprint": { "count": 0, "time_saved_min": 17.5 },
    "crisis-mode": { "count": 0, "time_saved_min": 180 }
  },
  "boilerplates": {
    "webapp": 0,
    "website": 0,
    "python-cli": 0
  }
}
EOF
    fi
}

# Log script usage
log_usage() {
    local script_name=$1
    init_metrics

    # Update usage count and timestamp
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Use jq to update JSON if available, else skip (metrics are optional)
    if command -v jq &> /dev/null; then
        local tmp_file
        tmp_file=$(mktemp)

        # Update script count
        jq ".scripts[\"$script_name\"].count += 1 | .last_use = \"$TIMESTAMP\"" \
           "$METRICS_DIR/usage.json" > "$tmp_file"

        # Set first_use if not set
        if [ "$(jq -r '.first_use' "$tmp_file")" = "" ] || [ "$(jq -r '.first_use' "$tmp_file")" = "null" ]; then
            jq ".first_use = \"$TIMESTAMP\"" "$tmp_file" > "$METRICS_DIR/usage.json"
        else
            mv "$tmp_file" "$METRICS_DIR/usage.json"
        fi

        rm -f "$tmp_file"
    fi
}

# Log boilerplate usage
log_boilerplate() {
    local boilerplate=$1
    init_metrics

    if command -v jq &> /dev/null; then
        local tmp_file
        tmp_file=$(mktemp)
        jq ".boilerplates[\"$boilerplate\"] += 1" \
           "$METRICS_DIR/usage.json" > "$tmp_file"
        mv "$tmp_file" "$METRICS_DIR/usage.json"
        rm -f "$tmp_file"
    fi
}

# Calculate total time saved
calculate_time_saved() {
    init_metrics

    if ! command -v jq &> /dev/null; then
        echo "0"
        return
    fi

    local total_minutes=0

    # Calculate for each script
    for script in init-project morning-setup validate-structure anti-pattern-detector feature-workflow bug-hunter doc-sprint crisis-mode; do
        local count
        local time_per
        local saved
        count=$(jq -r ".scripts[\"$script\"].count // 0" "$METRICS_DIR/usage.json")
        time_per=$(jq -r ".scripts[\"$script\"].time_saved_min // 0" "$METRICS_DIR/usage.json")
        saved=$(echo "$count * $time_per" | bc 2>/dev/null || echo "0")
        total_minutes=$(echo "$total_minutes + $saved" | bc 2>/dev/null || echo "$total_minutes")
    done

    echo "$total_minutes"
}

# Show quick summary
show_summary() {
    init_metrics

    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📊 Claude Code Library Metrics${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if ! command -v jq &> /dev/null; then
        echo -e "${YELLOW}⚠️  jq not installed - metrics tracking disabled${NC}"
        echo -e "${CYAN}Install jq to enable metrics: sudo apt install jq${NC}"
        return
    fi

    # Parse metrics
    local first_use
    local last_use
    first_use=$(jq -r '.first_use // "N/A"' "$METRICS_DIR/usage.json")
    last_use=$(jq -r '.last_use // "N/A"' "$METRICS_DIR/usage.json")

    # Calculate days used
    local days_used=0
    if [ "$first_use" != "N/A" ] && [ "$first_use" != "null" ] && [ "$first_use" != "" ]; then
        local first_epoch
        local now_epoch
        first_epoch=$(date -d "$first_use" +%s 2>/dev/null || echo "0")
        now_epoch=$(date +%s)
        days_used=$(( (now_epoch - first_epoch) / 86400 ))
    fi

    echo -e "${YELLOW}📅 Usage Period:${NC}"
    echo -e "  First use: $first_use"
    echo -e "  Last use:  $last_use"
    echo -e "  Days used: $days_used"
    echo ""

    # Most used scripts
    echo -e "${YELLOW}🔥 Most Used Scripts:${NC}"
    local top_scripts
    top_scripts=$(jq -r '.scripts | to_entries | sort_by(-.value.count) | .[0:3] | .[] | "  \(.key): \(.value.count) uses"' "$METRICS_DIR/usage.json")
    echo "$top_scripts"
    echo ""

    # Projects created
    echo -e "${YELLOW}📦 Projects Created:${NC}"
    local webapp
    local website
    local python
    webapp=$(jq -r '.boilerplates.webapp // 0' "$METRICS_DIR/usage.json")
    website=$(jq -r '.boilerplates.website // 0' "$METRICS_DIR/usage.json")
    python=$(jq -r '.boilerplates["python-cli"] // 0' "$METRICS_DIR/usage.json")
    local total_projects=$(( webapp + website + python ))

    echo -e "  webapp:      $webapp"
    echo -e "  website:     $website"
    echo -e "  python-cli:  $python"
    echo -e "  ${GREEN}Total:       $total_projects${NC}"
    echo ""

    # Time saved
    local total_minutes
    local total_hours
    total_minutes=$(calculate_time_saved)
    total_hours=$(echo "scale=1; $total_minutes / 60" | bc 2>/dev/null || echo "0")

    echo -e "${YELLOW}⏱️  Time Saved:${NC}"
    echo -e "  ${GREEN}$total_minutes minutes${NC} (${GREEN}$total_hours hours${NC})"
    echo ""

    echo -e "${CYAN}💡 Run 'metrics.sh --report' for detailed analysis${NC}"
}

# Generate detailed report
generate_report() {
    init_metrics

    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📈 Detailed Usage Report${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if ! command -v jq &> /dev/null; then
        echo -e "${YELLOW}⚠️  jq not installed - metrics tracking disabled${NC}"
        return
    fi

    # Parse metrics
    local first_use
    local last_use
    first_use=$(jq -r '.first_use // "N/A"' "$METRICS_DIR/usage.json")
    last_use=$(jq -r '.last_use // "N/A"' "$METRICS_DIR/usage.json")

    echo -e "${BLUE}1. Overview${NC}"
    echo -e "   First use: $first_use"
    echo -e "   Last use:  $last_use"
    echo ""

    echo -e "${BLUE}2. Script Usage${NC}"
    printf "   %-25s %-10s %-15s\n" "Script" "Count" "Time Saved"
    echo "   ──────────────────────────────────────────────────────"

    for script in init-project morning-setup validate-structure anti-pattern-detector feature-workflow bug-hunter doc-sprint crisis-mode; do
        local count=$(jq -r ".scripts[\"$script\"].count // 0" "$METRICS_DIR/usage.json")
        local time_per=$(jq -r ".scripts[\"$script\"].time_saved_min // 0" "$METRICS_DIR/usage.json")
        local saved=$(echo "$count * $time_per" | bc 2>/dev/null || echo "0")

        if [ "$count" -gt 0 ]; then
            printf "   %-25s %-10s %-15s\n" "$script" "$count" "${saved}m"
        fi
    done
    echo ""

    echo -e "${BLUE}3. Boilerplate Usage${NC}"
    local webapp=$(jq -r '.boilerplates.webapp // 0' "$METRICS_DIR/usage.json")
    local website=$(jq -r '.boilerplates.website // 0' "$METRICS_DIR/usage.json")
    local python=$(jq -r '.boilerplates["python-cli"] // 0' "$METRICS_DIR/usage.json")

    printf "   %-15s %s\n" "webapp:" "$webapp projects"
    printf "   %-15s %s\n" "website:" "$website projects"
    printf "   %-15s %s\n" "python-cli:" "$python projects"
    echo ""

    echo -e "${BLUE}4. ROI Analysis${NC}"
    local total_minutes=$(calculate_time_saved)
    local total_hours=$(echo "scale=1; $total_minutes / 60" | bc 2>/dev/null || echo "0")
    local total_days=$(echo "scale=1; $total_hours / 8" | bc 2>/dev/null || echo "0")

    echo -e "   Total time saved: ${GREEN}$total_minutes minutes${NC}"
    echo -e "   Equivalent to:    ${GREEN}$total_hours hours${NC}"
    echo -e "   Work days saved:  ${GREEN}$total_days days${NC}"

    # Calculate weekly savings if enough data
    if [ "$first_use" != "N/A" ] && [ "$first_use" != "null" ] && [ "$first_use" != "" ]; then
        local first_epoch=$(date -d "$first_use" +%s 2>/dev/null || echo "0")
        local now_epoch=$(date +%s)
        local weeks=$(echo "scale=1; ($now_epoch - $first_epoch) / 604800" | bc 2>/dev/null || echo "1")

        if (( $(echo "$weeks > 0" | bc -l 2>/dev/null || echo "0") )); then
            local weekly_savings=$(echo "scale=1; $total_hours / $weeks" | bc 2>/dev/null || echo "0")
            echo -e "   Weekly average:   ${GREEN}$weekly_savings hours/week${NC}"
        fi
    fi
    echo ""

    echo -e "${BLUE}5. Productivity Insights${NC}"

    # Find most productive script
    local max_saved=0
    local best_script=""

    for script in init-project morning-setup validate-structure anti-pattern-detector feature-workflow bug-hunter doc-sprint crisis-mode; do
        local count=$(jq -r ".scripts[\"$script\"].count // 0" "$METRICS_DIR/usage.json")
        local time_per=$(jq -r ".scripts[\"$script\"].time_saved_min // 0" "$METRICS_DIR/usage.json")
        local saved=$(echo "$count * $time_per" | bc 2>/dev/null || echo "0")

        if (( $(echo "$saved > $max_saved" | bc -l 2>/dev/null || echo "0") )); then
            max_saved=$saved
            best_script=$script
        fi
    done

    if [ -n "$best_script" ]; then
        echo -e "   Most valuable script: ${GREEN}$best_script${NC}"
        echo -e "   Total time saved:     ${GREEN}${max_saved}m${NC}"
    fi
    echo ""

    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Calculate ROI
calculate_roi() {
    init_metrics

    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}💰 Return on Investment (ROI)${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if ! command -v jq &> /dev/null; then
        echo -e "${YELLOW}⚠️  jq not installed - ROI calculation disabled${NC}"
        return
    fi

    # Calculate time saved
    local total_minutes=$(calculate_time_saved)
    local total_hours=$(echo "scale=2; $total_minutes / 60" | bc 2>/dev/null || echo "0")

    echo -e "${YELLOW}📊 Time Savings:${NC}"
    echo -e "   Total time saved: ${GREEN}$total_hours hours${NC}"
    echo ""

    # Assume hourly rate (can be customized)
    echo -e "${YELLOW}💵 Monetary Value:${NC}"
    echo -e "   ${CYAN}Assuming average developer rate:${NC}"
    echo ""

    # Calculate at different rates
    for rate in 50 75 100 150; do
        local value=$(echo "scale=2; $total_hours * $rate" | bc 2>/dev/null || echo "0")
        printf "   At \$${rate}/hour:  ${GREEN}\$%.2f${NC} saved\n" "$value"
    done
    echo ""

    # Calculate setup time ROI
    echo -e "${YELLOW}⏱️  ROI Calculation:${NC}"
    echo -e "   Setup time:       ${CYAN}~30 minutes${NC} (library installation)"
    echo -e "   Time saved:       ${GREEN}$total_hours hours${NC}"

    local setup_hours=$(echo "0.5" | bc)
    local net_savings=$(echo "scale=2; $total_hours - $setup_hours" | bc 2>/dev/null || echo "0")
    local roi_multiplier=$(echo "scale=1; $total_hours / $setup_hours" | bc 2>/dev/null || echo "0")

    echo -e "   Net time saved:   ${GREEN}$net_savings hours${NC}"
    echo -e "   ROI multiplier:   ${GREEN}${roi_multiplier}x${NC}"
    echo ""

    # Projected savings
    if [ "$total_hours" != "0" ]; then
        echo -e "${YELLOW}📈 Projected Annual Savings:${NC}"

        local first_use=$(jq -r '.first_use // "N/A"' "$METRICS_DIR/usage.json")
        if [ "$first_use" != "N/A" ] && [ "$first_use" != "null" ] && [ "$first_use" != "" ]; then
            local first_epoch=$(date -d "$first_use" +%s 2>/dev/null || echo "0")
            local now_epoch=$(date +%s)
            local days_used=$(( ($now_epoch - $first_epoch) / 86400 ))

            if [ "$days_used" -gt 0 ]; then
                local daily_rate=$(echo "scale=4; $total_hours / $days_used" | bc 2>/dev/null || echo "0")
                local annual_hours=$(echo "scale=1; $daily_rate * 365" | bc 2>/dev/null || echo "0")

                echo -e "   Based on ${days_used} days of usage:"
                echo -e "   Projected annual savings: ${GREEN}$annual_hours hours/year${NC}"

                # At $100/hour
                local annual_value=$(echo "scale=2; $annual_hours * 100" | bc 2>/dev/null || echo "0")
                printf "   Monetary value (\$100/hr):  ${GREEN}\$%.2f/year${NC}\n" "$annual_value"
            fi
        fi
    fi
    echo ""

    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Export metrics to JSON
export_metrics() {
    init_metrics

    local export_file="$METRICS_DIR/metrics-export-$(date +%Y%m%d-%H%M%S).json"

    if ! command -v jq &> /dev/null; then
        echo -e "${YELLOW}⚠️  jq not installed - export disabled${NC}"
        return
    fi

    # Add calculated fields
    local total_minutes=$(calculate_time_saved)

    jq ". + {\"total_time_saved_minutes\": $total_minutes}" "$METRICS_DIR/usage.json" > "$export_file"

    echo -e "${GREEN}✅ Metrics exported to: $export_file${NC}"
    echo -e "${CYAN}File size: $(du -h "$export_file" | cut -f1)${NC}"
}

# Reset metrics
reset_metrics() {
    echo -e "${YELLOW}⚠️  This will delete all usage metrics!${NC}"
    read -p "Are you sure? (yes/no): " confirmation

    if [ "$confirmation" = "yes" ]; then
        rm -rf "$METRICS_DIR"
        init_metrics
        echo -e "${GREEN}✅ Metrics reset complete${NC}"
    else
        echo -e "${CYAN}Cancelled${NC}"
    fi
}

# Main function
main() {
    case "${1:-summary}" in
        --report)
            generate_report
            ;;
        --roi)
            calculate_roi
            ;;
        --summary|"")
            show_summary
            ;;
        --reset)
            reset_metrics
            ;;
        --export)
            export_metrics
            ;;
        --help|-h)
            usage
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            ;;
    esac
}

main "$@"
