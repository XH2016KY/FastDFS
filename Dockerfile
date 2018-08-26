FROM hub.c.163.com/public/centos:7.2-tools
MAINTAINER GGG
RUN yum -y install gcc-c++
RUN yum -y install make
RUN yum -y install pcre pcre-devel
RUN yum -y install zlib zlib-devel
RUN yum -y install libevent
# 安装编译FastDFS
WORKDIR /usr
ADD fastdfs-nginx-module_v1.16.tar.gz local/
ADD libfastcommon-master-master.zip local/
RUN mkdir -p /home/FastDFS	
RUN mkdir -p /home/FastDFS/fdfs_storage

RUN yum -y install unzip
WORKDIR /usr/local
RUN unzip libfastcommon-master-master.zip
WORKDIR /usr/local/libfastcommon-master-master
RUN chmod 755 make.sh
RUN ./make.sh && ./make.sh install

WORKDIR /usr
ADD FastDFS_v5.08.tar.gz local/
WORKDIR /usr/local/FastDFS
RUN ./make.sh && ./make.sh install

WORKDIR /etc
ADD storage.conf fdfs/

WORKDIR /usr/local/FastDFS/conf
RUN cp client.conf http.conf mime.types storage_ids.conf tracker.conf /etc/fdfs


WORKDIR /usr/local/fastdfs-nginx-module/src
RUN rm -rf config
RUN rm -rf mod_fastdfs.conf
WORKDIR /usr/local/fastdfs-nginx-module
ADD config src/
WORKDIR /usr/local/fastdfs-nginx-module
ADD mod_fastdfs.conf src/

WORKDIR /usr
ADD nginx-1.8.1.tar.gz local/
WORKDIR /usr/local/nginx-1.8.1
RUN  ./configure --add-module=/usr/local/fastdfs-nginx-module/src
RUN make && make install

WORKDIR /usr/local/nginx/conf
RUN rm -rf nginx.conf
WORKDIR /usr/local/nginx 
ADD nginx.conf conf/
WORKDIR /etc
ADD mod_fastdfs.conf fdfs/
EXPOSE 80
EXPOSE 22
EXPOSE 22122
EXPOSE 23000
ENTRYPOINT /usr/local/nginx/sbin/nginx && /usr/bin/fdfs_storaged /etc/fdfs/storage.conf restart && /usr/sbin/sshd -D
