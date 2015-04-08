# RT kernel packages
PACKAGES="xenomai rtai linux linux-tools linux-latest"
# ZeroMQ packages
PACKAGES+=" czmq"
# Zultron Debian package repo
PACKAGES+=" dovetail-automata-keyring"

# Trusty arches
ARCHES="amd64 i386 armhf"

# Trusty distro mirror and components, other than 'main'
DISTRO_MIRROR=http://archive.ubuntu.com/ubuntu
DISTRO_MIRROR_armhf=http://ports.ubuntu.com/ubuntu-ports
DISTRO_COMPONENTS=universe

distro_configure_repos() {
    # Ubuntu distro
    case $HOST_ARCH in
	amd64|i386)
	    repo_add_apt_source ubuntu $DISTRO_MIRROR_armhf armhf \
		$DISTRO_COMPONENTS
	    ;;
    esac

    # Dovetail Automata; enable to pull deps not built locally
    #repo_configure_dovetail_automata  # include for partial builds
}

