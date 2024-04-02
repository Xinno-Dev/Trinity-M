SRC_DIR=$(pwd)
DART_OUT=$SRC_DIR/dartapi/lib

rm -rf "$DART_OUT"
mkdir -p "$DART_OUT"

protoc \
-I="$SRC_DIR" \
--dart_out=grpc:"$DART_OUT" \
"$SRC_DIR"/*.proto
