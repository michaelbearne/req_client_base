defmodule ReqClientBase do
  @external_resource readme = Path.join([__DIR__, "../README.md"])
  @doc_readme File.read!(readme)

  @moduledoc """
  #{@doc_readme}
  """

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts], location: :keep do
      @service_name opts[:service_name]
      @service_name_as_string opts[:service_name] |> Atom.to_string()
      @plug opts[:plug]

      require Logger

      alias OpenTelemetry.{Tracer, SemConv}

      @req_fuse_opts [fuse_name: __MODULE__, fuse_opts: {{:standard, 5, 1_000}, {:reset, 5_000}}]

      def get(opts) do
        opts = apply_telemetry_metadata(opts)
        Req.get(req(opts), pluck_req_opts(opts))
      end

      defp post(opts) do
        opts = pluck_req_opts(opts)
        Req.post(req(opts), apply_telemetry_metadata(opts))
      end

      def put(opts) do
        opts = apply_telemetry_metadata(opts)
        Req.put(req(opts), opts)
      end

      def patch(opts) do
        opts = apply_telemetry_metadata(opts)
        Req.patch(req(opts), opts)
      end

      def delete(opts) do
        opts = apply_telemetry_metadata(opts)
        Req.delete(req(opts), opts)
      end

      def req(opts) do
        url = opts[:url]

        opts
        |> Keyword.put_new(:retry_delay, &__MODULE__.exp_backoff_50ms/1)
        |> Keyword.put_new(:max_retries, 10)
        |> Keyword.put_new(:retry_log_level, :warn)
        |> Keyword.put_new(:plug, @plug)
        |> Keyword.put(:decode_body, false)
        |> Req.new()
        |> OpentelemetryReq.attach(
          span_name: url,
          opt_in_attrs: [
            SemConv.Incubating.URLAttributes.url_template(),
            SemConv.Incubating.URLAttributes.url_scheme(),
            SemConv.Incubating.HTTPAttributes.http_response_body_size()
          ]
        )
        |> Req.Request.prepend_response_steps(otel_span_ctx: &set_span_ctx/1)
        |> ReqFuse.attach(@req_fuse_opts)
        |> ReqTelemetry.attach(metadata: %{peer_service: @service_name})
      end

      def exp_backoff_50ms(n) do
        Integer.pow(2, n) * 50
      end

      defp set_span_ctx({request, %Req.Response{} = response}) do
        Tracer.set_attribute(
          SemConv.Incubating.PeerAttributes.peer_service(),
          @service_name_as_string
        )

        {request, response}
      end

      defp apply_telemetry_metadata(opts) do
        metadata = opts[:telemetry][:metadata] || %{}
        metadata = if opts[:base_url], do: Map.put_new(metadata, :base_url, opts[:base_url])
        metadata = if opts[:url], do: Map.put_new(metadata, :url, opts[:url])
        opts = Keyword.put_new(opts, :telemetry, Keyword.new())
        put_in(opts, [:telemetry, :metadata], metadata)
      end

      @opts [
        :headers,
        :base_url,
        :url,
        :body,
        :plug,
        :redirect,
        :redirect_trusted,
        :max_redirects,
        :retry,
        :retry_delay,
        :retry_log_level,
        :connect_options,
        :finch,
        :into
      ]
      def pluck_req_opts(opts \\ []) do
        Keyword.take(opts, @opts)
      end
    end
  end
end
