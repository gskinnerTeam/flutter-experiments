CALL flutter build web
CALL del .\docs /F /Q
CALL xcopy .\build\web .\docs /E /F /Q /Y