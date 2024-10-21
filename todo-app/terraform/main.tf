provider "aws" {
  region = "ap-south-1"
}

resource "aws_security_group" "k8s_sg" {
  name        = "k8s_sg"
  description = "Security group for Kubernetes EC2 instances"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "k8s_key" {
  key_name   = "k8s-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "k8s_master" {
  ami             = "ami-0c55b159cbfafe1f0"
  instance_type   = "t2.medium"
  key_name        = aws_key_pair.k8s_key.key_name
  security_groups = [aws_security_group.k8s_sg.name]

  tags = {
    Name = "K8S-Master"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt update && apt upgrade -y
              apt install -y apt-transport-https ca-certificates curl software-properties-common
              curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
              echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
              apt update
              apt install -y kubelet kubeadm kubectl
              apt-mark hold kubelet kubeadm kubectl
              kubeadm init --pod-network-cidr=10.244.0.0/16
              export KUBEVERSION=$(kubeadm version -o short)
              mkdir -p $HOME/.kube
              cp /etc/kubernetes/admin.conf $HOME/.kube/config
              chown $(id -u):$(id -g) $HOME/.kube/config
              kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
              EOF
}

resource "aws_instance" "k8s_worker" {
  ami             = "ami-0c55b159cbfafe1f0"
  instance_type   = "t2.medium"
  key_name        = aws_key_pair.k8s_key.key_name
  security_groups = [aws_security_group.k8s_sg.name]

  count = 2

  tags = {
    Name = "K8S-Worker-${count.index + 1}"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt update && apt upgrade -y
              apt install -y apt-transport-https ca-certificates curl software-properties-common
              curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
              echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
              apt update
              apt install -y kubelet kubeadm kubectl
              apt-mark hold kubelet kubeadm kubectl
              EOF
}

resource "aws_instance" "k8s_master_join" {
  ami             = "ami-0c55b159cbfafe1f0"
  instance_type   = "t2.medium"
  key_name        = aws_key_pair.k8s_key.key_name
  security_groups = [aws_security_group.k8s_sg.name]

  depends_on = [aws_instance.k8s_master]
  tags = {
    Name = "K8S-Master-Join"
  }

  user_data = <<-EOF
              #!/bin/bash
              sleep 30  # Allow master to initialize
              KUBE_JOIN_COMMAND=$(ssh -i "~/.ssh/id_rsa" ubuntu@${aws_instance.k8s_master.public_ip} "kubeadm token create --print-join-command")
              $KUBE_JOIN_COMMAND
              EOF
}
