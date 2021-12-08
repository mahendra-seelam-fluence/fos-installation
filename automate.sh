###Read Env file

#Replace das url and auth token in Puma Service
sed -i -e 's+REPLACE_DAS_URL+$DAS_URL+g' -e 's+REPLACE_DAS_AUTH_TOKEN+$DAS_AUTH_TOKEN+g' puma.service

#Replace das url and auth token in sidekiq service
sed -i -e 's+REPLACE_DAS_URL+$DAS_URL+g' -e 's+REPLACE_DAS_AUTH_TOKEN+$DAS_AUTH_TOKEN+g' sidekiq.service

#Replace site host url in nginx conf
sed -i -e 's+REPLACE_SITE_HOST_URL+$SITE_HOST_URL+g' nginx.conf

#Replace sidekiq service
sed -i -e 's+REPLACE_SITE_HOST_URL+$SITE_HOST_URL+g' fos-frontend.service