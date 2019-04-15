defmodule KafkaSyslog.MockDatabase do
  def get_rfc("1"), do: :rfc3164
  def get_rfc("2"), do: :rfc5424
  def get_rfc("3"), do: :rfc5424
  def get_rfc(_), do: :rfc5424

  def get_host(_), do: "localhost"

  def get_port(:rfc3164), do: 514
  def get_port(:rfc5424), do: 6514
end
