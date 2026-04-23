# Base image RunPod worker-comfyui (a le handler et runpod SDK)
FROM runpod/worker-comfyui:5.7.0-base

# Remplace ComfyUI par la version 0.18.2
RUN rm -rf /comfyui && \
    git clone https://github.com/Comfy-Org/ComfyUI.git /comfyui && \
    cd /comfyui && \
    git checkout v0.18.2

# Install dépendances ComfyUI 0.18.2
WORKDIR /comfyui
RUN pip install --no-cache-dir -r requirements.txt

# Install comfy-cli
RUN pip install --no-cache-dir comfy-cli

# Install custom nodes essentiels
RUN comfy-node-install comfyui-kjnodes && \
    comfy-node-install comfyui-videohelpersuite

# Clean
RUN pip cache purge

# Script de démarrage qui symlink les modèles du Network Volume
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
  echo "WARNING: Network Volume not found at /runpod-volume/runpod-slim/ComfyUI/models"\n\
fi\n\
exec /start.sh' > /custom-start.sh && \
    chmod +x /custom-start.sh

# Working dir
WORKDIR /

# Utiliser notre script custom au lieu de /start.sh
CMD ["/custom-start.sh"]