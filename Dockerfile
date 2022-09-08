# https://nodejs.org/en/about/releases/
# https://github.com/nodejs/Release#readme
FROM node:18-alpine3.16

WORKDIR /app/mongo-express

RUN apk -U add --no-cache bash tini

EXPOSE 8081

# override some config defaults with values that will work better for docker
ENV ME_CONFIG_EDITORTHEME="default" \
    ME_CONFIG_MONGODB_URL="mongodb://mongo:27017" \
    ME_CONFIG_MONGODB_ENABLE_ADMIN="true" \
    ME_CONFIG_BASICAUTH_USERNAME="" \
    ME_CONFIG_BASICAUTH_PASSWORD="" \
    VCAP_APP_HOST="0.0.0.0"

ENV MONGO_EXPRESS git+https://github.com/mongo-express/mongo-express.git#master

RUN set -eux; \
	apk -U add --no-cache --virtual .me-install-deps git;

RUN npm i mongo-express@$MONGO_EXPRESS; 

RUN apk del --no-network .me-install-deps

COPY docker-entrypoint.sh /

RUN cp /app/mongo-express/node_modules/mongo-express/config.default.js /app/mongo-express/node_modules/mongo-express/config.js

ENTRYPOINT [ "tini", "--", "/docker-entrypoint.sh"]
CMD ["mongo-express"]
