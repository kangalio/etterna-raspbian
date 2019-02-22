.PHONY: all
all:
	$(MAKE) package-download
	$(MAKE) download
	$(MAKE) prepare
	$(MAKE) build

.PHONY: package-download
package-download:
	sudo sed -i 's/#deb-src/deb-src/g' /etc/apt/sources.list
	sudo apt-get update
	sudo apt-get install -y \
		binutils-dev build-essential cmake ffmpeg libasound-dev libbz2-dev \
		libc6-dev libcairo2-dev libgdk-pixbuf2.0-dev libglew1.5-dev \
		libglib2.0-dev libglu1-mesa-dev libgtk2.0-dev libjack0 libjack-dev \
		libjpeg-dev libmad0-dev libogg-dev libpango1.0-dev libpng-dev \
		libpulse-dev libudev-dev libva-dev libvorbis-dev libxrandr-dev \
		libxtst-dev mesa-common-dev mesa-utils unclutter yasm zlib1g-dev \
		libssl-dev nasm libcurl4-openssl-dev # I've added these three

.PHONY: download
.ONESHELL:
download:
	git clone https://github.com/etternagame/etterna
	cd etterna
	# Reset to version 0.64.0
	git reset --hard 13267c3a4bfcf1c0713b77496ff1a4361e1ce4ed

.PHONY: prepare
.ONESHELL:
prepare:
	cd etterna
	git submodule init
	git submodule update
	git apply ../resources/raspi-3b-arm.patch
	mkdir -p Build
	cd Build
	cmake -G "Unix Makefiles" \
	        -DWITH_CRASH_HANDLER=0 \
	        -DWITH_SSE2=0 \
	        -DWITH_MINIMAID=0 \
	        -DWITH_FULL_RELEASE=1 \
		-DCMAKE_BUILD_TYPE=Release \
	        -DARM_CPU=cortex-a53 \
		-DARM_FPU=neon-fp-armv8 \
		..
	cmake ..
	cd ..

	# For some reason CMake puts a backslash into one command-line argument, so I had to revert that
	sed -i "s/-D\\\\ /-D /" Build/extern/LuaJIT-2.1.0-beta3/CMakeFiles/buildvm.dir/build.make

	# Etterna depends on cpuid.h which is unavailable for ARM
	git apply ../resources/cpuid-dependency-removal.patch

	# Replace x86 MinaCalc binary blob with ARM64 MinaCalc binary blob
	# (Etterna devs were kind enough to give me the code to compile it for ARM64)
	cp ../resources/MinaCalc.a extern/MinaCalc/MinaCalc.a
	cp ../resources/MinaCalc.a extern/MinaCalc/libMinaCalc.a

	# Replace x86 discord-rpc library binary
	cp ../resources/libdiscord-rpc.a extern/discord-rpc-2.0.1/lib/libdiscord-rpc.a

.PHONY: build
.ONESHELL:
build:
	cd etterna/Build
	$(MAKE)
