# Cloud Recognition Application

A mobile application for real-time cloud type classification using on-device machine learning inference, built with Flutter.

## 📱 Overview

This is a **final year project** that demonstrates:
- Real-time cloud image classification on mobile devices
- Local TensorFlow Lite runtime inference (no internet required)
- User-friendly interface with camera integration

## ✨ Features

- **Real-time Classification**: Classify cloud types instantly using your device camera
- **Local Inference**: Process images on-device with TensorFlow Lite and ONNX Runtime
- **Offline Capability**: No internet connection required for inference
- **Camera Integration**: Direct camera access for quick classification
- **Image Processing**: Crop and enhance images before classification
- **Persistent Storage**: Hive database for classification history and local storage
- **Multi-language Support**: English, Malay, Chinese

## 🛠️ Tech Stack

| Component | Technology |
|-----------|-----------|
| **Language** | Dart|
| **Framework** | Flutter |
| **ML Inference** | TensorFlow Lite |
| **Storage** | Hive |
| **UI Components** | Material Design |

## 📋 Requirements

- Flutter SDK: 3.5.2 or higher
- Android SDK 21+
- TensorFlow Lite model file (*.tflite)

## 🚀 Getting Started

### Prerequisites

```bash
# Ensure Flutter is installed
flutter --version

# Update dependencies
flutter pub get
```

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/LiZe-chai/cloud-recognition-application.git
cd cloud-recognition-application
```

2. **Download ML Model**
   - Download the TensorFlow Lite model from: [Cloud Drive Link](https://sotonac-my.sharepoint.com/:f:/g/personal/lzc1e23_soton_ac_uk/IgD9Qtn9GTaYTpAYkqF5QW0tAf-9AKSG7_Oxkl6uLkWHomI?e=viEgm8)
   - Place it in: `assets/models/cloud_classification_model.tflite`

3. **Install dependencies**
```bash
flutter pub get
```

4. **Generate code**
```bash
flutter pub run build_runner build
```

5. **Run the application**
```bash
flutter run
```

## 📥 Download APK

### For End Users
- **Direct Download**: [app-release.apk](https://sotonac-my.sharepoint.com/:u:/g/personal/lzc1e23_soton_ac_uk/IQAwYmyBxnvgQJxiJaao9gwXAZ1n8K84mWV3hPmW0qBRmb8?e=3MBaTu)

### Installation Instructions
1. Enable "Install from Unknown Sources" in Android Settings
2. Download the APK file
3. Tap the file to install
