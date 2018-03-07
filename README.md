# NGINX + PHP

Ubuntu based Nginx with PHP-FPM image. 

PHP version 5.6

Running:

```
docker run -d --restart=unless-stopped -v ./www:/var/www:ro -v nginx.conf:/etc/nginx/sites-available/default:ro huksley/nginx-php 
```
