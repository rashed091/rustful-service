#!/bin/bash
set -ex

res=$(curl -s -X POST http://127.0.0.1:5001/users -H "Content-Type: application/json" \
  -d '{"name": "Rashed", "age": "27"}')

echo "${res}"

# lastid="$(echo "${res}" | jq ".id")"

# can get it individually
# curl -s -X GET "http://127.0.0.1:5001/users/${lastid}"

# post not published yet
# curl -s -X GET http://127.0.0.1:5001/users | grep -v "${lastid}"

# publish
# curl -s -X PUT "http://127.0.0.1:5001/users/${lastid}"

# post now published
# curl -s -X GET http://127.0.0.1:5001/users | grep "${lastid}"

# delete post
# curl -s -X DELETE "http://127.0.0.1:5001/users/${lastid}"
