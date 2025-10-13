export OP_ACCOUNT=$(op account ls | grep chicks | awk '{print $3}')

#export AWS_ACCESS_KEY_ID=$(op read op://Private/allbuckets-fini-2025/access_key)
#export AWS_SECRET_ACCESS_KEY=$(op read op://Private/allbuckets-fini-2025/secret_key)

export SPACES_ACCESS_KEY_ID=$(op read op://Private/allbuckets-fini-2025/access_key)
export SPACES_SECRET_ACCESS_KEY=$(op read op://Private/allbuckets-fini-2025/secret_key)
