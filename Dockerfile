# Builder
FROM node:16-alpine AS builder

RUN apk add --no-cache bash

# set working directory
WORKDIR /home/node
USER node

# add `/app/node_modules/.bin` to $PATH
ENV PATH /home/node/node_modules/.bin:$PATH

COPY --chown=node:node package.json ./package.json
COPY --chown=node:node yarn.lock ./yarn.lock


RUN yarn install

COPY --chown=node:node . .

ARG NODE_ENV
ENV NODE_ENV $NODE_ENV

ARG DOC_ENV


RUN yarn run build

# COPY --chown=node ./env-config.sh ./env-config.sh
# RUN chmod +x ./env-config.sh
FROM nginx:stable as production
COPY --from=builder /home/node/build/dev /usr/share/nginx/html
COPY --from=builder /home/node/nginx.conf /etc/nginx/conf.d/default.conf

CMD ["/bin/bash", "-c", "nginx -g \"daemon off;\""]