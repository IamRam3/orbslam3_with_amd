# ORB_SLAM3 docker

This docker is based on ros noetic ubuntu 20. If you need melodic with ubuntu 18 checkout #8fde91d

There are two versions available:
- CPU based (Xorg Nouveau display)
- Nvidia Cuda based. 

To check if you are running the nvidia driver, simply run `nvidia-smi` and see if get anything.

Based on which graphic driver you are running, you should choose the proper docker. For cuda version, you need to have [nvidia-docker setup](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html) on your machine.

---

## Running

Steps to use the Orbslam3 

- `build_container_cpu2.sh` it is for amd architecture.

- `docker exec -it orbslam3 bash`
- inside the container source it by`source devel/setup.bash`

---

You can use vscode remote development (recommended) or sublime to change codes.
- `docker exec -it orbslam3 bash`
- `subl /ORB_SLAM3`
