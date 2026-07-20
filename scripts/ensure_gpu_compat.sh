#!/bin/bash
set -e
ARCH_OK=$(python3 -c "
import torch
try:
    cap = torch.cuda.get_device_capability(0)
    sm = f'sm_{cap[0]}{cap[1]}'
    print('yes' if sm in torch.cuda.get_arch_list() else 'no')
except Exception:
    print('no')
")
if [ "$ARCH_OK" = "no" ]; then
    echo "[gpu-compat] Upgrading torch/torchaudio for this GPU..."
    pip install --upgrade torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128 --break-system-packages
else
    echo "[gpu-compat] PyTorch already supports this GPU."
fi
