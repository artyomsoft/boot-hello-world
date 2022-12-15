FROM ubuntu:22.10
RUN apt update && apt install --yes make gcc-mingw-w64 fasm gnu-efi binutils
RUN apt install --yes mtools dosfstools xorriso isolinux xxd
RUN apt install --yes qemu-system-x86 ovmf 
WORKDIR /app/
