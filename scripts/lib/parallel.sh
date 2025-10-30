#!/bin/bash
# =============================================================================
# PARALLEL EXECUTION LIBRARY
# =============================================================================
# Run commands in parallel with progress tracking and resource management
#
# Usage:
#   source "$HOME/work/scripts/lib/parallel.sh"
#   parallel_run "command1" "command2" "command3"
#   parallel_map process_file file1.txt file2.txt file3.txt
#
# =============================================================================

# Configuration
PARALLEL_MAX_JOBS="${PARALLEL_MAX_JOBS:-4}"
PARALLEL_TEMP_DIR="${PARALLEL_TEMP_DIR:-/tmp/parallel-$$}"
PARALLEL_VERBOSE="${PARALLEL_VERBOSE:-false}"

# Internal state
declare -a PARALLEL_PIDS=()
declare -a PARALLEL_COMMANDS=()
declare -A PARALLEL_RESULTS=()

# =============================================================================
# INTERNAL HELPER FUNCTIONS
# =============================================================================

# Create temporary directory for parallel execution
_parallel_setup() {
    mkdir -p "$PARALLEL_TEMP_DIR"
}

# Clean up temporary directory
_parallel_cleanup() {
    if [[ -d "$PARALLEL_TEMP_DIR" ]]; then
        rm -rf "$PARALLEL_TEMP_DIR"
    fi
}

# Wait for a specific PID
_parallel_wait_for() {
    local pid="$1"
    wait "$pid" 2>/dev/null
    return $?
}

# Get number of currently running jobs
_parallel_running_count() {
    local count=0
    for pid in "${PARALLEL_PIDS[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            ((count++))
        fi
    done
    echo "$count"
}

# =============================================================================
# CORE PARALLEL FUNCTIONS
# =============================================================================

# Run multiple commands in parallel
# Usage: parallel_run "cmd1" "cmd2" "cmd3"
parallel_run() {
    local commands=("$@")
    local max_jobs="${PARALLEL_MAX_JOBS}"

    _parallel_setup
    trap '_parallel_cleanup' EXIT

    local job_id=0
    for cmd in "${commands[@]}"; do
        # Wait if we've hit max concurrent jobs
        while [[ $(_parallel_running_count) -ge $max_jobs ]]; do
            sleep 0.1
        done

        # Run command in background
        local output_file="$PARALLEL_TEMP_DIR/job-${job_id}.out"
        local error_file="$PARALLEL_TEMP_DIR/job-${job_id}.err"
        local status_file="$PARALLEL_TEMP_DIR/job-${job_id}.status"

        if [[ "$PARALLEL_VERBOSE" == "true" ]]; then
            echo "Starting job $job_id: $cmd"
        fi

        (
            eval "$cmd" > "$output_file" 2> "$error_file"
            echo $? > "$status_file"
        ) &

        local pid=$!
        PARALLEL_PIDS+=("$pid")
        PARALLEL_COMMANDS[$job_id]="$cmd"

        ((job_id++))
    done

    # Wait for all jobs to complete
    local failed=0
    for i in "${!PARALLEL_PIDS[@]}"; do
        local pid="${PARALLEL_PIDS[$i]}"
        wait "$pid"
        local status_file="$PARALLEL_TEMP_DIR/job-${i}.status"
        local exit_code
        exit_code=$(cat "$status_file" 2>/dev/null || echo "1")

        if [[ $exit_code -ne 0 ]]; then
            ((failed++))
            if [[ "$PARALLEL_VERBOSE" == "true" ]]; then
                echo "Job $i failed with exit code $exit_code: ${PARALLEL_COMMANDS[$i]}"
                cat "$PARALLEL_TEMP_DIR/job-${i}.err"
            fi
        fi

        PARALLEL_RESULTS[$i]=$exit_code
    done

    # Cleanup
    PARALLEL_PIDS=()
    PARALLEL_COMMANDS=()

    return "$failed"
}

# Map a function over multiple inputs in parallel
# Usage: parallel_map function_name arg1 arg2 arg3
parallel_map() {
    local func_name="$1"
    shift
    local args=("$@")

    # Check if function exists
    if ! declare -f "$func_name" >/dev/null 2>&1; then
        echo "Error: Function '$func_name' not found" >&2
        return 1
    fi

    # Build commands
    local commands=()
    for arg in "${args[@]}"; do
        commands+=("$func_name \"$arg\"")
    done

    # Run in parallel
    parallel_run "${commands[@]}"
}

# =============================================================================
# BATCH PROCESSING
# =============================================================================

# Process files in batches
# Usage: parallel_batch function_name batch_size file1 file2 file3...
parallel_batch() {
    local func_name="$1"
    local batch_size="$2"
    shift 2
    local items=("$@")

    local total=${#items[@]}
    local processed=0

    while [[ $processed -lt $total ]]; do
        local batch=("${items[@]:$processed:$batch_size}")
        parallel_map "$func_name" "${batch[@]}"
        processed=$((processed + ${#batch[@]}))

        if [[ "$PARALLEL_VERBOSE" == "true" ]]; then
            echo "Processed $processed/$total items"
        fi
    done
}

# =============================================================================
# QUEUE SYSTEM
# =============================================================================

# Initialize a job queue
parallel_queue_init() {
    _parallel_setup
    PARALLEL_PIDS=()
    PARALLEL_COMMANDS=()
}

# Add a job to the queue
# Usage: parallel_queue_add "command"
parallel_queue_add() {
    local cmd="$1"
    local max_jobs="${PARALLEL_MAX_JOBS}"

    # Wait if queue is full
    while [[ $(_parallel_running_count) -ge $max_jobs ]]; do
        sleep 0.1
    done

    local job_id=${#PARALLEL_COMMANDS[@]}
    local output_file="$PARALLEL_TEMP_DIR/job-${job_id}.out"
    local error_file="$PARALLEL_TEMP_DIR/job-${job_id}.err"
    local status_file="$PARALLEL_TEMP_DIR/job-${job_id}.status"

    if [[ "$PARALLEL_VERBOSE" == "true" ]]; then
        echo "Queueing job $job_id: $cmd"
    fi

    (
        eval "$cmd" > "$output_file" 2> "$error_file"
        echo $? > "$status_file"
    ) &

    local pid=$!
    PARALLEL_PIDS+=("$pid")
    PARALLEL_COMMANDS+=("$cmd")
}

# Wait for all queued jobs to complete
# Usage: parallel_queue_wait
parallel_queue_wait() {
    local failed=0

    for i in "${!PARALLEL_PIDS[@]}"; do
        local pid="${PARALLEL_PIDS[$i]}"
        wait "$pid"

        local status_file="$PARALLEL_TEMP_DIR/job-${i}.status"
        local exit_code
        exit_code=$(cat "$status_file" 2>/dev/null || echo "1")

        if [[ $exit_code -ne 0 ]]; then
            ((failed++))
            if [[ "$PARALLEL_VERBOSE" == "true" ]]; then
                echo "Job $i failed: ${PARALLEL_COMMANDS[$i]}"
            fi
        fi

        PARALLEL_RESULTS[$i]=$exit_code
    done

    return "$failed"
}

# Get results from parallel execution
# Usage: parallel_get_results
parallel_get_results() {
    for job_id in "${!PARALLEL_RESULTS[@]}"; do
        local exit_code="${PARALLEL_RESULTS[$job_id]}"
        local output_file="$PARALLEL_TEMP_DIR/job-${job_id}.out"
        local error_file="$PARALLEL_TEMP_DIR/job-${job_id}.err"

        echo "Job $job_id: ${PARALLEL_COMMANDS[$job_id]}"
        echo "  Exit code: $exit_code"

        if [[ -f "$output_file" ]]; then
            echo "  Output:"
            sed 's/^/    /' "$output_file"
        fi

        if [[ -f "$error_file" ]] && [[ -s "$error_file" ]]; then
            echo "  Errors:"
            sed 's/^/    /' "$error_file"
        fi
    done
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Run command with concurrency limit
# Usage: parallel_limit 4 "cmd1" "cmd2" "cmd3" "cmd4" "cmd5"
parallel_limit() {
    local limit="$1"
    shift
    local commands=("$@")

    local old_max="$PARALLEL_MAX_JOBS"
    PARALLEL_MAX_JOBS="$limit"

    parallel_run "${commands[@]}"
    local result=$?

    PARALLEL_MAX_JOBS="$old_max"
    return "$result"
}

# Detect optimal number of parallel jobs (CPU cores)
parallel_auto_jobs() {
    local cores
    if command -v nproc >/dev/null 2>&1; then
        cores=$(nproc)
    elif command -v sysctl >/dev/null 2>&1; then
        cores=$(sysctl -n hw.ncpu)
    else
        cores=4
    fi

    echo "$cores"
}

# Set max jobs automatically based on CPU cores
parallel_auto() {
    PARALLEL_MAX_JOBS=$(parallel_auto_jobs)
    if [[ "$PARALLEL_VERBOSE" == "true" ]]; then
        echo "Auto-detected $PARALLEL_MAX_JOBS CPU cores"
    fi
}

# =============================================================================
# EXAMPLE USAGE FUNCTIONS
# =============================================================================

# Example: Process multiple files in parallel
# parallel_process_files() {
#     process_file() {
#         local file="$1"
#         echo "Processing $file..."
#         # Do work here
#     }
#     export -f process_file
#
#     parallel_map process_file file1.txt file2.txt file3.txt
# }

# Example: Download multiple URLs in parallel
# parallel_downloads() {
#     local urls=(
#         "https://example.com/file1.zip"
#         "https://example.com/file2.zip"
#         "https://example.com/file3.zip"
#     )
#
#     parallel_queue_init
#     for url in "${urls[@]}"; do
#         parallel_queue_add "curl -O '$url'"
#     done
#     parallel_queue_wait
# }

# =============================================================================
# EXPORT FUNCTIONS
# =============================================================================

export -f parallel_run
export -f parallel_map
export -f parallel_batch
export -f parallel_queue_init
export -f parallel_queue_add
export -f parallel_queue_wait
export -f parallel_get_results
export -f parallel_limit
export -f parallel_auto_jobs
export -f parallel_auto
