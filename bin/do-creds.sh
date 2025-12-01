set -euo pipefail

echo "Reading creds from 1password...."

export OP_ACCOUNT=$(op account ls | awk 'NR==2 {print $3}')

export AWS_ACCESS_KEY_ID=$(op read op://Private/allbuckets-fini-2025/access_key)
export AWS_SECRET_ACCESS_KEY=$(op read op://Private/allbuckets-fini-2025/secret_key)

export SPACES_ACCESS_KEY_ID=$(op read op://Private/allbuckets-fini-2025/access_key)
export SPACES_SECRET_ACCESS_KEY=$(op read op://Private/allbuckets-fini-2025/secret_key)

echo "= creds DONE in ${SECONDS} seconds."

if [[ -n "$1" ]]; then
	if [[ -d "$1" ]]; then
		cd "$1" || exit 1
		#echo "cd success"
	else
		# just should prevent us from getting here
		echo "$1 is not a directory!"
		exit 2
	fi
fi
