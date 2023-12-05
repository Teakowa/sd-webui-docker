# Dockerfile v1.6

FROM nvidia/cuda:11.8.0-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND noninteractive

RUN set -eux && apt-get update && \
    apt install -y wget git git-lfs python3 python3-venv python3-pip libgl1 libglib2.0-0 ffmpeg libsm6 libxext6 && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip install torch==1.13.1+cu117 torchvision==0.14.1+cu117 --extra-index-url https://download.pytorch.org/whl/cu117
RUN pip install git+https://github.com/TencentARC/GFPGAN.git@8d2447a2d918f8eba5a4a01463fd48e45126a379 --prefer-binary
RUN pip install git+https://github.com/openai/CLIP.git@d50d76daa670286dd6cacf3bcd80b5e4823fc8e1 --prefer-binary
RUN pip install git+https://github.com/mlfoundations/open_clip.git@bb6e834e9c70d9c27d0dc3ecedeebeaeb1ffad6b --prefer-binary
RUN pip install xformers --prefer-binary
RUN pip install pyngrok --prefer-binary

RUN pip install --pre triton
RUN pip install numexpr

RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git

RUN git clone https://github.com/Stability-AI/stablediffusion.git /stable-diffusion-webui/repositories/stable-diffusion-stability-ai && \
    git -C /stable-diffusion-webui/repositories/stable-diffusion-stability-ai checkout cf1d67a6fd5ea1aa600c4df58e5b47da45f6bdbf

RUN git clone https://github.com/CompVis/taming-transformers.git /stable-diffusion-webui/repositories/taming-transformers
RUN git clone https://github.com/crowsonkb/k-diffusion.git /stable-diffusion-webui/repositories/k-diffusion
RUN git -C /stable-diffusion-webui/repositories/k-diffusion checkout v0.1.1

# RUN git clone https://github.com/sczhou/CodeFormer.git /stable-diffusion-webui/repositories/CodeFormer
RUN git clone https://github.com/salesforce/BLIP.git /stable-diffusion-webui/repositories/BLIP

# RUN pip install -r /stable-diffusion-webui/repositories/CodeFormer/requirements.txt --prefer-binary
RUN pip install -r /stable-diffusion-webui/requirements_versions.txt --prefer-binary

# extensions
RUN git clone https://github.com/yfszzx/stable-diffusion-webui-images-browser.git /stable-diffusion-webui/extensions/stable-diffusion-webui-images-browser
RUN git clone https://github.com/ranting8323/sd-webui-additional-networks.git /stable-diffusion-webui/extensions/sd-webui-additional-networks
RUN git clone https://github.com/ranting8323/sd-webui-cutoff.git /stable-diffusion-webui/extensions/sd-webui-cutoff
RUN git clone https://github.com/toshiaki1729/stable-diffusion-webui-dataset-tag-editor.git /stable-diffusion-webui/extensions/stable-diffusion-webui-dataset-tag-editor
RUN git clone https://github.com/yfszzx/stable-diffusion-webui-images-browser.git /stable-diffusion-webui/extensions/stable-diffusion-webui-images-browser
RUN git clone https://github.com/ranting8323/stable-diffusion-webui-wd14-tagger.git /stable-diffusion-webui/extensions/stable-diffusion-webui-wd14-tagger
RUN git clone https://github.com/overbill1683/stable-diffusion-webui-localization-zh_Hans.git /stable-diffusion-webui/extensions/stable-diffusion-webui-localization-zh_Hans
RUN git clone https://github.com/ranting8323/a1111-sd-webui-tagcomplete.git /stable-diffusion-webui/extensions/a1111-sd-webui-tagcomplete
RUN git clone https://github.com/Mikubill/sd-webui-controlnet.git /stable-diffusion-webui/extensions/sd-webui-controlnet
RUN git clone https://github.com/deforum-art/sd-webui-deforum /stable-diffusion-webui/extensions/deforum
RUN pip install -r /stable-diffusion-webui/extensions/sd-webui-controlnet/requirements.txt --prefer-binary

EXPOSE 7860

WORKDIR /stable-diffusion-webui/

CMD ["python3", "launch.py", "--listen", "--xformers", "--medvram", "--enable-insecure-extension-access"]