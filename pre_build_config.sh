#!/bin/bash
#
# To be executed before build
#


#### add oqs_conf.txt path as ENV variable ####

# Define the full path of the configuration file
CONFIG_PATH="$(pwd)/oqs_conf.txt"

# Check if the configuration file exists
if [ ! -f "$CONFIG_PATH" ]; then
    echo "Error: Configuration file not found at $CONFIG_PATH"
    exit 1
fi

# Export the path into the PISTACHE_OQS_CONFIG environment variable
export PISTACHE_OQS_CONFIG="$CONFIG_PATH"

# Display the variable for confirmation
echo "PISTACHE_OQS_CONFIG is set to: $PISTACHE_OQS_CONFIG"

# Append the export statement to .bashrc if it doesn't already exist
if ! grep -q "export PISTACHE_OQS_CONFIG=" ~/.bashrc; then
    echo "export PISTACHE_OQS_CONFIG=\"$CONFIG_PATH\"" >> ~/.bashrc
    echo "PISTACHE_OQS_CONFIG has been added to your .bashrc file."
else
    echo "PISTACHE_OQS_CONFIG is already in your .bashrc."
fi

#### replace old libssl.so & libcrypto.so to oqs supported ones in build.ninja ####

# Read SSL and Crypto library paths from config file
SSL_LIB_PATH=$(grep "SSL_LIB_PATH" $CONFIG_PATH | cut -d'=' -f2)
CRYPTO_LIB_PATH=$(grep "CRYPTO_LIB_PATH" $CONFIG_PATH | cut -d'=' -f2)

# Build ninja file path
NINJA_BUILD_FILE="./build/build.ninja"

# Check if the ninja build file exists
if [ ! -f "$NINJA_BUILD_FILE" ]; then
    echo "Error: build.ninja file not found at $NINJA_BUILD_FILE"
    exit 1
fi

# Replace old paths with new paths in build.ninja
# Match any non-space sequence that ends with libssl.so or libcrypto.a to cover full old paths
sed -i "s|[^ ]*libssl.so|$SSL_LIB_PATH|g" $NINJA_BUILD_FILE
sed -i "s|[^ ]*libcrypto.a|$CRYPTO_LIB_PATH|g" $NINJA_BUILD_FILE

# Check if "-ldl" is already after the $CRYPTO_LIB_PATH on line 135, if not, add it
if ! sed -n "135p" $NINJA_BUILD_FILE | grep -q "$CRYPTO_LIB_PATH -ldl"; then
    sed -i "135s|$CRYPTO_LIB_PATH|$CRYPTO_LIB_PATH -ldl|g" $NINJA_BUILD_FILE
    echo "-ldl added to $CRYPTO_LIB_PATH on line 135."
else
    echo "-ldl is already present after $CRYPTO_LIB_PATH on line 135."
fi

echo "Updated build.ninja with new library paths and added -ldl appropriately."

#### Read SSL and Crypto library paths from config file ####

SSL_LIB_PATH=$(grep "^SSL_LIB_PATH=" $CONFIG_PATH | cut -d'=' -f2)
CRYPTO_LIB_PATH=$(grep "^CRYPTO_LIB_PATH=" $CONFIG_PATH | cut -d'=' -f2)
OPENSSL_INCLUDE_PATH=$(grep "^OPENSSL_INCLUDE_PATH=" $CONFIG_PATH | cut -d'=' -f2)

#### Modify CMakeLists.txt for OpenSSL paths ####

CMAKELISTS_FILE="./CMakeLists.txt"

# Check if the CMakeLists.txt file exists
if [ ! -f "$CMAKELISTS_FILE" ]; then
    echo "Error: CMakeLists.txt not found at $CMAKELISTS_FILE"
    exit 1
fi

# Update CMakeLists.txt with new OpenSSL paths
# Remove the old OpenSSL configuration content inside the if (PISTACHE_USE_SSL) block
sed -i '/if (PISTACHE_USE_SSL)/,/endif ()/{//!d}' $CMAKELISTS_FILE

# Insert new OpenSSL settings within the if (PISTACHE_USE_SSL) block
sed -i "/if (PISTACHE_USE_SSL)/a \\    set(OPENSSL_INCLUDE_DIR $OPENSSL_INCLUDE_PATH)\n    set(OPENSSL_SSL_LIBRARY $SSL_LIB_PATH)\n    set(OPENSSL_CRYPTO_LIBRARY $CRYPTO_LIB_PATH)\n    include_directories(\${OPENSSL_INCLUDE_DIR})" $CMAKELISTS_FILE

echo "Updated CMakeLists.txt with new OpenSSL paths."
