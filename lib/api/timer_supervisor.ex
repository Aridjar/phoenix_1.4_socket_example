defmodule Api.TimerSupervisor do
  # Automatically defines child_spec/1
  use DynamicSupervisor

  require Logger

  def start_link(arg) do
    DynamicSupervisor.start_link(Api.TimerSupervisor, arg, name: Api.TimerSupervisor)
  end

  @impl true
  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_timer(room_name) do
    # If MyWorker is not using the new child specs, we need to pass a map:
    # spec = %{id: MyWorker, start: {MyWorker, :start_link, [foo, bar, baz]}}
    spec = {Api.TimerWorker, room_name: room_name}

    {:ok, pid} = DynamicSupervisor.start_child(Api.TimerSupervisor, spec)

    Process.put(room_name, pid)
  end

  def already_exist(room_name) do
    Process.get(room_name)
  end

  def stop_timer(pid) do
    DynamicSupervisor.terminate_child(Api.TimerSupervisor, pid)
  end

  # REMOVE
  # STOP CONNEXION (from the client)
end
