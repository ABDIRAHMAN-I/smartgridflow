FROM python:3.10-slim

WORKDIR /app

COPY . .

RUN pip install kafka-python psycopg2-binary

CMD ["python", "kafka_postgres_consumer.py"]
