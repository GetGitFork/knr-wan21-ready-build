FROM nvidia/cuda:12.4.1-devel-ubuntu22.04

ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive
ENV CUDA_HOME=/usr/local/cuda
ENV MAX_JOBS=2

WORKDIR /workspace

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip python3-dev \
    git git-lfs ffmpeg rclone espeak-ng ninja-build build-essential \
    wget curl unzip zip ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --upgrade pip setuptools wheel packaging

RUN python3 -m pip install --no-cache-dir \
    torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124

RUN python3 -m pip install --no-cache-dir \
    diffusers \
    transformers \
    accelerate \
    easydict \
    dashscope \
    imageio \
    imageio-ffmpeg \
    opencv-python-headless \
    edge-tts \
    huggingface_hub \
    pillow \
    requests

RUN python3 -m pip install --no-cache-dir flash-attn --no-build-isolation

RUN git lfs install && git clone --depth 1 https://github.com/Wan-Video/Wan2.1.git /workspace/Wan2.1

CMD ["sleep", "infinity"]
