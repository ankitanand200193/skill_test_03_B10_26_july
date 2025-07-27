# Microservices Deployment with Terraform and Docker on AWS

This project provisions AWS infrastructure using Terraform and deploys five Dockerized microservices (frontend + 4 backend services) on an EC2 instance. The frontend is publicly accessible.

---

#### Terminal results with IP and DNS details

![terminal](Screenshots/terminal_terraform_ec2.png)

---

#### Terminal docker installed view:

![terminal](Screenshots/docker_install.png)

---

#### EC2 on Console

![terminal](Screenshots/ec2_console.png)

---

#### VPC Console View:

![terminal](Screenshots/VPC.png)

---

#### Security Group Console View:

![terminal](Screenshots/security_gp.png)

---

#### Ec2 Subnet Console View:

![terminal](Screenshots/subnet_ec2.png)

---

#### Frotend on Public Access :

![terminal](Screenshots/frontend_public.png)

---

#### Frontend user logged-in :

![terminal](Screenshots/frontend_to_user_service.png)

---

### Frontend talking to products :

![terminal](Screenshots/frontend_to_product_service.png)

---

## Project Structure

```
skill_test_03_B10_26_july/
├── frontend
├── backend
├── Screenshots
├── terraform/                # Terraform configuration
│   ├── main.tf
│   └── outputs.tf
├── README.md                 # This file
```

---

## Architecture

```
Frontend (port 3000)
 └──> User Service     (port 3001)
 └──> Product Service  (port 3002)
 └──> Cart Service     (port 3003)
 └──> Order Service    (port 3004)
```

All services are deployed on a single EC2 instance in the `ap-south-1` region.

---

## Tech Stack

* **Terraform** for infrastructure provisioning
* **AWS EC2** with `t3.medium` instance
* **Docker** for containerized service deployment

---

## Infrastructure Provisioning

### What Terraform Provisions:

* VPC with a public subnet
* Internet Gateway + Route Table
* Security Group allowing:

  * Port `22` for SSH
  * Ports `3000-3004` for app access
* EC2 instance (`t3.medium`) with:

  * Docker installed via `remote-exec` provisioner
  * Docker containers automatically pulled and started

###  Remote Exec Docker Installation

The EC2 instance uses a `remote-exec` provisioner to:

* Install Docker (official Docker APT repository)
* Enable and start Docker
* Pull images from DockerHub
* Run containers for each service

---

##  Usage

### 1. Clone the Repository

```bash
git clone <repository-url>
cd skill_test_03_B10_26_july/terraform
```

---

### 2. Setup PEM File

Ensure your EC2 private key is accessible, e.g.:

```hcl
private_key = file("C:/Users/Ankit Anand/Downloads/AnkitAnandHeroViredB10.pem")
```

#### Docker Command in main.tf

```
"sudo docker run -d --rm -p 3001:3001 -e PORT=3001 -e MONGODB_URI=mongodb+srv://username:password@cluster0.ou9e6.mongodb.net/ecommerce_users ankit200193/user-service:latest"
"sudo docker run -d --rm -p 3002:3002 -e PORT=3002 -e MONGODB_URI=mongodb+srv://username:password@cluster0.ou9e6.mongodb.net/ecommerce_products ankit200193/product-service:latest"
"sudo docker run -d --rm -p 3003:3003 -e PORT=3003 -e MONGODB_URI=mongodb+srv://username:password@cluster0.ou9e6.mongodb.net/ecommerce_carts -e PRODUCT_SERVICE_URL=http://13.234.202.151:3002 ankit200193/cart-service:latest"

"sudo docker run -d --rm -p 3004:3004 -e PORT=3004 -e MONGODB_URI=mongodb+srv://username:password@cluster0.ou9e6.mongodb.net/ecommerce_orders -e CART_SERVICE_URL=http://EC2_IP:3003 -e PRODUCT_SERVICE_URL=http://13.234.202.151:3002 -e USER_SERVICE_URL=http://EC2_IP:3001 ankit200193/order-service:latest"

"sudo docker run -d --rm -p 3000:3000 -e PORT=3000 -e REACT_APP_USER_SERVICE_URL=http://EC2_IP:3001 -e REACT_APP_PRODUCT_SERVICE_URL=http://EC2_IP:3002 -e REACT_APP_CART_SERVICE_URL=http://EC2_IP:3003 -e REACT_APP_ORDER_SERVICE_URL=http://EC2_IP:3004 ankit200193/frontend:latest"

```

---

### 3. Initialize & Apply Terraform

```bash
terraform init
terrafrom validate
terraform apply
```
---

### 4. Outputs

Terraform prints the public IP and public DNS of the EC2 instance. Visit:

```
http://<EC2_PUBLIC_IP>:3000
```
---

## Mongodb_user data ingestion:

1. Ensure the user-service is up and running
2. Use Postman to ingest a data or run the frontend service and register via register button:

User-data endpoint : ```http://ec2_IP:3001/auth/register```

**Sample user date ingested :**
```
 "firstName": "Ankit",
  "lastName": "Anand",
  "email": "ankit.anand@example.com",
  "password": "securePass123",
  "phone": "9876543210",
  "address": {
    "street": "123 Main St",
    "city": "Bangalore",
    "state": "Karnataka",
    "zipCode": "560001",
    "country": "India"
  },
  "role": "customer",
  "isActive": true

```

---

## Cleanup

To destroy all resources:

```bash
terraform destroy -auto-approve
```

---

## Final Notes

* Ensure the `.pem` file has `chmod 400` permissions
* Terraform automatically installs Docker & deploys containers using remote-exec
* EC2 type `t3.medium` is used to handle 5 microservices on a single host

---

## Good to know facts:

#### Why use remote-exec instead of user_data?

user_data runs only once at boot, and debugging is harder when commands silently fail.

remote-exec ensures commands run after the instance is fully initialized, and errors are easier to trace in the Terraform logs.

It also allows more dynamic and flexible execution of provisioning scripts.

#### Why use t3.medium instead of t2.micro?
 
t3.medium provides 2 vCPUs and 4 GB RAM, which is better suited for running multiple Docker containers and services.

t2.micro is limited to 1 vCPU and 1 GB RAM, which may lead to performance issues or failures in deploying and running services.

t3.medium instances support burstable performance and are cost-efficient for small-to-medium Docker workloads.

