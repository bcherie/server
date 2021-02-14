FROM  debian:buster
RUN apt-get update -y && apt-get -y install nginx
RUN apt-get update -y && apt-get -y install mariadb-server
RUN apt-get update -y && apt-get install -y php7.3 php-mysql php-fpm php-pdo php-gd php-cli php-mbstring php-xml
RUN apt-get -y install openssl

#nginx
COPY ./srcs/nginx.conf /etc/nginx/sites-available
RUN ln -s /etc/nginx/sites-available/nginx.conf /etc/nginx/sites-enabled/nginx.conf

#php
ADD		https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-all-languages.tar.gz phpmyadmin.tar.gz
RUN 	tar -xf phpmyadmin.tar.gz && mv phpMyAdmin-5.0.2-all-languages phpmyadmin && mv phpmyadmin /var/www/html/
COPY 	./srcs/config.inc.php /var/www/html/phpmyadmin

#wordpress
ADD 	https://ru.wordpress.org/latest-ru_RU.tar.gz wordpress.tar.gz
RUN 	tar -xf wordpress.tar.gz && mv wordpress /var/www/html/ && rm wordpress.tar.gz
COPY 	./srcs/wp-config.php /var/www/html/wordpress
RUN		chown -R www-data /var/www/html/*

#generation key and cert:
RUN openssl req -newkey rsa:2048 -nodes -x509 -days 365 \
	-subj "/C=RU/ST=Moscow/L=Moscow/O=Bcherie/CN=localhost" \
	-keyout etc/ssl/key.key  \
	-out etc/ssl/cert.cert

COPY 	./srcs/start.sh ./
COPY 	./srcs/autoindex.sh ./

ENTRYPOINT bash start.sh