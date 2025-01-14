# Base stage
FROM node:latest AS base
WORKDIR /app

# Install stage
FROM base AS install
COPY package.json ./
RUN npm install

# Prerelease stage
FROM base AS prerelease
COPY --from=install /app/node_modules ./node_modules
COPY . . 
ENV NODE_ENV=production
RUN npm run build

# Stage 2: Serve the static files with Nginx
FROM nginx:alpine as runner
# Copy a custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf
# Copy the built static files from the build stage
COPY --from=prerelease /app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
