defmodule MoxEnvTest do
  use ExUnit.Case

  doctest MoxEnv

  describe "App" do
    test "#test_key" do
      assert "value" == App.test_key()
    end

    test "#test_key override" do
      App.ConfigMock.put_env(:test_key, "another_value")

      assert "another_value" == App.test_key()
    end

    test "#test_key override with nil" do
      App.ConfigMock.put_env(:test_key, nil)

      assert nil == App.test_key()
    end

    test "#test_key_default" do
      assert :default_value == App.test_key_default()
    end

    test "#test_key_default override" do
      App.ConfigMock.put_env(:test_key_default, :non_default_value)

      assert :non_default_value == App.test_key_default()
    end

    test "#test_key_default override with nil" do
      App.ConfigMock.put_env(:test_key_default, nil)

      assert nil == App.test_key_default()
    end

    test "#test_key_default override twice" do
      App.ConfigMock.put_env(:test_key_default, 1)
      App.ConfigMock.put_env(:test_key_default, 2)

      assert 2 == App.test_key_default()
      assert 2 == App.test_key_default()
    end
  end
end
