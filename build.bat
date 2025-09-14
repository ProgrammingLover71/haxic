@echo off
echo Creating Python build...

haxe -main src/Main.hx -python out/py/haxic.py -D release
if errorlevel 1 (
    echo Python build failed.
) else (
    echo Python build succeeded. Output file is out/py/haxic.py.
)

haxe -main src/Main.hx -cpp out/cpp -D release -D analyzer-optimize
if errorlevel 1 (
    echo C++ build failed.
    pause
) else (
    echo C++ build succeeded. Output file is out/cpp/Main.exe.
)

pause