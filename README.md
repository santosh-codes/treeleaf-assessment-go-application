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

## Deploying the Application with Kubernetes on AWS EC2 Instance

The application is deployed on a Kubernetes cluster running on an AWS EC2 instance. Minikube is used to create and manage the Kubernetes cluster.

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
3. **Access the app using http://ec2-public-ip-address:32743**
