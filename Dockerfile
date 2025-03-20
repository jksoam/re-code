# Stage 1: Build dependencies layer
FROM node:20 AS builder

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json first (for caching)
COPY package.json package-lock.json ./

# Install dependencies using npm ci (safer & faster)
RUN npm ci --no-progress --prefer-offline

# Copy rest of the app
COPY . .

# Build (if applicable, like React/Vue/Next.js apps)
RUN npm run build

# Stage 2: Create lightweight production container
FROM node:20-alpine AS runner

WORKDIR /app

# Copy only necessary files from builder stage
COPY --from=builder /app /app

# Expose port 80 for production
EXPOSE 80

# Run the application
CMD ["node", "server.js"]
