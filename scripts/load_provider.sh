#!/bin/bash

source .env.deploy

concatenate_u8_to_string() {
	local number=$1
	local text=$2
	local char=$(printf "\\$(printf '%03o' "$number")")
	echo "$char$text"
}

echo "Load data from provider.json"
cat scripts/provider.json | jq -c '.[]' | while read -r provider; do
	providerName=$(echo $provider | jq -r '.name')
	metadata=$(echo $provider | jq -r '.metadata' | base64)
	submitFee=$(echo $provider | jq -r '.submitFee')
	updateFee=$(echo $provider | jq -r '.updateFee')
	# totalLevels=$(echo $provider | jq -r '.totalLevels')
	score=$(echo $provider | jq -r '.score')
	owner=$(echo $provider | jq -r '.owner')

	levels=$(echo $provider | jq -r '.levels[]')

	sui client call \
		--function add_provider \
		--module suipass \
		--package ${PACKAGE_ADDR} \
		--json \
		--args \
		${ADMIN_CAP} \
		${SUIPASS_ADDR} \
		${owner} \
		${providerName} \
		${metadata} \
		${submitFee} \
		${updateFee} \
		${totalLevels} \
		${score} \
		--gas-budget 100000000
done
