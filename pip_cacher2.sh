#!/usr/bin/env sh

# Если нужно скачивать через прокси-сервер - определить переменные http_proxy или https_proxy
#   пример задания прокси-сервера:  export {http,https}_proxy=192.168.0.1:3128

# Если нужно воссоздать состав пакетов, как в существующей системе, получить список пакетов можно командой:
#   pip freeze > requirements.txt

export cache_dir=${PWD}/cache
if [ ! -d $cache_dir ]
then
  mkdir -p $cache_dir
fi

export logs_dir=${PWD}/logs
if [ ! -d $logs_dir ]
then
  mkdir -p $logs_dir
fi

export module=six   # модуль по умолчанию
#export module=six==1.15.0 # модуль по умолчанию с указанием номера версии модуля
if [ ! -z $1 ]
then
  # имя модуля передано из командной строки
  # если надо скачать определённую версию: six==1.16.0
  export module=$1
fi
if [ -f $module ]
then
  # указано не имя модуля, а имя файла, считаем, что это файл requirements.txt
  export dest_dir=${PWD}/downloads
else
  export dest_dir=${PWD}/downloads/${module}
fi

if [ ! -d $dest_dir ]
then
  mkdir -p $dest_dir
fi

export download_cmd="pip3 download"
if [ ! -z $http_proxy ]
then
  export download_cmd="$download_cmd --proxy $http_proxy"
else
  if [ ! -z $https_proxy ]
  then
    export download_cmd="$download_cmd --proxy $https_proxy"
  fi
fi
export download_cmd="$download_cmd --cache-dir $cache_dir --disable-pip-version-check --log ${logs_dir}/${module}.log --dest $dest_dir"
if [ -f $module ]
then
  # считаем, что вместо имени модуля указано имя файла со списком зависимостей (requirements.txt)
  export download_cmd="$download_cmd -r $module"
else
  export download_cmd="$download_cmd $module"
fi

echo DOWNLOAD_CMD: $download_cmd
$download_cmd
  
# --- install_script.sh ---
export install_script=${dest_dir}/install.sh
echo \#\!/usr/bin/sh > $install_script
echo "" >> $install_script
#export install_cmd="python -m pip install --no-index --find-links . $module"
export install_cmd="python -m pip install --no-index --find-links ."
if [ -f $module ]
then
  # вместо имени модуля - файл со списком модулей
  export install_cmd="$install_cmd *.whl"
else
  export install_cmd="$install_cmd $module"
fi
echo INSTALL_CMD: $install_cmd  to $install_script
echo $install_cmd >> $install_script
chmod 755 $install_script
