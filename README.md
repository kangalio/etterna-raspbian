# Etterna for Raspbian (Raspberry Pi)

This repository contains resources and a script to compile Etterna for the Raspberry Pi.

## What can you use this for?

I've developed this on a Raspberry Pi 3 B+, but it may very well work on other devices. The [repository](https://github.com/SpottyMatt/raspbian-3b-stepmania-arcade) I loosely based this off of says it's compatible with Raspberry Pi 3B (no plus) as well.

## Quick Start

1. Download this repository
1. Open a terminal in the downloaded directory and type "make -j4"
1. Wait for quite a while
1. [Enable the OpenGL driver](https://eltechs.com/how-to-enable-opengl-on-raspberry-pi/) for framerates over 2fps
1. Allocate more memory for the graphics:
    * Type `sudo raspi-config` and navigate into Advanced Options -> Memory Split. Type in 256MB or 512MB and then exit.
1. It's finished. To start Etterna, execute the etterna file inside the etterna directory

Note that this script does not install Etterna on the system. I might add it later, but for now you'll have to start Etterna in every time through the directory you compiled in.

## Errors?

Sometimes the build fails: when I was testing I encountered internal compiler errors as well as hang ups. In that case interrupt the compiling process using Ctrl+C and rebuild using `make -j4 build`.

## More control

When you run `make`, in the background 4 tasks are being executed one after another:

1. `make package-download` downloads all required packages using apt-get
1. `make download` downloads the source code of Etterna
1. `make prepare` patches Etterna and prepares compiliation
1. `make build` finally builds the whole thing. This step takes the longest.

You can execute these tasks manually, e.g. to have more control about what's being done or to be able to fix errors.
