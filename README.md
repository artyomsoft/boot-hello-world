# boot-hello-world

This is a sample project which helps to understand how booting from CD-ROM and flash disks works.

To create build enviromnent:

    docker build -t boot-hello-world:latest .

To create bootable ISO image in Windows PowerShell:

    docker run --name isobuilder -v ${pwd}:/app --rm -it boot-hello-world make clean all 
  
To create bootable ISO image in Linux:

    docker run --name isobuilder -v $(pwd):/app --rm -it boot-hello-world make clean all

To run ISO image in qemu emulator in Windows PowerShell:

    docker run --name isorunner -v ${pwd}:/app --rm -it boot-hello-world make qemu-bios-cdrom
    docker run --name isorunner -v ${pwd}:/app --rm -it boot-hello-world make qemu-efi-cdrom
    docker run --name isorunner -v ${pwd}:/app --rm -it boot-hello-world make qemu-bios-flash-disk
    docker run --name isorunner -v ${pwd}:/app --rm -it boot-hello-world make qemu-efi-flash-disk

To run ISO image in qemu emulator in Linux:

    docker run --name isorunner -v $(pwd):/app --rm -it boot-hello-world make qemu-bios-cdrom
    docker run --name isorunner -v $(pwd):/app --rm -it boot-hello-world make qemu-efi-cdrom
    docker run --name isorunner -v $(pwd):/app --rm -it boot-hello-world make qemu-bios-flash-disk
    docker run --name isorunner -v $(pwd):/app --rm -it boot-hello-world make qemu-efi-flash-disk

To quit emulator press *Ctrl+A* then *X*
