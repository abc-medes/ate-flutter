#!/bin/bash

# Define the base directory (Modify if needed)
BASE_DIR="lib"

# Core directories
mkdir -p $BASE_DIR/core/services
mkdir -p $BASE_DIR/core/utils
mkdir -p $BASE_DIR/core/constants
mkdir -p $BASE_DIR/core/routes

# Data layer
mkdir -p $BASE_DIR/data/models
mkdir -p $BASE_DIR/data/repositories
mkdir -p $BASE_DIR/data/sources

# Domain layer
mkdir -p $BASE_DIR/domain/entities
mkdir -p $BASE_DIR/domain/usecases

# Features directory (Feature-based organization)
mkdir -p $BASE_DIR/features/auth/views
mkdir -p $BASE_DIR/features/auth/state
mkdir -p $BASE_DIR/features/home/views
mkdir -p $BASE_DIR/features/home/state
mkdir -p $BASE_DIR/features/settings/views
mkdir -p $BASE_DIR/features/settings/state

# Create necessary files with placeholder content
touch $BASE_DIR/core/routes/router_provider.dart
touch $BASE_DIR/core/routes/auth_routes.dart
touch $BASE_DIR/core/routes/app_routes.dart
touch $BASE_DIR/main.dart

echo "Feature-based Flutter MVVM folder structure created successfully!"