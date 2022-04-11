#!/bin/bash
COMPRESS=(
	"usr/lib/libevent-2.1.so.7.0.1"
	"usr/lib/libevent_core-2.1.so.7.0.1"
	"usr/lib/libevent_extra-2.1.so.7.0.1"
	"usr/lib/libevent_pthreads-2.1.so.7.0.1"
	"usr/lib/libform.so.6.1"
	"usr/lib/libmenu.so.6.1"
	"usr/lib/libncurses.so.6.1"
	"usr/lib/libpanel.so.6.1"
	"usr/lib/libz.so.1.2.8"

	"bin/bash"
	"usr/bin/nano"
	"usr/bin/htop"
	"usr/bin/tmux"

	"usr/bin/dropbearkey"
	"usr/bin/dropbearconvert"
	"usr/sbin/dropbear"
)

INCLUDE=(
	"${COMPRESS[@]}"
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

	"etc/profile.d"
	"usr/lib/locale"
	"usr/lib/terminfo"
	"usr/share/terminfo"
	"usr/share/bash-completion"
	"etc/dropbear"
	"etc/init.d/S50dropbear"
)

cd output/target || exit 0
for f in "${COMPRESS[@]}"; do
	if [ -f "${f}" ]; then
#		upx -d "${f}"
		upx --android-shlib --ultra-brute "${f}"
	fi
done

fakeroot -- chown root:root -R "${INCLUDE[@]}" 
fakeroot -- tar zcvf ../../files.tgz "${INCLUDE[@]}"

