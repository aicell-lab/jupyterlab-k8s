
ARG NVIDIA_IMAGE=nvcr.io/nvidia/pytorch:21.09-py3

## Example Nvidia images available:
# PyTorch: https://ngc.nvidia.com/catalog/containers/nvidia:pytorch

FROM ${NVIDIA_IMAGE}

USER root
WORKDIR /workspace

RUN apt-get update && \
    apt-get install -y zsh 
# curl wget

# Install JupyterLab with conda
RUN conda install --quiet -y \
      openjdk maven \
      nodejs yarn \
      ipywidgets \
      jupyterlab \
      jupyterlab-git \
      jupyterlab-lsp \
      jupyter-lsp-python \
      jupyter_bokeh \
      jupyterlab-drawio \
      'jupyter-server-proxy>=3.1.0' && \
    conda install -y -c plotly 'plotly>=4.8.2'


# Install GPU dashboard: https://developer.nvidia.com/blog/gpu-dashboards-in-jupyter-lab/
RUN pip install --upgrade pip && \
    pip install --upgrade \
      jupyterlab-nvdashboard \
      mitosheet3 \
      jupyterlab-spreadsheet-editor

# RUN jupyter labextension update --all && \
#     jupyter lab build 


# Install VS Code server
RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN code-server --install-extension redhat.vscode-yaml \
        --install-extension ms-python.python \
        --install-extension vscjava.vscode-java-pack \
        --install-extension ginfuru.ginfuru-better-solarized-dark-theme

COPY settings.json /root/.local/share/code-server/User/settings.json
COPY icons/*.svg /etc/jupyter/


# Install ZSH
RUN sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
RUN wget -O ~/.oh-my-zsh/custom/themes/vemonet_bira.zsh-theme https://raw.githubusercontent.com/vemonet/zsh-theme-biradate/master/zsh/vemonet_bira.zsh-theme
RUN sed -i 's/robbyrussell/vemonet_bira/g' ~/.zshrc
ENV SHELL=/bin/zsh
RUN chsh -s /bin/zsh 

# Add jupyter config script run at the start of the container
COPY jupyter_notebook_config.py /etc/jupyter/jupyter_notebook_config.py

WORKDIR /workspace
EXPOSE 8888
ENTRYPOINT ["jupyter", "lab", "--allow-root", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--config=/etc/jupyter/jupyter_notebook_config.py"]