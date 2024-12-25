# ----------------------------------------------------------
# Dockerfile
# ----------------------------------------------------------
# Choose a suitable base image for your CUDA version (12.4).
#   -devel images have the tools needed to build from source.
#   -runtime images are smaller but missing some dev tools.
FROM nvidia/cuda:12.4.0-devel-ubuntu22.04

# Prevent interactive tzdata prompts
ENV DEBIAN_FRONTEND=noninteractive

# ----------------------------------------------------------
# 1. System Packages
# ----------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget curl ca-certificates git build-essential \
    && rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------------
# 2. Install Miniconda (or Anaconda)
# ----------------------------------------------------------
ENV CONDA_DIR=/opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh \
    && /bin/bash /tmp/miniconda.sh -b -p $CONDA_DIR \
    && rm /tmp/miniconda.sh \
    && $CONDA_DIR/bin/conda clean -afy
# Add conda to PATH
ENV PATH=$CONDA_DIR/bin:$PATH

# ----------------------------------------------------------
# 3. Create a conda environment
# ----------------------------------------------------------
# Example environment name: "myenv" with Python 3.9
RUN conda create -y -n myenv python=3.9

# We can activate the environment by default in the container.
# One method: modify /etc/bash.bashrc or create an ENV variable.
# For simplicity, we'll set a default SHELL to always activate.
SHELL ["bash", "-c"]
RUN echo "conda activate myenv" >> ~/.bashrc

# ----------------------------------------------------------
# 4. Install PyTorch (and other libs) within the environment
# ----------------------------------------------------------
# Since CUDA 12.4 is not officially supported by a prebuilt PyTorch
# binary, you either must:
#   - Switch to a supported version (e.g., 11.8 or 12.1), OR
#   - Build PyTorch from source for 12.4.
#
# The snippet below tries to install a prebuilt PyTorch.
# If you need 12.4 specifically, you likely have to build from source.
#
# For example, with CUDA 12.1 support (PyTorch nightly):
# RUN conda activate myenv && conda install -y pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch-nightly -c nvidia
#
# For demonstration, let's show how you would do it for CUDA 11.8
# (the standard stable approach), and you can adapt to 12.4 as needed.
RUN conda activate myenv && conda install -y pytorch torchvision torchaudio cudatoolkit=11.8 -c pytorch -c nvidia \
    && conda clean -afy

# (Optional) Install additional packages in the environment
RUN conda activate myenv && pip install timm jupyter pandas scikit-learn matplotlib

# ----------------------------------------------------------
# 5. (Optional) Build PyTorch from Source for CUDA 12.4
# ----------------------------------------------------------
# If you absolutely require CUDA 12.4, uncomment the following lines
# to build from source. This is just an example workflow:
# 
# RUN conda activate myenv && \
#     conda install -y numpy ninja pyyaml mkl mkl-include setuptools cmake cffi typing_extensions future six requests dataclasses && \
#     git clone --recursive https://github.com/pytorch/pytorch && \
#     cd pytorch && \
#     git checkout master && \
#     git submodule sync && \
#     git submodule update --init --recursive && \
#     python setup.py install && \
#     cd .. && rm -rf pytorch
#
# This will be time-consuming and you may want to adjust tags/branches.

# ----------------------------------------------------------
# 6. Switch back to bash as default shell
# ----------------------------------------------------------
SHELL ["/bin/bash", "-c"]

# Set up an entrypoint script to automatically activate conda env
# whenever the container starts (optional convenience).
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

# Default command: Bash
CMD ["/bin/bash"]
