#!/bin/bash
set -e
apt-get update -y && apt-get upgrade -y
apt-get install -y ca-certificates curl gnupg unzip lsb-release
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable docker && systemctl start docker
usermod -aG docker ubuntu

# TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
#   -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
# PUBLIC_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
#   http://169.254.169.254/latest/meta-data/public-ipv4)

# echo "My public IP is: $PUBLIC_IP"

# Pull and run all services
docker pull ankit200193/user-service:latest
docker pull ankit200193/product-service:latest
docker pull ankit200193/cart-service:latest
docker pull ankit200193/order-service:latest
docker pull ankit200193/frontend:latest

docker run -d --rm -p 3001:3001 -e PORT=3001 -e MONGODB_URI=mongodb+srv://ankit_200193:dwg2Cb4278nAqAEI@cluster0.ou9e6.mongodb.net/ecommerce_users ankit200193/user-service:latest

docker run -d --rm -p 3002:3002 -e PORT=3002 -e MONGODB_URI=mongodb+srv://ankit_200193:dwg2Cb4278nAqAEI@cluster0.ou9e6.mongodb.net/ecommerce_products ankit200193/product-service:latest

docker run -d --rm -p 3003:3003 -e PORT=3003 -e MONGODB_URI=mongodb+srv://ankit_200193:dwg2Cb4278nAqAEI@cluster0.ou9e6.mongodb.net/ecommerce_carts ankit200193/cart-service:latest

docker run -d --rm -p 3004:3004 -e PORT=3004 -e MONGODB_URI=mongodb+srv://ankit_200193:dwg2Cb4278nAqAEI@cluster0.ou9e6.mongodb.net/ecommerce_orders ankit200193/order-service:latest

docker run -d --rm -p 3000:3000 -e PORT=3000 ankit200193/frontend:latest



# docker run -d --rm -p 3001:3001 -e PORT=3001 -e MONGODB_URI=mongodb+srv://ankit_200193:dwg2Cb4278nAqAEI@cluster0.ou9e6.mongodb.net/ecommerce_users ankit200193/user-service:latest

# docker run -d --rm -p 3002:3002 -e PORT=3002 -e MONGODB_URI=mongodb+srv://ankit_200193:dwg2Cb4278nAqAEI@cluster0.ou9e6.mongodb.net/ecommerce_products ankit200193/product-service:latest

# docker run -d --rm -p 3003:3003 -e PORT=3003 -e MONGODB_URI=mongodb+srv://ankit_200193:dwg2Cb4278nAqAEI@cluster0.ou9e6.mongodb.net/ecommerce_carts -e PRODUCT_SERVICE_URL=http://$PUBLIC_IP:3002 ankit200193/cart-service:latest

# docker run -d --rm -p 3004:3004 -e PORT=3004 -e MONGODB_URI=mongodb+srv://ankit_200193:dwg2Cb4278nAqAEI@cluster0.ou9e6.mongodb.net/ecommerce_orders -e CART_SERVICE_URL=http://$PUBLIC_IP:3003 -e PRODUCT_SERVICE_URL=http://$PUBLIC_IP:3002 -e USER_SERVICE_URL=http://$PUBLIC_IP:3001 ankit200193/order-service:latest

# docker run -d --rm -p 3000:3000 -e PORT=3000 -e REACT_APP_USER_SERVICE_URL=http://$PUBLIC_IP:3001 -e REACT_APP_PRODUCT_SERVICE_URL=http://$PUBLIC_IP:3002 -e REACT_APP_CART_SERVICE_URL=http://$PUBLIC_IP:3003 -e REACT_APP_ORDER_SERVICE_URL=http://$PUBLIC_IP:3004 ankit200193/frontend:latest


# To stop all container : docker stop $(docker ps -q)

# mongodb+srv://ankit_200193:dwg2Cb4278nAqAEI@cluster0.ou9e6.mongodb.net/ecommerce_orders

# mongodb+srv://ankit_200193:dwg2Cb4278nAqAEI@cluster0.ou9e6.mongodb.net/ecommerce_carts

# mongodb+srv://ankit_200193:dwg2Cb4278nAqAEI@cluster0.ou9e6.mongodb.net/ecommerce_products

# mongodb+srv://ankit_200193:dwg2Cb4278nAqAEI@cluster0.ou9e6.mongodb.net/ecommerce_users

# **backend/user-service/.env:**
# ```env
# PORT=3001
# MONGODB_URI=mongodb+srv://ankit_200193:dwg2Cb4278nAqAEI@cluster0.ou9e6.mongodb.net/ecommerce_user

# JWT_SECRET=your-jwt-secret-key
# ```


# **backend/product-service/.env:**
# ```env
# PORT=3002
# MONGODB_URI=mongodb+srv://ankit_200193:dwg2Cb4278nAqAEI@cluster0.ou9e6.mongodb.net/ecommerce_products

# ```

# **backend/cart-service/.env:**
# ```env
# PORT=3003
# MONGODB_URI=mongodb+srv://ankit_200193:dwg2Cb4278nAqAEI@cluster0.ou9e6.mongodb.net/ecommerce_carts
# PRODUCT_SERVICE_URL=http://$BACKEND_IP:3002
# ```

# **backend/order-service/.env:**
# ```env
# PORT=3004
# MONGODB_URI=mongodb+srv://ankit_200193:dwg2Cb4278nAqAEI@cluster0.ou9e6.mongodb.net/ecommerce_orders
# CART_SERVICE_URL=http://$BACKEND_IP:3003
# PRODUCT_SERVICE_URL=http://$BACKEND_IP:3002
# USER_SERVICE_URL=http://$BACKEND_IP:3001
# ```

# **frontend/.env:**
# ```env
# REACT_APP_USER_SERVICE_URL=http://$BACKEND_IP:3001
# REACT_APP_PRODUCT_SERVICE_URL=http://$BACKEND_IP:3002
# REACT_APP_CART_SERVICE_URL=http://$BACKEND_IP:3003
# REACT_APP_ORDER_SERVICE_URL=http://$BACKEND_IP:3004

