FROM wdantuma/signalk-radar-demo:latest AS build

RUN apk add --no-cache git curl bash g++ make perl

WORKDIR /src

RUN curl -sSf https://sh.rustup.rs | bash -s -- -y

ENV PATH="/root/.cargo/bin:${PATH}"

COPY work work
RUN cd work && cargo build --release

FROM wdantuma/signalk-radar-demo:latest

RUN apk add --no-cache tcpreplay curl unzip

WORKDIR /app

COPY start.sh .
RUN chmod +x start.sh
RUN rm -rf mayara || :

COPY --from=build /src/work/target/release/mayara-server /app/mayara

CMD [ "/app/start.sh"]