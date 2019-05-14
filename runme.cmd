docker build . -t s3toaz:0.4 -t s3toaz:latest -t juanserv.azurecr.io:0.4 -t juanserv.azurecr.io:latest
docker run --env-file env.list s3toaz:latest
docker push