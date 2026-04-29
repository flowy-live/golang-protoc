
## Example usage
I use a script, which by default, assumes that your protobuf files are in relative path `./protocol`, and will generate a folder for outputs in `./genproto`:
```sh
#!/bin/bash -eu

PATH=$PATH:$(go env GOPATH)/bin

# Default values
protodir="./protocol"
outdir="./genproto"

# Parse command-line options
while getopts "p:o:" opt; do
  case $opt in
    p) protodir="$OPTARG" ;;
    o) outdir="$OPTARG" ;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
  esac
done

# Print the directories for verification
echo "Proto directory: $protodir"
echo "Output directory: $outdir"

rm -rf $outdir
mkdir -p $outdir

# use the public image from dockerhub which contains tools for protoc & golang/grpc
docker run --rm \
  -v "$protodir/":/protocol \
  -v "$outdir":/genproto \
  --workdir / \
  talksik/golang-protoc:latest \
  protoc --proto_path=./protocol \
         --go_out=./genproto \
         --go_opt=paths=source_relative \
         --go-grpc_out=./genproto \
         --go-grpc_opt=paths=source_relative \
         $(find ./protocol -name "*.proto")
```

