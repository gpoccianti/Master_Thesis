#!/bin/bash

# Stop execution if any command fails
set -e

# ==========================================
# 1. CONFIGURATION
# ==========================================

# Network topology type
NET_TYPE="BA"

# List of network sizes (N) to evaluate
N_LIST=(10)
#(10 100 200 300 400 500 600 700 800 900 1000 2000) 

# List of random seeds
SEEDS_LIST=(0)
#(0 42 100)

# Directory handling: Read from existing, write to v2
INPUT_DIR="results_${NET_TYPE}_scaling_N"
OUTPUT_DIR="results_${NET_TYPE}_scaling_N_v2"

# Centralized results file for this specific evaluation run
RESULTS_TXT="${OUTPUT_DIR}/summary_stats_${NET_TYPE}.txt"

# Verify that the input directory (containing models and configs) exists
if [ ! -d "$INPUT_DIR" ]; then
    echo "Error: Input directory $INPUT_DIR not found. Pre-trained models are required."
    exit 1
fi

# Safely create the new output directory
if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
fi

# ==========================================
# 2. EVALUATION LOOP
# ==========================================

for SEED in "${SEEDS_LIST[@]}"; do
    for N in "${N_LIST[@]}"; do
        
        echo "=== START EVALUATION: Type=$NET_TYPE | Seed=$SEED | N=$N ==="

        # --- A. Retrieve Existing Configuration ---
        CONFIG_FILE="$INPUT_DIR/params_S${SEED}_N${N}.yml"

        if [ ! -f "$CONFIG_FILE" ]; then
            echo "Warning: Configuration file $CONFIG_FILE not found. Skipping N=$N, Seed=$SEED."
            continue
        fi

        # --- B. PYTHON EXECUTION ---
        
        echo "Running model recovery..."
        python recover_model_v2.py --config_file "$CONFIG_FILE"

        echo "Running statistical evaluation..."
        python stats_on_a_model_v2.py \
            --config_file "$CONFIG_FILE" \
            --current_seed "$SEED" \
            --current_n "$N" \
            --net_type "$NET_TYPE" \
            --results_file "$RESULTS_TXT"

        # --- C. Artifact Redirection ---
        move_if_exists() {
            local FILE_NAME=$1
            local TARGET_PATH=$2
            
            if [ -f "$FILE_NAME" ]; then 
                mv "$FILE_NAME" "$TARGET_PATH"
            elif [ -f "$INPUT_DIR/$FILE_NAME" ]; then
                mv "$INPUT_DIR/$FILE_NAME" "$TARGET_PATH"
            fi
        }
        
        # MODIFICA QUI: Rimosso .png dal SUFFIX generale, aggiunto nei path successivi
        BASE_SUFFIX="_S=${SEED}_N=${N}"
        
        move_if_exists "HHpeaks.png" "$OUTPUT_DIR/HHpeaks${BASE_SUFFIX}.png"
        move_if_exists "L2histoFNO.png" "$OUTPUT_DIR/L2histoFNO${BASE_SUFFIX}.png"
        move_if_exists "loss_plot_fixed.png" "$OUTPUT_DIR/loss_plot_fixed${BASE_SUFFIX}.png"
        move_if_exists "raw_errors.csv" "$OUTPUT_DIR/raw_errors${BASE_SUFFIX}.csv" # <--- Spostamento CSV aggiunto
        
        echo "Done Evaluating Seed=$SEED, N=$N"
        echo "Artifacts saved to $OUTPUT_DIR"
        echo "--------------------------------------------------------"
    done
done