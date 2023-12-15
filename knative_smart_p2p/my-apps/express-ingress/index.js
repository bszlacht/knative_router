const express = require('express');
const kafka = require('kafka-node');
const bodyParser = require('body-parser');

const app = express();
const port = 3000;

// Kafka client setup
const client = new kafka.KafkaClient({ kafkaHost: 'my-cluster-kafka-bootstrap.kafka:9092' });
const producer = new kafka.Producer(client);
const topic_name = "events"

// Middleware to parse JSON bodies
app.use(bodyParser.json());

app.post('/', (req, res) => {
    const number = req.body.number;

    if (typeof number !== 'number') {
        return res.status(400).send('Invalid number');
    }

    const payloads = [
        { topic: topic_name, messages: number.toString(), partition: 0 }
    ];

    producer.send(payloads, (err, data) => {
        if (err) {
            console.error(err);
            // Include the error message in the HTTP response
            return res.status(500).send(`Failed to send message to Kafka: ${err.message}`);
        }

        res.send('Message sent to Kafka');
    });
});

app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});