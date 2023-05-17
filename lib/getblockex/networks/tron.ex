defmodule Getblockex.Networks.Tron do

  defp __json_rpc_version__(), do:
    Application.get_env(:getblockex, :json_rpc_version, "2.0")

  defp __endpoint_base_uri__(), do:
    Application.get_env(:getblockex, :base_uri) || raise "getblockex missing config: base_uri"

  defp __api_key__(), do:
    Application.get_env(:getblockex, :api_key) || raise "getblockex missing config: api_key"

  defp __id__(), do:
    Application.get_env(:getblockex, :id) || raise "getblockex missing config: id"


  defp gen_json_rpc_body(method, params \\ []) do
    %{
      "jsonrpc" => __json_rpc_version__(),
      "method" => method,
      "params" => params,
      "id" => __id__()
    }
  end

  defp call_endpoint(body) do
    HTTPoison.post(
      __endpoint_base_uri__(),
      body |> Jason.encode!(),
      [{"Content-Type", "application/json"}, {"x-api-key", __api_key__()}]
    )
    |> case do
      {:ok, %HTTPoison.Response{status_code: 200, body: raw_body}} ->
        %{"result" => result} = Jason.decode!(raw_body)
        {:ok, result}
      {:ok, _} ->
        {:error, :bad_request}
      {:error, _} ->
        {:error, :bad_response}
    end
  end

  def eth_blockNumber() do
    gen_json_rpc_body("eth_blockNumber")
    |> call_endpoint()
  end

  def eth_getBlockByNumber(block_number, fetch_transaction_object? \\ true) do
    gen_json_rpc_body("eth_getBlockByNumber", [block_number, fetch_transaction_object?])
    |> call_endpoint()
  end

  def eth_getBlockTransactionCountByNumber(block_number) do
    gen_json_rpc_body("eth_getBlockTransactionCountByNumber", [block_number])
    |> call_endpoint()
  end

  def eth_getTransactionByBlockNumberAndIndex(block_number, transaction_index) do
    gen_json_rpc_body("eth_getTransactionByBlockNumberAndIndex", [block_number, transaction_index])
    |> call_endpoint()
  end

  def eth_getTransactionByHash(transaction_hash) do
    gen_json_rpc_body("eth_getTransactionByHash", [transaction_hash])
    |> call_endpoint()
  end

  def eth_getTransactionReceipt(transaction_hash) do
    gen_json_rpc_body("eth_getTransactionByHash", [transaction_hash])
    |> call_endpoint()
  end
end
