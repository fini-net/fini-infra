. ../../bin/do-creds.sh

echo ""
tofu output -raw content_key_access

echo ""
tofu output -raw content_key_secret

echo ""
echo ""
echo "- getkeys DONE"
