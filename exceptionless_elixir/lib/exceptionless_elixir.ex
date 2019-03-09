defmodule ExceptionlessElixir do
  alias ExceptionlessElixir.Formater

  def init({__MODULE__, name}) do
    {:ok, configure(name, [])}
  end

  def handle_event(:flush, state) do
    {:ok, state}
  end

  def handle_event(
        {level, _group_leader, {Logger, message, timestamp, metadata}},
        %{level: min_level} = state
      ) do
    if right_log_level?(min_level, level) do
      Formater.format(level, message, timestamp, metadata)
      |> IO.inspect(label: "#{__ENV__.file}:#{__ENV__.line}")
    end

    {:ok, state}
  end

  # Enusre the message log level is greater than the configured log level
  # if the min log level is not configured log everything
  defp right_log_level?(nil, _level), do: true

  defp right_log_level?(min_level, level) do
    Logger.compare_levels(level, min_level) != :lt
  end

  # Handles configuration calls for the backend
  def handle_call({:configure, opts}, %{name: name} = state) do
    # first :ok lets elixir know the call was successful while the 2nd lets elixir know the configuration was successful
    {:ok, :ok, configure(name, opts, state)}
  end

  defp configure(name, []) do
    base_level = Application.get_env(:logger, :level, :debug)
    Application.get_env(:logger, name, []) |> Enum.into(%{name: name, level: base_level})
  end

  # Only allows configuration of the level for starters add more options to this as the lib grows
  defp configure(_name, [level: new_level], state) do
    Map.merge(state, %{level: new_level})
  end

  # In case sbd tries to configure an option not allowed
  defp configure(_name, _opts, state), do: state
end
