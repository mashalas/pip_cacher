# pip_cacher
Скачивание python-модулей для последующей offline-установки  

sudo ./pip_cacher.sh --download six		- скачать, но не устанавливать модуль six  
sudo ./pip_cacher.sh --install numpy		- установить ранее скаченный модуль numpy  
sudo ./pip_cacher.sh --both pitz		- скачать и установить модуль pits  
sudo ./pip_cacher.sh numpy			- скачать и установить модуль numpy  

Примеры команд на скачивание и установку:  
DOWNLOAD: pip3 download --verbose --log /tmp/_modules/_modules/_logs/requests_download.log --cache-dir /tmp/_modules/_modules/_cache requests  
INSTALL: python -m pip install --no-index --find-links /tmp/_modules/_modules/requests requests  
