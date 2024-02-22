# checking if you have nvidia
if ! nvidia-smi | grep "Driver" 2>/dev/null; then
  echo "******************************"
  echo """It looks like you don't have nvidia drivers running. Consider running build_container_cpu.sh instead."""
  echo "******************************"
  while true; do
    read -p "Do you still wish to continue?" yn
    case $yn in
      [Yy]* ) make install; break;;
      [Nn]* ) exit;;
      * ) echo "Please answer yes or no.";;
    esac
  done
fi 

# UI permisions
XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth
touch $XAUTH
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

xhost +local:docker
# docker pull sairam4/patched_slam_nano_withoutframbuffer:cuda1

# Remove existing container
docker rm -f orbslam3 &>/dev/null
[ -d "ORB_SLAM3" ] && sudo rm -rf ORB_SLAM3 && mkdir ORB_SLAM3

# Create a new container
docker run -td --privileged --net=host --ipc=host \
    --name="orbslam3" \
    --gpus=all \
    -e "DISPLAY=$DISPLAY" \
    -e "QT_X11_NO_MITSHM=1" \
    -v "/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    -e "XAUTHORITY=$XAUTH" \
    -e LD_LIBRARY_PATH="/usr/local/lib" \
    -e ROS_IP=127.0.0.1 \
    --cap-add=SYS_PTRACE \
    -v `pwd`/Datasets:/Datasets \
    -v /etc/group:/etc/group:ro \
    -v `pwd`/ORB_SLAM3:/ORB_SLAM3 \
    -v /run/user/1000/at-spi:/run/user/1000/at-spi \
    sairam4/patched_slam_nano_withoutframebuffer:cuda1 bash

docker exec -it orbslam3 bash -i -c "cd ../ && sudo cp -r repo/slam_ws ORB_SLAM3"
