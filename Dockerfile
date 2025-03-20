# Stage 1: Build React/Next.js app
FROM node:20 AS builder

# Set working directory
WORKDIR /home/ubuntu/app  # Set correct directory

# Copy package files first for caching
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci --no-progress --prefer-offline

# Copy rest of the app
COPY . .

# Build the application
RUN npm run build  # This will work if "build" script is in package.json

# Stage 2: Serve using Nginx
FROM nginx:latest AS runner

# Set working directory for nginx
WORKDIR /usr/share/nginx/html

# Remove default Nginx HTML files
RUN rm -rf ./*

# Copy build output from builder stage
COPY --from=builder /home/ubuntu/app/build ./

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
