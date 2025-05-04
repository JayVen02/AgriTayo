FROM ghcr.io/cirruslabs/flutter:latest AS builder

WORKDIR /app

COPY pubspec*.yaml ./
RUN flutter pub get

COPY . .
RUN flutter build apk --release

FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/build/app/outputs/apk/release/app-release.apk .

CMD ["sh", "-c", "echo 'Built APK is inside /app/app-release.apk'"]