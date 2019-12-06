defmodule MoxEnvTest do
  use ExUnit.Case

  doctest MoxEnv

  defmodule Config do
    def get(key, default \\ nil) do
      Application.get_env(:mox_env, key, default)
    end
  end

  defmodule ConfigMock do
    use MoxEnv, config: Config
  end

  defmodule App do
    def test_key do
      ConfigMock.get(:test_key)
    end

    def test_key_default do
      ConfigMock.get(:test_key_default, :default_value)
    end
  end

  describe "App" do
    test "#test_key" do
      assert "value" == App.test_key
    end

    test "#test_key override" do
      ConfigMock.put_env(:test_key, "another_value")

      assert "another_value" == App.test_key
    end

    test "#test_key override with nil" do
      ConfigMock.put_env(:test_key, nil)

      assert nil == App.test_key
    end

    test "#test_key_default" do
      assert :default_value == App.test_key_default
    end

    test "#test_key_default (override)" do
      ConfigMock.put_env(:test_key_default, :non_default_value)

      assert :non_default_value == App.test_key_default
    end

    test "#test_key_default override with nil" do
      ConfigMock.put_env(:test_key_default, nil)

      assert nil == App.test_key_default
    end
  end
end
