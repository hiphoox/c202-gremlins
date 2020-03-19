defmodule ParserTest do
  use ExUnit.Case
  doctest Compilador

  setup_all do
    {:ok,
     ast: {:ok, {:program, "program",
             {:function, "main",
              {:return_Reserveword, "return", {:constant, 2, {}, {}}, {}}, {}}, {}}
             }}
  end

  test "Prueba 1 de Nora Sandler: árbol ast de un código que retorna 2", state do
    token_list = Lexer.scan_word(File.read!("test/codigoc/return2.c"), :no_output);
    assert  Parser.parse_token_list(elem(token_list, 1), :no_output) == state[:ast]
  end

  test "Prueba 2 de Nora Sandler: árbol ast de un código que retorna 100" do
    token_list = Lexer.scan_word(File.read!("test/codigoc/multiplesdigitos.c"), :no_output);
    assert  Parser.parse_token_list(elem(token_list, 1), :no_output) ==
      {:ok, {:program, "program",
              {:function, "main",
               {:return_Reserveword, "return", {:constant, 100, {}, {}}, {}}, {}}, {}}}
  end

  test "Prueba 3 de Nora Sandler: código al cual le falta un paréntesis que cierra" do
    token_list = Lexer.scan_word(File.read!("test/codigoc/missing_par.c"), :no_output);
    assert  Parser.parse_token_list(elem(token_list, 1), :no_output) == {:error, "Error de sintáxis. Se esperaba ) y se encontró: {"}
  end

  # test "Prueba 4 de Nora Sandler: Sin valor de retorno" do
  #   token_list = Lexer.scan_word(File.read!("test/codigoc/missing_ret.c"), :no_output);
  #   assert  Parser.parse_token_list(elem(token_list, 1), :no_output) == {:error, "Error de sintaxis: Se esperaba una constante  y se encontró ;."}
  # end

  test "Código al cual le falta el return" do
    token_list = Lexer.scan_word("\n\tint main(\n ) { \n \t2; }", :no_output);
    assert  Parser.parse_token_list(elem(token_list, 1), :no_output) == {:error, "Error de sintáxis. Se esperaba return y se encontró: (empty)"}
  end

end