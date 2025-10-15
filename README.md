# pip_cacher
Скачивание python-модулей для последующей offline-установки  

./pip_cacher.sh --download six		- скачать, но не устанавливать модуль six  
./pip_cacher.sh --download size==1.16.0 - скачать определённую версию (1.16.0) пакета  
sudo ./pip_cacher.sh --install numpy		- установить ранее скаченный модуль numpy  
sudo ./pip_cacher.sh -d -i --proxy 10.20.30.40:3128	both pitz		- скачать через прокси и установить модуль pits  
sudo ./pip_cacher.sh numpy			- скачать и установить модуль numpy  


Примеры команд на скачивание и установку:  
DOWNLOAD: pip3 download --verbose --log /tmp/_modules/_modules/_logs/requests_download.log --cache-dir /tmp/_modules/_modules/_cache requests  
INSTALL: python -m pip install --no-index --find-links /tmp/_modules/_modules/requests requests  
