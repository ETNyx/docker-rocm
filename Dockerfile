# https://github.com/ROCm/ROCm-docker/blob/master/dev/Dockerfile-ubuntu-22.04-complete
FROM ubuntu:24.04

ARG ROCM_VERSION=7.1.1
ARG AMDGPU_VERSION=7.0.3
ARG UBUNTU_NAME=noble

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    libopenblas-dev \
    ninja-build \
    build-essential \
    pkg-config \
    curl \
    wget \
    git \
    make \
    gpg

RUN curl -sL https://repo.radeon.com/rocm/rocm.gpg.key \
    | gpg --dearmor \
    | tee /etc/apt/keyrings/amd-rocm.gpg > /dev/null \
    && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/amd-rocm.gpg] https://repo.radeon.com/amdgpu/7.0.3/ubuntu ${UBUNTU_NAME} main" > /etc/apt/sources.list.d/amdgpu.list \
    && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/amd-rocm.gpg] https://repo.radeon.com/rocm/apt/7.1.1 ${UBUNTU_NAME} main" > /etc/apt/sources.list.d/rocm.list \
    && echo "Package: *\nPin: release o=repo.radeon.com\nPin-Priority: 600" > /etc/apt/preferences.d/rocm-pin-600

RUN apt-get update && apt-get install -y \
    rocm-dev \
    rocm-libs

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PATH=/opt/miniconda/bin:${PATH}
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh --no-check-certificate && \
    /bin/bash ~/miniconda.sh -b -p /opt/miniconda && \
    conda init bash && \
    conda config --set auto_activate_base false && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r && \
    conda update --all && \
    rm ~/miniconda.sh && conda clean -ya
ENV PYTHON_VERSION=3.11
RUN conda install python=${PYTHON_VERSION} pip

ENV PYTHON_LIB_ROCM_URL=https://repo.radeon.com/rocm/manylinux/rocm-rel-${ROCM_VERSION}

ENV TRITON_VERSION=3.5.1
ENV TRITON_VERSION_DETAILS=gita272dfa8-cp311-cp311
RUN pip3 install $PYTHON_LIB_ROCM_URL/triton-$TRITON_VERSION+rocm$ROCM_VERSION.$TRITON_VERSION_DETAILS-linux_x86_64.whl
ENV TORCH_VERSION=2.9.1
ENV TORCH_VERSION_DETAILS=lw.git351ff442-cp311-cp311
RUN pip3 install $PYTHON_LIB_ROCM_URL/torch-$TORCH_VERSION+rocm$ROCM_VERSION.$TORCH_VERSION_DETAILS-linux_x86_64.whl
ENV TORCHVISION_VERSION=0.24.0
ENV TORCHVISION_VERSION_DETAILS=gitb919bd0c-cp311-cp311
RUN pip3 install $PYTHON_LIB_ROCM_URL/torchvision-$TORCHVISION_VERSION+rocm$ROCM_VERSION.$TORCHVISION_VERSION_DETAILS-linux_x86_64.whl
ENV TORCHAUDIO_VERSION=2.9.0
ENV TORCHAUDIO_VERSION_DETAILS=gite3c6ee2b-cp311-cp311
RUN pip3 install $PYTHON_LIB_ROCM_URL/torchaudio-$TORCHAUDIO_VERSION+rocm$ROCM_VERSION.$TORCHAUDIO_VERSION_DETAILS-linux_x86_64.whl

ENV TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1

RUN pip install \
    transformers \
    peft \
    sentencepiece \
    scipy \
    protobuf
