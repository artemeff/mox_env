defmodule App do
  defmodule Config do
    def get(key, default \\ nil) do
      Application.get_env(:mox_env, key, default)
    end
  end

  defmodule ConfigMock do
    use MoxEnv, config: App.Config
  end

  def test_key do
    ConfigMock.get(:test_key)
  end

  def test_key_default do
    ConfigMock.get(:test_key_default, :default_value)
  end
end
