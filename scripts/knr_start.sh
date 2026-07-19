#!/bin/bash
echo "=== KnR v2.2 Startup $(date) ==="
# All credentials come from RunPod template environment variables
# Set these in: RunPod > My Templates > KnR-v2 > Edit > Environment variables
# GDRIVE_CLIENT_ID, GDRIVE_CLIENT_SECRET, GDRIVE_TOKEN, GDRIVE_FOLDER_ID
if [ -n "$GDRIVE_TOKEN" ] && [ -n "$GDRIVE_CLIENT_ID" ]; then
    mkdir -p /root/.config/rclone /workspace/KnR/runpod/backups
    python3 -c "
import os
cfg = '[gdrive]\ntype = drive\nclient_id = {}\nclient_secret = {}\nscope = drive\ntoken = {}\nroot_folder_id = {}\n'.format(
    os.environ['GDRIVE_CLIENT_ID'],
    os.environ.get('GDRIVE_CLIENT_SECRET',''),
    os.environ['GDRIVE_TOKEN'],
    os.environ.get('GDRIVE_FOLDER_ID','1s1wfuCt0xn2NOwY175nMu8at6gHK7-59')
)
for p in ['/root/.config/rclone/rclone.conf',
          '/workspace/KnR/runpod/backups/rclone.conf']:
    open(p,'w').write(cfg)
print('[startup] rclone configured from env vars')
"
elif [ -f /workspace/KnR/runpod/backups/rclone.conf ]; then
    mkdir -p /root/.config/rclone
    cp /workspace/KnR/runpod/backups/rclone.conf /root/.config/rclone/rclone.conf
    echo "[startup] rclone loaded from backup"
else
    echo "[startup] WARNING: No rclone config. Paste token manually after startup."
fi

# Download 14B model if missing (one-time per pod, ~28GB, ~10-15 min)
MODEL_DIR=/workspace/KnR/models/Wan2.1-T2V-14B
if [ ! -d "$MODEL_DIR" ] || [ -z "$(ls -A "$MODEL_DIR" 2>/dev/null)" ]; then
    echo "[startup] Downloading Wan2.1-T2V-14B model (first time, ~28GB, ~10-15 min)..."
    python3 -c "
from huggingface_hub import snapshot_download
snapshot_download(
    repo_id='Wan-AI/Wan2.1-T2V-14B',
    local_dir='/workspace/KnR/models/Wan2.1-T2V-14B',
    local_dir_use_symlinks=False
)
print('[startup] 14B model ready.')
"
else
    echo "[startup] 14B model present. Skipping download."
fi

# Set renderer env vars to use the 14B model
export KNR_WAN_MODEL_DIR=/workspace/KnR/models/Wan2.1-T2V-14B
export KNR_WAN_TASK=t2v-14B
export KNR_WAN_EXTRA_ARGS=""

mkdir -p /workspace/knr_runs /workspace/KnR_BACKUPS
chmod +x /workspace/KnR/runpod/*.sh

# Permanent fix for flash-attn AssertionError crash: redirect model.py's
# direct flash_attention( calls to the SDPA-capable attention() dispatcher.
echo "[startup] Applying flash-attention call patch to model.py..."
python3 /workspace/scripts/patch_model_attention_calls.py 2>/dev/null || true

echo "[startup] Starting KnR GPU service on port 7860..."
exec bash /workspace/KnR/runpod/run_knr_gpu_service.sh
