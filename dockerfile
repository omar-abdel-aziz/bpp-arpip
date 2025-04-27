FROM ubuntu:22.04

ENV PATH=/DASM-arpip/.local/bin:$PATH \
    LD_LIBRARY_PATH=/DASM-arpip/.local/lib:$LD_LIBRARY_PATH

# install basics
RUN apt-get update \
 && apt-get install -y \
      g++ \
      git \
      wget \
      make \
      libssl-dev \
      zlib1g-dev \
 && rm -rf /var/lib/apt/lists/*
 

WORKDIR /DASM-arpip

# build & install CMake locally
RUN wget https://cmake.org/files/v3.16/cmake-3.16.3.tar.gz \
 && tar zxvf cmake-3.16.3.tar.gz \
 && cd cmake-3.16.3 \
 && ./bootstrap --prefix=/DASM-arpip/.local \
 && make -j"$(nproc)" && make install \
 && cd .. \
 && rm -rf cmake-3.16.3 cmake-3.16.3.tar.gz

# # bpp-core
# RUN git clone https://github.com/BioPP/bpp-core \
#  && cd bpp-core \
#  && git checkout tags/v2.4.1 -b v241 \
#  && mkdir build && cd build \
#  && cmake .. -DCMAKE_INSTALL_PREFIX=../../.local \
#  && make install \
#  && cd ../.. 

 # bpp-core
RUN git clone https://github.com/BioPP/bpp-core \
&& cd bpp-core \
&& git checkout tags/v2.4.1 -b v241 \
\
# patch GlobalGraph.cpp: add <limits> and qualify numeric_limits
&& sed -i '1i#include <limits>' src/Bpp/Graph/GlobalGraph.cpp \
&& sed -i 's/numeric_limits</std::numeric_limits</g' src/Bpp/Graph/GlobalGraph.cpp \
\
&& mkdir build && cd build \
&& cmake .. -DCMAKE_INSTALL_PREFIX=../../.local \
&& make install \
&& cd ../..

# bpp-seq
RUN git clone https://github.com/BioPP/bpp-seq \
 && cd bpp-seq \
 && git checkout tags/v2.4.1 -b v241 \
 && mkdir build && cd build \
 && cmake .. -DCMAKE_INSTALL_PREFIX=../../.local \
 && make install \
 && cd ../..

# bpp-phyl
RUN git clone https://github.com/BioPP/bpp-phyl \
 && cd bpp-phyl \
 && git checkout tags/v2.4.1 -b v241 \
 && mkdir build && cd build \
 && cmake .. -DCMAKE_INSTALL_PREFIX=../../.local \
 && make install \
 && cd ../..

# Boost 1.79
RUN wget https://downloads.sourceforge.net/project/boost/boost/1.79.0/boost_1_79_0.tar.gz \
 && tar xvf boost_1_79_0.tar.gz \
 && cd boost_1_79_0 \
 && ./bootstrap.sh --prefix=/DASM-arpip/.local \
 && ./b2 && ./b2 install \
 && cd .. \
 && rm -rf boost_1_79_0 boost_1_79_0.tar.gz

# glog
RUN git clone -b v0.5.0 https://github.com/google/glog \
 && cd glog \
 && cmake -H. -Bbuild -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=../.local \
 && cmake --build build --target install \
 && cd ..

# # googletest
# RUN git clone https://github.com/google/googletest.git -b release-1.11.0 \
#  && cd googletest \
#  && mkdir build && cd build \
#  && cmake .. -DCMAKE_INSTALL_PREFIX=../../.local \
#  && make install \
#  && cd ../..

# install GoogleTest system‑wide so that -lgtest works
RUN git clone https://github.com/google/googletest.git -b release-1.11.0 \
 && cd googletest \
 && mkdir build && cd build \
 && cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local \
 && make -j"$(nproc)" install

# # bpp-arpip
# RUN git clone https://github.com/acg-team/bpp-arpip/ \
#  && cd bpp-arpip \
#  && cmake --target ARPIP -- -DCMAKE_BUILD_TYPE=Release-static \
#       -DCMAKE_INSTALL_PREFIX=../.local \
#       -DCMAKE_PREFIX_PATH=../.local \
#       -DCMAKE_EXE_LINKER_FLAGS="-L../.local/lib" CMakeLists.txt \
#  && make \
#  && cd ..
# bpp-arpip, with tests
RUN git clone https://github.com/acg-team/bpp-arpip/ \
 && cd bpp-arpip \
 && mkdir build && cd build \
 && cmake .. \
      -DCMAKE_BUILD_TYPE=Release-static \
      -DCMAKE_INSTALL_PREFIX=../../.local \
      -DCMAKE_PREFIX_PATH=../../.local \
      -DCMAKE_LIBRARY_PATH=/DASM-arpip/.local/lib \
      -DCMAKE_INCLUDE_PATH=/DASM-arpip/.local/include \
 && make \
 && cd ../..


CMD ["bash"]
