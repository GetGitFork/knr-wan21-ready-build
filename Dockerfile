FROM pytorch/pytorch:2.5.1-cuda12.4-cudnn9-runtime

ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive
ENV CUDA_HOME=/usr/local/cuda
ENV MAX_JOBS=2

WORKDIR /workspace

RUN apt-get update && apt-get install -y --no-install-recommends \
    git git-lfs ffmpeg rclone espeak-ng ninja-build build-essential \
    wget curl unzip zip ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN python -m pip install --upgrade pip setuptools wheel packaging

RUN python -m pip install --no-cache-dir \
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

RUN git lfs install && git clone --depth 1 https://github.com/Wan-Video/Wan2.1.git /workspace/Wan2.1

CMD ["sleep", "infinity"]
