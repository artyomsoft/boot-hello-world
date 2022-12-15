		use16
		org 0x7c00
		
		cli
		jmp 0:start
		times 8-($-$$) nop		; Pad to file offset 8

; iso_boot_info structure is filled by xorriso when we generate ISO file.
iso_boot_info:
bi_pvd:		dd 16				; LBA of primary volume descriptor
bi_file:	dd 0				; LBA of boot file
bi_length:	dd 0xdeadbeef			; Length of boot file
bi_csum:	dd 0xdeadbeef			; Checksum of boot file
bi_reserved:	times 10 dd 0xdeadbeef		; Reserved
iso_boot_info_end:

signature:	dd 0x7078c0fb			; used by ISOLINUX hybrid MBR

start:
		xor ax, ax
		push ax
		pop es
		push ax
		pop ds
		sti

		mov ax, 0x03
		int 0x10

		mov si, hello_message

		mov ah, 0xe
print_loop:
		lodsb
		or al, al
		jz done
		int 0x10
  		jmp print_loop

done:
		jmp $
hello_message:
		db "Hello world BIOS", 0x0a, 0

		times 510 - ($ - $$) db 0
		dw 0xaa55
