# simulates smart meter data coming in like a client then sends it to a kafka topic 
import time
import json
import random
from datetime import datetime
from kafka import KafkaProducer

def generate_smart_meter_data(meter_id):
    return {
        "meter_id": meter_id,
        "timestamp": datetime.utcnow().isoformat(),
        "energy_kWh": round(random.uniform(0.5, 5.0), 2),
        "voltage": round(random.uniform(210, 250), 1),
        "current": round(random.uniform(0.5, 15.0), 2)
    }

producer = KafkaProducer(
    bootstrap_servers='kafka.default.svc.cluster.local:9092',
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

def run_simulator(interval=2):
    meter_ids = [f"METER-{i:04}" for i in range(1, 6)]
    while True:
        for meter_id in meter_ids:
            data = generate_smart_meter_data(meter_id)
            producer.send("smart-meter-data", value=data)
            print(f"Produced: {data}")
        time.sleep(interval)

if __name__ == "__main__":
    run_simulator()
