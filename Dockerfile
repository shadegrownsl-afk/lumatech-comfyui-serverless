# Base image RunPod worker-comfyui
FROM runpod/worker-comfyui:5.7.0-base

# Remplace ComfyUI par la version 0.18.2
RUN rm -rf /comfyui && \
    git clone https://github.com/Comfy-Org/ComfyUI.git /comfyui && \
    cd /comfyui && \
    git checkout v0.18.2

WORKDIR /comfyui
RUN pip install --no-cache-dir -r requirements.txt

# ==== CUSTOM NODES ====

# ComfyUI Manager (safety net, pour ajouter des nodes à chaud)
RUN git clone https://github.com/Comfy-Org/ComfyUI-Manager.git /comfyui/custom_nodes/ComfyUI-Manager && \
    pip install --no-cache-dir -r /comfyui/custom_nodes/ComfyUI-Manager/requirements.txt

# KJNodes (ExtractLastImage, GetImageRangeFromBatch)
RUN git clone https://github.com/kijai/ComfyUI-KJNodes.git /comfyui/custom_nodes/ComfyUI-KJNodes && \
    pip install --no-cache-dir -r /comfyui/custom_nodes/ComfyUI-KJNodes/requirements.txt

# VideoHelperSuite (VHS_Load/Combine, audio VHS)
RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git /comfyui/custom_nodes/ComfyUI-VideoHelperSuite && \
    pip install --no-cache-dir -r /comfyui/custom_nodes/ComfyUI-VideoHelperSuite/requirements.txt

# Bjornulf (ConcatVideos ffmpeg)
RUN git clone https://github.com/justUmen/Bjornulf_custom_nodes.git /comfyui/custom_nodes/Bjornulf_custom_nodes && \
    (pip install --no-cache-dir -r /comfyui/custom_nodes/Bjornulf_custom_nodes/requirements.txt || true)

# GGUF (Qwen Image Edit 2509, modèles quantized)
RUN git clone https://github.com/city96/ComfyUI-GGUF.git /comfyui/custom_nodes/ComfyUI-GGUF && \
    pip install --no-cache-dir -r /comfyui/custom_nodes/ComfyUI-GGUF/requirements.txt

# WanVideoWrapper (InfiniteTalk lipsync)
RUN git clone https://github.com/kijai/ComfyUI-WanVideoWrapper.git /comfyui/custom_nodes/ComfyUI-WanVideoWrapper && \
    pip install --no-cache-dir -r /comfyui/custom_nodes/ComfyUI-WanVideoWrapper/requirements.txt

# Frame Interpolation RIFE (transitions fluides entre clips, 25→50fps)
RUN git clone https://github.com/Fannovel16/ComfyUI-Frame-Interpolation.git /comfyui/custom_nodes/ComfyUI-Frame-Interpolation && \
    (pip install --no-cache-dir -r /comfyui/custom_nodes/ComfyUI-Frame-Interpolation/requirements-no-cupy.txt || \
     pip install --no-cache-dir -r /comfyui/custom_nodes/ComfyUI-Frame-Interpolation/requirements.txt || true)

# Video Upscale WithModel (RealESRGAN + OpenModelDB models)
RUN git clone https://github.com/ShmuelRonen/ComfyUI-VideoUpscale_WithModel.git /comfyui/custom_nodes/ComfyUI-VideoUpscale_WithModel

# ComfyUI_essentials (toolkit : resize, crop, LUT, blend, etc.)
RUN git clone https://github.com/cubiq/ComfyUI_essentials.git /comfyui/custom_nodes/ComfyUI_essentials && \
    (pip install --no-cache-dir -r /comfyui/custom_nodes/ComfyUI_essentials/requirements.txt || true)

RUN pip cache purge

# Script de démarrage avec symlink des modèles
RUN echo '#!/bin/bash\n\
echo "=== Symlinking models from Network Volume ==="\n\
if [ -d "/runpod-volume/runpod-slim/ComfyUI/models" ]; then\n\
  for dir in /runpod-volume/runpod-slim/ComfyUI/models/*/; do\n\
    name=$(basename "$dir")\n\
    mkdir -p "/comfyui/models/$name"\n\
    for file in "$dir"*; do\n\
      if [ -e "$file" ]; then\n\
        ln -sf "$file" "/comfyui/models/$name/$(basename $file)"\n\
      fi\n\
    done\n\
    echo "Linked models/$name"\n\
  done\n\
  echo "=== Symlink complete ==="\n\
else\n\
  echo "WARNING: Network Volume not found"\n\
fi\n\
exec /start.sh' > /custom-start.sh && \
    chmod +x /custom-start.sh

WORKDIR /
CMD ["/custom-start.sh"]
