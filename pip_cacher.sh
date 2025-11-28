#!/usr/bin/env sh

#echo Press any key to continue...
#read -s -n 1

if [ -z $1 ]
then
  echo No arguments specified
  echo "$0 package      - download a package"
  echo "$0 -r reqfile   - download packages listed in the file"
  echo Press any key to continue...
  read -s -n 1
  exit
fi

# --- как называется установщик: pip или pip3 ---
unset pip
which pip > /dev/null 2>&1
if [ $? -eq 0 ]
then
  export pip=pip
else
  which pip3 > /dev/null 2>&1
  if [ $? -eq 0 ]
  then
    export pip=pip3
  fi
fi
if [ -z $pip ]
then
  echo Cannot find pip
  exit
fi


export reqs_file=requirements.txt
if [ "$1" == "-r" ]
then
  # скачать пакеты перечисленные в файле
  export reqs_file=$2
  if [ ! -f $reqs_file ]
  then
    echo Cannot find requirements-file \"$reqs_file\"
    exit
  fi
else
  # скачать один пакет указанный в командной строке
  echo $1 > $reqs_file
fi

unset proxy_opt
if [ ! -z $http_proxy ]
then
  export proxy_opt="--proxy $http_proxy"
else
  if [ ! -z $https_proxy ]
  then
    export proxy_opt="--proxy $https_proxy"
  fi
fi

#export task=$RANDOM
export task="20`date '+%y-%m-%d_%H-%M-%S'`"
echo Using requirement-file: \"$reqs_file\"
if [ ! -z "$proxy_opt" ]
then
  echo Proxy: $proxy_opt
fi
echo Task number: $task
echo ------------ requirements: ------------
cat $reqs_file
echo ---------------------------------------
echo Press any key to continue...
read -s -n 1

export logs_dir=logs
export cache_dir=cache
export downloads_dir=downloads/${task}

mkdir -p $logs_dir
mkdir -p $cache_dir
mkdir -p $downloads_dir

export log_file=${logs_dir}/download__${task}.log
export install_script=${downloads_dir}/install.sh
cp $reqs_file ${downloads_dir}/requirements.txt

$pip download --cache-dir $cache_dir --disable-pip-version-check --no-color --log $log_file -r $reqs_file --dest $downloads_dir $proxy_opt

echo "#!/usr/bin/env sh" > $install_script
echo "" >> $install_script
echo "python -m pip install --no-index --find-links . --root-user-action=ignore *.whl" >> $install_script
chmod 755 $install_script

echo --------------------------------------------------------
echo INFO. Task number: $task
echo INFO. Download completed to $downloads_dir directory
echo INFO. Log-file: $log_file
echo --------------------------------------------------------


echo Press any key to continue...
read -s -n 1
