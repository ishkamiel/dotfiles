# A toolchains file for generating Aarch64 builds on Ubuntu.
# 
# Requires at least following packages, or equivalent:
#   binutils-aarch64-linux-gnu
#   gcc-aarch64-linux-gnu
#   g++-aarch64-linux-gnu
#
# Use by passing -DCMAKE_TOOLCHAIN_FILE=<path_to_thils_file> when configuring
# the build with CMake.

set(_TOOLCHAIN_PATH            /usr/bin)
set(_TOOLCHAIN_PREFIX          aarch64-linux-gnu-)

# path to the toolchain binaries (C compiler, C++ compiler, linker, etc.):
set(CMAKE_AR                    ${_TOOLCHAIN_PATH}/${_TOOLCHAIN_PREFIX}ar)
set(CMAKE_ASM_COMPILER          ${_TOOLCHAIN_PATH}/${_TOOLCHAIN_PREFIX}as)
set(CMAKE_C_COMPILER            ${_TOOLCHAIN_PATH}/${_TOOLCHAIN_PREFIX}gcc)
set(CMAKE_CXX_COMPILER          ${_TOOLCHAIN_PATH}/${_TOOLCHAIN_PREFIX}g++)
set(CMAKE_LINKER                ${_TOOLCHAIN_PATH}/${_TOOLCHAIN_PREFIX}ld)
set(CMAKE_OBJCOPY               ${_TOOLCHAIN_PATH}/${_TOOLCHAIN_PREFIX}objcopy)
set(CMAKE_RANLIB                ${_TOOLCHAIN_PATH}/${_TOOLCHAIN_PREFIX}ranlib)
set(CMAKE_SIZE                  ${_TOOLCHAIN_PATH}/${_TOOLCHAIN_PREFIX}size)
set(CMAKE_STRIP                 ${_TOOLCHAIN_PATH}/${_TOOLCHAIN_PREFIX}strip)

# name of the target platform (and optionally target processor architecture):
set(CMAKE_SYSTEM_NAME           Linux)
set(CMAKE_SYSTEM_PROCESSOR      aarch64)

# required compilation and linking flags on that particular platform:
set(CMAKE_C_FLAGS               )
set(CMAKE_CXX_FLAGS             )
set(CMAKE_C_FLAGS_DEBUG         )
set(CMAKE_C_FLAGS_RELEASE       )
set(CMAKE_CXX_FLAGS_DEBUG       )
set(CMAKE_CXX_FLAGS_RELEASE     )
set(CMAKE_EXE_LINKER_FLAGS      )

# toolchain sysroot settings:
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM     NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY     ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE     ONLY)

# Optionally reduce compiler sanity check when cross-compiling.
set(CMAKE_TRY_COMPILE_TARGET_TYPE         STATIC_LIBRARY)