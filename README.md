# fos-installation


## Preparation:

### FOS Installation Instructions

**Make sure you have access to the correct git archive for hmi.**
**Make sure that both port 443 and port 8443 are open and can be accessed.**
**Verify that the /etc/nginx.conf file contains references to “listen 8443”.**
**Obtain copies of fos_ds.csv and fos_dp.csv from the Dev team.**
**Create a DAS token from the DAS server.**

# Backend Installation

## Login to Server:
- Open Terminal and SSH to the server

```
ssh username@host_address
```
- Switch to FOSUI User

```
sudo su - fosui
```

## Install RVM (https://rvm.io/rvm/install):

```
gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
\curl -sSL https://get.rvm.i- | bash -s stable
rvm install ruby-3.0.1
```

## GIT Setup:

```
git clone https://github.com/FluenceEnergy/hmi.git
cd /home/fosui/hmi)
bundle install
```

## Setup Project Environment:
- Add new environment in ‘config/database.yml’
- Generate Secret Key
- rake secret => returns key
- Copy the key and paste into ‘config/secrets.yml’

```
sandbox:
secret_key_base: <add_key_here>
 ```

- Create a new environment file under ‘config/environments’


# Adding Services:

## Sidekiq Service:

- Go to Path /lib/systemd/system 
- Once the file `sidekiq.service` is created, run the following command
```
sudo vim sidekiq.service
```

- sudo chmod 777 sidekiq.service # (change file permissions) 
- sudo systemctl daemon-reload
- sudo systemctl enable sidekiq.service
- sudo service sidekiq status/start/stop

## Puma Service

- Go to Path /lib/systemd/system 
- Once the file `puma.service` is created, run the following command
```
sudo vim puma.service
```
- sudo chmod 777 puma.service # (Change file permissions) 
- sudo systemctl daemon-reload
- sudo systemctl enable puma.service
- chmod -R 777 /home/fosui/hmi/tmp/pids/
- chmod -R 777 /home/fosui/hmi/log/ 
- sudo service puma status/start/stop

## Frontend Service

cd /tmp
- wget https://nodejs.org/download/release/v12.12.0/node-v12.12.0-linux-x64.tar.gz
- tar -xvf node-v12.12.0-linux-x64.tar.gz --directory /usr/local --strip-components 1
- curl --silent --location https://dl.yarnpkg.com/rpm/yarn.rep- | sudo tee
/etc/yum.repos.d/yarn.repo
- sudo dnf install yarn
- Switch to FOSUI User sudo su - fosui
Pull the UI code
git clone https://github.com/FluenceEnergy/fos_interface.git
cd to the project path (/home/fosui/fos_interface) Run below commands
yarn
yarn build

- FOS Frontend Service
- cd to `/etc/init.d `folder
- create ‘fos-fronend’ file

```bash
cd ‘/home/fosui/fos_interface’
mkdir logs
touch fos.log
chown –R 777 logs/
sudo chmod 777 fos-fronend
sudo systemctl daemon-reload
sudo systemctl fos-fronend
sudo service fos-fronend status/start/stop
```

## NGINX Configuration
cd to `/etc/nginx/`
Update ‘nginx.conf ‘file below configuration
Test nginx.conf before restarting ▪ nginx –t
    `sudo service nginx restart/start/stop/status`

## Setup .bash_profile  and .bashrc for fosui user



##  Application Setup
`sudo su - fosui`
- cd to the project path `/home/fosui/hmi`
- Restore test server database and run below commands,
 ```
 RAILS_ENV=sandbox rake db:create
 RAILS_ENV=sandbox rake db:migrate
 RAILS_ENV=sandbox rake tmp:cache:clear
 ```
- Add site configuration from excel sheet,
 ```
 RAILS_ENV=sandbox rake fos_configuration:parse_file[<file_path>]
 ```
- Make sure to copy the data_sources , data_points files to server and run the below commands
 ```
 RAILS_ENV=sandbox rake das_data:parse_csvs['/home/fosui/hmi/data_sources.csv','/home/fosui/h mi/data_points.csv']
 RAILS_ENV=sandbox rake das_data:create_links
 ```
- Start puma server
    `sudo service puma start/stop/status`
Start sidekiq server
    `sudo service sidekiq start/stop/status`
- Start hmi shell script from project path 
    `./hmi_startup.sh start/stop/status sandbox`
- Start fos-frontend script
    `sudo service fos-frontend start/stop/status`

