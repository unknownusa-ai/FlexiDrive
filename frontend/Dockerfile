FROM ghcr.io/cirruslabs/flutter:stable

WORKDIR /app

# Enable Flutter web support once in the container image.
RUN flutter config --enable-web

EXPOSE 3000

CMD ["sh", "-c", "flutter pub get && flutter run -d web-server --web-hostname 0.0.0.0 --web-port 3000"]
