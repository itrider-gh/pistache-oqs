# Pistache-OQS: Pistache with OpenSSL OQS Support

Pistache-OQS is a fork of the Pistache C++ library, enhanced with OpenSSL OQS to provide support for post-quantum cryptography algorithms within the TLS framework. This version is designed to work with the OQS fork of OpenSSL that incorporates quantum-safe cryptographic algorithms.

## Prerequisites

This project has been tested solely on Ubuntu 20.04. Ensure that your system meets the following requirements:
- Ubuntu 20.04
- Basic build tools (gcc, g++, make)
- Meson build system
- Ninja-build

## Installation Steps

Follow these steps to set up and build Pistache-OQS:

### 1. Clone the Repository
Start by cloning the Pistache-OQS repository from GitHub:
```bash
git clone https://github.com/itrider-gh/pistache-oqs.git
cd pistache-oqs
```

### 2. Configure the Installation
Before building, you need to configure the settings:
- Create and configure `oqs_conf.txt` in the root directory of the project.
- Specify the Key Encapsulation Mechanism (KEM) algorithm and the path to the OpenSSL OQS libraries (include dir and .so lib). The configuration of the KEM algorithm can be done post-build if necessary.

Example of `oqs_conf.txt`:
```
KEMAlgorithm=kyber512
OPENSSL_INCLUDE_PATH=/path/to/openssl-oqs/include
SSL_LIB_PATH=/path/to/openssl-oqs/libssl.so
CRYPTO_LIB_PATH=/path/to/openssl-oqs/libcrypto.so
```

### 3. Setup the Build Environment
Use Meson to configure the build environment:
```bash
meson setup build -DPISTACHE_USE_SSL=true
```

### 4. Run Pre-Build Configuration
Execute the provided script to finalize the pre-build configuration:
```bash
./pre_build_config.sh
```

### 5. Build with Ninja
Compile the project using Ninja:
```bash
ninja -C build  && ninja -C build install
```

### 6. Set the OpenSSL Configuration
Ensure that the `OPENSSL_CONF` environment variable is set to point to a compatible OpenSSL OQS configuration file. This file should be configured to utilize the quantum-safe cryptographic algorithms supported by OpenSSL OQS.

## Post-Installation

After successfully building and setting up Pistache-OQS, you can proceed to integrate it into your applications. Remember to link against the modified OpenSSL libraries when developing applications that utilize Pistache-OQS.

## Compatibility Notes

- **Operating System**: As previously mentioned, this project has only been tested on Ubuntu 20.04.
- **OpenSSL OQS**: This project requires a compatible version of OpenSSL that includes the OQS (Open Quantum Safe) project modifications.

## Support and Contribution

For issues, suggestions, or contributions, please use the GitHub issues and pull requests features to contribute or request assistance.

