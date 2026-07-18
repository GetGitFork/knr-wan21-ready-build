#!/bin/bash
echo "===== 1. Actual process env var ====="
echo "KNR_WAN_EXTRA_ARGS=[$KNR_WAN_EXTRA_ARGS]"

echo ""
echo "===== 2. .env file contents ====="
cat /workspace/KnR/runpod/.env 2>/dev/null | grep -i "KNR_WAN_EXTRA_ARGS\|OFFLOAD"

echo ""
echo "===== 3. All env vars containing OFFLOAD or WAN_EXTRA ====="
env | grep -i "OFFLOAD\|WAN_EXTRA"

echo ""
echo "===== 4. How renderer loads .env (load_env function) ====="
grep -n "def load_env" -A 15 /workspace/KnR/runpod/knr_gpu_direct_renderer.py

echo ""
echo "===== 5. What --env default is used at startup ====="
grep -n 'add_argument("--env"' /workspace/KnR/runpod/knr_gpu_direct_renderer.py

echo ""
echo "===== 6. Is renderer currently running, and with what env? ====="
ps aux | grep -i "knr_gpu_direct_renderer\|generate.py" | grep -v grep

echo ""
echo "===== 7. Last render log tail ====="
tail -20 /workspace/KnR/runpod/knr_gpu_service_last_render.log 2>/dev/null

echo ""
echo "===== DIAGNOSIS COMPLETE ====="
