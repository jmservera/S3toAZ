docker build . -t s3toaz:0.7 -t s3toaz:latest -t juanserv.azurecr.io/s3toaz:0.7 -t juanserv.azurecr.io/s3toaz:latest
docker run --env-file env.list s3toaz:latest
docker push juanserv.azurecr.io/s3toaz