#!/usr/bin/env bash
# demo.sh — Quick S3 operations demo against Garage
# Usage: source .awsrc && bash demo.sh

set -euo pipefail

AWS="${HOME}/.local/bin/aws"
BUCKET="${GARAGE_DEFAULT_BUCKET:-my-bucket}"

echo "==> Listing buckets..."
"${AWS}" s3 ls

echo ""
echo "==> Uploading a test file..."
echo "Hello from Garage S3!" > /tmp/hello.txt
"${AWS}" s3 cp /tmp/hello.txt "s3://${BUCKET}/hello.txt"

echo ""
echo "==> Listing objects in bucket..."
"${AWS}" s3 ls "s3://${BUCKET}"

echo ""
echo "==> Downloading the file back..."
"${AWS}" s3 cp "s3://${BUCKET}/hello.txt" /tmp/hello-downloaded.txt
echo "Downloaded content: $(cat /tmp/hello-downloaded.txt)"

echo ""
echo "==> Generating a pre-signed URL (valid 60s)..."
"${AWS}" s3 presign "s3://${BUCKET}/hello.txt" --expires-in 60

echo ""
echo "==> Done!"
