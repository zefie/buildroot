#!/bin/bash
COMPRESSABLE=(
	"usr/lib/libevent-2.1.so.7.0.1"
	"usr/lib/libevent_core-2.1.so.7.0.1"
	"usr/lib/libevent_extra-2.1.so.7.0.1"
	"usr/lib/libevent_pthreads-2.1.so.7.0.1"
	"usr/lib/libform.so.6.1"
	"usr/lib/libmenu.so.6.1"
	"usr/lib/libncurses.so.6.1"
	"usr/lib/libpanel.so.6.1"
	"usr/lib/libssl.so.1.1"
	"usr/lib/libcrypto.so.1.1"
	"usr/lib/libz.so.1.2.12"
	"usr/lib/liblz4.so.1.3.1"
	"usr/lib/engines-1.1/afalg.so"
	"usr/lib/engines-1.1/capi.so"
	"usr/lib/engines-1.1/padlock.so"
	"usr/lib/openvpn/plugins/openvpn-plugin-down-root.so"
	"usr/lib/libcurl.so.4.7.0"

	"bin/bash"
	"usr/bin/curl"
	"usr/bin/nano"
	"usr/bin/htop"
	"usr/bin/tmux"
	"usr/bin/openssl"
	"usr/bin/lz4"
	"usr/bin/lz4c"

	"usr/sbin/dropbear"
	"usr/sbin/openvpn"
)

BASH_COMPLETIONS=(
	$(echo usr/share/bash-completion/completions/lz{ma,op,4,4c})
	$(echo usr/share/bash-completion/completions/{bzip2,gzip,xz,tar})
	$(echo usr/share/bash-completion/completions/{strings,passwd,pgrep})
	$(echo usr/share/bash-completion/completions/{insmod,modinfo,rmmod})
	$(echo usr/share/bash-completion/completions/{htop,kill,killall})
	$(echo usr/share/bash-completion/completions/{ping,ping6,arping,tcpdump,route})
	$(echo usr/share/bash-completion/completions/{nc,route,hostname})
	$(echo usr/share/bash-completion/completions/{openssl,curl})
	$(echo usr/share/bash-completion/completions/iw{list,priv,config,spy})
	$(echo usr/share/bash-completion/completions/ip{tables,calc,})
	$(echo usr/share/bash-completion/completions/if{up,down})
)

TEMP_DIRS=(
	"data/etc/dropbear"
)

INCLUDE=(
	"${COMPRESSABLE[@]}"
	"usr/lib/libcurses.so"
	"usr/lib/libevent-2.1.so.7"
	"usr/lib/libevent_core-2.1.so.7"
	"usr/lib/libevent_core.so"
	"usr/lib/libevent_extra-2.1.so.7"
	"usr/lib/libevent_extra.so"
	"usr/lib/libevent_pthreads-2.1.so.7"
	"usr/lib/libevent_pthreads.so"
	"usr/lib/libevent.so"
	"usr/lib/libform.so"
	"usr/lib/libform.so.6"
	"usr/lib/libmenu.so"
	"usr/lib/libmenu.so.6"
	"usr/lib/libncurses.so"
	"usr/lib/libncurses.so.6"
	"usr/lib/libpanel.so"
	"usr/lib/libpanel.so.6"
	"usr/lib/libz.so.1"
	"usr/lib/libz.so"
	"usr/lib/libcrypto.so"
	"usr/lib/libssl.so"
	"usr/lib/liblz4.so.1"
	"usr/lib/liblz4.so"
	"usr/lib/libcurl.so.4"
	"usr/lib/libcurl.so"
	"usr/bin/lz4cat"
	"usr/bin/dropbearkey"
	"usr/bin/dropbearconvert"
	"usr/bin/ssh"
	"usr/bin/scp"
	"usr/bin/dbclient"

	"etc/profile.d"
	"usr/lib/locale"
	"usr/lib/terminfo"
	"usr/share/terminfo"
	"etc/dropbear"

	"${BASH_COMPLETIONS[@]}"

	"etc/init.d/S50dropbear"
	"etc/init.d/S60openvpn"

	"${TEMP_DIRS[@]}"
)

cd output/target || exit 0

## disabled due to favoring RAM over NAND space
#for f in "${COMPRESSABLE[@]}"; do
#	if [ -f "${f}" ]; then
#		upx -d "${f}"
#		upx --android-shlib --ultra-brute "${f}"
#	fi
#done

if [ ${#TEMP_DIRS[@]} -gt 0 ]; then
	for d in ${TEMP_DIRS[@]}; do
		mkdir -p "${d}";
	done
fi

fakeroot -- chown root:root -R "${INCLUDE[@]}" 
fakeroot -- tar zcvf ../../files.tgz "${INCLUDE[@]}"

if [ ${#TEMP_DIRS[@]} -gt 0 ]; then
	for d in ${TEMP_DIRS[@]}; do
		rm -rf "${d}";
	done
fi
