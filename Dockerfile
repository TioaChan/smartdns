FROM ubuntu:latest as smartdns-builder

RUN apt update && apt install -y curl libgtest-dev dnsperf make gcc g++ cmake openssl libssl-dev dnsutils clang libclang-dev

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
ARG MAKE_THREADS=1

COPY . /app
WORKDIR /app
RUN make all -j${MAKE_THREADS} WITH_UI=1

FROM ubuntu:latest
WORKDIR /usr/sbin/
COPY --from=smartdns-builder /app/src/smartdns ./
COPY --from=smartdns-builder /app/etc/smartdns/smartdns.conf /etc/smartdns/
EXPOSE 53/udp
VOLUME ["/etc/smartdns/"]

CMD ["smartdns", "-f", "-x"]