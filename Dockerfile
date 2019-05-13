FROM python:3.7-alpine

RUN apk --no-cache add gcc libffi-dev openssl-dev musl-dev

ADD requirements.txt /
RUN pip install -r requirements.txt

ADD main.py /

CMD ["python", "./main.py"]