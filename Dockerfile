#docker buildx build --platform linux/arm64,linux/amd64 --tag wdantuma/signalk-radar-demo:latest --push .
FROM node:20-alpine AS build
RUN apk add --no-cache git make musl-dev go python3 py3-pip g++ libpcap-dev gcc curl perl pkgconf bash openssl-dev openssl-libs-static && \
    curl –proto ‘=https’ –tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y 
ENV PATH="$PATH:/root/.cargo/bin"
WORKDIR /src
RUN git clone https://github.com/SignalK/signalk-server.git && \
    cd signalk-server && \
    npm i && sed -ri 's/ && npm run build:docs//' package.json && \
    npm run build:workspaces && \
    npm run build
RUN git clone --branch radar-support https://github.com/wdantuma/freeboard-sk.git && \
    cd freeboard-sk && \
    sed -ri 's/"declaration"/"skipLibCheck": true,\n"declaration"/' tsconfig.json && \
    npm i && \
    NG_CLI_ANALYTICS=ci npm run build
RUN git clone https://github.com/keesverruijt/mayara.git && \
    cd mayara && \
    . "$HOME/.cargo/env" && \
    cargo build --release
RUN git clone https://github.com/wdantuma/signalk-radar.git && \
    cd signalk-radar/signalk-radar-plugin && \
    npm i && npm run build &&
FROM node:20-alpine
WORKDIR /app
COPY signalk signalk
COPY start.sh .
RUN chmod +x start.sh
COPY --from=build /src/signalk-server /app/signalk-server
COPY --from=build /src/freeboard-sk/public /app/signalk-server/node_modules/@signalk/freeboard-sk/public
COPY --from=build /src/mayara/target/release/mayara-server /app/mayara
RUN cd signalk && \
    npm i @signalk/charts-plugin
COPY --from=build /src/signalk-radar/signalk-radar-plugin /app/signalk/node_modules/signalk-radar-plugin
CMD [ "/app/start.sh"]
