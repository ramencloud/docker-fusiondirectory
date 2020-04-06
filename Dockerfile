FROM nginx:1.16.1
LABEL maintainer="mps299792458@gmail.com" \
      version="0.4.0"

ENV FUSIONDIRECTORY_VERSION=1.3
ENV FUSIONDIRECTORY_PKG_RELEASE=1
ENV PHP_VERSION=7.3

RUN rm -f /etc/apt/sources.list.d/* \
 && apt-get update \
 && apt-get install -y gnupg ca-certificates \
 && gpg --keyserver keys.gnupg.net --recv-key 0xD744D55EACDA69FF \
 && gpg --export -a "FusionDirectory Project Signing Key <contact@fusiondirectory.org>" > FD-archive-key \
 && apt-key add FD-archive-key \
 && (echo "deb https://repos.fusiondirectory.org/fusiondirectory-releases/fusiondirectory-${FUSIONDIRECTORY_VERSION}/debian-stretch/ stretch main") \
    > /etc/apt/sources.list.d/fusiondirectory.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    argonaut-server \
    fusiondirectory=${FUSIONDIRECTORY_VERSION}-${FUSIONDIRECTORY_PKG_RELEASE} \
    fusiondirectory-plugin-argonaut=${FUSIONDIRECTORY_VERSION}-${FUSIONDIRECTORY_PKG_RELEASE} \
    fusiondirectory-plugin-autofs=${FUSIONDIRECTORY_VERSION}-${FUSIONDIRECTORY_PKG_RELEASE} \
    fusiondirectory-plugin-certificates=${FUSIONDIRECTORY_VERSION}-${FUSIONDIRECTORY_PKG_RELEASE} \
    fusiondirectory-plugin-gpg=${FUSIONDIRECTORY_VERSION}-${FUSIONDIRECTORY_PKG_RELEASE} \
    fusiondirectory-plugin-ldapdump=${FUSIONDIRECTORY_VERSION}-${FUSIONDIRECTORY_PKG_RELEASE} \
    fusiondirectory-plugin-ldapmanager=${FUSIONDIRECTORY_VERSION}-${FUSIONDIRECTORY_PKG_RELEASE} \
    fusiondirectory-plugin-mail=${FUSIONDIRECTORY_VERSION}-${FUSIONDIRECTORY_PKG_RELEASE} \
    fusiondirectory-plugin-postfix=${FUSIONDIRECTORY_VERSION}-${FUSIONDIRECTORY_PKG_RELEASE} \
    fusiondirectory-plugin-ssh=${FUSIONDIRECTORY_VERSION}-${FUSIONDIRECTORY_PKG_RELEASE} \
    fusiondirectory-plugin-sudo=${FUSIONDIRECTORY_VERSION}-${FUSIONDIRECTORY_PKG_RELEASE} \
    fusiondirectory-plugin-systems=${FUSIONDIRECTORY_VERSION}-${FUSIONDIRECTORY_PKG_RELEASE} \
    fusiondirectory-plugin-weblink=${FUSIONDIRECTORY_VERSION}-${FUSIONDIRECTORY_PKG_RELEASE} \
    fusiondirectory-plugin-webservice=${FUSIONDIRECTORY_VERSION}-${FUSIONDIRECTORY_PKG_RELEASE} \
    fusiondirectory-smarty3-acl-render=${FUSIONDIRECTORY_VERSION}-${FUSIONDIRECTORY_PKG_RELEASE} \
    fusiondirectory-webservice-shell=${FUSIONDIRECTORY_VERSION}-${FUSIONDIRECTORY_PKG_RELEASE} \
    php-mdb2 \
    php-mbstring \
    php-fpm \
 && rm -rf /var/lib/apt/lists/*

RUN export TARGET=/etc/php/${PHP_VERSION}/fpm/php.ini \
 && sed -i -e "s:^;\(opcache.enable\) *=.*$:\1=1:" ${TARGET} \
 && sed -i -e "s:^;\(opcache.enable_cli\) *=.*$:\1=0:" ${TARGET} \
 && sed -i -e "s:^;\(opcache.memory_consumption\) *=.*$:\1=1024:" ${TARGET} \
 && sed -i -e "s:^;\(opcache.max_accelerated_files\) *=.*$:\1=65407:" ${TARGET} \
 && sed -i -e "s:^;\(opcache.validate_timestamps\) *=.*$:\1=0:" ${TARGET} \
 && sed -i -e "s:^;\(opcache.revalidate_path\) *=.*$:\1=1:" ${TARGET} \
 && sed -i -e "s:^;\(opcache.error_log\) *=.*$:\1=/dev/null:" ${TARGET} \
 && sed -i -e "s:^;\(opcache.log_verbosity_level\) *=.*$:\1=1:" ${TARGET} \
 && unset TARGET

RUN export TARGET=/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf \
 && sed -i -e "s:^\(listen *= *\).*$:\1/run/php-fpm.sock:" ${TARGET} \
 && sed -i -e "s:^\(user *= *\).*$:\1nginx:" ${TARGET} \
 && unset TARGET

RUN export TARGET=/etc/nginx/nginx.conf \
 && sed -i -e "s:^\(user \).*;$:\1 nginx www-data;:" ${TARGET} \
 && unset TARGET

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh
COPY cmd.sh /sbin/cmd.sh
RUN chmod 755 /sbin/cmd.sh
COPY default.conf /etc/nginx/conf.d/

EXPOSE 80 443
ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["/sbin/cmd.sh"]
