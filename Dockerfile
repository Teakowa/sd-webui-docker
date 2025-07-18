# Dockerfile v1.6
FROM alpine/git:2.49.1 as download

COPY clone.sh /clone.sh

RUN . /clone.sh stable-diffusion-stability-ai https://github.com/Stability-AI/stablediffusion.git cf1d67a6fd5ea1aa600c4df58e5b47da45f6bdbf \
  && rm -rf assets data/**/*.png data/**/*.jpg data/**/*.gif

RUN . /clone.sh CodeFormer https://github.com/sczhou/CodeFormer.git c5b4593074ba6214284d6acd5f1719b6c5d739af \
  && rm -rf assets inputs

RUN . /clone.sh BLIP https://github.com/salesforce/BLIP.git 48211a1594f1321b00f14c9f7a5b4813144b2fb9
RUN . /clone.sh k-diffusion https://github.com/crowsonkb/k-diffusion.git ab527a9a6d347f364e3d185ba6d714e22d80cb3c
RUN . /clone.sh clip-interrogator https://github.com/pharmapsychotic/clip-interrogator 2cf03aaf6e704197fd0dae7c7f96aa59cf1b11c9
RUN . /clone.sh generative-models https://github.com/Stability-AI/generative-models 45c443b316737a4ab6e40413d7794a7f5657c19f
RUN . /clone.sh taming-transformers https://github.com/CompVis/taming-transformers.git 3ba01b241669f5ade541ce990f7650a3b8f65318


# FROM nvidia/cuda:11.8.0-runtime-ubuntu22.04
FROM pytorch/pytorch:2.3.1-cuda12.1-cudnn8-runtime


ENV DEBIAN_FRONTEND=noninteractive PIP_PREFER_BINARY=1

RUN --mount=type=cache,target=/var/cache/apt \
  apt-get update && \
  # we need those
  apt-get install -y fonts-dejavu-core rsync git jq moreutils aria2 \
  # extensions needs those
  ffmpeg libglfw3-dev libgles2-mesa-dev pkg-config libcairo2 libcairo2-dev build-essential

WORKDIR /
RUN --mount=type=cache,target=/root/.cache/pip \
  git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git && \
  cd stable-diffusion-webui && \
  git reset --hard 4afaaf8a020c1df457bcf7250cb1c7f609699fa7 && \
  pip install -r requirements_versions.txt

ENV ROOT=/stable-diffusion-webui

COPY --from=download /repositories/ ${ROOT}/repositories/
RUN mkdir ${ROOT}/interrogate && cp ${ROOT}/repositories/clip-interrogator/clip_interrogator/data/* ${ROOT}/interrogate
RUN --mount=type=cache,target=/root/.cache/pip \
  pip install -r ${ROOT}/repositories/CodeFormer/requirements.txt

RUN --mount=type=cache,target=/root/.cache/pip \
  pip install pyngrok xformers \
  git+https://github.com/TencentARC/GFPGAN.git@8d2447a2d918f8eba5a4a01463fd48e45126a379 \
  git+https://github.com/openai/CLIP.git@d50d76daa670286dd6cacf3bcd80b5e4823fc8e1 \
  git+https://github.com/mlfoundations/open_clip.git@bb6e834e9c70d9c27d0dc3ecedeebeaeb1ffad6b

  # extensions
RUN git clone https://github.com/yfszzx/stable-diffusion-webui-images-browser.git ${ROOT}/extensions/stable-diffusion-webui-images-browser
RUN git clone https://github.com/kohya-ss/sd-webui-additional-networks.git ${ROOT}/extensions/sd-webui-additional-networks
RUN git clone https://github.com/hnmr293/sd-webui-cutoff.git ${ROOT}/extensions/sd-webui-cutoff
RUN git clone https://github.com/toshiaki1729/stable-diffusion-webui-dataset-tag-editor.git ${ROOT}/extensions/stable-diffusion-webui-dataset-tag-editor
RUN git clone https://github.com/picobyte/stable-diffusion-webui-wd14-tagger.git ${ROOT}/extensions/stable-diffusion-webui-wd14-tagger
RUN git clone https://github.com/hanamizuki-ai/stable-diffusion-webui-localization-zh_Hans.git ${ROOT}/extensions/stable-diffusion-webui-localization-zh_Hans
RUN git clone https://github.com/DominikDoom/a1111-sd-webui-tagcomplete.git ${ROOT}/extensions/a1111-sd-webui-tagcomplete
RUN git clone https://github.com/Mikubill/sd-webui-controlnet.git ${ROOT}/extensions/sd-webui-controlnet
RUN git clone https://github.com/deforum-art/sd-webui-deforum ${ROOT}/extensions/deforum
RUN pip install -r ${ROOT}/extensions/sd-webui-controlnet/requirements.txt --prefer-binary

COPY . /docker

  RUN \
  # mv ${ROOT}/style.css ${ROOT}/user.css && \
  # one of the ugliest hacks I ever wrote \
  sed -i 's/in_app_dir = .*/in_app_dir = True/g' /opt/conda/lib/python3.10/site-packages/gradio/routes.py && \
  git config --global --add safe.directory '*'

WORKDIR ${ROOT}
ENV NVIDIA_VISIBLE_DEVICES=all
ENV CLI_ARGS=""
EXPOSE 7860
ENTRYPOINT ["/docker/entrypoint.sh"]
CMD python -u webui.py --listen --port 7860 ${CLI_ARGS}