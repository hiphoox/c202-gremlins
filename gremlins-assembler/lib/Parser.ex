defmodule Parser do 
    def parse_token_list(token_list, flag) do
      output = parse_program(token_list)
      if elem(output, 0) == :error , do: output, else: parsing_flag(output, flag)
    end
  
    def parse_program(tokens) do
      [tokens, func_node] = parse_function(tokens)
      case tokens do
        {:error, _} -> tokens
        _-> {:program, "program", func_node, {}}
      end
    end

    def parse_function(tokens) do
      {_atom, _value, tokens} = parse(tokens, :int_Reserveword)
      {_atom, _value, tokens} = parse(tokens, :main_Reserveword)
      {_atom, _value, tokens} = parse(tokens, :open_par)
      {_atom, _value, tokens} = parse(tokens, :close_par)
      {_atom, _value, tokens} = parse(tokens, :open_brace)
      [tokens, state_node] = parse_stmnt(tokens)
      {_atom, _value, tokens} = parse(tokens, :close_brace)
      
      case tokens do
        {:error, _} -> [tokens, ""]
        
        _ -> [tokens, {:function, "main", state_node, {}}]
      end
    end

     def parse(token, atom) do
      #Si el token entrante es un error, devuelvelo asi
      case token do
        {:error, _} -> {"", "", token};
        _ -> if List.first(token) == atom do
                {atom, "", Enum.drop(token, 1)}
             else
                {"", "", {:error, "Error de sintáxis. Se esperaba "<> dicc(atom) <>" y se encontró: " <> dicc(List.first(token))}}
             end
      end
    end

    def parse_stmnt(tokens) do
      case tokens do #case 1
        {:error, _} -> [tokens, ""]
        _-> {atom, _value, tokens} = parse(tokens, :return_Reserveword)
  
        #Parseando expresión completa
        case tokens do #case 2
          {:error, _} -> [tokens, ""]
          _-> [tokens, exp_node] = parse_express(tokens, :constant)
              #Finalizando, revisa si existe el ;
              {_atom, _value, tokens} = parse(tokens, :semicolon)
              case tokens do #case 3
              #Si tokens trae error, devuelve ese mismo error sin crear un nodo de árbol
              {:error, _} -> [tokens, ""]
              #De lo contrario, devuelve lista de tokens y el nodo a construir.
              _ -> [tokens, {atom, "return", exp_node, {}}]
            end #end case 3
        end #end case 2
      end #end case 1
    end

    def parse_express(tokens) do
    [tokens, node_term] = parse_term(tokens, ""); #term -> factor (constant, unop, binop)
    end

    def parse_term(tokens, last_op) do
    #envia el operador parseado con anterioridad por si ocurre un error
    [tokens, node_factor] = pars_factor(tokens, last_op); #oks
      
    end



     def parse_constant(token, atom) do
      #¿Token trae tupla error en vez de la lista? devuelvela tal como está.
      case token do
        {:error, _} -> {"", "", token}; #envia null porque solo te interesa propagar tokens
        _ -> if elem(List.first(token), 0) == atom do
                [Enum.drop(token, 1), {elem(List.first(token),0), elem(List.first(token),1),{},{}}]
             else
                #{"", "", {:error, "Error de sintáxis. Constante inválida."}}
            end
      end
    end

    def pars_factor(tokens, last_op) do
      #Parseando con operador unario
      if List.first(tokens) == :negation_Reserveword  or List.first(tokens) == :logicalNeg  do
          [tokens, operator] = parse_operation(tokens);
          [tokens, factor] = parse_factor(tokens, "")
          #Operador unario con un operando solamente
          parse_unary_op(tokens, operator, factor)
      else
          #Constante unicamente, parsear y devolver
          #Control de errores si no fue ninguno de los casos anteriores
          case List.first(tokens) do
            {:constant, _} -> parse_constant(tokens, :constant)
            _ -> [{:error, "Error de sintaxis: Se esperaba una constante u operador y se encontró " <> diccionario(List.first(tokens)) <> "."}, ""]  
          end
      end
    end
  

    def parse_un_op(tokens, operator, factor) do
        [tokens, {operator, diccionario(operator), factor, {}}]
    end

    def parse_oper(tokens) do
      operator = List.first(tokens); #guardo el operador
      tokens = Enum.drop(tokens, 1) #extraccion del operador
      [tokens, operator];
    end

#funcion que parsea el operador unario
    def parse_un_ops(token, atom) do
      case token do
        {:error, _} -> {"", "", token}; 
        _ -> if List.first(token) == atom do
                remain=Enum.drop(token, 1) 
                [token, inner_exp] = parse_expression(remain)
                [token, {atom, dicc(atom), inner_exp,{}}]
            else
                [{:error, ""}, ""]
            end
      end
    end


    #Muestra en pantalla el árbol. Finaliza ejecución al devolver la tupla :only_ast
    def parsing_flag(ast, :show_ast) do
      IO.inspect(ast)
      {:only_ast, ast}
    end
  
    #Sólo devuelve el árbol al orquestador
    def parsing_flag(ast, _) do
      {:ok, ast}
    end


    #Diccionario utilizado para transformar los Reserveword a caractéres.
    def dicc(atom)do
        case atom do
            :int_Reserveword->"int"
            :main_Reserveword->"main"
            :open_par->"("
            :close_par->")"
            :open_brace->"{"
            :close_brace->"}"
            :logicalNeg->"!"
            :negation_Reserveword->"-"
            :return_Reserveword->"return"
            :semicolon->";"
            _ -> "(empty)"
        end
    end
end 
