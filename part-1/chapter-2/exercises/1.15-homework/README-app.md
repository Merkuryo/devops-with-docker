# Temperature Converter

A simple command-line application that converts temperatures between Celsius, Fahrenheit, and Kelvin.

## Features

- Convert Celsius to Fahrenheit and Kelvin
- Convert Fahrenheit to Celsius and Kelvin  
- Convert Kelvin to Celsius and Fahrenheit
- Interactive command-line interface
- Error handling for invalid inputs

## Prerequisites

- Python 3.6+

## Installation

### Local Installation

```bash
python3 app.py
```

### Docker Installation

```bash
docker build -t temperature-converter .
docker run -it temperature-converter
```

## Usage

Run the application:

```bash
python3 app.py
```

Or with Docker:

```bash
docker run -it <username>/temperature-converter
```

Follow the interactive prompts to select a conversion type and enter a temperature value.

## Example

```
Temperature Converter
====================

1. Celsius to Fahrenheit
2. Celsius to Kelvin
3. Fahrenheit to Celsius
4. Fahrenheit to Kelvin
5. Kelvin to Celsius
6. Kelvin to Fahrenheit

Select conversion (1-6): 1
Enter temperature value: 25

25.0°C = 77.00°F
```

## Building and Pushing to Docker Hub

### Build the image locally

```bash
docker build -t temperature-converter .
```

### Tag the image with your Docker Hub username

```bash
docker tag temperature-converter <username>/temperature-converter
```

### Push to Docker Hub

First, login to Docker Hub:
```bash
docker login
```

Then push the image:
```bash
docker push <username>/temperature-converter
```

## Running from Docker Hub

Once pushed, anyone can run your image:

```bash
docker run -it <username>/temperature-converter
```

Replace `<username>` with your Docker Hub username.
