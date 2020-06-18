defmodule LexerTest do
  use ExUnit.Case
  doctest Compilador

  setup_all do
    {:ok,
     tokens: {:ok, [
       :int_Reserveword,
       :main_Reserveword,
       :open_par,
       :close_par,
       :open_brace,
       :return_Reserveword,
       {:constant, 2},
       :semicolon,
       :close_brace
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

  #STAGE 1 

  test "Prueba 1-1 : return de una constante de 1 digito" do
    assert Lexer.scan_word(File.read!("test/codigoc/sinespacios.c"), :no_output) == {:ok, [
      :int_Reserveword,
      :main_Reserveword,
      :open_par,
      :close_par,
      :open_brace,
      :return_Reserveword,
      {:constant, 2},
      :semicolon,
      :close_brace]}
  end

  test "Prueba 1-2 : Return de 2", state do
    assert Lexer.scan_word(File.read!("test/codigoc/return2.c"), :no_output) == state[:tokens]
  end

  test "Prueba 1-3 : Return de 0" do
    assert Lexer.scan_word(File.read!("test/codigoc/return0.c"), :no_output) == {:ok,[
      :int_Reserveword,
      :main_Reserveword,
      :open_par,
      :close_par,
      :open_brace,
      :return_Reserveword,
      {:constant, 0},
      :semicolon,
      :close_brace]}
  end

  test "Prueba 1-4 : Codigo sin saltos de linea" do
    assert Lexer.scan_word(File.read!("test/codigoc/sinsaltosdelinea.c"), :no_output) == {:ok, [
      :int_Reserveword,
      :main_Reserveword,
      :open_par,
      :close_par,
      :open_brace,
      :return_Reserveword,
      {:constant, 2},
      :semicolon,
      :close_brace]}
  end

  test "Prueba 1-5: Return de constante con multiples digitos" do
    assert Lexer.scan_word(File.read!("test/codigoc/multiplesdigitos.c"), :no_output) == {:ok, [
      :int_Reserveword,
      :main_Reserveword,
      :open_par,
      :close_par,
      :open_brace,
      :return_Reserveword,
      {:constant, 100},
      :semicolon,
      :close_brace]}
  end

  test "Prueba 1-6 : Codigo con multiples saltos de linea " do
    assert Lexer.scan_word(File.read!("test/codigoc/consaltosdelinea.c"), :no_output) == {:ok, [
      :int_Reserveword,
      :main_Reserveword,
      :open_par,
      :close_par,
      :open_brace,
      :return_Reserveword,
      {:constant, 2},
      :semicolon,
      :close_brace]}
  end

  test "Prueba 1-7 : Palabra reservada return en mayusculas" do
    assert Lexer.scan_word(File.read!("test/codigoc/returnenmayusculas.c"), :no_output) == {:error, "Error léxico."}
  end

 ## AGREGANDO PRUEBAS

  test "Prueba 1-8 : Aceptando operador unario - " do
    assert Lexer.scan_word(File.read!("test/codigoc/negacion.c"), :no_output) == {:ok, [
      :int_Reserveword,
      :main_Reserveword,
      :open_par,
      :close_par,
      :open_brace,
      :return_Reserveword,
      :negation_Reserveword,
      {:constant, 5},
      :semicolon,
      :close_brace]}
  end

  test "Prueba 1-8 : Aceptando operador unario ~ " do
    assert Lexer.scan_word(File.read!("test/codigoc/bitwise_zero.c"), :no_output) == {:ok, [
      :int_Reserveword,
      :main_Reserveword,
      :open_par,
      :close_par,
      :open_brace,
      :return_Reserveword,
      :bitewise_Reserveword,
      {:constant, 0},
      :semicolon,
      :close_brace]}
  end

  #test "Prueba 1-9 : Aceptando operador unario  !" do
    #assert Lexer.scan_word(File.read!("test/codigoc/not_ten.c"), :no_output) == {:ok, [
      #:int_Reserveword,
      #:main_Reserveword,
      #:open_par,
      #:close_par,
      #:open_brace,
      #:return_Reserveword,
      #:logicalNeg_Reserveword,
      #{:constant, 10},
      #{:constant, 0},
      #:semicolon,
      #:close_brace]}
  #end

  test "Prueba 1-10 : Aceptando operador binario +  " do
    assert Lexer.scan_word(File.read!("test/codigoc/adicion.c"), :no_output) == {:ok, [
      :int_Reserveword,
      :main_Reserveword,
      :open_par,
      :close_par,
      :open_brace,
      :return_Reserveword,
      {:constant, 1},
      :add_Reserveword,
      {:constant, 2},
      :semicolon,
      :close_brace]}
  end

  test "Prueba 1-11 : Aceptando operador binario -  " do
    assert Lexer.scan_word(File.read!("test/codigoc/resta.c"), :no_output) == {:ok, [
      :int_Reserveword,
      :main_Reserveword,
      :open_par,
      :close_par,
      :open_brace,
      :return_Reserveword,
      {:constant, 3},
      :negation_Reserveword,
      {:constant, 2},
      :semicolon,
      :close_brace]}
  end

  test "Prueba 1-12 : Aceptando operador binario *  " do
    assert Lexer.scan_word(File.read!("test/codigoc/multiplicacion.c"), :no_output) == {:ok, [
      :int_Reserveword,
      :main_Reserveword,
      :open_par,
      :close_par,
      :open_brace,
      :return_Reserveword,
      {:constant, 1},
      :multiplication_Reserveword,
      {:constant, 2},
      :semicolon,
      :close_brace]}
  end

  test "Prueba 1-12 : Aceptando operador binario * con varios digitos  " do
    assert Lexer.scan_word(File.read!("test/codigoc/multiplicacion2.c"), :no_output) == {:ok, [
      :int_Reserveword,
      :main_Reserveword,
      :open_par,
      :close_par,
      :open_brace,
      :return_Reserveword,
      {:constant, 10},
      :multiplication_Reserveword,
      {:constant, 2},
      :semicolon,
      :close_brace]}
  end

  test "Prueba 1-13 : Aceptando operador binario /  " do
    assert Lexer.scan_word(File.read!("test/codigoc/division.c"), :no_output) == {:ok, [
      :int_Reserveword,
      :main_Reserveword,
      :open_par,
      :close_par,
      :open_brace,
      :return_Reserveword,
      {:constant, 4},
      :division_Reserveword,
      {:constant, 2},
      :semicolon,
      :close_brace]}
  end

  test "Prueba 1-13 : Aceptando operador binario / con varios digitos  " do
    assert Lexer.scan_word(File.read!("test/codigoc/division2.c"), :no_output) == {:ok, [
      :int_Reserveword,
      :main_Reserveword,
      :open_par,
      :close_par,
      :open_brace,
      :return_Reserveword,
      {:constant, 100},
      :division_Reserveword,
      {:constant, 2},
      :semicolon,
      :close_brace]}
  end

  test "Prueba 1-14 : Aceptando operador binario &&  " do
    assert Lexer.scan_word(File.read!("test/codigoc/andLogico.c"), :no_output) == {:ok, [
      :int_Reserveword,
      :main_Reserveword,
      :open_par,
      :close_par,
      :open_brace,
      :return_Reserveword,
      {:constant, 1},
      :logicalAnd_Reserveword,
      {:constant, 1},
      :semicolon,
      :close_brace]}
  end

  test "Prueba 1-15 : Aceptando operador binario ||  " do
    assert Lexer.scan_word(File.read!("test/codigoc/orLogico.c"), :no_output) == {:ok, [
      :int_Reserveword,
      :main_Reserveword,
      :open_par,
      :close_par,
      :open_brace,
      :return_Reserveword,
      {:constant, 1},
      :logicalOr_Reserveword,
      {:constant, 1},
      :semicolon,
      :close_brace]}
  end

  test "Prueba 1-15 : Aceptando operador binario || con varios digitos  " do
    assert Lexer.scan_word(File.read!("test/codigoc/orLogico2.c"), :no_output) == {:ok, [
      :int_Reserveword,
      :main_Reserveword,
      :open_par,
      :close_par,
      :open_brace,
      :return_Reserveword,
      {:constant, 100},
      :logicalOr_Reserveword,
      {:constant, 100},
      :semicolon,
      :close_brace]}
  end

  test "Prueba 1-16 : Aceptando operador binario ==  " do
    assert Lexer.scan_word(File.read!("test/codigoc/equal.c"), :no_output) == {:ok, [
      :int_Reserveword,
      :main_Reserveword,
      :open_par,
      :close_par,
      :open_brace,
      :return_Reserveword,
      {:constant, 1},
      :equalTo_Reserveword,
      {:constant, 1},
      :semicolon,
      :close_brace]}
  end

  test "Prueba 1-17 : Aceptando operador binario !=  " do
    assert Lexer.scan_word(File.read!("test/codigoc/notEqual.c"), :no_output) == {:ok, [
      :int_Reserveword,
      :main_Reserveword,
      :open_par,
      :close_par,
      :open_brace,
      :return_Reserveword,
      {:constant, 1},
      :notEqualTo_Reserveword,
      {:constant, 2},
      :semicolon,
      :close_brace]}
  end

  test "Prueba 1-18 : Aceptando operador binario <  " do
    assert Lexer.scan_word(File.read!("test/codigoc/lessThan.c"), :no_output) == {:ok, [
      :int_Reserveword,
      :main_Reserveword,
      :open_par,
      :close_par,
      :open_brace,
      :return_Reserveword,
      {:constant, 1},
      :lessThan_Reserveword,
      {:constant, 2},
      :semicolon,
      :close_brace]}
  end

  test "Prueba 1-19 : Aceptando operador binario <=  " do
    assert Lexer.scan_word(File.read!("test/codigoc/lessEqual.c"), :no_output) == {:ok, [
      :int_Reserveword,
      :main_Reserveword,
      :open_par,
      :close_par,
      :open_brace,
      :return_Reserveword,
      {:constant, 1},
      :lessEqual_Reserveword,
      {:constant, 1},
      :semicolon,
      :close_brace]}
  end

  test "Prueba 1-20 : Aceptando operador binario >  " do
    assert Lexer.scan_word(File.read!("test/codigoc/greaterThan.c"), :no_output) == {:ok, [
      :int_Reserveword,
      :main_Reserveword,
      :open_par,
      :close_par,
      :open_brace,
      :return_Reserveword,
      {:constant, 2},
      :greaterThan_Reserveword,
      {:constant, 1},
      :semicolon,
      :close_brace]}
  end

  test "Prueba 1-21 : Aceptando operador binario >=  " do
    assert Lexer.scan_word(File.read!("test/codigoc/greaterEqual.c"), :no_output) == {:ok, [
      :int_Reserveword,
      :main_Reserveword,
      :open_par,
      :close_par,
      :open_brace,
      :return_Reserveword,
      {:constant, 2},
      :greaterEqual_Reserveword,
      {:constant, 1},
      :semicolon,
      :close_brace]}
  end

end