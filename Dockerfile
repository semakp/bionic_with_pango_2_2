#Homebrew
#brew install glib cairo libexif libjpeg giflib libtiff autoconf libtool automake pango pkg-config
#brew link gettext --force

#Debian
#sudo apt-get install libgif-dev autoconf libtool automake build-essential gettext libglib2.0-dev libcairo2-dev libtiff-dev libexif-dev

FROM mcr.microsoft.com/dotnet/core/aspnet:2.2-bionic as builder
RUN apt-get update \
    && apt-get install -y --no-install-recommends libpango1.0-dev libc6-dev \
     libgif-dev git autoconf libtool automake build-essential gettext libglib2.0-dev libcairo2-dev libtiff-dev libexif-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/mono/libgdiplus
WORKDIR /libgdiplus
RUN ./autogen.sh --with-pango \
    && make \
    && make install

FROM mcr.microsoft.com/dotnet/core/aspnet:2.2-bionic
RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula \
    select true | debconf-set-selections
RUN apt-get update \
    && apt-get install -y --no-install-recommends ttf-mscorefonts-installer gss-ntlmssp libpango1.0-dev libc6-dev \
     libgif-dev libglib2.0-dev libcairo2-dev libtiff-dev libexif-dev language-pack-ru gnupg1 libgdiplus \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* 
RUN echo 'deb http://deb.debian.org/debian buster main contrib non-free' > /etc/apt/sources.list.d/backports.list \
    && apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 04EE7237B7D453EC \
    && apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 648ACFD622F3D138 \
    && apt-key adv --recv-keys --keyserver keyserver.ubuntu.com DCC9EFBF77E11517 \
    && apt-get update \
    && apt-get install -y --no-install-recommends libpangocairo-1.0-0 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
#COPY --from=builder /usr/local/lib/libgdiplus* /usr/lib/
# Установка локализации в контейнере
ENV LANGUAGE ru_RU.UTF-8
ENV LANG ru_RU.UTF-8
ENV LC_ALL ru_RU.UTF-8
RUN echo "ru_RU.CP866 IBM866" >> /etc/locale.gen \
    && locale-gen

# Очищаем предопределенные адреса прослушивания ASP.NET Core, чтобы не было warning-ов при старте сервисов.
ENV ASPNETCORE_URLS=
