#!/bin/sh

usage()
{
  echo "pip_cacher.sh [flags] <module>"
  echo "  flag:"
  echo "    -h|--help      print this help"
  echo "    -d|--download  only download without installation"
  echo "    -i|--install   install downloaded module"
  echo "    -b|--both      download and install"
  echo " examples:"
  echo "   pip_cacher.sh pands           download and install module pandas"
  echo "   pip_cacher --download pands   only download module pandas"
}

# +++ Проверка на root-овость +++
if [ ! "$EUID" == "0" ]
then
  echo You are not the ROOT.
  echo Try \"sudo $0\".
  echo May be its need to execute \"usermod -a -G wheel $USER\" to add ability for using sudo for you.
  exit
fi

# +++ Проверка наличия pip - системы управления пакетами python +++
command=pip3
which $command > /dev/null
command_not_found=`echo $?`
if [ ! "$command_not_found" == "0" ]
then
  echo Command \"$command\" not found
  if [ -f /usr/bin/dnf ]
  then
    # rosa, redhat, fedora, centos
    #dnf update # может обновить много других установленных пакетов
    dnf install python3-pip
  elif [ -f /usr/bin/apt ]
  then
    # astra, debian, ubuntu
    apt update && apt install python3-pip
  elif [ -f /usr/bin/zypper ]
  then
    # suse
    zypper install python-pip
  else
    curl https://bootstrap.pypa.io/get-pip.py | python
  fi
  exit
fi

# +++ Разбор параметров +++
if [ "$1" == "" ]
then
  usage
  exit
fi
if [ "$1" == "-h" ] || [ "$1" == "--help" ] || [ "$1" == "-help" ]
then
  usage
  exit
fi
download_flag=0
install_flag=0
module=-
if [ "$1" == "-d" ] || [ "$1" == "--download" ]
then
  download_flag=1
fi
if [ "$1" == "-i" ] || [ "$1" == "--install" ]
then
  install_flag=1
fi
if [ "$1" == "-b" ] || [ "$1" == "--both" ]
then
  download_flag=1
  install_flag=1
fi
if [ "$2" == "" ] && [ ! "$1" == "" ] && [ "$download_flag" == "0" ] && [ "$install_flag" == "0" ]
then
  # указан только один параметр - это имя модуля, скачать и установить модуль
  echo qqqqqq
  download_flag=1
  install_flag=1
  module=$1
fi
if [ "$2" != "" ]
then
  module=$2
fi
if [ "$modile" == "-" ]
then
  echo module not specified
  usage
  exit
fi
echo $download_flag $install_flag $module

modules_root_dir=$PWD/_modules
logs_dir=$modules_root_dir/_logs
cache_dir=$modules_root_dir/_cache
module_dir=$modules_root_dir/$module
save_dir=$PWD

download_cmd="pip3 download --verbose --log $logs_dir/${module}_download.log --cache-dir $cache_dir $module"
install_cmd="python -m pip install --no-index --find-links $module_dir $module"

if [ "$download_flag" == "1" ]
then
  if [ ! -d $modules_root_dir ] ; then mkdir $modules_root_dir ; fi
  if [ ! -d $logs_dir ] ; then mkdir $logs_dir ; fi
  if [ ! -d $cache_dir ] ; then mkdir $cache_dir ; fi
  if [ ! -d $module_dir ] ; then mkdir $module_dir ; fi
  cd $module_dir
  $download_cmd
  cd $save_dir
fi

if [ "$install_flag" == "1" ]
then
  if [ ! -d $module_dir ]
  then
    echo Nothing to install. There is no directory \"$module_dir\".
    exit
  fi
  $install_cmd
fi

cd $save_dir
echo -----------------------------------
ls $module_dir
echo ----------------------------------
echo MODULE: $module
echo DOWNLOAD: $download_cmd
echo INSTALL: $install_cmd
echo ----------------------------------

# WARNING: Running pip as the 'root' user can result in broken permissions and conflicting behaviour with the system package manager. It is recommended to use a virtual environment instead: https://pip.pypa.io/warnings/venv
