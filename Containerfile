FROM registry.access.redhat.com/ubi9/go-toolset:1.21 as build
WORKDIR /app
COPY ./api api
COPY ./cmd cmd
COPY ./deploy deploy
COPY ./hack hack
COPY ./internal internal
COPY ./go.* .
COPY ./pkg pkg
COPY ./test test
COPY ./Makefile .

USER 0
RUN make build

FROM registry.access.redhat.com/ubi9/ubi-minimal as certs
RUN microdnf update --nodocs -y  && microdnf install ca-certificates --nodocs -y

FROM registry.access.redhat.com/ubi9/ubi-micro
WORKDIR /app
COPY --from=build /app/bin/flightctl-server .
COPY --from=certs /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem /etc/pki/ca-trust/extracted/pem/

CMD ./flightctl-server
