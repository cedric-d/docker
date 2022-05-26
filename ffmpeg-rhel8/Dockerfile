ARG BASE_IMAGE=rockylinux:8


FROM ${BASE_IMAGE} AS base

COPY certs/ /etc/pki/ca-trust/source/anchors/

RUN update-ca-trust \
 && echo "install_weak_deps=False" >> /etc/dnf/dnf.conf \
 && dnf -y install dnf-plugins-core \
 && dnf -y config-manager --set-enabled powertools

RUN dnf -y install \
      bzip2 \
      fontconfig \
      freetype \
      libdrm \
      libGL \
      libX11 \
      libXext \
      libXfixes \
      libXrandr \
      libxcb \
      SDL2 \
      xorg-x11-utils \
      xz \
      zlib



FROM base AS devel

ARG FFMPEG_VERSION=5.0.1
ARG GMMLIB_VERSION=22.1.3
ARG INTELMEDIASDK_VERSION=22.3.0
ARG LIBVA_VERSION=2.14.0

ARG CUDA_RPM_VERSION
ARG NVCODEC_VERSION
ARG NVIDIA_DRIVER_VERSION

RUN dnf -y config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo \
 && dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm \
 && dnf -y install \
      cmake \
      cuda-toolkit-${CUDA_RPM_VERSION} \
      diffutils \
      file \
      gcc \
      gcc-c++ \
      make \
      nasm \
      patch \
      wget \
      \
      fontconfig-devel \
      freetype-devel \
      kernel-devel \
      libdrm-devel \
      libGL-devel \
      libX11-devel \
      libXext-devel \
      libXfixes-devel \
      libXrandr-devel \
      libxcb-devel \
      SDL2-devel \
      xz-devel \
      zlib-devel


ARG PREFIX

ENV PATH=$PREFIX/bin:/usr/local/cuda/bin:$PATH
ENV PKG_CONFIG_PATH=$PREFIX/lib64/pkgconfig


WORKDIR /build

RUN wget -N \
  https://www.ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.xz \
  https://github.com/Intel-Media-SDK/MediaSDK/archive/intel-mediasdk-${INTELMEDIASDK_VERSION}.tar.gz \
  https://github.com/intel/gmmlib/archive/intel-gmmlib-${GMMLIB_VERSION}.tar.gz \
  https://github.com/intel/libva/releases/download/${LIBVA_VERSION}/libva-${LIBVA_VERSION}.tar.bz2 \
  https://github.com/FFmpeg/nv-codec-headers/releases/download/n${NVCODEC_VERSION}/nv-codec-headers-${NVCODEC_VERSION}.tar.gz \
  https://fr.download.nvidia.com/XFree86/Linux-x86_64/${NVIDIA_DRIVER_VERSION}/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_VERSION}.run


RUN tar xvf libva-${LIBVA_VERSION}.tar.bz2 \
 && cd libva-${LIBVA_VERSION} \
 && ./configure --prefix=$PREFIX --libdir=$PREFIX/lib64 \
 && make -j$(nproc) \
 && make install \
 && cd .. \
 && rm -rf libva-${LIBVA_VERSION}

RUN tar xvf intel-gmmlib-${GMMLIB_VERSION}.tar.gz \
 && cd gmmlib-intel-gmmlib-${GMMLIB_VERSION} \
 && mkdir build && cd build \
 && cmake -DBUILD_TYPE=release -DCMAKE_INSTALL_PREFIX=$PREFIX .. \
 && make -j$(nproc) \
 && make install \
 && cd ../.. \
 && rm -rf gmmlib-intel-gmmlib-${GMMLIB_VERSION}

RUN tar xvf intel-mediasdk-${INTELMEDIASDK_VERSION}.tar.gz \
 && cd MediaSDK-intel-mediasdk-${INTELMEDIASDK_VERSION} \
 && mkdir build && cd build \
 && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DBUILD_SAMPLES=OFF \
      -DBUILD_TUTORIALS=OFF \
      -DENABLE_X11_DRI3=ON \
      .. \
 && make -j$(nproc) \
 && make install \
 && cd ../.. \
 && rm -rf MediaSDK-intel-mediasdk-${INTELMEDIASDK_VERSION}

RUN tar xvf nv-codec-headers-${NVCODEC_VERSION}.tar.gz \
 && cd nv-codec-headers-${NVCODEC_VERSION} \
 && make install PREFIX=$PREFIX LIBDIR=lib64 \
 && cd .. \
 && rm -rf nv-codec-headers-${NVCODEC_VERSION}

RUN tar xvf ffmpeg-${FFMPEG_VERSION}.tar.xz \
 && cd ffmpeg-${FFMPEG_VERSION} \
 && ./configure --prefix=$PREFIX --libdir=$PREFIX/lib64 \
      --extra-cflags="-I/usr/local/cuda/include" --extra-ldflags="-L/usr/local/cuda/lib64" \
      --enable-cuda-nvcc \
      --enable-cuvid \
      --enable-ffnvcodec \
      --enable-libdrm \
      --enable-libfontconfig \
      --enable-libfreetype \
      --enable-libmfx \
      --enable-libxcb \
      --enable-nvdec \
      --enable-nvenc \
      --enable-opengl \
      --enable-vaapi \
    --disable-static --enable-shared --enable-rpath --enable-lto --disable-doc \
    --enable-nonfree \
 && make -j$(nproc) \
 && make install \
 && cd .. \
 && rm -rf ffmpeg-${FFMPEG_VERSION}


FROM base

ARG NVIDIA_DRIVER_VERSION
ARG PREFIX

COPY --from=devel /build/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_VERSION}.run /tmp/
RUN ln -s /bin/true /usr/local/sbin/depmod \
 && ln -s /bin/true /usr/local/sbin/lsmod \
 && ln -s /bin/true /usr/local/sbin/modprobe \
 && ln -s /bin/true /usr/local/sbin/rmmod \
 && sh /tmp/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_VERSION}.run --silent \
           --no-nvidia-modprobe --no-rpms --no-backup --no-kernel-module \
           --no-x-check --no-nouveau-check --no-kernel-module-source \
 && rm /tmp/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_VERSION}.run \
       /usr/local/sbin/depmod \
       /usr/local/sbin/lsmod \
       /usr/local/sbin/modprobe \
       /usr/local/sbin/rmmod

COPY --from=devel $PREFIX/ $PREFIX/

ENV PATH=$PREFIX/bin:$PATH
