#!/bin/bash

# Define the base directory (Modify if needed)
BASE_DIR="lib"

# # Create directories
# mkdir -p $BASE_DIR/core/services
# mkdir -p $BASE_DIR/core/utils
# mkdir -p $BASE_DIR/core/constants
# mkdir -p $BASE_DIR/data/models
# mkdir -p $BASE_DIR/data/repositories
# mkdir -p $BASE_DIR/data/sources
# mkdir -p $BASE_DIR/domain/entities
# mkdir -p $BASE_DIR/domain/usecases
# mkdir -p $BASE_DIR/presentation/views/home
# mkdir -p $BASE_DIR/presentation/views/login
# mkdir -p $BASE_DIR/presentation/components
# mkdir -p $BASE_DIR/presentation/navigation
# mkdir -p $BASE_DIR/presentation/theme

# # Create necessary files with placeholder content
# touch $BASE_DIR/core/routes.dart
# touch $BASE_DIR/core/dependency_injection.dart
# touch $BASE_DIR/main.dart

mkdir -p $BASE_DIR/features/auth/views
mkdir -p $BASE_DIR/features/auth/state
mkdir -p $BASE_DIR/features/home/views
mkdir -p $BASE_DIR/features/home/state
mkdir -p $BASE_DIR/features/settings/views
mkdir -p $BASE_DIR/features/settings/state

echo "Flutter MVVM folder structure created successfully!"