# Rice Disease Detection System

A deep learning system to detect and classify rice leaf diseases using CNN and TensorFlow.

## Features

- **4 Disease Classes**: Bacterial Blight, Blast, Brown Spot, Tungro
- **96.8% Accuracy** with custom CNN architecture
- **Web Interface** for image upload and predictions
- **Treatment Recommendations** for each disease
- **5,932 Training Images** (balanced dataset)

## Installation

```bash
pip install -r requirements.txt
```

## Usage

### 1. Train the Model
```bash
jupyter notebook rice_disease_detection.ipynb
```

### 2. Run the Web App
Open `website/index.html` in your browser.

## Project Structure

```
├── app.py                           # Flask backend
├── rice_disease_detection.ipynb    # Model training
├── models/                         # Trained models
├── website/                        # Web interface
│   ├── index.html
│   ├── style.css
│   └── script.js
└── README.md
```

## Model Details

- **Architecture**: Custom CNN with 4 convolutional blocks
- **Input**: 224×224×3 RGB images
- **Optimizer**: Adam (lr=0.001)
- **Epochs**: 50 (with early stopping)

## Performance

| Disease          | Accuracy |
|------------------|----------|
| Bacterial Blight | 97.2%    |
| Blast            | 95.4%    |
| Brown Spot       | 97.8%    |
| Tungro           | 95.6%    |

## Built With

- TensorFlow & Keras
- Flask
- HTML/CSS/JavaScript
- Python

---

**Status**: Ready for use
