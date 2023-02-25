#!/usr/bin/env sh

export env_dir=./env
#export modules=(six)
export modules=(six numpy seaborn pandas matplotlib)

if [ ! -d $env_dir ]
then
  mkdir $env_dir
fi

export activated=0
if [ ! -f ${env_dir}/pyvenv.cfg ]
then
  echo --- Creating environment directory \[$env_dir\] ---
  python -m venv $env_dir
  source ${env_dir}/bin/activate
  export activated=1
  # upgrade python installer in virtual environment:
  python -m pip install --upgrade pip
fi
export download_dir=${env_dir}/.download
export cache_dir=${env_dir}/.cache
export logs_dir=${env_dir}/.logs
mkdir -p $download_dir
mkdir -p $cache_dir
mkdir -p $logs_dir

if [ $activated -eq 0 ]
then
  echo --- Activating environment from \[$env_dir\] ---
  source ${env_dir}/bin/activate
fi

# Install modules (if not installed)
for m in ${modules[@]}
do
  export complete_file=${logs_dir}/complete_${m}.log
  if [ ! -f $complete_file ]
  then
    echo --- Installing module \[$m\] ---
    export module_dir=${download_dir}/${m}
    mkdir -p $module_dir

    # Download module
    pip download --cache-dir $cache_dir --no-color --log ${logs_dir}/download_${m}.log --dest $module_dir $m

    # Create script for installation module from its personal directory
    export install_script=${module_dir}/install.sh
    export env_path=`which env`
    echo \#\!$env_path sh > $install_script
    echo -e "" >> $install_script
    echo pip install --no-index --find-links . $m >> $install_script
    chmod 755 $install_script
    
    # Install downloaded module
    pip install --no-index --find-links $module_dir --log ${logs_dir}/install_${m}.log $m
    #echo RetCode: $?
    if [ $? -eq 0 ]
    then
      # Module installed successfullt
      date >> $complete_file
    fi
  fi
done

pip list
which python
