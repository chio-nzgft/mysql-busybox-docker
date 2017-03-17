FROM busybox:ubuntu-14.04
WORKDIR /
RUN wget http://ftp.ntu.edu.tw/MySQL/Downloads/MySQL-5.7/mysql-5.7.16-linux-glibc2.5-x86_64.tar.gz
RUN tar zxvf mysql-5.7.16-linux-glibc2.5-x86_64.tar.gz
RUN mv mysql-5.7.16-linux-glibc2.5-x86_64 mysql
RUN mkdir /mysql/sql_data
RUN rm -rf mysql-5.7.16*.*
RUN echo "mysql:x:1:1:mysql:/:/bin/sh" >> /etc/passwd
RUN echo "mysql:x:1:" >> /etc/group
COPY /lib/libaio.so.1 /lib
COPY /lib/libcrypt.so.1 /lib
COPY /lib/libstdc++.so.6 /lib
COPY /lib/libgcc_s.so.1 /lib
COPY /lib/libfreebl3.so /lib
COPY /lib/libncurses.so.5 /lib
RUN  chmod 1777 /tmp
RUN chown -R mysql:mysql /mysql
EXPOSE 3306
USER mysql
RUN echo "[server]" > /mysql/my.cnf
RUN echo "user=mysql" >> /mysql/my.cnf
RUN echo "basedir=/mysql/mysql" >> /mysql/my.cnf
RUN echo "datadir=/mysql/sql_data" >> /mysql/my.cnf
RUN echo "port=3306" >> /mysql/my.cnf
RUN echo "update mysql.user set authentication_string=password('rootpass') , password_expired='N' where user='root';" > /mysql/pass.sql
RUN echo "update mysql.user set  host='%' where user='root';" >> /mysql/pass.sql
RUN echo "flush privileges;" >> /mysql/pass.sql
RUN echo "#!/bin/sh" > /mysql/start.sh
RUN echo "cd /mysql;./bin/mysqld --defaults-file=/mysql/my.cnf --initialize-insecure" >> /mysql/start.sh
RUN echo "cd /mysql;./bin/mysqld_safe --defaults-file=/mysql/my.cnf  --init-file=/mysql/pass.sql &" >> /mysql/start.sh
RUN echo "while true; do" >> /mysql/start.sh
RUN echo "sleep 5" >> /mysql/start.sh
RUN echo "done" >> /mysql/start.sh
RUN chmod +x /mysql/start.sh
ENTRYPOINT /mysql/start.sh
