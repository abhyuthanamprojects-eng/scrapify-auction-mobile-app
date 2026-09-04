#!/bin/bash

# Run Flutter app with different flavors
# Usage: bash run_flavor.sh dev|staging|prod

FLAVOR=$1

if [ -z "$FLAVOR" ]; then
    echo "Usage: bash run_flavor.sh [dev|staging|prod]"
    echo ""
    echo "Examples:"
    echo "  bash run_flavor.sh dev       # Run Dev flavor"
    echo "  bash run_flavor.sh staging   # Run Staging flavor"
    echo "  bash run_flavor.sh prod      # Run Prod flavor"
    exit 1
fi

case $FLAVOR in
    dev)
        echo "🚀 Running Dev flavor (lib/main_dev.dart)..."
        flutter run --flavor dev -t lib/main_dev.dart
        ;;
    staging)
        echo "🚀 Running Staging flavor (lib/main_staging.dart)..."
        flutter run --flavor staging -t lib/main_staging.dart
        ;;
    prod)
        echo "🚀 Running Prod flavor (lib/main_prod.dart)..."
        flutter run --flavor prod -t lib/main_prod.dart
        ;;
    *)
        echo "❌ Invalid flavor: $FLAVOR"
        echo "Valid options: dev, staging, prod"
        exit 1
        ;;
esac
