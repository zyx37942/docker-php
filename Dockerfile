FROM php:7.4.26-fpm-alpine
RUN cp $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini \
    && sed -i '/;date.timezone =/a date.timezone = Asia/Shanghai' $PHP_INI_DIR/php.ini \
    && sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
    && apk update && apk add --no-cache \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libzip-dev \
        libstdc++ \
        git \
        openssh-client \
        unzip \
    && apk add --no-cache --virtual build-dependencies \
        autoconf \
        gcc \
        g++ \
        make \
        openssl-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) bcmath gd pcntl pdo_mysql mysqli zip \
    && pecl install redis \
    && docker-php-ext-enable redis opcache \
    && sed -i '/\[opcache\]/a opcache.enable=1\nopcache.enable_cli=1\nopcache.memory_consumption=128\nopcache.interned_strings_buffer=8\nopcache.max_accelerated_files=10000\nopcache.revalidate_freq=10\nopcache.blacklist_filename=/workbench/conf.d/opcache-blacklist' $PHP_INI_DIR/php.ini \
    && apk del build-dependencies \
    && pecl clear-cache \
    && rm -rf /tmp/pear/download/* \
    && curl -O https://getcomposer.org/composer-stable.phar \
    && mv composer-stable.phar /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer \
    && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/
