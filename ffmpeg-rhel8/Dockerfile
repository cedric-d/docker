ARG BASE_IMAGE=rockylinux:8

FROM ${BASE_IMAGE} AS base

RUN echo "install_weak_deps=False" >> /etc/dnf/dnf.conf \
 && dnf -y install dnf-plugins-core \
 && dnf -y config-manager --set-enabled powertools \
 && dnf -y config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo \
 && dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm \
 && dnf -y update

ARG CUDA_RPM_VERSION

RUN dnf -y install \
      bzip2 \
      cuda-runtime-${CUDA_RPM_VERSION} \
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
      zlib \
      xz



FROM base AS devel

RUN dnf -y install \
      cmake \
      diffutils \
      gcc \
      gcc-c++ \
      make \
      nasm \
      wget \
 && dnf -y install \
      cuda \
      fontconfig-devel \
      freetype-devel \
      git \
      kernel-devel \
      libdrm-devel \
      libGL-devel \
      libX11-devel \
      libXext-devel \
      libXfixes-devel \
      libXrandr-devel \
      libxcb-devel \
      opencl-headers \
      SDL2-devel \
      xz-devel \
      zlib-devel


ARG FFMPEG_VERSION
ARG GMMLIB_VERSION
ARG INTELMEDIASDK_VERSION
ARG LIBVA_VERSION
ARG NVCODEC_VERSION
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
 && git clone --branch stable --depth 1 https://code.videolan.org/videolan/x264.git \
 && git clone --branch stable --depth 2 https://bitbucket.org/multicoreware/x265_git

RUN rm -rf libva-${LIBVA_VERSION} \
 && tar xvf libva-${LIBVA_VERSION}.tar.bz2 \
 && cd libva-${LIBVA_VERSION} \
 && ./configure --prefix=$PREFIX --libdir=$PREFIX/lib64 \
 && make -j$(nproc) \
 && make install \
 && cd ..

RUN rm -rf gmmlib-intel-gmmlib-${GMMLIB_VERSION} \
 && tar xvf intel-gmmlib-${GMMLIB_VERSION}.tar.gz \
 && cd gmmlib-intel-gmmlib-${GMMLIB_VERSION} \
 && mkdir build && cd build \
 && cmake -DBUILD_TYPE=release -DCMAKE_INSTALL_PREFIX=$PREFIX .. \
 && make -j$(nproc) \
 && make install \
 && cd ../..

RUN rm -rf MediaSDK-intel-mediasdk-${INTELMEDIASDK_VERSION} \
 && tar xvf intel-mediasdk-${INTELMEDIASDK_VERSION}.tar.gz \
 && cd MediaSDK-intel-mediasdk-${INTELMEDIASDK_VERSION} \
 && mkdir build && cd build \
 && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DBUILD_SAMPLES=OFF \
      -DBUILD_TUTORIALS=OFF \
      -DENABLE_X11_DRI3=ON \
      .. \
 && make -j$(nproc) \
 && make install \
 && cd ../..

RUN rm -rf nv-codec-headers-${NVCODEC_VERSION} \
 && tar xvf nv-codec-headers-${NVCODEC_VERSION}.tar.gz \
 && cd nv-codec-headers-${NVCODEC_VERSION} \
 && make install PREFIX=$PREFIX LIBDIR=lib64 \
 && cd ..

RUN cd x264 \
 && git clean -fdx \
 && ./configure --prefix=$PREFIX --libdir=$PREFIX/lib64 \
      --disable-cli --enable-shared --enable-lto \
 && make -j$(nproc) \
 && make install \
 && cd ..

RUN cd x265_git/build/linux \
 && git clean -fdx \
 && cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=$PREFIX -DLIB_INSTALL_DIR=lib64 ../../source \
 && make -j$(nproc) \
 && make install \
 && rm -f $PREFIX/lib64/libx265.a \
 && cd ../../..

RUN rm -rf ffmpeg-${FFMPEG_VERSION} \
 && tar xvf ffmpeg-${FFMPEG_VERSION}.tar.xz \
 && cd ffmpeg-${FFMPEG_VERSION} \
 && ./configure --prefix=$PREFIX --libdir=$PREFIX/lib64 \
      --extra-cflags="-I/usr/local/cuda/include" --extra-ldflags="-L/usr/local/cuda/lib64" \
      --enable-cuda-nvcc --nvccflags="-gencode arch=compute_52,code=sm_52 -O2" \
      --enable-cuvid \
      --enable-ffnvcodec \
      --enable-libdrm \
      --enable-libfontconfig \
      --enable-libfreetype \
      --enable-libmfx \
      --enable-libnpp \
      --enable-libx264 \
      --enable-libx265 \
      --enable-libxcb \
      --enable-nvdec \
      --enable-nvenc \
      --enable-opencl \
      --enable-opengl \
      --enable-vaapi \
    --disable-static --enable-shared --enable-rpath --enable-lto --disable-doc \
    --enable-gpl --enable-version3 --enable-nonfree \
 && make -j$(nproc) \
 && make install \
 && cd ..


FROM base

ARG FFMPEG_VERSION
ARG PREFIX

COPY --from=devel $PREFIX $PREFIX

RUN if mountpoint -q /output; then \
      tar cvJf /output/ffmpeg-${FFMPEG_VERSION}-bin.tar.xz -P "$PREFIX" ; \
    fi

VOLUME /output
