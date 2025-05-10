FROM python:3.10-slim

WORKDIR /app

COPY . .

RUN pip install --no-cache-dir kafka-python

CMD ["python", "smart_meter_simulator.py"]
