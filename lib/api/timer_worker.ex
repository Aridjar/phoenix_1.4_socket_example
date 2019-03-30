defmodule Api.TimerWorker do
  use GenServer, restart: :transient
  require Logger

  def start_link(arg) do
    IO.inspect(arg)
    GenServer.start_link(__MODULE__, arg)
  end

  def child_spec(room_name: room_name) do
    %{
      id: "Api.TimerWorker:" <> room_name,
      start: {Api.TimerWorker, :start_link, [%{room_name: room_name}]}
    }
  end

  def init(%{room_name: room_name}) do
    Logger.warn("Api Uptime server started : " <> room_name)
    schedule_timer(1_000)
    broadcast(0, "Started timer!", room_name)
    {:ok, %{time: 1, room_name: room_name}}
  end

  def handle_info(:update, %{time: time, room_name: room_name}) do
    broadcast(time, "room : " <> room_name, room_name)
    schedule_timer(1_000)
    {:noreply, %{time: time + 1, room_name: room_name}}
  end

  defp schedule_timer(time) do
    Process.send_after(self(), :update, time)
  end

  defp broadcast(time, response, room_name) do
    ApiWeb.Endpoint.broadcast!("timer:" <> room_name, "updated_time", %{
      response: response,
      time: time
    })
  end
end
