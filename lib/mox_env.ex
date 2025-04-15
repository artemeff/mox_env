defmodule MoxEnv do
  @callback get(key, default) :: term | default when key: atom, default: term

  defmacro __using__(opts \\ []) do
    module = Keyword.fetch!(opts, :config)

    quote do
      @behaviour MoxEnv

      def get(key, default \\ nil) do
        MoxEnv.get(unquote(module), key, default)
      end

      def put_env(key, value) do
        MoxEnv.put_env(unquote(module), key, value)
      end

      def allow_env(owner_pid, allowed_via) do
        MoxEnv.allow_env(unquote(module), owner_pid, allowed_via)
      end

      def set_env_from_context(context) do
        MoxEnv.set_env_from_context(context)
      end
    end
  end

  @timeout :timer.seconds(30)
  @this {:global, MoxEnv.Server}

  @doc false
  def get(module, key, default \\ nil) do
    case fetch_fun_to_dispatch([self() | caller_pids()], module, key) do
      {:ok, term} ->
        term

      :no_expectation ->
        module.get(key, default)
    end
  catch
    :exit, {:noproc, _} ->
      module.get(key, default)
  end

  @doc false
  def put_env(module, key, value) do
    add_expectation(self(), module, key, value)
  end

  @doc false
  def allow_env(module, owner_pid, allowed_via) do
    allowed_pid_or_function =
      case allowed_via do
        fun when is_function(fun, 0) -> fun
        pid_or_name -> GenServer.whereis(pid_or_name)
      end

    if allowed_pid_or_function == owner_pid do
      raise ArgumentError, "owner_pid and allowed_pid must be different"
    end

    case NimbleOwnership.allow(@this, owner_pid, allowed_pid_or_function, module, @timeout) do
      :ok ->
        :ok

      {:error, %NimbleOwnership.Error{reason: :cant_allow_in_shared_mode}} ->
        # Already allowed
        :ok

      {:error, reason} ->
        raise reason
    end
  end

  @doc false
  def set_env_from_context(%{async: true}) do
    NimbleOwnership.set_mode_to_private(@this)
  end

  @doc false
  def set_env_from_context(_context) do
    NimbleOwnership.set_mode_to_shared(@this, self())
  end

  @doc false
  def start_link_ownership do
    case NimbleOwnership.start_link(name: @this) do
      {:error, {:already_started, _}} -> :ignore
      other -> other
    end
  end

  defp add_expectation(owner_pid, module, key, value) do
    case get_and_update(owner_pid, module, fn(state) -> {:ok, Map.put(state || %{}, key, value)} end) do
      {:ok, _value} ->
        :ok

      {:error, error} ->
        {:error, error}
    end
  end

  defp fetch_fun_to_dispatch(caller_pids, module, key) do
    with {:ok, owner_pid} <- fetch_owner_from_callers(caller_pids, module) do
      get_and_update!(owner_pid, module, fn(state) ->
        case Map.fetch(state, key) do
          {:ok, term} ->
            {{:ok, term}, state}

          :error ->
            {:no_expectation, state}
        end
      end)
    end
  end

  defp fetch_owner_from_callers(caller_pids, mock) do
    # If the mock doesn't have an owner, it can't have expectations so we return :no_expectation.
    case NimbleOwnership.fetch_owner(@this, caller_pids, mock, @timeout) do
      {tag, owner_pid} when tag in [:shared_owner, :ok] -> {:ok, owner_pid}
      :error -> :no_expectation
    end
  end

  defp get_and_update(owner_pid, mock, update_fun) do
    NimbleOwnership.get_and_update(@this, owner_pid, mock, update_fun, @timeout)
  end

  defp get_and_update!(owner_pid, mock, update_fun) do
    case get_and_update(owner_pid, mock, update_fun) do
      {:ok, return} -> return
      {:error, %NimbleOwnership.Error{} = error} -> raise error
    end
  end

  defp caller_pids do
    case Process.get(:"$callers") do
      nil -> []
      pids when is_list(pids) -> pids
    end
  end
end
