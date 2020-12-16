# https://hub.docker.com/_/alpine
FROM alpine:3.12

WORKDIR /root

ENV \
LANG=C.UTF-8 \
PS1='\[\e[1;7m\] $\?=$? $(. /etc/os-release && echo $ID-$VERSION_ID) \u@$(hostname -i)@\H:\w \[\e[0m\]\n\$ '

RUN function log { echo -e "\e[7;36m$(date +%F_%T)\e[0m\e[1;96m $*\e[0m" > /dev/stderr ; } \
# https://pkgs.alpinelinux.org/
# https://developer.aliyun.com/mirror/alpine
&& log "updating apk repositories mirror" \
&& sed -i "s/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g" /etc/apk/repositories \
\
# https://pkgs.alpinelinux.org/package/v3.12/main/x86_64/curl
&& log "installing 'curl'" \
&& apk add --no-cache curl \
\
# https://wiki.alpinelinux.org/wiki/Setting_the_timezone
&& log "installing tzdata and set timezone as 'Asia/Shanghai'" \
&& apk add --no-cache tzdata \
&& cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
&& echo "Asia/Shanghai" > /etc/timezone \
&& apk del tzdata \
\
&& log "installing docker-cli" \
&& apk add --no-cache docker-cli \
\
&& log "installing git" \
&& apk add --no-cache git \
\
&& log "installing maven" \
&& apk add --no-cache openjdk8 maven \
\
# https://developer.aliyun.com/mirror/NPM
# https://npm.taobao.org/mirrors
&& log "installing nodejs and set npm mirror" \
&& apk add --no-cache npm \
&& npm config set registry https://registry.npm.taobao.org -g \
&& npm config set sass_binary_site https://npm.taobao.org/mirrors/node-sass/ -g \
&& npm config set phantomjs_cdnurl https://npm.taobao.org/mirrors/phantomjs/ -g \
&& npm config set electron_mirror https://npm.taobao.org/mirrors/electron/ -g \
\
# https://wiki.alpinelinux.org/wiki/Release_Notes_for_Alpine_3.12.0#python3_no_longer_provides_pip3.2C_use_py3-pip_from_community
# https://developer.aliyun.com/mirror/pypi
&& log "installing python3 and set pip3 mirror" \
&& apk add --no-cache py3-pip \
&& echo -e '[global]\nindex-url=https://mirrors.aliyun.com/pypi/simple/\ntrusted-host=mirrors.aliyun.com' > /etc/pip.conf \
\
# https://docs.amazonaws.cn/cli/latest/userguide/install-linux-al2017.html
&& log "installing aws-cli" \
&& pip3 install awscli \
\
# https://help.aliyun.com/document_detail/121541.html , not all versions support BushBox so we lock version
# https://github.com/aliyun/aliyun-cli/releases
&& log "installing aliyun-cli" \
&& wget https://github.com/aliyun/aliyun-cli/releases/download/v3.0.62/aliyun-cli-linux-3.0.62-amd64.tgz -O- | tar xz \
&& chown root:root aliyun && chmod 755 aliyun && mv aliyun /bin/aliyun \
\
# https://stedolan.github.io/jq/
&& log "installing jq" \
&& apk add --no-cache jq \
\
# https://github.com/mikefarah/yq/releases
&& log "installing yq" \
&& wget "https://github.com/mikefarah/yq/releases/download/3.3.0/yq_linux_amd64" -O /bin/yq \
&& chmod a+x /bin/yq \
\
# https://docs.amazonaws.cn/AmazonECR/latest/userguide/Registries.html#registry-auth-credential-helper
&& log "installing docker-credential-ecr-login" \
&& wget "https://amazon-ecr-credential-helper-releases.s3.us-east-2.amazonaws.com/0.4.0/linux-amd64/docker-credential-ecr-login" -O /bin/docker-credential-ecr-login \
&& chmod a+x /bin/docker-credential-ecr-login \
\
# https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-linux
&& log "installing kubectl" \
# && KUBECTL_VERSION=$(wget -O- https://storage.googleapis.com/kubernetes-release/release/stable.txt) \
&& wget https://storage.googleapis.com/kubernetes-release/release/v1.20.0/bin/linux/amd64/kubectl -O /bin/kubectl \
&& chmod a+x /bin/kubectl \
\
# https://helm.sh/
&& log "installing helm" \
&& wget "https://get.helm.sh/helm-v2.17.0-linux-amd64.tar.gz" -O- | tar xz \
&& mv linux-amd64/helm /bin/helm2 \
&& rm -rf linux-amd64 \
&& wget "https://get.helm.sh/helm-v3.4.2-linux-amd64.tar.gz" -O- | tar xz \
&& mv linux-amd64/helm /bin/helm3 \
&& rm -rf linux-amd64 \
&& ln -sf helm3 /bin/helm \
\
&& log "cleaning all cache files" \
&& rm -rf ~/.ash_history ~/.cache/ ~/.config/ ~/.npm* ~/* /var/cache/apk/* /tmp/*
