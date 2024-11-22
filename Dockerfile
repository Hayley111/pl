FROM pytorch/pytorch:2.1.1-cuda12.1-cudnn8-devel

ENV DEBIAN_FRONTEND=noninteractive
ENV MINICONDA_URL=https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
ENV PATH=/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
COPY ./torch_2_1.yml /torch_2_1.yml

RUN sed -i 's@//.*archive.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -yq --no-install-recommends \
    tzdata s6 ssh sudo psmisc vim git curl ca-certificates bzip2&& \
    ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    mkdir /run/sshd && mkdir -p /etc/s6/sshd && \
    printf '#!/bin/sh\nexec /usr/sbin/sshd -D' >> /etc/s6/sshd/run && \
    chmod +x /etc/s6/sshd/run && groupadd -g 1000 -o ubuntu && \
    useradd -rm -d /home/ubuntu -s /bin/bash -G sudo -u 1000 -g 1000 \
    -p '$1$iFaj7WOK$E6tAyVen.qs/5rKGMpftl/' ubuntu && \
    curl -fsSL $MINICONDA_URL > /miniconda.sh && \
    chmod +x /miniconda.sh && \
    /bin/bash /miniconda.sh -b -p /opt/conda && \
    rm /miniconda.sh && echo 'export PATH="/opt/conda/bin:$PATH"' >> /home/ubuntu/.bashrc \
    && conda update -y conda && conda init && conda env create -f /torch_2_1.yml && \
    rm -rf /torch_2_1.yml
ENTRYPOINT ["/bin/s6-svscan", "/etc/s6/"]