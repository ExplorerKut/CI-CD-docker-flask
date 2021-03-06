#using python 3.8
FROM python:3.8-slim-buster
ENV CUSTOM_MESSAGE "HELLO_OPSLYFT"
WORKDIR /flask-docker

COPY requirements.txt requirements.txt

RUN pip3 install --no-cache-dir -r requirements.txt 

COPY . .

CMD ["python3","-m","flask","run","--host=0.0.0.0"]