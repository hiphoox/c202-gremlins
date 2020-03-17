defmodule ScannerTest do
  use ExUnit.Case
  doctest Compilador

  setup_all do
     {:ok,
      sanity_error: {:error, "Error. Archivo código fuente vacío."} }
  end

  test "Código fuente vacío", state do
    assert Lexer.scan_word("", :show_token) == state[:sanity_error]
  end

end