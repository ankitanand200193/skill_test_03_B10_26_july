# 🛠️ Terraform Mongo Backend Deployment with Docker

This project provisions infrastructure on AWS using Terraform and deploys a backend application (Node.js or Python) that connects to a MongoDB database (MongoDB Atlas).

## 🏗️ Architecture Overview

This application demonstrates modern microservices architecture with the following components:

```
Frontend (React) → API Gateway → Microservices
                                    ├── User Service (3001)
                                    ├── Product Service (3002)
                                    ├── Cart Service (3003)
                                    └── Order Service (3004)

```
```bash
.

├── backend
├── frontend                  # Application code
├── terraform/              # Terraform configuration files
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf                   
└── README.md
```


## 🔧 Technology Stack



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

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd ecommerce-microservices
```


## 🚀 Deployment Steps

### 1️⃣ Build Docker Image (Locally or CI)

```bash
docker build -t ./backend/user-service:latest .
```

---

### 2️⃣ Provision AWS Infrastructure with Terraform

```bash
cd terraform
terraform init
terraform apply
```

> Confirm with `yes` when prompted.

Terraform provisions:

* VPC, subnets
* Security groups
* EC2 instance with Docker
* User-defined outputs

---

### 3️⃣ SSH into EC2 and Run Docker Container

```bash
ssh -i <your-key.pem> ec2-user@<public-ip>
```

Then on the EC2 instance:

```bash
docker run -d --rm -p 3001:3001 -e PORT=3001 -e MONGODB_URI=yourmongo-db/ecommerce_users ankit200193/user-service:latest

docker run -d --rm -p 3002:3002 -e PORT=3002 -e MONGODB_URI=yourmongo-db/ecommerce_products ankit200193/product-service:latest
docker run -d --rm -p 3003:3003 -e PORT=3003 -e MONGODB_URI=yourmongo-db/ecommerce_carts -e PRODUCT_SERVICE_URL=http://13.202.94.86:3002 ankit200193/cart-service:latest

docker run -d --rm -p 3004:3004 -e PORT=3004 -e MONGODB_URI=yourmongo-db/ecommerce_orders -e CART_SERVICE_URL=http://13.202.94.86:3003 -e PRODUCT_SERVICE_URL=http://13.202.94.86:3002 -e USER_SERVICE_URL=http://13.202.94.86:3001 ankit200193/order-service:latest

docker run -d --rm -p 3000:3000 -e PORT=3000 -e REACT_APP_USER_SERVICE_URL=http://13.202.94.86:3001 -e REACT_APP_PRODUCT_SERVICE_URL=http://13.202.94.86:3002 -e REACT_APP_CART_SERVICE_URL=http://13.202.94.86:3003 -e REACT_APP_ORDER_SERVICE_URL=http://13.202.94.86:3004 ankit200193/frontend:latest

```

---

## 🔄 Destroy Infrastructure

```bash
cd terraform
terraform destroy
```

> Type `yes` to confirm deletion of all AWS resources.

---



## Environement requirements :

**backend/user-service/.env:**
```env
PORT=3001
MONGODB_URI=yourmongo-db/ecommerce_users
```


**backend/product-service/.env:**
```env
PORT=3002
MONGODB_URI=yourmongo-db/ecommerce_products
```

**backend/cart-service/.env:**
```env
PORT=3003
MONGODB_URI=yourmongo-db/ecommerce_carts
PRODUCT_SERVICE_URL=http://EC2_IP:3002
```

**backend/order-service/.env:**
```env
PORT=3004
MONGODB_URI=yourmongo-db/ecommerce_orders
CART_SERVICE_URL=http://EC2_IP:3003
PRODUCT_SERVICE_URL=http://EC2_IP:3002
USER_SERVICE_URL=http://EC2_IP:3001
```

**frontend/.env:**
```env
REACT_APP_USER_SERVICE_URL=http://EC2_IP:3001
REACT_APP_PRODUCT_SERVICE_URL=http://EC2_IP:3002
REACT_APP_CART_SERVICE_URL=http://EC2_IP:3003
REACT_APP_ORDER_SERVICE_URL=http://EC2_IP:3004
```

## 🔧 API Testing

You can test the APIs using tools like Postman or curl:

```bash
# Health check for all services
curl http://EC2_IP:3001/health
curl http://EC2_IP:3002/health
curl http://EC2_IP:3003/health
curl http://EC2_IP:3004/health

