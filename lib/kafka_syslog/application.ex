defmodule KafkaSyslog.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    consumer_group_opts = [
      heartbeat_interval: 1_000,
      commit_interval: 1_000
    ]

    consumer_group_name = "kafka_syslog"
    topic_names = ["messages"]

    children = [
      supervisor(
        KafkaEx.ConsumerGroup,
        [KafkaSyslog.Consumer, consumer_group_name, topic_names, consumer_group_opts]
      ),
      {Task.Supervisor, name: KafkaSyslog.TaskSupervisor, strategy: :one_for_one}
    ]

    opts = [strategy: :one_for_one, name: KafkaSyslog.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
