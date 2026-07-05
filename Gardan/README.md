# Gardan

Gardan is a Flutter-based plant care application with Supabase-backed storage and authentication, plus a separate Flask machine-learning service for plant disease detection.

## Project Overview

- `lib/` contains the Flutter app, routing, state management, screens, repositories, and services.
- `Classifier/` contains the Python Flask inference API used by the scan flow.
- Supabase provides authentication, PostgreSQL data storage, realtime order tracking, and file storage.

## Architecture

See the full system architecture in [ARCHITECTURE.md](ARCHITECTURE.md).

## Getting Started

This project uses the standard Flutter workflow.

- Run the Flutter app from the `Gardan/` directory.
- Configure the ML API host through app settings or `--dart-define=FLASK_HOST=...`.
- Start the Flask classifier service separately when you need scan predictions.
