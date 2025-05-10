import json
import psycopg2
from kafka import KafkaConsumer

# Kafka config
consumer = KafkaConsumer(
    "smart-meter-data",
    bootstrap_servers="kafka.default.svc.cluster.local:9092",
    value_deserializer=lambda m: json.loads(m.decode("utf-8")),
    auto_offset_reset="earliest",
    group_id="smartgrid-consumer-group"
)

# PostgreSQL config
conn = psycopg2.connect(
    host="postgresql.default.svc.cluster.local",
    port=5432,
    dbname="smartgrid",
    user="smartuser",
    password="smartpass"
)

cur = conn.cursor()

# Create table if it doesn't exist
cur.execute("""
    CREATE TABLE IF NOT EXISTS smart_readings (
        meter_id VARCHAR(50),
        timestamp TIMESTAMPTZ,
        energy_kWh NUMERIC,
        voltage NUMERIC,
        current NUMERIC
    );
""")
conn.commit()

print("📥 Consumer is now running and listening for data...")

# Read from Kafka and insert into PostgreSQL
for message in consumer:
    data = message.value
    print(f"Inserting: {data}")
    cur.execute(
        "INSERT INTO smart_readings (meter_id, timestamp, energy_kWh, voltage, current) VALUES (%s, %s, %s, %s, %s)",
        (data["meter_id"], data["timestamp"], data["energy_kWh"], data["voltage"], data["current"])
    )
    conn.commit()
