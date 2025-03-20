# Stage 1: Build React Application
FROM node:20 AS build

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json separately to leverage Docker cache
COPY package*.json ./

# Install dependencies (safer & better)
RUN npm ci --no-progress --prefer-offline

# Copy the rest of the app source code
COPY . .

# Build the React application
RUN npm run build

# Stage 2: Serve with NGINX
FROM nginx:alpine

# Remove default NGINX static files to prevent conflicts
RUN rm -rf /usr/share/nginx/html/*

# Copy build files to NGINX html directory
COPY --from=build /app/build /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]
