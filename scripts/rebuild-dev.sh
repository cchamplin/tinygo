#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

# Prefer the locally installed Go if present.
if [ -x /home/vscode/.local/go/bin/go ]; then
  export PATH="/home/vscode/.local/go/bin:$PATH"
fi

cd "$ROOT"

# Build native wasm-opt (Binaryen).
make binaryen

# Build tinygo using system LLVM (same flags used during setup).
LLVM_VERSION=$(llvm-config --version | cut -d. -f1)
GO_TAGS="llvm18"
go build -tags="${GO_TAGS}" \
  -ldflags "-X github.com/tinygo-org/tinygo/goenv.BinaryenVersion=${LLVM_VERSION}" \
  -o build/tinygo .

# Assemble a native bundle layout.
BUNDLE=build/release-native/tinygo
mkdir -p "$BUNDLE/bin"
cp -p build/tinygo "$BUNDLE/bin/"
cp -p build/wasm-opt "$BUNDLE/bin/"
rsync -a --delete lib/ "$BUNDLE/lib/"
rsync -a --delete src/ "$BUNDLE/src/"
rsync -a --delete targets/ "$BUNDLE/targets/"

# Add compiler-rt builtins for host builds.
mkdir -p "$BUNDLE/lib/compiler-rt-builtins"
cp -rp llvm-project/compiler-rt/lib/builtins/* "$BUNDLE/lib/compiler-rt-builtins/"
cp -p llvm-project/compiler-rt/LICENSE.TXT "$BUNDLE/lib/compiler-rt-builtins/"

# Add clang headers for CGo support.
mkdir -p "$BUNDLE/lib/clang/include"
cp -p llvm-project/clang/lib/Headers/*.h "$BUNDLE/lib/clang/include/"

# Create a native tarball like the release layout.
tar -czf build/release-native-arm64.tar.gz -C build/release-native tinygo

# Quick sanity build of a tiny wasm file.
if [ ! -f build/hello.go ]; then
  cat > build/hello.go <<'GO'
package main

func main() {}
GO
fi

"$BUNDLE/bin/tinygo" build -o build/hello.native.wasm -target wasm build/hello.go

echo "OK: build/tinygo and bundle at $BUNDLE"
echo "OK: build/hello.native.wasm"
