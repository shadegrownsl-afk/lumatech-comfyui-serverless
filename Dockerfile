# Base image RunPod worker-comfyui (a le handler et runpod SDK)
FROM runpod/worker-comfyui:5.7.0-base

# Remplace ComfyUI par la version 0.18.2 (celle de ton Network Volume)
RUN rm -rf /comfyui && \
    git clone https://github.com/Comfy-Org/ComfyUI.git /comfyui && \
    cd /comfyui && \
    git checkout v0.18.2

# Install dépendances ComfyUI 0.18.2
WORKDIR /comfyui
RUN pip install --no-cache-dir -r requirements.txt

# Install comfy-cli (pour gérer les custom nodes facilement)
RUN pip install --no-cache-dir comfy-cli

# Install custom nodes essentiels pour ton workflow LTX-2.3
RUN comfy-node-install comfyui-kjnodes && \
    comfy-node-install comfyui-videohelpersuite

# Clean
RUN pip cache purge

# Working dir pour handler
WORKDIR /

# Lancement standard worker-comfyui
CMD ["/start.sh"]