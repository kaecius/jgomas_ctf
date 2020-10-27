@ECHO off
cd C:\Users\ehu\Desktop\jgomas_ctf\jgomas\bin\mas
ECHO Running manager
start jgomas_manager.bat
pause
ECHO Running launcher
start jgomas_launcher.bat
pause
ECHO Running render
cd ../render/w32/
start run_jgomasrender.bat