FROM python:3.7-slim-stretch as base

FROM base as builder

RUN mkdir /install
WORKDIR /install

RUN apt-get update && apt-get install -y gcc libffi-dev libssl-dev 

ADD requirements.txt /
RUN pip install --install-option="--prefix=/install" -r /requirements.txt

FROM base

COPY --from=builder /install /usr/local
ADD main.py /

CMD ["python","-u", "./main.py"]