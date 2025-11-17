#!/usr/bin/sh

export {http,https}_proxy=192.168.0.1:3128   # получать пакеты через прокси, если напрямую - закоментировать строку
export DATE="20`date '+%y-%m-%d_%H-%M-%S'`"  # каталог, в котором создать скрипты скачивания/установки и файл requirements.txt
echo DownloadDirectory: $DATE
mkdir $DATE

# --- Создать requirements.txt---
if [ ! -z $1 ] && [ -f $1 ] && [ -r $1 ]
then
  # если передан параметр, то считаем, что передан файл со списком зависимостей
  echo REQUIREMENTS from command-line-argument $1
  cp -p $1 ${DATE}/requirements.txt
elif [ -f ./requirements.txt ] && [ -r ./requirements.txt ]
then
  # если в текущем каталоге есть файл requirements.txt, то используем его в качестве файла со списком зависимостей
  echo REQUIREMENTS from ./requirements.txt
  cp -p ./requirements.txt ${DATE}/requirements.txt
else
  # если файл зависимостей не передан в параметрах командной строки и не существует в текущем каталоге, создаём новый со перечисленными ниже зависимостями
  echo REQUIREMENTS from script. Can be received by command \"pip freeze\"
  cat << EOF > ${DATE}/requirements.txt
blinker==1.9.0
click==8.1.8
colorama==0.4.6
Flask==3.1.1
importlib_metadata==8.7.0
itsdangerous==2.2.0
Jinja2==3.1.6
MarkupSafe==3.0.2
pika==1.3.2
Werkzeug==3.1.3
zipp==3.23.0
EOF
fi

#export sh_path=`which sh`
#echo sh_path: $sh_path
#exit

# --- Создать скрипт скачивания ---
echo '#!/usr/bin/env sh' > ${DATE}/download.sh
echo '' >> ${DATE}/download.sh
unset proxy_opt
if [ ! -z $http_proxy ]
then
  export proxy_opt="--proxy $http_proxy"
elif [ ! -z $https_proxy ]
then
    export proxy_opt="--proxy $https_proxy"
fi
echo pip3 download --no-cache-dir --disable-pip-version-check $proxy_opt --log download.log -r requirements.txt >> ${DATE}/download.sh
chmod 755 ${DATE}/download.sh

# --- Создать скрипт установки ---
echo '#!/usr/bin/env sh' > ${DATE}/install.sh
echo '' >> ${DATE}/install.sh
echo 'python -m pip install --no-index --find-links . --root-user-action=ignore *.whl' >> ${DATE}/install.sh
chmod 755 ${DATE}/install.sh

# --- Создать временный контейнер, который скачает пакеты (в каталог с текущей датой) ---
docker run --rm -it \
  -v ${PWD}/${DATE}:/download \
  --workdir /download \
  python:3.12.3-bookworm \
  ./download.sh \

