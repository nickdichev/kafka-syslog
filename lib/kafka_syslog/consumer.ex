defmodule KafkaSyslog.Consumer do
  use KafkaEx.GenConsumer

  alias KafkaEx.Protocol.Fetch.Message
  alias NSyslog.Writer
  alias NSyslog.Writer.{Registry, Supervisor}

  @db KafkaSyslog.MockDatabase

  defp send_message(aid, message) do
    Task.Supervisor.start_child(KafkaSyslog.TaskSupervisor, fn ->
      Writer.send(aid, message)
    end)
  end

  def handle_message_set(message_set, state) do
    for %Message{value: message} <- message_set do
      %{"aid" => aid, "message" => msg} = Jason.decode!(message)

      case Registry.lookup(aid) do
        [{_pid, _}] ->
          send_message(aid, msg)

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

          send_message(aid, message)
      end
    end

    {:async_commit, state}
  end
end
