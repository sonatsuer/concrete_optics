defmodule ConcreteOptics.Core.Common do
  @core_capabilities [:view, :review, :over, :to_list, :traverse]

  @moduledoc """
  TODO #{inspect(@core_capabilities)}
  """
  alias ConcreteOptics.Core.Capabilities


  @capability_module ConcreteOptics.Core.Capabilities

  defp attach_type(capability) do
    { capability,
      case capability do
        :view ->
          quote do: Capabilities.view_t(s, a)
        :review ->
          quote do: Capabilities.review_t(t, b)
        :over ->
          quote do: Capabilities.over_t(s, t, a, b)
        :to_list ->
          quote do: Capabilities.to_list_t(s, a)
        :traverse ->
          quote do: Capabilities.traverse_t(s, a)
        other ->
          raise ArgumentError, "Cannot attach type to unknown capability: " <> inspect(other)
      end
    }
  end

  defp extract_variables(caps) do
    get_vars = fn cap ->
      cond do
        cap in [:view, :to_list, :traverse] -> [:s, :a]
        cap == :review -> [:t, :b]
        cap == :over -> [:s, :t, :a, :b]
      end
    end

    found_variables =
      caps |> Enum.flat_map(get_vars) |> MapSet.new()

    [:s, :t, :a, :b]
      |> Enum.filter(fn element -> MapSet.member?(found_variables, element) end)
      |> Enum.map(fn n -> Macro.var(n, nil) end)
    end

    defmacro __using__(opts) do
      caller_module = __CALLER__.module
      capabilities = Enum.uniq(Keyword.get(opts, :capabilities, []))
      unrecognized = capabilities -- @core_capabilities

      if unrecognized != [] do
        raise ArgumentError, "Unrecognized capabilities: #{inspect(unrecognized)}. Recognized capabilities are " <>
          "#{inspect(@core_capabilities)}."
      end
      capability_type_map = Enum.map(capabilities, &attach_type/1)
      variables = extract_variables(capabilities)

      s = quote do
        alias unquote(@capability_module)
        def supported_capabilities(), do: unquote(capabilities)
        defstruct unquote(capabilities)
        @type unquote(:t)(unquote_splicing(variables)) :: %unquote(caller_module){unquote_splicing(capability_type_map)}
      end
      IO.puts(Macro.to_string(s))
      s
    end
end
