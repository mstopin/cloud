FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json yarn.lock tsconfig.json ./

COPY src ./src

RUN yarn install --frozen-lockfile

RUN yarn build



FROM node:20-alpine AS runtime

WORKDIR /app

ENV NODE_ENV=production

COPY package.json yarn.lock ./

COPY --from=builder /app/dist ./dist

RUN yarn install --prod

CMD ["yarn", "start"]
