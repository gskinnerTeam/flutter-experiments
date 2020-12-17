CALL flutter build web
CALL del .\docs /F /Q
CALL mkdir .\docs
CALL copy .\build\web .\docs