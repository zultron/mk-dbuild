docker_user() {
    if test $DOCKER_UID = 0; then
	echo root
    else
	echo user
    fi
}

docker_set_user() {
    if ! $IN_DOCKER || $IN_SCHROOT; then
	# Only set up user in Docker container
	return 0
    fi

    if test "$DOCKER_UID" = 0; then
	error "Set user ID on command line or in 'local-config.sh'"
	return 0
    fi

    if id -u user >/dev/null 2>&1; then
	# /etc/passwd already configured; do nothing
	return 0
    fi

    # Get `sbuild` group ID
    SBUILD_GID=$(id -g sbuild)
    test -n "$SBUILD_GID" || \
	error "Unable to look up group 'sbuild'"

    debug "    Setting docker user to $DOCKER_UID:$SBUILD_GID"

    DOCKER_PASSWD_ENTRY="user:*:$DOCKER_UID:$SBUILD_GID:User:/srv:/bin/bash"
    debug "      User ID:  $DOCKER_UID"
    echo "$DOCKER_PASSWD_ENTRY" >> /etc/passwd
    debug "    Adding user $DOCKER_UID to 'sbuild' group"
    sed -i /etc/group -e "/^sbuild:/ s/\$/user/"
    debug "      'user' passwd entry:  $(getent passwd user)"
    debug "      'sbuild' group entry:  $(getent group sbuild)"
}

docker_setup() {
    if ! $IN_DOCKER || $IN_SCHROOT; then
	# Only set up in Docker container
	return 0
    fi

    docker_set_user
}

docker_build() {
    msg "Building Docker container image '$DOCKER_IMAGE' from 'Dockerfile'"
    run bash -c "docker build $DOCKER_NO_CACHE -t $DOCKER_IMAGE - < Dockerfile"
}

docker_run() {
    DOCKER_BIND_MOUNTS="-v `pwd`:/srv"
    DOCKER_BIND_MOUNTS+=" -v $OUTSIDE_SBUILD_CHROOT_DIR:$SBUILD_CHROOT_DIR"
    if $DOCKER_ALWAYS_ALLOCATE_TTY || test -z "$*"; then
	msg "Starting interactive shell in Docker container '$DOCKER_IMAGE'"
	DOCKER_TTY=-t
    fi
    run docker run --privileged -i -e IN_DOCKER=true $DOCKER_TTY --rm=true \
	$DOCKER_BIND_MOUNTS \
	$DOCKER_IMAGE "${OTHER_ARGS[@]}"
}

