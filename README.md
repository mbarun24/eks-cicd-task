# AWS EKS Product Catalog | End-to-End DevOps CI/CD Project

A cloud-native DevOps project demonstrating infrastructure provisioning, containerization, automated CI/CD deployment, Kubernetes orchestration, monitoring, autoscaling, and application rollback on Amazon Web Services (AWS).

## Project Overview

This project deploys a Python Flask-based Product Catalog REST API on Amazon EKS using Docker, Amazon ECR, Kubernetes, and AWS Application Load Balancer.

Infrastructure is provisioned using Terraform, while GitHub Actions automates the Docker image build, push, and application deployment process.

A Jenkins Declarative Pipeline (Groovy) is also provided as an alternative CI/CD implementation.

## Technology Stack

| Category | Technologies |
|---|---|
| Cloud Platform | AWS |
| Infrastructure as Code | Terraform |
| Containerization | Docker |
| Container Registry | Amazon ECR |
| Container Orchestration | Amazon EKS, Kubernetes |
| CI/CD | GitHub Actions, Jenkins (alternative) |
| Application | Python, Flask, Gunicorn |
| Load Balancing | AWS Application Load Balancer |
| Autoscaling | Kubernetes HPA |
| Monitoring | Amazon CloudWatch, Container Insights |
| Infrastructure Access | AWS CLI, kubectl |
| Source Control | Git, GitHub |

## Architecture

```text
Developer
    |
    v
GitHub Repository
    |
    v
GitHub Actions CI/CD
    |
    +--> Build Docker Image
    |
    +--> Push Image to Amazon ECR
    |
    +--> Update Kubernetes Deployment
                     |
                     v
                Amazon EKS
                     |
              AWS ALB Ingress
                     |
              Kubernetes Service
                     |
              Product Catalog Pods
                 (3 Replicas)
                     |
               Flask REST API

Monitoring:
CloudWatch + Container Insights

Autoscaling:
HPA (Min: 3, Max: 6)
```

## AWS Infrastructure

The infrastructure was provisioned using Terraform in the AWS `ap-southeast-2` region.

The architecture includes:

- Custom VPC with CIDR `10.0.0.0/16`
- Two public and two private subnets
- Internet Gateway and NAT Gateway
- Amazon EKS cluster with managed worker nodes
- Amazon ECR repository
- AWS Load Balancer Controller
- Kubernetes Metrics Server
- CloudWatch Observability Add-on
- IAM roles and policies

The EKS worker nodes were deployed in private subnets.

## Application Details

The Product Catalog API is a Python Flask application running on port `5000`.

### API Endpoints

| Endpoint | Method | Description |
|---|---|---|
| `/` | GET | Application information and version |
| `/products` | GET | Product catalog data |
| `/health` | GET | Application health |
| `/ready` | GET | Application readiness |

Example application response:

```json
{
  "application": "Product Catalog API",
  "status": "running",
  "version": "1.0"
}
```

## Project Structure

```text
eks-cicd-task/
|
+-- app/
|   +-- app.py
|   +-- requirements.txt
|   +-- Dockerfile
|
+-- terraform/
|   +-- Terraform configuration files
|
+-- k8s/
|   +-- Kubernetes Deployment and Service manifests
|   +-- alb.ingress.yaml
|   +-- hpa.yaml
|
+-- .github/
|   +-- workflows/
|       +-- deploy.yml
|
+-- README.md
```

## Step 1 — Provision Infrastructure with Terraform

```bash
cd terraform

terraform init
terraform validate
terraform plan
terraform apply
```

Terraform provisions the AWS networking infrastructure, EKS cluster, worker nodes, IAM resources, and supporting components.

## Step 2 — Configure EKS Access

```bash
aws eks update-kubeconfig \
  --region ap-southeast-2 \
  --name product-catalog-eks
```

Verify the worker nodes:

```bash
kubectl get nodes
```

## Step 3 — Build Docker Image

```bash
docker build -t product-catalog:v1 ./app
```

## Step 4 — Push Docker Image to Amazon ECR

Authenticate Docker with ECR:

```bash
aws ecr get-login-password \
  --region ap-southeast-2 |
docker login \
  --username AWS \
  --password-stdin \
  245716172720.dkr.ecr.ap-southeast-2.amazonaws.com
```

Tag the Docker image:

```bash
docker tag product-catalog:v1 \
  245716172720.dkr.ecr.ap-southeast-2.amazonaws.com/product-catalog:v1
```

Push the image:

```bash
docker push \
  245716172720.dkr.ecr.ap-southeast-2.amazonaws.com/product-catalog:v1
```

## Step 5 — Deploy Application to Kubernetes

Create the application namespace:

```bash
kubectl create namespace product-catalog
```

Apply the Kubernetes Deployment and Service manifests from the `k8s/` directory.

Verify:

```bash
kubectl get deployments -n product-catalog

kubectl get pods -n product-catalog

kubectl get svc -n product-catalog
```

The application was configured with three replicas, readiness probes, liveness probes, and CPU/memory resource requests and limits.

## Step 6 — Configure AWS ALB Ingress

The AWS Load Balancer Controller provisions an internet-facing Application Load Balancer for the Kubernetes Ingress.

```bash
kubectl apply -f k8s/alb.ingress.yaml
```

Verify:

```bash
kubectl get ingress -n product-catalog
```

The ALB routes incoming requests to the Kubernetes Service and application Pods.

## Step 7 — Configure Horizontal Pod Autoscaling

The application uses Kubernetes HPA with the following configuration:

| Parameter | Value |
|---|---|
| Minimum Replicas | 3 |
| Maximum Replicas | 6 |
| Target CPU Utilization | 60% |

Verify:

```bash
kubectl get hpa -n product-catalog

kubectl top pods -n product-catalog
```

The HPA configuration and CPU metrics were verified. A full scale-out load test was not performed.

## Step 8 — Implement CI/CD with GitHub Actions

The GitHub Actions workflow is defined in:

`.github/workflows/deploy.yml`

The pipeline performs:

1. Checkout source code
2. Configure AWS authentication
3. Authenticate with Amazon ECR
4. Build Docker image
5. Push image to ECR using the Git commit SHA
6. Configure EKS access
7. Update Kubernetes Deployment
8. Verify rollout status

The pipeline triggers on pushes to the `main` branch and supports manual execution.

### Jenkins CI/CD Alternative

A Jenkins Declarative Pipeline written in Groovy can perform the same build, push, and deployment stages.

Jenkins is an alternative implementation; the verified automated deployment in this project used GitHub Actions.

## Step 9 — Monitoring and Observability

Amazon CloudWatch Observability and Container Insights were configured for the EKS cluster.

Monitoring included:

- Kubernetes application logs
- Node and Pod resource metrics
- CPU utilization
- Memory utilization metric discovery
- CloudWatch Container Insights log groups

Useful commands:

```bash
kubectl top pods -n product-catalog

kubectl get pods -n product-catalog

kubectl logs deployment/product-catalog \
  -n product-catalog
```

## Step 10 — Rolling Deployment and Rollback

The application was updated from version `1.0` to `2.0` through the CI/CD workflow.

Kubernetes performed a rolling update.

Deployment history can be inspected using:

```bash
kubectl rollout history \
  deployment/product-catalog \
  -n product-catalog
```

The application was successfully rolled back to the earlier revision:

```bash
kubectl rollout undo \
  deployment/product-catalog \
  -n product-catalog \
  --to-revision=2
```

Verify:

```bash
kubectl rollout status \
  deployment/product-catalog \
  -n product-catalog
```

The ALB endpoint returned application version `1.0` after rollback, confirming successful end-to-end recovery.

## Project Validation

The following checks were completed during the hands-on implementation:

| Validation | Result |
|---|---|
| EKS Worker Nodes | 2/2 Ready |
| Kubernetes Deployment | 3/3 Available |
| Application Pods | 3/3 Running |
| Pod Restarts | 0 |
| ALB API Access | Verified |
| GitHub Actions Deployment | Successful |
| CloudWatch Logs | Verified |
| HPA Configuration | Verified |
| Kubernetes Rollback | Successful |

These results describe the completed lab validation, not continuous production availability guarantees.

## Key Learnings

- Provisioning AWS infrastructure using Terraform
- Deploying containerized Python applications to EKS
- Implementing automated CI/CD pipelines
- Managing container images in Amazon ECR
- Configuring ALB Ingress routing
- Implementing Kubernetes health probes
- Configuring HPA and monitoring resource utilization
- Collecting application logs with CloudWatch
- Performing rolling deployments and Kubernetes rollback
- Managing AWS infrastructure lifecycle and cleanup

## Security Considerations

- EKS worker nodes are placed in private subnets.
- IAM permissions control AWS and Kubernetes access.
- Application containers run with configured resource limits.
- CI/CD credentials must be managed securely.
- Long-lived AWS access keys should be avoided in production; OIDC or IAM roles are preferred.
- No AWS secrets should be committed to the repository.

## Cost Management

This project uses AWS resources that can incur charges, including EKS, EC2 worker nodes, NAT Gateway, and Application Load Balancer.

After completing the lab, remove the Kubernetes-managed ALB and associated resources before destroying Terraform-managed infrastructure.

Always review the Terraform destroy plan before execution.

```bash
terraform plan -destroy
terraform destroy
```

Never run `terraform apply` as a substitute for `terraform destroy`.

## Conclusion

This project demonstrates an end-to-end AWS DevOps workflow covering infrastructure automation, containerization, Kubernetes orchestration, CI/CD, observability, autoscaling configuration, and rollback.

It provides practical hands-on experience relevant to DevOps Engineer, Cloud Engineer, and Site Reliability Engineer roles.
