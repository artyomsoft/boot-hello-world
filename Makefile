CC = x86_64-w64-mingw32-gcc 
CFLAGS = -shared -I/usr/include/efi -nostdlib -mno-red-zone -fno-stack-protector -Wall -e EfiMain

BUILDDIR = build
OUT = out
ISO_DIR = $(BUILDDIR)/iso-image
EFI_BOOT_DIR = $(ISO_DIR)/EFI/boot

EFI_APP = bootx64.efi
BIOS_APP = bootsec.bin
ESP_IMAGE = uefi.img
BOOT_ISO = $(OUT)/bootdisk.iso

HYBRID_MBR = /usr/lib/ISOLINUX/isohdpfx.bin
TARGETS = $(BOOT_ISO)

all: $(TARGETS)  	

$(BUILDDIR):
	mkdir -p $(BUILDDIR)
	mkdir -p $(OUT)


$(BUILDDIR)/$(BIOS_APP): bioshello.asm | $(BUILDDIR)
	@echo "[BUILDING BIOS APP]"
	fasm $< $@

$(BUILDDIR)/$(EFI_APP): efihello.c | $(BUILDDIR)
	@echo "[BUILDING EFI APP]"
	$(CC) $(CFLAGS) $< -o $@.dll
	objcopy --target=efi-app-x86_64 $@.dll $@

$(BUILDDIR)/$(ESP_IMAGE): $(BUILDDIR)/$(EFI_APP) | $(BUILDDIR)
	@echo "[BUILDING ESP IMAGE]"
	dd if=/dev/zero of=${BUILDDIR}/${ESP_IMAGE} bs=512 count=2880
	mkfs.msdos -F 12 -n 'EFIBOOTISO' ${BUILDDIR}/${ESP_IMAGE}
	mmd -i ${BUILDDIR}/${ESP_IMAGE} ::EFI
	mmd -i ${BUILDDIR}/${ESP_IMAGE} ::EFI/BOOT
	mcopy -i ${BUILDDIR}/${ESP_IMAGE} ${BUILDDIR}/${EFI_APP} ::EFI/BOOT/bootx64.efi

$(ISO_DIR): $(BUILDDIR)/$(BIOS_APP) $(BUILDDIR)/$(ESP_IMAGE)
	@echo "[CREATING ISO DIRECTORY WITH FILES]"
	mkdir -p ${ISO_DIR}/boot
	mkdir -p ${EFI_BOOT_DIR}
	cp ${BUILDDIR}/${EFI_APP} ${EFI_BOOT_DIR}/
	cp ${BUILDDIR}/${BIOS_APP} ${ISO_DIR}/boot/
	cp ${BUILDDIR}/${ESP_IMAGE} ${ISO_DIR}/boot/   

$(BOOT_ISO): $(ISO_DIR)
	@echo "[BUILDING HYBRYD ISO FILE]"
	xorriso  -as mkisofs -V "HybridBootISOSample" -o $@ -isohybrid-mbr $(HYBRID_MBR) -c boot/boot.cat -b boot/$(BIOS_APP) -no-emul-boot -boot-info-table \
	-boot-load-size 4 -eltorito-alt-boot -e boot/$(ESP_IMAGE) -no-emul-boot -isohybrid-gpt-basdat $(ISO_DIR) --sort-weight 0 /boot --sort-weight 1 /
	@echo "The Hybrid ISO file [$@] was created. You can burn it to CD/DVD or to the flash disk and test"
clean:
	@echo "[PERFORMING CLEAN]"
	rm -rf $(BUILDDIR)
	rm -rf $(OUT)

qemu-bios-cdrom: $(BOOT_ISO)
	@echo "[STARTING QEMU WITH BIOS FIRMWARE FROM CDROM]"
	qemu-system-x86_64 -boot d -cdrom $(BOOT_ISO) -nographic -net none -monitor telnet::45454,server,nowait -serial mon:stdio

qemu-efi-cdrom: $(BOOT_ISO)
	@echo "[STARTING QEMU WITH UEFI FIRMWARE FROM CDROM]"
	qemu-system-x86_64 -bios /usr/share/ovmf/OVMF.fd -boot d -cdrom $(BOOT_ISO) -nographic -net none -monitor telnet::45454,server,nowait -serial mon:stdio

qemu-bios-flash-disk: $(BOOT_ISO) 
	@echo "[STARTING QEMU WITH BIOS FIRMWARE FROM FLASH DISK]"
	qemu-system-x86_64 -boot d -hda $(BOOT_ISO) -nographic -net none -monitor telnet::45454,server,nowait -serial mon:stdio
 
qemu-efi-flash-disk: $(BOOT_ISO)
	@echo "[STARTING QEMU WITH UEFI FIRMWARE FROM FLASH DISK]"
	qemu-system-x86_64 -bios /usr/share/ovmf/OVMF.fd -boot d -hda $(BOOT_ISO) -nographic -net none -monitor telnet::45454,server,nowait -serial mon:stdio
