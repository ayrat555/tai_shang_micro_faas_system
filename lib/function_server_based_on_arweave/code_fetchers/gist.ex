defmodule FunctionServerBasedOnArweave.CodeFetchers.Gist do
  alias Components.ExHttp
  require Logger
  @prefix "https://api.github.com/gists"

  def get_from_gist(gist_id) do
    {:ok, %{"files" => files}} =
      do_get_from_gist(gist_id)
    {_file_name, %{"content" => content}} =
      Enum.fetch!(files, 0)
    # same format as get from arweave.
    {:ok, %{content: content}}
  end
  def get_from_gist(gist_id, file_name) do
    {:ok, %{"files" => files}} =
      do_get_from_gist(gist_id)

      content =
      files
      |> Map.get(file_name)
      |> Map.get("content")
    # same format as get from arweave.
    {:ok, %{content: content}}
  end

  def do_get_from_gist(gist_id) do
    Logger.info("get from gist: #{@prefix}/#{gist_id}")
    ExHttp.http_get("#{@prefix}/#{gist_id}")
  end
end
