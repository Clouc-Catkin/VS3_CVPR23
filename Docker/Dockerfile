FROM nvidia/cuda:11.1.1-cudnn8-devel-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    PIP_NO_CACHE_DIR=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

# ① 修复临时目录（有些构建环境/根镜像会把 /tmp 弄成不可写）
#   并把 TMPDIR 指到 /var/tmp 作为兜底
ENV TMPDIR=/var/tmp
RUN set -eux; \
    mkdir -p /tmp /var/tmp; \
    chmod 1777 /tmp /var/tmp

# ②（可选但推荐，国内更稳）切到国内 Ubuntu 源
#   如果你已经在公司内网有缓存源，可以替换为你的内网地址
RUN set -eux; \
    sed -i 's@http://archive.ubuntu.com/ubuntu@http://mirrors.aliyun.com/ubuntu@g' /etc/apt/sources.list; \
    sed -i 's@http://security.ubuntu.com/ubuntu@http://mirrors.aliyun.com/ubuntu@g' /etc/apt/sources.list

# ③ 更新并安装基础包（先确保 ca-certificates & gnupg 到位，避免签名问题）
RUN set -eux; \
    apt-get update; \
    # 关键：阻止升级 ca-certificates，避免触发 postinst
    # apt-mark hold ca-certificates; \
    # 安装你需要的包（不包含 ca-certificates）
    apt-get install -y --no-install-recommends gnupg git curl ca-certificates; \
    rm -rf /var/lib/apt/lists/*

# # 指定 Ubuntu 代号
# ARG UBUNTU_CODENAME=ubuntu2004
# # 指定 Nvidia 源
# ARG NVIDIA_DOMAIN=developer.download.nvidia.cn
# # 安装 NVIDIA cuda-keyring（自动写入源 & 安装 GPG key）
# RUN set -eux; \
#     # 删掉已添加的 nvidia 源（如果存在）
#     rm -f /etc/apt/sources.list.d/nvidia-cuda.list \
#           /etc/apt/sources.list.d/nvidia-ml.list; \
#     apt-key del 7fa2af80; \
#     curl -fsSL https://${NVIDIA_DOMAIN}/compute/cuda/repos/${UBUNTU_CODENAME}/x86_64/cuda-keyring_1.1-1_all.deb -o /tmp/cuda-keyring.deb; \
#     dpkg -i /tmp/cuda-keyring.deb; \
#     rm -f /tmp/cuda-keyring.deb
    
# 现在再更新并安装你原本要的包（这时不要 hold ca-certificates）
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      gnupg git \
      # opencv-python 必备库
      libgl1 libglib2.0-0 libsm6 libxext6 libxrender1 libgtk-3-0; \
    rm -rf /var/lib/apt/lists/*; \
    # 忽略 git 安全检查
    git config --global --add safe.directory '*'

# 基础依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
        software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update && apt-get install -y --no-install-recommends \
        python3.9 python3.9-dev python3.9-venv \
        python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1

    
# ④ 下面接你原来的 Python 依赖安装（示例）
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir einops shapely timm yacs tensorboardX ftfy prettytable pymongo transformers SceneGraphParser spacy &&\
    pip3 install --no-cache-dir torch==1.9.1+cu111 torchvision==0.10.1+cu111 torchaudio==0.9.1 -f https://download.pytorch.org/whl/torch_stable.html

# ⑤ HF 缓存与离线（仅对 Transformers/Datasets 生效）
ENV HF_HOME=/opt/hf \
    HF_HUB_CACHE=/opt/hf/hub \
    TRANSFORMERS_CACHE=/opt/hf/transformers \
    export HF_ENDPOINT=https://hf-mirror.com \
    HF_DATASETS_CACHE=/opt/hf/datasets \
    HF_HUB_OFFLINE=1 \
    TRANSFORMERS_OFFLINE=1 \
    DATASETS_OFFLINE=1 \
    GRADIO_SERVER_NAME=0.0.0.0
RUN mkdir -p /opt/hf/transformers /opt/hf/datasets

RUN pip install ipykernel joblib

RUN pip uninstall -y transformers tokenizers huggingface-hub numpy pycocotools scipy h5py nltk opencv-python matplotlib && \
    pip install "transformers==4.30.2" "tokenizers==0.13.3" "huggingface-hub<1.0,>=0.14.0" "numpy==1.21.6" && \
    apt-get update && apt-get install -y wget

#   >>> import nltk
#   >>> nltk.download('wordnet')

WORKDIR /workspace/VS3_CVPR23
EXPOSE 7860
CMD ["/bin/bash"]
