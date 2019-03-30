defmodule ApiWeb.TimerChannel do
  use ApiWeb, :channel

  def join("timer:auto", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def join("timer:" <> _room_name, payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("updated_time", msg, socket) do
    push(socket, "updated_time", msg)
    {:noreply, socket}
  end

  def handle_in("start_timer", %{"channel_name" => room_name}, socket) do
    ApiWeb.Endpoint.broadcast("timer:start", "start_timer", %{room_name: room_name})
    {:noreply, socket}
  end

  def handle_in("stop_timer", %{"channel_name" => room_name}, socket) do
    ApiWeb.Endpoint.broadcast("timer:start", "stop_timer", %{room_name: room_name})
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
