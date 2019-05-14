FROM python:3.7-alpine as base

FROM base as builder

RUN mkdir /install
WORKDIR /install

RUN apk --no-cache add gcc libffi-dev openssl-dev musl-dev

ADD requirements.txt /
RUN pip install --install-option="--prefix=/install" -r /requirements.txt

FROM base

COPY --from=builder /install /usr/local
ADD main.py /

CMD ["python","-u", "./main.py"]