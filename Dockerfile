# Stage 1: Build React App
FROM node:20 AS builder

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json first
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci --no-progress --prefer-offline

# Copy source code
COPY . .

# Build React app
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:latest AS runner

# Remove default Nginx static files
RUN rm -rf /usr/share/nginx/html/*

# Copy built React files to Nginx HTML directory
COPY --from=builder /app/build /usr/share/nginx/html

# Copy custom Nginx config (Optional)
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
