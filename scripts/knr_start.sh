#!/bin/bash
echo "=== KnR v2.0 Startup $(date) ==="

# Load rclone config if present in bundle backup
if [ -f /workspace/KnR/runpod/backups/rclone.conf ]; then
    mkdir -p /root/.config/rclone
    cp /workspace/KnR/runpod/backups/rclone.conf /root/.config/rclone/rclone.conf
    echo "[startup] rclone config loaded"
fi

# Download model on first start (~17GB, ~5-10 min)
MODEL=/workspace/KnR/models/Wan2.1-T2V-1.3B/diffusion_pytorch_model.safetensors
if [ ! -f "$MODEL" ]; then
    echo "[startup] First start: downloading Wan2.1 model (~5-10 min)..."
    python3 -c "
from huggingface_hub import snapshot_download
snapshot_download(repo_id='Wan-AI/Wan2.1-T2V-1.3B',
                  local_dir='/workspace/KnR/models/Wan2.1-T2V-1.3B')
print('Model ready.')
"
else
    echo "[startup] Model found. Starting service now."
fi

mkdir -p /workspace/knr_runs /workspace/KnR_BACKUPS
chmod +x /workspace/KnR/runpod/*.sh
echo "[startup] Starting KnR GPU service on port 7860..."
exec bash /workspace/KnR/runpod/run_knr_gpu_service.sh
