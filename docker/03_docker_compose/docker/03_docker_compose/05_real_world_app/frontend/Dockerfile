# Use a lightweight Node.js image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy everything to container
COPY . .

# Install dependencies
RUN npm install

# Build the frontend app
RUN npm run build

# Expose port (optional, useful for dev, usually not needed in prod build container)
EXPOSE 3000

# Start app (use serve for static files if build folder is created)
RUN npm install -g serve
CMD ["serve", "-s", "build", "-l", "3000"]
