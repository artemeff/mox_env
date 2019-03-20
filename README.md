# MoxEnv [![Hex.pm](https://img.shields.io/hexpm/v/mox_env.svg)](https://hex.pm/packages/mox_env)

---

It's your application config but simply mocked with Mox.

---

## Usage

```elixir
# myapp/lib/myapp/config.ex
defmodule MyApp.Config do
  def get(key, default \\ nil) do
    Application.get_env(:mox_env, key, default)
  end
end

# myapp/test/support/config_mock.ex
defmodule MyApp.ConfigMock do
  use MoxEnv, config: MyApp.Config
end

# myapp/lib/myapp.ex
defmodule MyApp do
  @config Application.get_env(:my_app, :config_module, MyApp.Config)

  def test_key do
    @config.get(:test_key)
  end

  def test_key_default do
    @config.get(:test_key_default, :default_value)
  end
end

# config/test.exs
config :my_app, config_module: MyApp.ConfigMock
```

With that configuration you can simply mock your config in tests, like Mox:

```elixir
iex> MyApp.test_key
:test_value

iex> MyApp.ConfigMock.put_env(:test_key, :new_value)
:new_value
```

---

### Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
