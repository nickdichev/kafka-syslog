# KafkaSyslog

This is an example application for the `NSyslog` library. The source code and documentation for the library can be found [here](https://github.com/nickdichev/nsyslog).

This application reads off of a Kafka topic and dispatches messages to a remote syslog server. The messages are expected to be in the format:

```json
{"aid":"account-id", "message":"the message"}
```

When the Kafka consumer reads a message, it will dispatch the message to the account's configured destination syslog server. The configuration for this demo application currently comes from a mock database.

## Example

Some test data is provided in the file `test_data`. This file can be loaded into Kafka in several ways, however, I like using `kafkacat`. The data can be loaded as follows:

```bash
cat test_data | kafkacat -P -D "\n" -b localhost:9092 -t messages
```

This will write the data in the `test_data` file into the topic `messages` on the broker at `localhost:9092`.

The test data assumes there are three possible account ids: "1", "2", or "3". The configuration of the destination syslog hosts for these accounts is defined in `KafkaSyslog.MockDatabase`. Currently, they are all configured to point at `localhost:{514,6514}`. Assuming everything is configured correctly, you should see something similar to this in the syslog of the remote destination:

```none
Apr 15 04:24:24 spooky-mac nsyslog[0.210.0]: this is a test message for account id 1
Apr 15 04:24:24 172.29.0.1  2019-04-15 04:24:24.836556Z spooky-mac nsyslog 0.209.0 - - this is a test message for account id 3
Apr 15 04:24:24 172.29.0.1  2019-04-15 04:24:24.839063Z spooky-mac nsyslog 0.209.0 - - this is a test message for account id 3
Apr 15 04:24:24 172.29.0.1  2019-04-15 04:24:24.836568Z spooky-mac nsyslog 0.208.0 - - this is a test message for account id 2
Apr 15 04:24:24 spooky-mac nsyslog[0.210.0]: this is a test message for account id 1
Apr 15 04:24:24 172.29.0.1  2019-04-15 04:24:24.839293Z spooky-mac nsyslog 0.208.0 - - this is a test message for account id 2
```

See the "Kafka and syslog-ng" section for instructions on launching development Kafka and syslog-ng containers.

## Configuration

The `NSyslog` library requires SSL for RFC5424 destinatons. You will need a certificate if you want send to RFC5424 destinations. A self-signed certificate will suffice for testing/development purposes.

The provided mock data and database configuration does assume that account ids "2" and "3" have RFC5424 destinations. If you want to use this example as-is then provide the following configuration:

```elixir
config :nsyslog,
  pemfile: "path/to/some/domain.pem"
```

You can also modify `KafkaSyslog.MockDatabase` to only use `:rfc3164` and port 514 if you do not want to use SSL.

See the file `config/config.exs` for the default settings of the `KafkaEx` configuration.

## Kafka and syslog-ng

You can launch Kafka and syslog-ng containers using `docker-compose`. However, there is some configuration you need to set first.

You are required to generate a self-signed certificate and drop the `.crt` and `.key` in `docker/syslog-ng/certs`. The configuration expects the file names to be `domain.crt` and `domain.key`, however, you can modify the configuration file if necessary.

After configuring the syslog-ng container's certificates, you can launch the entire stack of containers:

```bash
docker-compose up -d
```

You can check the messages recieved by syslog-ng with the following command:

```bash
docker-compose exec syslog-ng sh -c "tail -f /var/log/messages"
```