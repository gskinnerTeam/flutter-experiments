CALL flutter build web
CALL del .\docs /F /Q
CALL mkdir .\docs
CALL copy .\build\web .\docs

CALL git add -A
CALL git commit -m "Web Deploy"
CALL git push -u origin master