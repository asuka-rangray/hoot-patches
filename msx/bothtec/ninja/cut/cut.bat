md mus
cd mus

rem bcut ..\NINJA.DSK DRIVER.BIN 0x00BE00 0x4000
rem a000
bcut ..\NINJA.DSK DRIVER.BIN 0x039000 0x0e00
rem ae00
bcut ..\NINJA.DSK DRIVER2.BIN 0x04B000 0x4000

cd ..