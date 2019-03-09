defmodule ExceptionlessElixirTest do
  use ExUnit.Case
  doctest ExceptionlessElixir

  test "greets the world" do
    assert ExceptionlessElixir.hello() == :world
  end
end
