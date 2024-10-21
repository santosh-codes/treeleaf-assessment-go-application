# treeleaf-assessment-go-application

# Todo List Application

This project is a simple **Todo List** application built with **GO**. It provides a web interface to add tasks, mark them as done, and view the current list of tasks.

## Application Structure

The application is structured with the following folders:

- **main.go**: Contains the core Go application logic, including task management and routing.
- **templates/index.html**: Provides the frontend UI for displaying and managing tasks.

## Running the Application Locally

To run the application locally, follow these steps:

1. **Clone the repository** to your local machine:

   ```bash
   git clone https://github.com/santosh-codes/treeleaf-assessment-go-application
   cd treeleaf-assessment-go-application

   ```

2. **Navigate to the src folder**:

   ```bash
   cd todo-app

   ```

3. **Initialize the Go module** (if not done already):

   ```bash
   go mod init todo-app

   ```

4. Run the application:

   ```bash
   go run main.go

   ```

The application will start on http://localhost:8080

## Running the Application in Docker Container

The application is containerized using Docker. The Dockerfile uses a multi-stage build to separate the build environment and runtime environment for the Go application.

### Docker Stages:

1. **Builder Stage**: This stage installs Go, fetches dependencies, and builds the application into a binary.
2. **Runner Stage**: This stage uses the Alpine base image to run the application, ensuring a smaller container size and faster performance. It also copies the necessary templates and the compiled Go binary from the builder stage.

### Docker Commands

1. **Build the Docker image**:

   ```bash
   docker build -t <image-name> .
   ```

2. **Run the Docker container**:

   ```bash
   docker run -p 8080:8080 <image-name>

   ```

## Pushing the Docker Image to Docker Hub

After building the Docker image, push it to Docker Hub to make it accessible for deployment on any machine

1. **Tag the Docker image with Docker Hub repository name**:

   ```bash
   docker tag local-image-name:latest myusername/docker-hub-repo-name:latest

   ```

2. **Login to Docker Hub**:

   ```bash
   docker login

   ```

3. **Push the Docker image to Docker Hub**:

   ```bash
   docker push myusername/docker-hub-repo-name:latest

   ```

## Deploying the Application with Kubernetes on AWS EC2 Instance

This application is deployed on a Kubernetes cluster running on AWS EC2 instances. The cluster consists of two EC2 instances: one for the master node and one for the worker node, created and set up using kubeadm.

Prerequisites
Two EC2 instances (Master and Worker) are running.
kubeadm is used to set up the Kubernetes cluster

## AWS EC2 Setup

All instance are in same Security group.
Exposed port 6443 in the Security group, so that worker nodes can join the cluster.

## Commands Execute on both "Master" and "Worker Node"

```bash
# disable swap
sudo swapoff -a

# Create the .conf file to load the modules at bootup
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

## Install CRIO Runtime
sudo apt-get update -y
sudo apt-get install -y software-properties-common curl apt-transport-https ca-certificates gpg

sudo curl -fsSL https://pkgs.k8s.io/addons:/cri-o:/prerelease:/main/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://pkgs.k8s.io/addons:/cri-o:/prerelease:/main/deb/ /" | sudo tee /etc/apt/sources.list.d/cri-o.list

sudo apt-get update -y
sudo apt-get install -y cri-o

sudo systemctl daemon-reload
sudo systemctl enable crio --now
sudo systemctl start crio.service

echo "CRI runtime installed successfully"

# Add Kubernetes APT repository and install required packages
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update -y
sudo apt-get install -y kubelet="1.29.0-*" kubectl="1.29.0-*" kubeadm="1.29.0-*"
sudo apt-get update -y
sudo apt-get install -y jq

sudo systemctl enable --now kubelet
sudo systemctl start kubelet
```

## Excute only on Master Node

```bash
sudo kubeadm config images pull

sudo kubeadm init

mkdir -p "$HOME"/.kube
sudo cp -i /etc/kubernetes/admin.conf "$HOME"/.kube/config
sudo chown "$(id -u)":"$(id -g)" "$HOME"/.kube/config


# Network Plugin = calico
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.0/manifests/calico.yaml

kubeadm token create --print-join-command

```

Copy kubeadm token and execute on worker node

```bash
sudo kubeadm reset pre-flight checks
sudo your-token --v=5
```

A deployment.yaml file is created which defines the deployment and service configuration for the Todo List application.

After the creation of deployment.yml file use following commands tp deploy

1. **Apply the deployment and service configuration**:

```bash
 kubectl apply -f deployment.yml

```

2. **Verify the service and pod status**:

```bash
 kubectl get pods
 kubectl get svc

```

## Accessing the Application

Once the application is deployed, it can be accessed from a web browser by following the below steps:

1. **Allow Inbound Rule for port number in AWS EC2 Security group : For this project port number 32743 is used**
2. **Port Forward the application**
   kubectl port-forward svc/todo-app-service(service-name-of-application) 32743:8080 --address 0.0.0.0 &
3. **Access the app using http://15.206.47.68:32743/**

.
