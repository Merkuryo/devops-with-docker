# Exercise 1.15 - Homework (Mandatory)

## Objective

Create a Dockerfile for a personal project and publish it to Docker Hub with proper documentation.

## Requirements

- Create a Dockerfile for your own application (not a fork/clone of backend or frontend examples)
- Publish the image to Docker Hub
- Include a basic description in the Docker Hub repository overview
- Include instructions for how to run the application
- Submit the Docker Hub link in the format: username/repository

## Project Details

For this exercise, I created a **Temperature Converter** application:
- A command-line tool written in Python
- Converts between Celsius, Fahrenheit, and Kelvin
- Supports 6 different conversion types
- Handles both interactive and batch input modes

## Files Created

- `app.py` - Main application
- `Dockerfile` - Container configuration
- `README.md` - Documentation with installation and usage instructions

## Docker Hub Publishing Steps

1. Create an account on https://hub.docker.com
2. Navigate to Dashboard and create a new repository
3. Set repository name to something descriptive (e.g., temperature-converter)
4. Set visibility to Public
5. Local build and tag: `docker tag temperature-converter <username>/temperature-converter`
6. Login: `docker login`
7. Push: `docker push <username>/temperature-converter`

## Verification

The application builds successfully and runs without errors. Both interactive and piped input modes are supported.

## Docker Hub Link Format

Submit answer as: `username/temperature-converter`

Replace `username` with your actual Docker Hub username.
