debug "    Sourcing distro.sh"

repo_add_apt_key() {
    KEY=$1
    KEYRING=$CHROOT_DIR/etc/apt/trusted.gpg.d/sbuild-extra.gpg
    debug "    Adding apt key '$KEY'"
    case $KEY in
	http://*|https://*)
	    # Install key from URL
	    run bash -c "wget -O - -q $KEY | apt-key --keyring $KEYRING add -"
	    ;;
	*/sbuild-key.pub)
	    # Install sbuild key from sbuild-key.pub
	    run apt-key --keyring $KEYRING add $KEY
	    ;;
	[0-9A-F][0-9A-F][0-9A-F][0-9A-F]*)
	    # Install key from key server
	    run apt-key --keyring $KEYRING \
		adv --keyserver $GPG_KEY_SERVER --recv-key $KEY
	    ;;
	*)
	    error "Unrecognized key '$KEY'"
	    ;;
    esac
    run_debug apt-key --keyring $KEYRING list
}

repo_add_apt_source() {
    local NAME=$1
    local URL=$2
    local ARCHES=${3:-$BUILD_ARCH}
    local COMPONENTS="main${4:+ $4}"
    echo "deb [arch=$ARCHES] $URL $CODENAME $COMPONENTS" \
	>> $CHROOT_DIR/etc/apt/sources.list.d/$NAME.list
}

repo_configure_dovetail_automata() {
    # Dovetail Automata LLC Machinekit repository; currently Wheezy,
    # Jessie, Trusty
    repo_add_apt_source machinekit http://deb.dovetail-automata.com
    repo_add_apt_key 7F32AE6B73571BB9
}

repo_configure_emdebian() {
    # Emdebian.org cross-build toolchain
    repo_add_apt_source emdebian http://emdebian.org/tools/debian
    repo_add_apt_key \
	http://emdebian.org/tools/debian/emdebian-toolchain-archive.key
}

repo_configure_rcn() {
    # Robert C Nelson's Beaglebone Black distro; currently Wheezy,
    # Jessie, Trusty
    repo_add_apt_source rcn http://repos.rcn-ee.net/debian armhf
    repo_add_apt_key \
	http://repos.rcn-ee.net/debian/conf/repos.rcn-ee.net.gpg.key
}

