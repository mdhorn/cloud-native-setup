#!/bin/bash
install_certs() {
	TEMP_DIR="$(mktemp -d)"
	pushd "$TEMP_DIR"
	CERT_URLS=($2)
	for CERT_URL in "${CERT_URLS[@]}"; do
		curl --fail --silent --show-error --remote-name "$CERT_URL"
	done
	find . -mindepth 1 -type f -name '*.zip' -exec unzip -o '{}' -d . \;
	sudo -E find . -mindepth 1 -type f ! -name '*.zip' -exec cp -a '{}' "$1" \;
	popd
	rm -rf "$TEMP_DIR"
}

SUDO="sudo -E "
if [ "${EUID}" -eq 0 ]
then
    SUDO=""
fi

${SUDO}mkdir -p /etc/ca-certs/trusted
install_certs /etc/ca-certs/trusted 'http://certificates.intel.com/repository/certificates/IntelSHA2RootChain-Base64.zip http://certificates.intel.com/repository/certificates/PublicSHA2RootChain-Base64-crosssigned.zip http://certificates.intel.com/repository/certificates/ComodoExternalIssuingCA_base64_Chain.zip http://certificates.intel.com/repository/certificates/Intel%20Root%20Certificate%20Chain%20Base64.zip http://certificates.intel.com/repository/certificates/Public%20Root%20Certificate%20Chain%20Base64.zip'
${SUDO}rm -rf /run/lock/clrtrust.lock
${SUDO}clrtrust generate
