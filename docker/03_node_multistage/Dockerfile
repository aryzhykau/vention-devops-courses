# Stage 1: Build React frontend
FROM node:18 AS frontend

WORKDIR /app
COPY client ./client
RUN cd client && npm install && npm run build

# Stage 2: Run backend with static frontend
FROM node:18-alpine

WORKDIR /app

# Copy backend and install dependencies
COPY server ./server
RUN cd server && npm install --only=production

# Copy built frontend from previous stage
COPY --from=frontend /app/client/build ./client/build

EXPOSE 3000

CMD ["node", "server/index.js"]
