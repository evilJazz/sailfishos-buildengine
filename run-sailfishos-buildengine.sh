#!/bin/bash
SCRIPT_FILENAME="`cd \`dirname \"$0\"\`; pwd`/`basename \"$0\"`"
SCRIPT_ROOT=$(dirname "$SCRIPT_FILENAME")
cd "$SCRIPT_ROOT"

IMAGE_NAME="buildengine-sailfishos"

USER=$SUDO_USER
USERDIR=/home/$USER
SDK=/opt/SailfishOS
BUILDENGINE="$SCRIPT_ROOT/rootfs.1701"

if [ $EUID -ne 0 ]; then
	echo "This script must be run with sudo." 1>&2
	exit 1
fi

# Rewrite user id and group id entries to match host system's users
updateConfigs()
{
	sed -i -e "s/$1:x:$2:100000:/$1:x:$(id -u $USER):$(id -g $USER):/" "$3/passwd"
	sed -i -e "s/$1:x:100000:/$1:x:$(id -g $USER):/" "$3/group"
	cp /etc/resolv.conf "$3/"
}

updateConfigs mersdk 1001 "$BUILDENGINE/etc"
updateConfigs nemo 100000 "$BUILDENGINE/srv/mer/targets/SailfishOS-armv7hl/etc"
updateConfigs nemo 100000 "$BUILDENGINE/srv/mer/targets/SailfishOS-i486/etc"

docker build -t "$IMAGE_NAME" docker

docker run --rm -it \
	--cap-add SYS_PTRACE \
	--network=host \
	--volume "$BUILDENGINE/bin:/bin" \
	--volume "$BUILDENGINE/boot:/boot" \
	--volume "$BUILDENGINE/etc:/etc" \
	--volume "$BUILDENGINE/home:/home" \
	--volume "$BUILDENGINE/lib:/lib" \
	--volume "$BUILDENGINE/media:/media" \
	--volume "$BUILDENGINE/mnt:/mnt" \
	--volume "$BUILDENGINE/opt:/opt" \
	--volume "$BUILDENGINE/root:/root" \
	--volume "$BUILDENGINE/run:/run" \
	--volume "$BUILDENGINE/sbin:/sbin" \
	--volume "$BUILDENGINE/srv:/srv" \
	--volume "$BUILDENGINE/tmp:/tmp" \
	--volume "$BUILDENGINE/usr:/usr" \
	--volume "$BUILDENGINE/var:/var" \
	--volume "$USERDIR:/home/mersdk/share" \
	--volume "$USERDIR:/home/src1" \
	--volume "$SDK/mersdk/ssh:/etc/ssh/authorized_keys" \
	--volume "$SDK/mersdk/targets:/host_targets" \
	--volume "$SDK/vmshare:/etc/mersdk/share" \
	-p 2222:2222 \
	-p 8080:8080 \
	"$IMAGE_NAME" \
	/runmersdkengine.sh
