nginx 配置

前端网站通过宝塔配置即可

后端服务重定向配置
location / {
    proxy_pass: http://127.0.0.1:XXXX
}

注意需注释宝塔静态文件配置：（应该有更好的处理）

#location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$
#{
#    expires      30d;
#    error_log /dev/null;
#    access_log off;
#}

#location ~ .*\.(js|css)?$
#{
#    expires      12h;
#    error_log /dev/null;
#    access_log off;
#}