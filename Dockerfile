FROM nvcr.io/nvidia/pytorch:24.05-py3

ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /workspace

RUN apt-get update && apt-get install -y --no-install-recommends \
    git git-lfs ffmpeg rclone espeak-ng ninja-build build-essential \
    wget curl unzip zip \
    && rm -rf /var/lib/apt/lists/*

RUN python -m pip install --upgrade pip setuptools wheel

RUN python -m pip install \
    diffusers \
    transformers \
    accelerate \
    easydict \
    dashscope \
    imageio \
    imageio-ffmpeg \
    opencv-python \
    edge-tts \
    huggingface_hub \
    pillow \
    requests

RUN python -m pip install flash-attn --no-build-isolation

RUN git lfs install
RUN git clone https://github.com/Wan-Video/Wan2.1.git /workspace/Wan2.1

CMD ["sleep", "infinity"]
