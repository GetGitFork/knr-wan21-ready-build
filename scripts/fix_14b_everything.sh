#!/bin/bash
set -e

echo "===== DIAGNOSIS ====="
echo "-- knr_start.sh 14B references:"
grep -c "14B" /workspace/knr_start.sh 2>/dev/null || echo "0 (file missing or no matches)"

echo "-- Current .env WAN settings:"
grep "KNR_WAN_TASK\|KNR_WAN_MODEL_DIR\|KNR_WAN_EXTRA_ARGS" /workspace/KnR/runpod/.env

echo "-- 14B model folder:"
ls -la /workspace/KnR/models/Wan2.1-T2V-14B/ 2>/dev/null || echo "MISSING"

echo ""
echo "===== FIX: Downloading 14B model if missing ====="
MODEL_DIR=/workspace/KnR/models/Wan2.1-T2V-14B
if [ ! -d "$MODEL_DIR" ] || [ -z "$(ls -A "$MODEL_DIR" 2>/dev/null)" ]; then
    echo "Downloading Wan2.1-T2V-14B (~28GB, this will take a while)..."
    python3 -c "
from huggingface_hub import snapshot_download
snapshot_download(
    repo_id='Wan-AI/Wan2.1-T2V-14B',
    local_dir='/workspace/KnR/models/Wan2.1-T2V-14B',
    local_dir_use_symlinks=False
)
print('14B download complete.')
"
else
    echo "14B model already present, skipping download."
fi

echo ""
echo "===== FIX: Updating .env ====="
ENV_FILE="/workspace/KnR/runpod/.env"
sed -i '/^KNR_WAN_MODEL_DIR=/d' "$ENV_FILE"
sed -i '/^KNR_WAN_TASK=/d' "$ENV_FILE"
sed -i '/^KNR_WAN_EXTRA_ARGS=/d' "$ENV_FILE"
echo "KNR_WAN_MODEL_DIR=/workspace/KnR/models/Wan2.1-T2V-14B" >> "$ENV_FILE"
echo "KNR_WAN_TASK=t2v-14B" >> "$ENV_FILE"
echo "KNR_WAN_EXTRA_ARGS=" >> "$ENV_FILE"

echo ""
echo "===== VERIFY ====="
grep "KNR_WAN_TASK\|KNR_WAN_MODEL_DIR\|KNR_WAN_EXTRA_ARGS" "$ENV_FILE"
du -sh "$MODEL_DIR" 2>/dev/null

echo ""
echo "===== DONE. Restart the render service by running: ====="
echo "curl -X POST localhost:7860/run -H \"Content-Type: application/json\" -d '{\"secret\":\"knr_wcf_18JOooGOWqDLMUiJ_kSBYYW32hsXh3TUBzVuKyDGk2s\",\"action\":\"start_auto_run\"}'"
