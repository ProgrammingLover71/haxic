@echo off
echo Creating Python build...

haxe -main src/Main.hx -python out/py/haxic.py -D release
if errorlevel 1 (
    echo Python build failed.
    pause
)

echo Python build succeeded. Output file is out/py/haxic.py.
pause