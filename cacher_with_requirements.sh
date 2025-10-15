#!/bin/sh

export cache_dir=./cache
export downloads_dir=./downloads

if [ ! -d $cache_dir ]
then
  mkdir -p $cache_dir
fi

if [ ! -d $downloads_dir ]
then
  mkdir -p $downloads_dir
fi

# ------------ список пакетов с их версиями, которые сохранить в файл requirements.txt ---------------
cat > requirements.txt << EOF
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
# -----------------------------------------------------------------------------------------------------

#When restricting platform and interpreter constraints using --python-version, --platform, --abi, or --implementation, 
#either --no-deps must be set, or --only-binary=:all: must be set and --no-binary must not be set (or must be set to :none:).

pip3 download --dest $downloads_dir --python-version 312 -r requirements.txt --only-binary=:all:
