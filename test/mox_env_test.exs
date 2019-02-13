defmodule MoxEnvTest do
  use ExUnit.Case
  doctest MoxEnv

  test "greets the world" do
    assert MoxEnv.hello() == :world
  end
end
