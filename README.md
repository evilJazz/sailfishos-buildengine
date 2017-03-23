SailfishOS/MerSDK build engine as Docker container
--------------------------------------------------

I have been struggling with the SailfishOS Build Engine VM for quite some time. 4 out of 5 SailfishOS builds of QuasarMX would fail because the Shared Folder (vboxsf) mechanism in VirtualBox at some point starts to corrupt files on my system, even though the system’s RAM and storage are perfectly fine. Since QuasarMX heavily relies on qmlpp (see previous post) to work with QtQuick 2, a lot of files will be touched during compilation. For this, vboxsf is both unreliable and slow (!).

Before you can use this Docker container you have to have the latest SailfishOS SDK installed and copy over the rootfs of the build engine VM to a local directory that will be hooked up in the Docker container we are about to run.

Start the build engine VM and make sure you can connect to it via SSH (see [Developer FAQ](https://sailfishos.org/develop/sdk-overview/develop-faq) for details):

$SUDO_USER is the username you used to sudo into root privileges, change it if you have not used sudo to become root.

    ssh -p 2222 -i /home/$SUDO_USER/SailfishOS/vmshare/ssh/private_keys/engine/root root@localhost  

If it works:

    exit  

Now, become root:

    sudo -i  

Change directory to where you cloned this repository and create a sub-directory "rootfs" next to the start script "run-sailfishos-buildengine.sh" and the "docker" directory.

    mkdir rootfs

Now use rsync to copy the rootfs from the VM:

    rsync --numeric-ids -xazuv -e "ssh -p 2222 -i /home/$SUDO_USER/SailfishOS/vmshare/ssh/private_keys/engine/root" root@localhost:/ ./rootfs/

This will take a while. Go, have dinner or get a cup of tea.

Once finished, make sure to un-sudo, i.e. become a unpriviledged user again:

    exit

Now, shut down the build engine VM and start your new Dockerized build engine via

    sudo ./run-sailfishos-buildengine.sh

**Known issues and caveats:**

 - The dockerized build engine can not deploy to the emulator and will time out. This seems to be caused by a hard-coded IP address in one of the binaries used during the deployment process. I have not looked into the issue in detail yet.
 - The modified Qt Creator that is included in the SailfishOS SDK also will not recognize that our build engine is already working. I am guessing it is directly interfacing with Virtual Box. Workaround: Start the VM after the Docker container is already running and ports are bound.
