defmodule Components.ExHttp do
  @retries 5
  @default_user_agent "faas"

  require Logger

  def http_get(url) do
    http_get(url, @retries)
  end

  def http_get(_url, retries) when retries == 0 do
    {:error, "GET retires #{@retries} times and not success"}
  end

  def http_get(url, retries) do
    url
    |> HTTPoison.get([{"User-Agent", @default_user_agent}],
      hackney: [headers: [{"User-Agent", @default_user_agent}]]
    )
    |> handle_response()
    |> case do
      {:ok, body} ->
        {:ok, body}

      {:error, _} ->
        Process.sleep(500)
        http_get(url, retries - 1)
    end
  end

  def http_post(url, data) do
    http_post(url, data, @retries)
  end

  def http_post(_url, _data, retries) when retries == 0 do
    {:error, "POST retires #{@retries} times and not success"}
  end

  def http_post(url, data, retries) do
    body = Jason.encode!(data)

    url
    |> HTTPoison.post(
      body,
      [{"User-Agent", @default_user_agent}, {"Content-Type", "application/json"}],
      hackney: [headers: [{"User-Agent", @default_user_agent}]]
    )
    |> handle_response()
    |> case do
      {:ok, body} ->
        {:ok, body}

      {:error, _} ->
        Process.sleep(500)
        http_post(url, data, retries - 1)
    end
  end

  # normal
  defp handle_response({:ok, %HTTPoison.Response{status_code: status_code, body: body}})
       when status_code in 200..299 do
    case Poison.decode(body) do
      {:ok, json_body} ->
        {:ok, json_body}

      {:error, payload} ->
        Logger.error("Reason: #{inspect(payload)}")
        {:error, :network_error}
    end
  end

  # 404 or sth else
  defp handle_response({:ok, %HTTPoison.Response{status_code: status_code, body: _}}) do
    Logger.error("Reason: #{status_code} ")
    {:error, :network_error}
  end

  defp handle_response(error) do
    Logger.error("Reason: other_error")
    error
  end
end
