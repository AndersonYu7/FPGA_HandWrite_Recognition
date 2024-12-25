# FPGA_HandWrite_Recognition

This project aims to implement a handwritten digit recognition model using FPGA (Field Programmable Gate Array) for hardware acceleration. The model recognizes digits from 0 to 9 and uses a simple three-layer deep neural network (DNN) for inference. This document details the project structure, model architecture, and usage instructions.

## Model Architecture

The DNN model has a simple three-layer fully connected architecture as follows:

1. Input Layer: 28 × 28 input features (handwritten digit images, flattened to 784 features).
2. Fully Connected Layer 1: 128 neurons with ReLU activation.
    * Dropout1: Randomly drops 30% of neurons during training.
3. Fully Connected Layer 2: 128 neurons with ReLU activation.
    * Dropout2: Randomly drops 30% of neurons during training.
4. Output Layer: 10 neurons corresponding to digit classes (0-9) with Softmax activation.
* Optimizer: Adam, learning rate = 0.001
* Loss Function: Sparse Categorical Crossentropy

## Hardware
* DE2-70 FPGA development board
* DE2-80 LTM Display

## Result

https://github.com/user-attachments/assets/d06d7a4e-89c0-4cdf-bbc5-2a141f0d756e

