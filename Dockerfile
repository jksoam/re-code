# Stage 1: Build React Application
FROM node:23 as build

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .

# Build the React application
RUN npm run build

# Stage 2: Serve with NGINX
FROM nginx:alpine

# Copy build files to NGINX html directory
COPY --from=build /app/build /usr/share/nginx/html

# Copy custom NGINX config (optional but recommended)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]
