#!/bin/bash
COMPRESSABLE=(
	"./usr/lib/libevent-2.1.so.7.0.1"
	"./usr/lib/libevent_core-2.1.so.7.0.1"
	"./usr/lib/libevent_extra-2.1.so.7.0.1"
	"./usr/lib/libevent_pthreads-2.1.so.7.0.1"
	"./usr/lib/libform.so.6.1"
	"./usr/lib/libmenu.so.6.1"
	"./usr/lib/libncurses.so.6.1"
	"./usr/lib/libpanel.so.6.1"
	"./usr/lib/libssl.so.1.1"
	"./usr/lib/libcrypto.so.1.1"
	"./usr/lib/libz.so.1.2.12"
	"./usr/lib/liblz4.so.1.3.1"
	"./usr/lib/engines-1.1/afalg.so"
	"./usr/lib/engines-1.1/capi.so"
	"./usr/lib/engines-1.1/padlock.so"
	"./usr/lib/openvpn/plugins/openvpn-plugin-down-root.so"
	"./usr/lib/libcurl.so.4.7.0"
	"./usr/lib/libpopt.so.0.0.1"
	"./usr/libexec/sftp-server"
	"./usr/libexec/ssh-keysign"
	"./usr/libexec/ssh-pkcs11-helper"
	"./usr/bin/ssh-agent"
	"./usr/bin/ssh-add"
	"./usr/bin/ssh-copy-id"
	"./usr/bin/ssh-keyscan"
	"./usr/bin/ssh"
	"./usr/bin/ssh-keygen"
	"./usr/sbin/sshd"

	"./usr/bin/rsync"
	"./usr/bin/rsync-ssl"

	"./bin/bash"
	"./usr/bin/curl"
	"./usr/bin/nano"
	"./usr/bin/htop"
	"./usr/bin/tmux"
	"./usr/bin/openssl"
	"./usr/bin/lz4"
	"./usr/bin/lz4c"

	"./usr/sbin/openvpn"
)

BASH_COMPLETIONS=(
	$(echo ./usr/share/bash-completion/completions/lz{ma,op,4,4c})
	$(echo ./usr/share/bash-completion/completions/{bzip2,gzip,xz,tar})
	$(echo ./usr/share/bash-completion/completions/{strings,passwd,pgrep})
	$(echo ./usr/share/bash-completion/completions/{insmod,modinfo,rmmod})
	$(echo ./usr/share/bash-completion/completions/{htop,kill,killall})
	$(echo ./usr/share/bash-completion/completions/{ping,ping6,arping,tcpdump})
	$(echo ./usr/share/bash-completion/completions/{nc,route,hostname,rsync})
	$(echo ./usr/share/bash-completion/completions/{openssl,curl})
	$(echo ./usr/share/bash-completion/completions/ssh{-add,-keygen,})
	$(echo ./usr/share/bash-completion/completions/iw{list,priv,config,spy})
	$(echo ./usr/share/bash-completion/completions/ip{tables,calc,})
	$(echo ./usr/share/bash-completion/completions/if{up,down})
)

TEMP_DIRS=()

INCLUDE=(
	"${COMPRESSABLE[@]}"
	"./usr/lib/libcurses.so"
	"./usr/lib/libevent-2.1.so.7"
	"./usr/lib/libevent_core-2.1.so.7"
	"./usr/lib/libevent_core.so"
	"./usr/lib/libevent_extra-2.1.so.7"
	"./usr/lib/libevent_extra.so"
	"./usr/lib/libevent_pthreads-2.1.so.7"
	"./usr/lib/libevent_pthreads.so"
	"./usr/lib/libevent.so"
	"./usr/lib/libform.so"
	"./usr/lib/libform.so.6"
	"./usr/lib/libmenu.so"
	"./usr/lib/libmenu.so.6"
	"./usr/lib/libncurses.so"
	"./usr/lib/libncurses.so.6"
	"./usr/lib/libpanel.so"
	"./usr/lib/libpanel.so.6"
	"./usr/lib/libz.so.1"
	"./usr/lib/libz.so"
	"./usr/lib/libcrypto.so"
	"./usr/lib/libssl.so"
	"./usr/lib/liblz4.so.1"
	"./usr/lib/liblz4.so"
	"./usr/lib/libcurl.so.4"
	"./usr/lib/libcurl.so"
	"./usr/lib/libpopt.so.0"
	"./usr/lib/libpopt.so"
	"./usr/bin/lz4cat"
	"./var/empty"

	"./etc/profile.d"
	"./usr/lib/locale"
	"./usr/lib/terminfo"
	"./usr/share/terminfo"
	"./etc/ssh"

	"${BASH_COMPLETIONS[@]}"

	"./etc/init.d/S50sshd"
	"./etc/init.d/S60openvpn"

	"${TEMP_DIRS[@]}"
)

SED_PATCHES=(
	"./etc/ssh/sshd_config" "s|\#PermitRootLogin prohibit-password|PermitRootLogin yes|" "Enable root login with password"
)

cd output/target || exit 0

rm -rf ../tar_staging
mkdir ../tar_staging || exit 0
cd ../tar_staging || exit 0

echo " * Extracting from rootfs.tar (w/ fakeroot) ..."
fakeroot -- tar --strip-components=1 -xpf ../images/rootfs.tar "${INCLUDE[@]}"

## disabled due to favoring RAM over NAND space
#for f in "${COMPRESSABLE[@]}"; do
#	if [ -f "${f}" ]; then
#		upx -d "${f}"
#		upx --android-shlib --ultra-brute "${f}"
#	fi
#done

if [ ${#TEMP_DIRS[@]} -gt 0 ]; then
	echo " * Temporarly creating directory ${d} ..."
	for d in ${TEMP_DIRS[@]}; do
		mkdir -p "${d}";
		chown root:root -R "${d}"
	done
fi

if [ ${#SED_PATCHES[@]} -gt 0 ]; then
	for f in $(seq 0 ${#SED_PATCHES[@]}); do
		if [ -f "${SED_PATCHES[${f}]}" ]; then
			echo " * Patching ${SED_PATCHES[${f}]} (${SED_PATCHES[$((f+2))]}) ..."
			sed -i "${SED_PATCHES[$((f+1))]}" "${SED_PATCHES[${f}]}"
		else
			if [ "${SED_PATCHES[${f}]:0,1}" == "." ]; then
				echo "No such file: ${SED_PATCHES[${f}]} ..."
			fi
			continue;
		fi
	done
fi

echo " * Packaging files info files.tgz (w/ fakeroot) ..."
fakeroot -- tar zcpf ../../files.tgz "${INCLUDE[@]}"


if [ ${#TEMP_DIRS[@]} -gt 0 ]; then
	echo " * Removing temporary directory ${d} ..."
	for d in ${TEMP_DIRS[@]}; do
		rm -rf "${d}";
	done
fi
