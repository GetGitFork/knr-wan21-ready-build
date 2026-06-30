#!/bin/bash
echo "=== KnR v2.0 Startup $(date) ==="

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

# Download model if missing
MODEL=/workspace/KnR/models/Wan2.1-T2V-1.3B/diffusion_pytorch_model.safetensors
if [ ! -f "$MODEL" ]; then
    echo "[startup] Downloading Wan2.1 model (first time ~10 min)..."
    python3 -c "
from huggingface_hub import snapshot_download
snapshot_download(repo_id='Wan-AI/Wan2.1-T2V-1.3B',
                  local_dir='/workspace/KnR/models/Wan2.1-T2V-1.3B')
print('[startup] Model ready.')
"
else
    echo "[startup] Model present. Starting now."
fi

mkdir -p /workspace/knr_runs /workspace/KnR_BACKUPS
chmod +x /workspace/KnR/runpod/*.sh
echo "[startup] Starting KnR GPU service on port 7860..."
exec bash /workspace/KnR/runpod/run_knr_gpu_service.sh
