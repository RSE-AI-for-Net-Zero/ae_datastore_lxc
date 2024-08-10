NAME=$1 #"postgres_1_debian_amd64"
_TRUSTED_HOST=$2

####################################################################################
#
# Debian package provides PERL wrappers around postgres's own pg_ctl, initdb, etc.
#
# Look here: https://wiki.debian.org/PostgreSql
#
# Not terribly well documented
#
####################################################################################

export TRUSTED_HOST=$_TRUSTED_HOST

systemd-run --user --scope -p "Delegate=yes" -- lxc-attach -n ${NAME} --clear-env \
	    --keep-var TRUSTED_HOST \
	    -- /home/host/scripts/configure-single-node.sh







