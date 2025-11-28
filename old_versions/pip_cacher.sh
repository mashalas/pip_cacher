#!/bin/sh

CACHER_ROOT_DIR=$PWD/_cacher
#CACHER_ROOT_DIR=/tmp/_cacher.${USER}

usage()
{
  echo "pip_cacher.sh [flags] <module>"
  echo "  flag:"
  echo "    -h|--help             print this help"
  echo "    -d|--download         only download without installation"
  echo "    -i|--install          install downloaded module"
  echo "    -p|--proxy <proxy>    Specify a proxy in the form"
  echo "                          [user:passwd@]proxy.server:port"
  echo "    -v|--verbose          verbose mode"
  echo " examples:"
  echo "   pip_cacher.sh pands           download and install module pandas"
  echo "   pip_cacher --download -p 10.20.30.34:3128 pands   only download module pandas through proxy"
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
download_flag=0
install_flag=0
verbose_flag=0
proxy=""
module=""
while :; do
  case "${1-}" in
  -h | --help | -help) usage ;;
  -d | --download) download_flag=1 ;; # do download
  -i | --install) install_flag=1 ;; # do install
  -p | --proxy) # example named parameter
    proxy="${2-}"
    shift
     ;;
  -v | --verbose) verbose_flag=1 ;; # verbose mode
  -?*)
    echo "ERROR: unknown option: $1"
    exit 1
    ;;
  *) break ;;
  esac
  shift
done

# поместить в args[] оставшиеся параметры, которые указаны без минуса перед именем параметра
args=("$@")
#echo "- arguments: ${args[*]-}"

module=${args[0]-}

# если не указано ни скачать, ни установить, то подразумеваем оба действия
if [ "$download_flag" == "0" ] && [ "$install_flag" == "0" ]
then
  download_flag=1
  install_flag=1
fi
#echo $download_flag $install_flag [$proxy] [$module]

#if [ "$modile" == "-" ]
if [ -z $module ]
then
  # не указан модуль
  echo ERROR: module not specified!
  usage
  exit
fi
echo Parsed parameters: [download_flag=$download_flag] [install_flag=$install_flag] [verbose_flag=$verbose_flag] [proxy=$proxy] [module=$module]

#modules_root_dir=$CACHER_ROOT_DIR/_modules
logs_dir=$CACHER_ROOT_DIR/_logs
cache_dir=$CACHER_ROOT_DIR/_cache
module_dir=$CACHER_ROOT_DIR/$module
save_dir=$PWD

download_cmd="pip3 download --log $logs_dir/${module}_download.log --cache-dir $cache_dir"
if [ $verbose_flag -eq 1 ]; then download_cmd="$download_cmd --verbose"; fi
if [ ! -z $proxy ]; then download_cmd="${download_cmd} --proxy $proxy"; fi
#if [ $verbose_flag -eq 1 ]
#then
#  download_cmd="$download_cmd --verbose"
#fi
#if [ ! -z $proxy ]
#then
#  download_cmd="${download_cmd} --proxy $proxy"
#fi
download_cmd="${download_cmd} $module"
install_cmd="python -m pip install --no-index --find-links $module_dir $module"

if [ $download_flag -eq 1 ]
then
  if [ ! -d $CACHER_ROOT_DIR ] ; then mkdir $CACHER_ROOT_DIR ; fi
  if [ ! -d $logs_dir ] ; then mkdir $logs_dir ; fi
  if [ ! -d $cache_dir ] ; then mkdir $cache_dir ; fi
  if [ ! -d $module_dir ] ; then mkdir $module_dir ; fi
  cd $module_dir
  $download_cmd
  cd $save_dir
fi

if [ $install_flag -eq 1 ]
then
  if [ ! -d $module_dir ]
  then
    echo Nothing to install. There is no directory \"$module_dir\".
    exit
  fi
  $install_cmd
fi

echo -------- $module_dir ---------------------------
ls $module_dir
echo ----------------------------------
echo MODULE: $module
echo DOWNLOAD: $download_cmd
echo INSTALL: $install_cmd
echo ----------------------------------

# WARNING: Running pip as the 'root' user can result in broken permissions and conflicting behaviour with the system package manager. It is recommended to use a virtual environment instead: https://pip.pypa.io/warnings/venv
#DOWNLOAD:	pip3 download --verbose --log /tmp/_cacher/_logs/six_download.log --cache-dir /tmp/_cacher/_cache --proxy 180.210.189.65:8080 six
#INSTALL:	python -m pip install --no-index --find-links /tmp/_cacher/six six
#UPGRADE_PIP:	python -m pip install --upgrade pip
