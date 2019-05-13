FROM python:3.7-alpine
RUN apk --no-cache add build-base musl-dev linux-headers g++
RUN apk --no-cache add libffi-dev openssl-dev

ADD requirements.txt /
RUN pip install -r requirements.txt

ADD main.py /

CMD ["python", "./main.py"]