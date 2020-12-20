call flutter build web
call del .\docs /F /Q
call xcopy .\build\web .\docs /E /F /Q /Y