md mus
cd mus

bcut ..\F1S3D_A.DSK BIOS.BIN 0x00800 0x1000
bcut ..\F1S3D_A.DSK FMDRV.BIN 0x060000 0x2000
bcut ..\F1S3D_A.DSK FM0.BIN 0x062000 0x0d00
bcut ..\F1S3D_A.DSK FM1.BIN 0x062e00 0x0d00
bcut ..\F1S3D_A.DSK PSGDRV.BIN 0x064000 0x1A00
bcut ..\F1S3D_A.DSK PSG0.BIN 0x065A00 0x0800
bcut ..\F1S3D_A.DSK PSG1.BIN 0x066200 0x0a00


bcut ..\F1S3D_B.DSK FM2.BIN 0x06E000 0x0d00
bcut ..\F1S3D_B.DSK FM3.BIN 0x06EE00 0x0d00
bcut ..\F1S3D_B.DSK FM4.BIN 0x06FC00 0x0d00
bcut ..\F1S3D_B.DSK FM5.BIN 0x070A00 0x0d00
bcut ..\F1S3D_B.DSK FM6.BIN 0x071800 0x0d00
bcut ..\F1S3D_B.DSK FM7.BIN 0x072600 0x0d00
bcut ..\F1S3D_B.DSK FM8.BIN 0x073400 0x0d00
bcut ..\F1S3D_B.DSK PSG2.BIN 0x074200 0x0a00
bcut ..\F1S3D_B.DSK FM9.BIN 0x074C00 0x0d00
bcut ..\F1S3D_B.DSK PSG3.BIN 0x092000 0x0600
bcut ..\F1S3D_B.DSK FMA.BIN 0x092600 0x0400
bcut ..\F1S3D_B.DSK PSG4.BIN 0x092a00 0x0800

cd ..