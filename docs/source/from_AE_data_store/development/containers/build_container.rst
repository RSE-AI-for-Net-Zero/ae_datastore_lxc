===================
Build lxc container
===================

Install lxc and supporting packages::

  sudo apt update && apt install lxc liblxc-dev lxc-utils python3-lxc

To create an unpriviledged container::

  lxc-create -n my_container -t download -- -d ubuntu -r focal -a amd64

Start and attach to current terminal (with Ubuntu on running on host)::

  lxc-start -n my_container && lxc-attach -n openLDAP

(with Debian running on host)::

  lxc-unpriv-start -n my_container && lxc-attach -n my_container

Install openssh-server inside container then exit::

  apt update && apt install -y openssh-server && exit

Create a non-root user::

  adduser <username>

and follow the prompts.

To get IP addresses for all running containers from outside::

  lxc-ls --fancy



  
