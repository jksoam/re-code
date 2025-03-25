# Stage 1: Build React/Next.js app
FROM node:20

# Set working directory
WORKDIR /app

# Copy rest of the app
COPY . .

# Build the application
RUN npm istall && npm run build  # This will work if "build" script is in package.json

RUN apt update && nginx install -y

# Copy build output from builder stage
COPY ./build/* /var/www/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
