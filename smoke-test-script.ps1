$SITE_URL = "https://example.com"
echo Running smoke tests
status=`curl -LIs $SITE_URL | tac | grep -o "^HTTP.*" | cut -f 2 -d' ' | head -1`
if [ $status -eq "200" ]
then
  echo "status is 200"
else
  echo "status is '$status'"
  exit 1
fi
