NAME=$1 #"postgres_1_debian_amd64"
TRUSTED_HOST=$2

export _TRUSTED_HOST=${TRUSTED_HOST}

####################################################################################
#
# Debian package provides PERL wrappers around postgres's own pg_ctl, initdb, etc.
#
# Look here: https://wiki.debian.org/PostgreSql
#
# Not terribly well documented
#
####################################################################################

systemd-run --user --scope -p "Delegate=yes" -- lxc-attach -n ${NAME} --clear-env \
	    --keep-var _TRUSTED_HOST \
	    -- /home/host/scripts/add_trusted_host.sh







