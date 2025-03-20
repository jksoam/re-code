# Stage 1: Build React/Next.js app
FROM node:20 AS builder

# Set working directory
WORKDIR /app

# Copy package files first for caching
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci --no-progress --prefer-offline

# Copy rest of the app
COPY . .

# Build the application
RUN npm run build

# Stage 2: Serve using Nginx
FROM nginx:latest AS runner

# Set working directory
WORKDIR /usr/share/nginx/html

# Remove default Nginx HTML files
RUN rm -rf ./*

# Copy build output from builder stage
COPY --from=builder /app/build ./

# Copy custom Nginx configuration (optional)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
