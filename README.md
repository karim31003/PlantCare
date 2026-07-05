# 🌿 PlantCare

<div align="center">

![PlantCare Banner](https://img.shields.io/badge/PlantCare-AI%20Disease%20Detection-2d6a4f?style=for-the-badge&logo=leaf&logoColor=white)

[![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=flat-square&logo=python&logoColor=white)](https://python.org)
[![Flask](https://img.shields.io/badge/Flask-REST%20API-000000?style=flat-square&logo=flask&logoColor=white)](https://flask.palletsprojects.com)
[![Flutter](https://img.shields.io/badge/Flutter-Mobile%20App-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![PyTorch](https://img.shields.io/badge/PyTorch-EfficientNet--B0-EE4C2C?style=flat-square&logo=pytorch&logoColor=white)](https://pytorch.org)
[![YOLOv8](https://img.shields.io/badge/YOLOv8-Detection-00FFFF?style=flat-square&logo=yolo&logoColor=black)](https://ultralytics.com)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?style=flat-square&logo=supabase&logoColor=white)](https://supabase.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](LICENSE)

**An AI-powered plant disease detection system using a two-stage deep learning pipeline.**  
Point your camera at a leaf — get an instant diagnosis.

[Features](#features) · [Architecture](#architecture) · [Supported Crops](#supported-crops) · [Installation](#installation) · [API Reference](#api-reference) · [Flutter App](#flutter-app)

</div>

---

## Overview

PlantCare combines a YOLOv8 plant species classifier with per-crop EfficientNet-B0 disease models to deliver accurate, fast disease diagnosis from a single leaf photo. The Flutter mobile app communicates with a Flask REST API, and scan history is persisted in Supabase with Google OAuth authentication.

---

## Features

- 🔍 **Two-stage pipeline** — YOLOv8 detects the plant species, then a dedicated EfficientNet-B0 model classifies the disease
- 🌾 **7 supported crops** — Tomato, Potato, Apple, Soybean, Cucumber, Mango ,Lemon
- 📱 **Flutter mobile app** — Full UI with camera integration and scan history
- ⚡ **Flask REST API** — Lightweight backend with lazy-loaded models
- 🗄️ **Supabase backend** — Scan history, user profiles, and real-time sync
- 🔐 **Google OAuth** — One-tap sign-in via Google
- 🧠 **Per-crop models** — Each crop has its own trained `.pt` model for maximum accuracy

---

## Architecture

```
📱 Flutter App
      │
      │  POST /predict (image)
      ▼
🌐 Flask REST API
      │
      ├─── Stage 1: YOLOv8 (best.pt)
      │         Detects plant species from leaf image
      │
      └─── Stage 2: EfficientNet-B0 (per-crop .pt)
                Classifies disease for detected species
                      │
                      ▼
              📊 Prediction Result
              { species, disease, confidence }
                      │
                      ▼
              🗄️ Supabase
              Saves scan to history
```

---

## Supported Crops

| Crop | Model File | Classes |
|------|-----------|---------|
| 🍅 Tomato | `tomato_efficientnet.pt` | 11 (Bacterial Spot, Early Blight, Late Blight, Leaf Mold, Septoria Leaf Spot, Spider Mites, Target Spot, Yellow Leaf Curl Virus, Mosaic Virus, Healthy, …) |
| 🥔 Potato | `potato_efficientnet.pt` | 7 (Early Blight, Late Blight, Black Scurf, Common Scab, Healthy, …) |
| 🍎 Apple | `apple_efficientnet.pt` | 9 (Apple Scab, Black Rot, Cedar Rust, Sooty Blotch, Fly Speck, Healthy, …) |
| 🌿 Soybean | `soybean_efficientnet.pt` | 5 (Bacterial Pustule, Frogeye Leaf Spot, Sudden Death Syndrome, Healthy, …) |
| 🥒 Cucumber | `cucumber_efficientnet.pt` | 8 (Downy Mildew, Powdery Mildew, Angular Leaf Spot, Anthracnose, Healthy, …) |
| 🥭 Mango | `mango_efficientnet.pt` | TBD |

---

## Project Structure

```
PlantCare/
├── API/
│   └── app.py                  # Flask REST API with lazy model loading
├── Classifier/
│   ├── models/
│   │   ├── tomato_efficientnet.pt
│   │   ├── potato_efficientnet.pt
│   │   ├── apple_efficientnet.pt
│   │   ├── soybean_efficientnet.pt
│   │   ├── cucumber_efficientnet.pt
│   │   └── mango_efficientnet.pt
│   └── predict.py              # Inference logic for EfficientNet models
├── YOLO/
│   └── best.pt                 # YOLOv8 plant species detection model
├── FlutterApp/
│   ├── lib/
│   │   ├── main.dart
│   │   ├── screens/
│   │   ├── services/
│   │   └── models/
│   └── pubspec.yaml
├── requirements.txt
├── .env.example
├── LICENSE
└── README.md
```

---

## Installation

### Prerequisites

- Python 3.10+
- Flutter 3.x
- Git

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/PlantCare.git
cd PlantCare
```

### 2. Set Up the Python Environment

```bash
python -m venv venv
source venv/bin/activate      # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 3. Configure Environment Variables

```bash
cp .env.example .env
```

Edit `.env` with your credentials:

```env
# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-anon-key

# Google OAuth
GOOGLE_CLIENT_ID=your-client-id
GOOGLE_CLIENT_SECRET=your-client-secret

# Model paths
MODEL_DIR=./Classifier/models
YOLO_MODEL=./YOLO/best.pt

# API
FLASK_PORT=5000
CONFIDENCE_THRESHOLD=0.6
```

### 4. Run the Flask API

```bash
cd API
python app.py
```

The API will be available at `http://localhost:5000`.

### 5. Run the Flutter App

```bash
cd FlutterApp
flutter pub get
flutter run
```

> **Note:** Update the `baseUrl` in `FlutterApp/lib/services/api_service.dart` to point to your Flask API address.

---

## API Reference

### `POST /predict`

Analyzes a leaf image and returns species + disease prediction.

**Request**

```http
POST /predict
Content-Type: multipart/form-data

image: <leaf image file>
```

**Response**

```json
{
  "species": "tomato",
  "disease": "Early Blight",
  "confidence": 0.94,
  "healthy": false,
  "model_used": "tomato_efficientnet.pt"
}
```

**Error Response**

```json
{
  "error": "Species not supported",
  "detected_species": "wheat",
  "supported": ["tomato", "potato", "apple", "soybean", "cucumber", "mango"]
}
```

---

### `GET /health`

Health check endpoint.

**Response**

```json
{
  "status": "ok",
  "models_loaded": ["tomato", "potato"],
  "yolo": "ready"
}
```

---

### `GET /crops`

Returns the list of supported crops and their disease classes.

**Response**

```json
{
  "supported_crops": ["tomato", "potato", "apple", "soybean", "cucumber", "mango"],
  "classes": {
    "tomato": ["Bacterial Spot", "Early Blight", "..."],
    "potato": ["Early Blight", "Late Blight", "..."]
  }
}
```

---

## Flutter App

The Flutter mobile app provides a full end-to-end experience:

| Screen | Description |
|--------|-------------|
| **Home** | Dashboard with recent scans and quick-scan button |
| **Camera / Gallery** | Capture or select a leaf image |
| **Result** | Disease name, confidence score, and treatment tips |
| **History** | Past scans synced from Supabase |
| **Profile** | Google OAuth sign-in and account settings |

---

## Supabase Schema

```sql
-- Users (managed by Supabase Auth + Google OAuth)

-- Scans table
create table scans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id),
  species text not null,
  disease text not null,
  confidence float not null,
  image_url text,
  created_at timestamp default now()
);

-- Enable Row Level Security
alter table scans enable row level security;
create policy "Users see own scans" on scans
  for select using (auth.uid() = user_id);
```

---

## Model Training

Each disease classifier was trained using:

- **Architecture:** EfficientNet-B0 (pretrained on ImageNet)
- **Training strategy:** Two-phase transfer learning (frozen backbone → full fine-tune)
- **Optimizer:** AdamW with cosine LR schedule
- **Class imbalance:** WeightedRandomSampler
- **Regularization:** Label smoothing, dropout, early stopping
- **Framework:** PyTorch

Training notebooks are available in the `Classifier/notebooks/` directory (Google Colab compatible).

---

## Requirements

```txt
flask>=2.3
torch>=2.0
torchvision>=0.15
ultralytics>=8.0
pillow>=10.0
supabase>=2.0
python-dotenv>=1.0
```

---

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/new-crop`)
3. Commit your changes (`git commit -m 'Add grape disease model'`)
4. Push to the branch (`git push origin feature/new-crop`)
5. Open a Pull Request

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## Acknowledgements

- [Ultralytics YOLOv8](https://github.com/ultralytics/ultralytics) — plant detection backbone
- [EfficientNet](https://arxiv.org/abs/1905.11946) — disease classification backbone
- [PlantVillage Dataset](https://plantvillage.psu.edu/) — training data
- [Supabase](https://supabase.com) — open-source backend
- [Flutter](https://flutter.dev) — cross-platform mobile framework

---

<div align="center">
Made with 🌱 by Karim
</div>
