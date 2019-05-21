FROM circleci/node:10-browsers

USER root

# Reduce excessive npm logs
ENV NPM_CONFIG_LOGLEVEL error
# https://gist.github.com/ralphtheninja/f7c45bdee00784b41fed
ENV JOBS max

ENV WORKDIR /app
WORKDIR $WORKDIR

# Point node to where the modules are for custom tests location
ENV NODE_PATH $WORKDIR/node_modules

# Copy in package/lock explicitly to allow caching of modules
COPY package.json $WORKDIR
COPY package-lock.json $WORKDIR
RUN npm install --production

COPY . $WORKDIR

USER circleci

# start xvfb automatically, local-only access
ENV DISPLAY :99
RUN printf '#!/bin/sh\nXvfb :99 -screen 0 1280x1024x24 -ac -nolisten tcp -nolisten unix &\nexec node ./bin/run.js "$@"\n' > /tmp/entrypoint \
  && chmod +x /tmp/entrypoint \
  && sudo mv /tmp/entrypoint /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "tests/**/*.js" ]
