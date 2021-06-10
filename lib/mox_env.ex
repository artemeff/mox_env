defmodule MoxEnv do
  @callback get(key, default) :: term | default when key: atom, default: term

  defmacro __using__(opts \\ []) do
    module = Keyword.fetch!(opts, :config)

    quote do
      @behaviour MoxEnv

      def get(key, default \\ nil) do
        case call({:fetch_fun_to_dispatch, [self() | caller_pids()], make_key(key)}) do
          {:ok, fun} -> fun.()
          :no_expectation -> unquote(module).get(key, default)
        end
      end

      def put_env(key, value, owner_pid \\ self()) do
        call({:add_expectation, owner_pid, make_key(key), make_value(value)})
      end

      def allow_env(pid, owner \\ self()) do
        call({:allow, __MODULE__, owner, pid})
      end

      def set_mode(owner_pid, mode) do
        call({:set_mode, owner_pid, mode})
      end

      def set_env_from_context(%{async: true} = _context), do: set_mode(self(), :private)
      def set_env_from_context(_context), do: set_mode(self(), :global)

      defp make_key(config_key) do
        {__MODULE__, config_key, 0}
      end

      defp make_value(value) do
        {0, [], fn -> value end}
      end

      defp call(message) do
        GenServer.call(Mox.Server, message)
      end

      defp caller_pids do
        case Process.get(:"$callers") do
          nil -> []
          pids when is_list(pids) -> pids
        end
      end
    end
  end
end
