defmodule Api.Timer do
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(_) do
    Logger.warn("Api simple Timer Uptime server started")
    ApiWeb.Endpoint.subscribe("timer:start", [])
    schedule_timer(1_000)
    broadcast(0, "Started timer!")
    {:ok, 1}
  end

  def handle_info(:update, time) do
    broadcast(time, "tick tock... tick tock")
    schedule_timer(1_000)
    {:noreply, time + 1}
  end

  def handle_info(%{event: "start_timer", payload: %{room_name: room_name}}, time) do
    with nil <- Api.TimerSupervisor.already_exist(room_name) do
      Api.TimerSupervisor.start_timer(room_name)
    end

    {:noreply, time}
  end

  def handle_info(%{event: "stop_timer", payload: %{room_name: room_name}}, time) do
    pid = Api.TimerSupervisor.already_exist(room_name)

    if pid != nil do
      Api.TimerSupervisor.stop_timer(pid)
    end

    {:noreply, time}
  end

  defp schedule_timer(time) do
    Process.send_after(self(), :update, time)
  end

  defp broadcast(time, response) do
    ApiWeb.Endpoint.broadcast!("timer:auto", "updated_time", %{
      response: response,
      time: time
    })
  end
end
