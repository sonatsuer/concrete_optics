defmodule ConcreteOptics.Core.Compose do
  @allowed_fields [:view, :review, :over, :to_list, :traverse]

  def extract_fields!(module) do
    unless Kernel.function_exported?(module, :__info__, 1) and module.__info__(:struct) do
      raise "Optic module #{inspect(module)} must define a struct."
    end
    module.__info__(:struct)
    fields = Map.keys(module.__info__(:struct)) -- [:__struct__]
    invalid_fields = fields -- @allowed_fields

    if invalid_fields != [] do
      raise "Optic module #{inspect(module)} has invalid fields: #{inspect(invalid_fields)}. Allowed fields are: #{inspect(@allowed_fields)}."
    end
    fields
  end

  defp classify_module!(fields) do
    field_set = MapSet.new(fields)
    cond do
      field_set == MapSet.new [:view, :review, :over, :to_list, :traverse] ->
        :Iso
      true ->
        raise "Not a valid set of fields for an optic: #{fields}"
    end
  end

  @doc """

  """
  defmacro generate_compose(optics_root, capability_module, module1, module2) do
    fields1 = extract_fields!(module1)
    fields2 = extract_fields!(module2)
    common_fields = fields1 |> Enum.to_list() |> Enum.filter(&(&1 in fields2))

    if common_fields == [] do
      raise "The structs in #{inspect(module1)} and #{inspect(module2)} share no common fields."
    end

    return_module_suffix = classify_module!(common_fields)
    return_module = Module.concat(optics_root, return_module_suffix)

    compose_list = [
      view: (quote do: unquote(capability_module).compose_view(val1, val2)),
      review: (quote do: unquote(capability_module).compose_review(val1, val2)),
      over: (quote do: unquote(capability_module).compose_over(val1, val2)),
      to_list: (quote do: unquote(capability_module).compose_to_list(val1, val2)),
      traverse: (quote do: unquote(capability_module).compose_traverse(val1, val2))
    ]

    s = quote do
      @spec compose(
        optic1 :: unquote(module1).t(),
        optic2 :: unquote(module2).t()
      )
    end
    IO.puts(Macro.to_string(s))
    s
  end
end
