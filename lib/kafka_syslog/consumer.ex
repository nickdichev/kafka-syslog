defmodule KafkaSyslog.Consumer do
  use KafkaEx.GenConsumer

  alias KafkaEx.Protocol.Fetch.Message
  alias NSyslog.Writer
  alias NSyslog.Writer.{Registry, Supervisor}

  @db KafkaSyslog.MockDatabase

  def handle_message_set(message_set, state) do
    for %Message{value: message} <- message_set do
      %{"aid" => aid, "message" => msg} = Jason.decode!(message)

      case Registry.lookup(aid) do
        [{_pid, _}] ->
          Writer.send(aid, msg)

        [] ->
          rfc = @db.get_rfc(aid)
          host = @db.get_host(aid)
          port = @db.get_port(rfc)

          Supervisor.create_writer(%Writer{
            rfc: rfc,
            protocol: :tcp,
            host: host,
            port: port,
            aid: aid
          })

          Writer.send(aid, msg)
      end
    end

    {:async_commit, state}
  end
end
