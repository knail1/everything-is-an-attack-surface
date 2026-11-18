# Reverse-shell listener — GNU ncat (nmap-ncat), replacing the fragile macOS BSD nc.
# `ncat -lvk 4444` listens verbosely and KEEPS the port open across reconnects, so it
# catches a shell from each demo act. Caught shells appear in `docker logs demo-listener`;
# type into one with `docker attach demo-listener` (detach with Ctrl-P Ctrl-Q).
FROM alpine:3.20
RUN apk add --no-cache nmap-ncat
EXPOSE 4444
CMD ["ncat", "-lvk", "4444"]
