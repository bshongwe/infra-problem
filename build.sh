#!/bin/bash
set -e

echo "Building common-utils..."
cd common-utils
lein install
cd ..

echo "Building quotes..."
cd quotes
lein uberjar
cp target/uberjar/*-standalone.jar ../build/quotes.jar
cd ..

echo "Building newsfeed..."
cd newsfeed
lein uberjar
cp target/uberjar/*-standalone.jar ../build/newsfeed.jar
cd ..

echo "Building front-end..."
cd front-end
lein uberjar
cp target/uberjar/*-standalone.jar ../build/front-end.jar
cd ..

echo "Build complete! JARs are in the build/ directory."
