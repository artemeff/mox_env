defmodule MoxEnv.Application do
  @moduledoc false

  use Application

  def start(_, _) do
    children = [
      %{id: MoxEnv, type: :worker, start: {MoxEnv, :start_link_ownership, []}}
    ]

    Supervisor.start_link(children, name: MoxEnv.Supervisor, strategy: :one_for_one)
  end
end
