FOS Installation Instructions Preparation: 


• Make sure you have access to the correct git archive for hmi. 
• Make sure that both port 443 and port 8443 are open and can be accessed. 
• Verify that the /etc/nginx.conf file contains references to "listen 8443". 
• Obtain copies of fos_ds.csv and fos_dp.csv from the Dev team. 
• Create a DAS token from the DAS server. Backend Installation Login to Server:\
• Open Terminal and SSH to the server \$ ssh username\@host_address 

• Switch to FOSUI User sudo su - fosui Install RVM
(https://rvm.io/rvm/install): • gpg --keyserver
hkp://pool.sks-keyservers.net --recv-keys\
409B6B1796C275462A1703113804BB82D39DC0E3\
7D2BAF1CF37B13E2069D6956105BD0E739499BDB • `\curl `{=tex}-sSL
https://get.rvm.io \| bash -s stable • rvm install ruby-3.0.1 GIT
Setup:\
• git clone https://github.com/FluenceEnergy/hmi.git 
• cd to the project
path (/home/fosui/hmi) • bundle install Setup Project Environment: • Add
new environment in 'config/database.yml' • Generate Secret Key o rake
secret => returns key o Copy the key and paste into 'config/secrets.yml'
sandbox: secret_key_base: `<add_key_here>`{=html} • Create a new
environment file under 'config/environments' Adding Services: • SideKiq
Service o Go to Path /lib/systemd/system o sudo vim sidekiq.service o
Add below script #!/usr/bin/env \[Unit\] Description=sidekiq
After=syslog.target network.target \[Service\] Type=notify
WatchdogSec=10
Environment="DAS_URL=https://advancion-dv-das.fluenceenergy.com:9443"
Environment="DAS_AUTH_TOKEN=eyJhbGciOiJFUzUxMiJ9.eyJzdWIiOiJlZmZvbmUuYnBtZ
W5kZSIsImV4cCI6MTkwNTU3Mzc4NywiaWQiOjMzLCJ2IjoyLCJ0eXAiOiJhdXRoIn0.ADYbJao
cCNMfiEhEkwzD67XYOcMzEIrhb8UvXXzTQJy4l19aFSOaozpz2I_9dRjK9fKW0rN39EFAvG40
NAhZNCNcAFP3C1Q3c
ZxM55g4qg_ftirMOkisy7mw_ePa3FMqRypAVrZqJQ6YGr8u03RSL9si0XvrzxVIbYO5g5MxrI
Dmrp7" WorkingDirectory=/home/fosui/hmi
ExecStart=/home/fosui/.rvm/gems/ruby-3.0.1\@hmi/wrappers/bundle exec
sidekiq -e sandbox -C config/sidekiq.yml\
User=fosui Group=users UMask=0002 \# if we crash, restart RestartSec=1
Restart=on-failure TimeoutSec=10 \# output goes to /var/log/syslog
(Ubuntu) or /var/log/messages (CentOS) #StandardOutput=syslog
#StandardError=syslog \# This will default to "bundler" if we don't
specify it SyslogIdentifier=sidekiq \[Install\]
WantedBy=multi-user.target o sudo chmod 777 sidekiq.service \# (change
file permissions) o sudo systemctl daemon-reload o sudo systemctl enable
sidekiq.service o sudo service sidekiq status/start/stop • Puma Service
o Go to Path /lib/systemd/system o sudo vim puma.service o Add below
script \[Unit\] Description=Puma HTTP Server After=network.target
Type=simple \# If your Puma process locks up, systemd's watchdog will
restart it within seconds. \# WatchdogSec=10 \# Preferably configure a
non-privileged user User=fosui Group=users
Environment="DAS_URL=https://advancion-dv-das.fluenceenergy.com:9443"
Environment="DAS_AUTH_TOKEN=eyJhbGciOiJFUzUxMiJ9.eyJzdWIiOiJlZmZvbmUuYnBt
ZW5kZSIsImV4cCI6MTkwNTU3Mzc4NywiaWQiOjMzLCJ2IjoyLCJ0eXAiOiJhdXRoIn0.ADYbJ
aocCNMfiEhEkwzD67XYOcMzEIrhb8UvXXzTQJy4l19aFSOaozpz2I_9dRjK9fKW0rN39EFAv
G40NAhZNCNcAFP3C1Q3c
ZxM55g4qg_ftirMOkisy7mw_ePa3FMqRypAVrZqJQ6YGr8u03RSL9si0XvrzxVIbYO5g5MxrI
Dmrp7" \# The path to the your application code root directory. \# Also
replace the "`<YOUR_APP_PATH>`{=html}" place holders below with this
path. \# Example /home/username/myapp WorkingDirectory=/home/fosui/hmi
ExecStart=/home/fosui/.rvm/gems/ruby-3.0.1\@hmi/wrappers/puma -p 3001 -e
sandbox /home/fosui/hmi/config.ru Restart=always \[Install\]
WantedBy=multi-user.target o sudo chmod 777 puma.service \# (Change file
permissions) o sudo systemctl daemon-reload o sudo systemctl enable
puma.service o chmod -R 777 /home/fosui/hmi/tmp/pids/ o chmod -R 777
/home/fosui/hmi/log/ o sudo service puma status/start/stop Frontend
Installation • cd /tmp • wget
https://nodejs.org/download/release/v12.12.0/node-v12.12.0-linux-x64.tar.gz
• tar -xvf node-v12.12.0-linux-x64.tar.gz --directory /usr/local
--strip-components 1 • curl --silent --location
https://dl.yarnpkg.com/rpm/yarn.repo \| sudo tee
/etc/yum.repos.d/yarn.repo • sudo dnf install yarn • Switch to FOSUI
User sudo su - fosui

Pull the UI code git clone
https://github.com/FluenceEnergy/fos_interface.git

cd to the project path (/home/fosui/fos_interface)

Run below commands yarn yarn build • FOS Frontend Service o cd to
/etc/init.d folder o create 'fos-fronend' file o update file with below
script #!/bin/sh ##\# BEGIN INIT INFO \# Provides: fos-frontend \#
Required-Start: \$remote_fs \$all \# Required-Stop: \# X-Start-Before:
\# X-Stop-After: \# Default-Start: 2 3 4 5 \# Default-Stop: \#
Short-Description: Fluence Operating System Frontend \# Description:
Fluence Operating System Frontend ##\# END INIT INFO
ADVHMIHOME=/home/fosui case "\$1" in start) chown -R fosui:users
/home/fosui su - fosui -c "(cd \$ADVHMIHOME/fos_interface/; rm -rf
build; yarn; CABLE_SERVER=wss://advancion-dv-fos.fluenceenergy.com/cable
API_ENDPOINT=https://advancion-dv-fos.fluenceenergy.com/api/v1
NODE_ENV=staging yarn build \> logs/fos.log 2>&1 &)" ;; stop) ;;
restart) \$0 stop sleep 15
$0 start  sleep 5  /usr/sbin/service nginx restart  ;;  status)  echo  /usr/sbin/service nginx status  ;;  *)  echo "Usage: /etc/init.d/fos-frontend {start|stop|restart|status}" ;; esac o cd to ‘/home/fosui/fos_interface’ o mkdir logs o touch fos.log o chown –R 777 logs/ o sudo chmod 777 fos-fronend o sudo systemctl daemon-reload o sudo systemctl fos-fronend o sudo service fos-fronend status/start/stop • NGINX Configuration o cd to ‘/etc/nginx/’ o Update ‘nginx.conf ‘file below configuration # For more information on configuration, see: # * Official English Documentation: http://nginx.org/en/docs/ # * Official Russian Documentation: http://nginx.org/ru/docs/ user fosui users; worker_processes 4; pid /var/run/nginx.pid; error_log /var/log/nginx/error.log; events {  use epoll;  worker_connections 2048;  multi_accept on; } # http://www.slashroot.in/nginx-web-server-performance-tuning-how-to-do-it http {  log_format main '$remote_addr -
$remote_user [$time_local\] "$request" ' '$status
$body_bytes_sent "$http_referer" '
'"$http_user_agent" "$http_x\_forwarded_for"'; include
/etc/nginx/mime.types; default_type application/octet-stream;
keepalive_timeout 2000; keepalive_requests 1000; sendfile on; charset
utf-8; tcp_nopush on; gzip on; gzip_min_length 256; gzip_comp_level 3;
gzip_types text/plain text/css application/json application/x-javascript
text/xml application/xml application/xml+rss text/javascript;
server_tokens off; include /etc/nginx/conf.d/\*.conf; proxy_cache_path
/tmp/nginx levels=1:2 keys_zone=veye_zone:10m inactive=30d;
proxy_cache_key "$scheme$request_method$host$request_uri";
#proxy_cache_key "$host$request_uri\|\$request_body"; add_header
X-Frame-Options SAMEORIGIN; proxy_headers_hash_max_size 512;
proxy_headers_hash_bucket_size 128; upstream hmi { server 0.0.0.0:3001;
} upstream hmi2 { server 0.0.0.0:3002; } server { listen 8443; \#
proxy_redirect off; ssl_certificate
/usr/local/etc/dehydrated/certs/advancion-dv
fos.fluenceenergy.com/fullchain.pem; ssl_certificate_key
/usr/local/etc/dehydrated/certs/advancion-dv
fos.fluenceenergy.com/privkey.pem; ssl on; server_name
advancion-dv-fos.fluenceenergy.com:8443 www.advancion-dv
fos.fluenceenergy.com:8443; proxy_buffers 8 1024k; proxy_buffer_size
1024k; root /home/fosui/fos_interface/build; index index.html; location
/api { proxy_set_header X-Forwarded-Proto \$scheme; proxy_set_header
X-Forwarded-For \$proxy_add_x\_forwarded_for; proxy_set_header Host
\$http_host; proxy_pass http://hmi; proxy_set_header Upgrade
\$http_upgrade; proxy_set_header Connection "upgrade"; }\
location / { proxy_set_header X-Forwarded-Proto \$scheme;
proxy_set_header X-Forwarded-For \$proxy_add_x\_forwarded_for;
proxy_set_header X-Forwarded-For \$remote_addr; \# proxy_set_header Host
\$http_host; \# proxy_pass http://hmi2; \# proxy_http_version 1.1;
proxy_set_header Upgrade
$http_upgrade;  proxy_set_header Connection "upgrade";  }  }  server  {  listen 80;  listen [::]:80;  server_name advancion-dv-fos.fluenceenergy.com www.advancion-dv fos.fluenceenergy.com;  return 301 https://advancion-dv-fos.fluenceenergy.com$request_uri;
} server { listen 443; \# proxy_redirect off; \# ssl_certificate
/usr/local/certs/advancion-dv-hmi_fluenceenergy_com.crt; \#
ssl_certificate_key
/usr/local/certs/advancion-dv-hmi_fluenceenergy_com.key; ssl_certificate
/usr/local/etc/dehydrated/certs/advancion-dv
fos.fluenceenergy.com/fullchain.pem; ssl_certificate_key
/usr/local/etc/dehydrated/certs/advancion-dv
fos.fluenceenergy.com/privkey.pem; ssl on; server_name
advancion-dv-fos.fluenceenergy.com www.advancion-dv
fos.fluenceenergy.com; proxy_buffers 8 1024k; proxy_buffer_size 1024k;
if ($request_method !~ ^(GET|HEAD|PUT|POST|DELETE|OPTIONS)$ ) { return
444; } location /assets/ { proxy_redirect off; proxy_pass_header Cookie;
proxy_ignore_headers Set-Cookie; proxy_hide_header Set-Cookie;
proxy_cache veye_zone; proxy_cache_valid 200 302 120m; add_header
X-Cache-Status \$upstream_cache_status; root /home/fosui/hmi/public; }
location /cable { proxy_pass http://hmi; proxy_redirect off;
proxy_http_version 1.1; proxy_set_header Upgrade \$http_upgrade;
proxy_set_header Connection Upgrade; proxy_set_header X-Forwarded-Proto
\$scheme; proxy_set_header Host \$http_host; proxy_set_header
X-Forwarded-For \$proxy_add_x\_forwarded_for; proxy_read_timeout 86400;
} location / { proxy_set_header X-Forwarded-Proto \$scheme;
proxy_set_header X-Forwarded-For \$proxy_add_x\_forwarded_for; \#
proxy_set_header X-Forwarded-For \$remote_addr; proxy_set_header Host
\$http_host; proxy_pass http://hmi; \# proxy_http_version 1.1;
proxy_set_header Upgrade \$http_upgrade; proxy_set_header Connection
"upgrade"; } error_page 404 /404.html; error_page 502 503 504
/maintenance.html; location = /maintenance.html { root
/home/fosui/hmi/public/; } } client_max_body_size 3M; } o Test
nginx.conf before restarting ▪ nginx --t o Restart nginx sudo service
nginx restart/start/stop/status • Setup .bash_profile for fosui user o
Add the following to '.bash_profile' for fosui user export
RAILS_ENV='sandbox' export
API_ENDPOINT='https://advancion-dv-fos.fluenceenergy.com/api/v1' export
CABLE_SERVER='wss://advancion-dv-fos.fluenceenergy.com/cable' export
NAME_ARRAY='DV Array' o Add the following to '.bashrc' for fosui user.
export DAS_URL='https://advancion-dv-das.fluenceenergy.com:9443' export\
DAS_AUTH_TOKEN='eyJhbGciOiJFUzUxMiJ9.eyJzdWIiOiJlZmZvbmUuYnBtZW5kZSIsImV4
cCI6MTkwNTU3Mzc4NywiaWQiOjMzLCJ2IjoyLCJ0eXAiOiJhdXRoIn0.ADYbJaocCNMfiEhEk
wzD67XYOcMzEIrhb8UvXXzTQJy4l19aFSOaozpz2I_9dRjK9fKW0rN39EFAvG40NAhZNCNc
AFP3C1Q3c-
ZxM55g4qg_ftirMOkisy7mw_ePa3FMqRypAVrZqJQ6YGr8u03RSL9si0XvrzxVIbYO5g5MxrI
Dmrp7' • Application Setup o sudo su - fosui o cd to the project path
(/home/fosui/hmi) o Restore test server database and run below commands,
▪ RAILS_ENV=sandbox rake db:create ▪ RAILS_ENV=sandbox rake db:migrate ▪
RAILS_ENV=sandbox rake tmp:cache:clear o Add site configuration from
excel sheet, ▪ RAILS_ENV=sandbox rake
fos_configuration:parse_file\[`<file_path>`{=html}\] o Make sure to copy
the data_sources , data_points files to server and run the below
commands ▪ RAILS_ENV=sandbox rake\
das_data:parse_csvs\['/home/fosui/hmi/data_sources.csv','/home/fosui/h
mi/data_points.csv'\] ▪ RAILS_ENV=sandbox rake das_data:create_links o
Start puma server sudo service puma start/stop/status o Start sidekiq
server sudo service sidekiq start/stop/status o Start hmi shell script
from project path ./hmi_startup.sh start/stop/status sandbox o Start
fos-frontend script sudo service fos-frontend start/stop/status
