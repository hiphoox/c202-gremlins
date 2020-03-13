defmodule LexerTest do
  use ExUnit.Case
  doctest Compilador

  setup_all do
    {:ok,
     tokens: {:ok, [
       :int_Reserveword,
       :main_Reserveword,
       :open_brace,
       :close_brace,
       :open_par,
       :return_Reserveword,
       {:constant, 2},
       :semicolon,
       :close_par
     ]}}
  end

  test "Elementos separados unicamente por espacios", state do
    assert Lexer.scan_word(" int main( ) { return 2; }", :no_output) == state[:tokens]
  end

  test "Elementos con saltos de línea y tabuladores", state do
    assert Lexer.scan_word("\n\tint main(\n ) { \nreturn \t2; }", :no_output) == state[:tokens]
  end

  test "Lista con elementos totalmente separados", state do
    assert Lexer.start_lexing(["int", "main", "(", ")", "{", "return", "2", ";", "}"], :no_output) == state[:tokens]
  end

  test "Lista con algunos elementos separados", state do
    assert Lexer.start_lexing(["int", "main()", "{", "return", "2", ";}"], :no_output) == state[:tokens]
  end

  test "Prueba 1 de Nora Sandler" do
    assert Lexer.scan_word(File.read!("test/codigoc/sinespacios.c"), :no_output) == {:ok, [
      :int_Reserveword,
      :main_Reserveword,
      :open_brace,
      :close_brace,
      :open_brace,
      :return_Reserveword,
      {:constant, 0},
      :semicolon,
      :close_brace]}
  end

  test "Prueba 2 de Nora Sandler", state do
    assert Lexer.scan_word(File.read!("test/codigoc/return2.c"), :no_output) == state[:tokens]
  end

  test "Prueba 3 de Nora Sandler:" do
    assert Lexer.scan_word(File.read!("test/codigoc/return0.c"), :no_output) == {:ok,[
      :int_Keyword,
      :main_Keyword,
      :open_paren,
      :close_paren,
      :open_brace,
      :return_Keyword,
      {:constant, 0},
      :semicolon,
      :close_brace]}
  end

  test "Prueba 4 de Nora Sandler" do
    assert Lexer.scan_word(File.read!("test/codigoc/sinsaltosdelinea.c"), :no_output) == {:ok, [
      :int_Reserveword,
      :main_Reserveword,
      :open_brace,
      :close_brace,
      :open_brace,
      :return_Reserveword,
      {:constant, 0},
      :semicolon,
      :close_brace]}
  end

  test "Prueba 5 de Nora Sandler" do
    assert Lexer.scan_word(File.read!("test/codigoc/multiplesdigitos.c"), :no_output) == {:ok, [
      :int_Reserveword,
      :main_Keyword,
      :open_brace,
      :close_brace,
      :open_brace,
      :return_Reserveword,
      {:constant, 100},
      :semicolon,
      :close_brace]}
  end

  test "Prueba 6 de Nora Sandler" do
    assert Lexer.scan_word(File.read!("test/codigoc/consaltosdelinea.c"), :no_output) == {:ok, [
      :int_Reserveword,
      :main_Reserveword,
      :open_brace,
      :close_brace,
      :open_brace,
      :return_Reserveword,
      {:constant, 0},
      :semicolon,
      :close_brace]}
  end

  test "Prueba 7 de Nora Sandler" do
    assert Lexer.scan_word(File.read!("test/codigoc/returnenmayusculas.c"), :no_output) == {:error, "Error léxico."}
  end

end