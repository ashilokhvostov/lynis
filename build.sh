#!/bin/bash

UPSTREAM_VERSION=2.5.8
TS_VERSION=1

VERSION="${UPSTREAM_VERSION}-ts${TS_VERSION}"

rm -f *.deb &>/dev/null

mkdir -p tmp/buildroot/etc/lynis \
tmp/buildroot/usr/sbin \
tmp/buildroot/usr/share/doc/lynis \
tmp/buildroot/usr/share/lynis/db/languages \
tmp/buildroot/usr/share/lynis/include \
tmp/buildroot/usr/share/lynis/plugins \
tmp/buildroot/usr/share/man/man8 \
tmp/buildroot/etc/bash_completion.d

#tmp/buildroot/usr/share/lintian/overrides
#cp tmp/buildroot/usr/share/lintian/overrides

cp {default.prf,developer.prf} tmp/buildroot/etc/lynis
cp lynis tmp/buildroot/usr/sbin
cp {CHANGELOG.md,CONTRIBUTIONS.md,CONTRIBUTORS.md,FAQ,INSTALL,LICENSE,README,README.md} tmp/buildroot/usr/share/doc/lynis
cp -r db tmp/buildroot/usr/share/lynis
cp -r include tmp/buildroot/usr/share/lynis
cp -r plugins tmp/buildroot/usr/share/lynis
gzip lynis.8 -c > lynis.8.gz && cp lynis.8.gz tmp/buildroot/usr/share/man/man8
cp extras/bash_completion.d/lynis tmp/buildroot/etc/bash_completion.d

docker run --rm -i --workdir /build -v ${PWD}/tmp:/build tenzer/fpm  --verbose \
  -v "${VERSION}" \
  -n ts-lynis \
  -t deb \
  -s dir \
  -m "Tradeshift Operations <operations@tradeshift.com>" \
  --description "Security auditing tool for Linux systems
 Lynis is an auditing tool for systems running Linux, Mac OS X,
 BSD, or any other UNIX-based operating system. It helps with
 discovering configuration issues and implementing best practices.
 .
 Lynis can be used in addition to other software, like security
 scanners, system benchmarking and fine-tuning tools.
 .
 This package patched by Tradeshift devops team." \
  --vendor "CISOfy <software@cisofy.com>" \
  --license "GPLv3" \
  --url "https://github.com/Tradeshift/lynis" \
  --prefix "/" \
  --deb-user root \
  --deb-group root \
  --deb-priority optional \
  --architecture all \
  --deb-recommends menu \
  --deb-suggests dnsutils \
  --deb-suggests bash-completion \
  --conflicts lynis \
  -C /build/buildroot \
  .

mv ${PWD}/tmp/*deb ${PWD}/
rm -r tmp lynis.8.gz
