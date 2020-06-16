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
  
  ##STAGE 1

  test "Prueba 1-1 de Nora Sandler: árbol ast de un código que retorna 2", state do
    token_list = Lexer.scan_word(File.read!("test/codigoc/return2.c"), :no_output);
    assert  Parser.parse_token_list(elem(token_list, 1), :no_output) == state[:ast]
  end

  test "Prueba 1-2 de Nora Sandler: árbol ast de un código que retorna 100" do
    token_list = Lexer.scan_word(File.read!("test/codigoc/multiplesdigitos.c"), :no_output);
    assert  Parser.parse_token_list(elem(token_list, 1), :no_output) ==
      {:ok, {:program, "program",
              {:function, "main",
               {:return_Reserveword, "return", {:constant, 100, {}, {}}, {}}, {}}, {}}}
  end

  test "Prueba 1-3 de Nora Sandler: código al cual le falta un paréntesis que cierra" do
    token_list = Lexer.scan_word(File.read!("test/codigoc/missing_par.c"), :no_output);
    assert  Parser.parse_token_list(elem(token_list, 1), :no_output) == {:error, "Error de sintáxis. Se esperaba ) y se encontró: {"}
  end

  test "Prueba 1-4 de Nora Sandler: Código al cual le falta el return" do
    token_list = Lexer.scan_word("\n\tint main(\n ) { \n \t2; }", :no_output);
    assert  Parser.parse_token_list(elem(token_list, 1), :no_output) == {:error, "Error de sintáxis. Se esperaba return y se encontró: (empty)"}
  end

 ### STAGE 2
 
 test "Prueba 2-1 de Nora Sandler: Operador unario, negacion lógica" do
    token_list = Lexer.scan_word(File.read!("test/codigoc/not_ten.c"), :no_output);
    assert  Parser.parse_token_list(elem(token_list, 1), :no_output) ==
      {:ok, {:program, "program",
             {:function, "main",
              {:return_Reserveword, "return",
               {:logicalNeg, "!", {:constant, 10, {}, {}}, {}}, {}}, {}}, {}}}
  end

  test "Prueba2-2 de Nora Sandler: Operador unario, complemento bit a bit de 0" do
    token_list = Lexer.scan_word(File.read!("test/codigoc/bitwise_zero.c"), :no_output);
    assert  Parser.parse_token_list(elem(token_list, 1), :no_output) ==
      {:ok, {:program, "program",
             {:function, "main",
              {:return_Reserveword, "return",
               {:bitewise_Reserveword, "~", {:constant, 0, {}, {}}, {}}, {}}, {}}, {}}}
  end
 
 
 test "Prueba 2-3 de Nora Sandler: Operador unario, negación" do
    token_list = Lexer.scan_word(File.read!("test/codigoc/negacion.c"), :no_output);
    assert  Parser.parse_token_list(elem(token_list, 1), :no_output) ==
      {:ok, {:program, "program",
             {:function, "main",
              {:return_Reserveword, "return",
               {:negation_Reserveword, "-", {:constant, 5, {}, {}}, {}}, {}}, {}}, {}}}
  end 

  test "Prueba 2-4 de Nora Sandler: Anidando operadores unarios" do
    token_list = Lexer.scan_word(File.read!("test/codigoc/nested_ops.c"), :no_output);
    assert  Parser.parse_token_list(elem(token_list, 1), :no_output) ==
      {:ok, {:program, "program",
             {:function, "main",
              {:return_Reserveword, "return",
               {:logicalNeg, "!",
                {:negation_Reserveword, "-", {:constant, 3, {}, {}}, {}}, {}}, {}}, {}}, {}}}
  end

  test "Prueba 2-5 de Nora Sandler: Anidando operadores unarios 2" do
    token_list = Lexer.scan_word(File.read!("test/codigoc/nested_ops_2.c"), :no_output);
    assert  Parser.parse_token_list(elem(token_list, 1), :no_output) ==
      {:ok, {:program, "program",
             {:function, "main",
              {:return_Reserveword, "return",
               {:negation_Reserveword, "-",
                {:bitewise_Reserveword, "~", {:constant, 0, {}, {}}, {}}, {}}, {}}, {}}, {}}}
  end
  #INVALIDAS
  #test "Prueba 2-6 de Nora Sandler: Operadores desordenados" do
   # token_list = Lexer.scan_word(File.read!("test/codigoc/wrong_order.c"), :no_output);
    #assert  Parser.parse_token_list(elem(token_list, 1), :no_output) == {:error, "Error de sintáxis. Falta el siguiente operando después de -."}
  #end



  ### STAGE 3

  #INVALIDAS

  test "Prueba 3-1 de Nora Sandler: Sin punto y coma" do
    token_list = Lexer.scan_word(File.read!("test/codigoc/sin_semicolo.c"), :no_output);
    assert  Parser.parse_token_list(elem(token_list, 1), :no_output) == {:error, "Error de sintáxis. Se esperaba ; y se encontró: }"}
  end

  test "Prueba 3-2 de Nora Sandler: Falta el primer operando." do
    token_list = Lexer.scan_word(File.read!("test/codigoc/falta_primer_oper.c"), :no_output);
    assert  Parser.parse_token_list(elem(token_list, 1), :no_output) == {:error, "Error de sintaxis: Falta el primer operando antes de +."}
  end

  test "Prueba 3-3 de Nora Sandler: Falta el segundo operando." do
    token_list = Lexer.scan_word(File.read!("test/codigoc/falta_seg_oper.c"), :no_output);
    assert  Parser.parse_token_list(elem(token_list, 1), :no_output) == {:error, "Error de sintaxis: Se esperaba una constante u operador y se encontró ;."}
  end

  ##VALIDAS


end