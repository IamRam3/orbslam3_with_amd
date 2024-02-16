# checking if you have nvidia
if nvidia-smi | grep -q "Driver" 2>/dev/null; then
  echo "******************************"
  echo """It looks like you have nvidia drivers running. Please make sure your nvidia-docker is setup by following the instructions linked in the README and then run build_container_cuda.sh instead."""
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

docker pull jahaniam/orbslam3:ubuntu20_noetic_cpu

# Remove existing container
docker rm -f orbslam3 &>/dev/null
[ -d "ORB_SLAM3" ] && sudo rm -rf ORB_SLAM3 && mkdir ORB_SLAM3

# Create a new container
docker run -td --privileged --net=host --ipc=host \
    --name="orbslam3" \
    -e "DISPLAY=$DISPLAY" \
    -e "QT_X11_NO_MITSHM=1" \
    -v "/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    -e "XAUTHORITY=$XAUTH" \
    -e ROS_IP=127.0.0.1 \
    --cap-add=SYS_PTRACE \
    -v `pwd`/Datasets:/Datasets \
    -v /etc/group:/etc/group:ro \
    -v `pwd`/ORB_SLAM3:/ORB_SLAM3 \
    jahaniam/orbslam3:ubuntu20_noetic_cpu bash
    
# Set python priority to python3.8
docker exec -it orbslam3 bash -i -c "update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1 && update-alternatives --install /usr/bin/python python /usr/bin/python3.8 2"

# Install catkin build and noetic hector trajectory
docker exec -it orbslam3 bash -i -c "sudo apt install ros-noetic-hector-trajectory-server && sudo apt install python3-catkin-tools

