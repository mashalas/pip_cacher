echo off
cls

rem set http_proxy=127.0.0.1:1444

if "%1" == "" (
  echo No arguments specified.
  echo %0 package      - download a package
  echo %0 -r reqfile   - download packages listed in the file
  goto quit
)

set reqs_file=requirements.txt
if "%1" == "-r" (
  rem скачать пакеты перечисленные в файле
  set reqs_file=%2
  if not exist %reqs_file% (
    echo Cannot find requirements-file "%reqs_file%"
    goto quit
  )
) else (
  rem скачать один пакет указанный в командной строке
  echo %1 > %reqs_file%
)

set proxy_opt=
if defined http_proxy (
  set proxy_opt= --proxy %http_proxy%
) else (
  if defined https_proxy set proxy_opt= --proxy %https_proxy%
)

set task=%random%
echo Using requirement-file: "%reqs_file%
if defined proxy_opt echo Proxy: %proxy_opt%
echo Task number: %task%
echo ------------ requirements: ------------
type %reqs_file%
echo ---------------------------------------
pause

set logs_dir=logs
set cache_dir=cache
set downloads_dir=downloads\%task%

if not exist %logs_dir% mkdir %logs_dir%
if not exist %cache_dir% mkdir %cache_dir%
if not exist %downloads_dir% mkdir %downloads_dir%

set log_file=%logs_dir%\download__%task%.log
set install_script=%downloads_dir%\install.bat
copy %reqs_file% %downloads_dir%\requirements.txt > nul

pip download --cache-dir %cache_dir% --disable-pip-version-check --no-color --log %log_file% -r %reqs_file% --dest %downloads_dir% %proxy_opt%
rem set download_cmd=pip download --cache-dir %cache_dir% --disable-pip-version-check --no-color --log %log_file% -r %reqs_file% --dest %downloads_dir%
rem if defined http_proxy (
rem   set download_cmd=%download_cmd% --proxy %http_proxy%
rem ) else (
rem   if defined https_proxy set download_cmd=%download_cmd% --proxy %https_proxy%
rem )
rem echo download_cmd: %download_cmd%
rem pause
rem %download_cmd%

echo echo off > %install_script%
echo cls >> %install_script%
echo. >> %install_script%
echo python.exe -m pip install --no-index --find-links . -r requirements.txt >> %install_script%
echo. >> %install_script%
echo pause >> %install_script%

echo --------------------------------------------------------
echo INFO. Task number: %task%
echo INFO. Download completed to %downloads_dir% directory
echo INFO. Log-file: %log_file%
echo --------------------------------------------------------


:quit
pause
