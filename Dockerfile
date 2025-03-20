### Stage 1: Build React App ###
FROM node:20 AS builder

WORKDIR /app

# Copy entire app folder (including package.json and package-lock.json)
COPY app/ .

# Install dependencies
RUN npm install --no-progress --prefer-offline

# Build React app
RUN npm run build


### Stage 2: Serve with Nginx ###
FROM nginx:latest AS runner

# Set working directory
WORKDIR /usr/share/nginx/html

# Remove default Nginx static files
RUN rm -rf ./*

# Copy built files from builder stage
COPY --from=builder /app/build .

# Copy Nginx configuration file
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
