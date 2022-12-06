#!/bin/bash

tags() {
  repo=$1
  gh api repos/$repo/releases --paginate | jq -r '.[].tag_name'
}

my_tags=$(tags KoviRobi/erlang-builder)
otp_tags=$(
  tags erlang/otp | \
    # OTP 23.2+, 23.3+, or 24
    grep -e OTP-23.2 -e OTP-23.3 -e OTP-24
)

for i in $otp_tags; do
  if [[ "$my_tags" == *"$i"* ]]; then
    echo release $i already exists
  else
    echo "Kicking off build for $i"
    gh workflow run -R "KoviRobi/erlang-builder" build_otp.yml -f version=${i/OTP-/}
  fi
done
