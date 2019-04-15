defmodule KafkaSyslogTest do
  use ExUnit.Case
  doctest KafkaSyslog

  test "greets the world" do
    assert KafkaSyslog.hello() == :world
  end
end
