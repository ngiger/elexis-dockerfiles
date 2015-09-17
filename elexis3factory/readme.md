### Simple factory for elexis-3-core and elexis-3-base

Usage:

(The docker image is on dockerhub, so no need to build it yourself.)

    sudo docker run -v /path/to/elexis/sources:/opt/elexisfactory rgwch/elexisfactory

where `/path/to/elexis/sources` ist a directory on the host, where the elexis-3-core repository is or can be cloned into.

_Note_: On Mac and Windows-Hosts, this directory must be within the User's home, or docker won't be able to access it. (see [here](https://docs.docker.com/userguide/dockervolumes/) this note: 
 
----     
 "Note: If you are using Docker Machine on Mac or Windows, your Docker daemon only has limited access to your OS X/Windows filesystem. Docker Machine tries to auto-share your /Users (OS X) or C:\Users (Windows) directory - and so you can mount files or directories using docker run -v /Users/<path>:/<container path> ... (OS X) or docker run -v /c/Users/<path>:/<container path ... (Windows). All other paths come from your virtual machine’s filesystem."

---                                                                                                                        
                                                                                                                                

The factory will clone elexis-3-core, and elexis-3-base, if the respective repository doesn't exist. If it exists, it will `git pull` to update. 
Then it creates the elexis core for all supported architectures and copies them to `/path/to/elexis/sources/dist` after successful build. The files of elexis-3-base are compiled and left in-place.

### Speeding up consecutive builds

To re-use a container, find the container using `sudo docker ps -a` and relaunch it with

    sudo docker start -ia name_of_container
    
This will re-use the downloaded maven repository and rebuild the elexis product, saving a lot of time compared to a build from scratch.


To persist a container with preloaded repositories into a new docker image, try something like this:

    sudo docker commit -a "weirich@elexis.ch" -m "loaded maven repository" thirsty_brown rgwch/elexisfactory:1.1.0
    
    
where 'thirsty_brown' is the name of the container as found with `docker ps -a`.
One can create a new container from such an image with:

   sudo docker run -v /path/to/sources:/opt/elexisfactory rgwch/elexisfactory:1.1.0 
  
Much the same way than with reusing a container, maven repositories are preloaded in this image, thus speeding up the compile process. The downside is, that such an image is much larger than the pristine elexisfactory.


### Using a different upstream repository

Since elexisfactory applies only a `git pull`, if it finds an existing repository, this is easy: Check out the desired repository manually into the directory you give to elexisfactory.
If no repository ist found there, elexisfactory will always check out http://github.com/elexis/elexis-3-core and http://github.com/elexis/elexis-3-base.
