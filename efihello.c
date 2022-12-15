#include <efi.h>
#include <efilib.h>

EFI_STATUS EfiMain (EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE  *SystemTable ) {

    SystemTable->ConOut->OutputString(SystemTable->ConOut, L"UEFI Hello World!\n");
    while(1);
    return EFI_SUCCESS;
}
