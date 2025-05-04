# Build stage
FROM node:20-alpine3.19 AS build
WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci

# Copy app code and build
COPY . .
RUN npm run build

# Production stage
FROM nginx:1.25.4-alpine AS production
RUN apk update && apk upgrade --no-cache

# Copy build artifacts to nginx
COPY --from=build /app/dist /usr/share/nginx/html

# Optional: Add custom nginx config if needed
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose and healthcheck
EXPOSE 80
HEALTHCHECK CMD wget --no-verbose --spider http://localhost || exit 1

CMD ["nginx", "-g", "daemon off;"]
