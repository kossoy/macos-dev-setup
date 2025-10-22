# AI/ML Development Tools

Complete setup for artificial intelligence and machine learning development.

## Prerequisites

- [Python Environment](02-python-environment.md) completed
- At least 8GB RAM

## 1. Core ML Libraries

Already installed if you followed Python setup, but here's the complete list:

```bash
# Install core data science stack
pip install numpy pandas matplotlib seaborn scipy

# Machine learning
pip install scikit-learn

# Deep learning frameworks
pip install tensorflow
pip install torch torchvision torchaudio

# Install all at once
pip install numpy pandas matplotlib seaborn scipy scikit-learn tensorflow torch torchvision torchaudio
```

## 2. Jupyter Lab

Interactive computing environment for data science.

```bash
# Install Jupyter Lab
pip install jupyterlab

# Install extensions
pip install jupyter-contrib-nbextensions jupyterlab-git

# Generate config
jupyter lab --generate-config

# Start Jupyter Lab
jupyter lab

# Opens browser at http://localhost:8888
```

### Jupyter Lab Extensions

```bash
# Install useful extensions
pip install jupyterlab-lsp python-lsp-server
pip install jupyterlab-code-formatter black isort

# Enable extensions
jupyter labextension install @jupyter-widgets/jupyterlab-manager
```

### Jupyter Kernels

```bash
# List available kernels
jupyter kernelspec list

# Install additional kernels
pip install ipykernel
python -m ipykernel install --user --name=myenv

# Remove kernel
jupyter kernelspec uninstall myenv
```

## 3. MLflow (Experiment Tracking)

MLflow tracks ML experiments, parameters, and results.

```bash
# Install MLflow
pip install mlflow

# Start MLflow UI
mlflow ui

# Opens browser at http://localhost:5000
```

### MLflow Usage

```python
import mlflow

# Start run
with mlflow.start_run():
    # Log parameters
    mlflow.log_param("learning_rate", 0.01)
    mlflow.log_param("batch_size", 32)
    
    # Train model
    accuracy = train_model()
    
    # Log metrics
    mlflow.log_metric("accuracy", accuracy)
    
    # Log model
    mlflow.sklearn.log_model(model, "model")
```

## 4. TensorBoard (Visualization)

TensorBoard visualizes training metrics and model graphs.

```bash
# Install TensorBoard
pip install tensorboard

# Start TensorBoard
tensorboard --logdir=./logs

# Opens browser at http://localhost:6006
```

### TensorBoard Usage

```python
from torch.utils.tensorboard import SummaryWriter

writer = SummaryWriter('runs/experiment1')

for epoch in range(num_epochs):
    loss = train_epoch()
    writer.add_scalar('Loss/train', loss, epoch)
    
writer.close()
```

## 5. LLM Usage Tracking

Track API usage and costs for LLM services.

```bash
# Script already installed via integration
llm-usage.sh

# Check usage for date range
llm-usage.sh 2025-01-01 2025-12-31

# Show detailed breakdown
SHOW_DETAILS=true llm-usage.sh
```

### Setup

```bash
# Configure credentials
editapi

# Add your LLM API credentials:
export LLM_API_BASE_URL="https://llm.oklabs.uk"
export LLM_API_KEY="sk-YOUR_KEY"
export LLM_API_TOKEN="YOUR_JWT_TOKEN"
```

## 6. Additional ML Tools

### Hugging Face Transformers

```bash
# Install transformers
pip install transformers datasets accelerate

# Example usage
python << 'EOF'
from transformers import pipeline

# Sentiment analysis
classifier = pipeline("sentiment-analysis")
result = classifier("I love this!")
print(result)
EOF
```

### OpenCV (Computer Vision)

```bash
# Install OpenCV
pip install opencv-python opencv-contrib-python

# For GUI support
brew install opencv
```

### NLTK (Natural Language Processing)

```bash
# Install NLTK
pip install nltk

# Download data
python -c "import nltk; nltk.download('popular')"
```

### Weights & Biases

```bash
# Install wandb
pip install wandb

# Login
wandb login

# Use in code
import wandb

wandb.init(project="my-project")
wandb.log({"accuracy": 0.95})
```

## 7. GPU Support (Apple Silicon)

### TensorFlow on M1

```bash
# Install TensorFlow with Metal support
pip install tensorflow-macos tensorflow-metal

# Verify GPU is available
python << 'EOF'
import tensorflow as tf
print("GPUs Available:", tf.config.list_physical_devices('GPU'))
EOF
```

### PyTorch on M1

```bash
# PyTorch automatically detects M1
pip install torch torchvision torchaudio

# Verify MPS (Metal Performance Shaders) available
python << 'EOF'
import torch
print("MPS Available:", torch.backends.mps.is_available())
EOF
```

## 8. Development Environments

### PyCharm for Data Science

PyCharm Professional has excellent ML/DS features:
- Jupyter notebook support
- Scientific tools (plots, DataFrames)
- TensorFlow/PyTorch integration
- Database tools
- Remote interpreter support

```bash
# Open ML project in PyCharm
pycharm ~/work/projects/personal/ml-project
```

### VS Code / Cursor with Extensions

```bash
# Open in Cursor
cursor ~/work/projects/personal/ml-project

# Install extensions:
# - Python
# - Jupyter
# - Pylance
# - Data Wrangler
```

## 9. Model Deployment

### FastAPI for Model Serving

```bash
# Create API service
mkdir -p ~/work/projects/personal/ml-api
cd ~/work/projects/personal/ml-api

# Install FastAPI
pip install fastapi uvicorn

# Create main.py
cat > main.py << 'EOF'
from fastapi import FastAPI
import pickle

app = FastAPI()

# Load model
with open("model.pkl", "rb") as f:
    model = pickle.load(f)

@app.post("/predict")
def predict(data: dict):
    prediction = model.predict([data["features"]])
    return {"prediction": prediction.tolist()}
EOF

# Run server
uvicorn main:app --reload
```

### Docker for ML Models

```dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## 10. Best Practices

### 1. Use Virtual Environments

```bash
# Create env for each project
cd ~/work/projects/personal/ml-project
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 2. Track Experiments

Use MLflow or Weights & Biases to track:
- Parameters
- Metrics
- Models
- Datasets

### 3. Version Control for Data

```bash
# Install DVC (Data Version Control)
pip install dvc

# Initialize
dvc init

# Track data
dvc add data/dataset.csv
git add data/dataset.csv.dvc data/.gitignore
git commit -m "Add dataset"
```

### 4. Reproducible Environments

```bash
# Pin exact versions
pip freeze > requirements.txt

# Or use Poetry
poetry export -f requirements.txt --output requirements.txt
```

## 11. Resources

- **Jupyter Notebook Gallery**: https://jupyter.org/try
- **TensorFlow Tutorials**: https://tensorflow.org/tutorials
- **PyTorch Tutorials**: https://pytorch.org/tutorials
- **Hugging Face**: https://huggingface.co/
- **Kaggle**: https://kaggle.com/
- **Papers with Code**: https://paperswithcode.com/

## Next Steps

Continue with:
- **[Security & Monitoring](13-security-monitoring.md)** - Secure your environment
- **[Databases](06-databases.md)** - Store training data

---

**Estimated Time**: 25 minutes  
**Difficulty**: Intermediate  
**Last Updated**: October 5, 2025
