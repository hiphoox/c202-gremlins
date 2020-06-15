defmodule Parser do 
    def parse_token_list(token_list, flag) do
      output = parse_program(token_list)
      if elem(output, 0) == :error , do: output, else: parsing_flag(output, flag)
    end
  
    def parse_program(tokens) do
      [tokens, func_node] = parse_main(tokens)
      case tokens do
        {:error, _} -> tokens
        _-> {:program, "program", func_node, {}}
      end
    end

    def parse_main(tokens) do
      {_atom, _value, tokens} = parse(tokens, :int_Reserveword)
      {_atom, _value, tokens} = parse(tokens, :main_Reserveword)
      {_atom, _value, tokens} = parse(tokens, :open_par)
      {_atom, _value, tokens} = parse(tokens, :close_par)
      {_atom, _value, tokens} = parse(tokens, :open_brace)
      [tokens, state_node] = parse_stmnt(tokens)
      {_atom, _value, tokens} = parse(tokens, :close_brace)
      
      case tokens do
        {:error, _} -> [tokens, ""] # Si hay error no se construye el nodo
        
        _ -> [tokens, {:function, "main", state_node, {}}]# Si no hay, se pasa la lista con el nodo
      end
    end

     def parse(token, atom) do
      #Si el token entrante es un error, devuelvelo asi
      case token do
        {:error, _} -> {"", "", token};
        _ -> if List.first(token) == atom do
                {atom, "", Enum.drop(token, 1)} # Borra el elemento erróneo del enumerable
                # que no pertenece a los atomos ni al diccionario
             else
                {"", "", {:error, "Error de sintáxis. Se esperaba "<> dicc(atom) <>" y se encontró: " <> dicc(List.first(token))}}
             end
      end
    end

    def parse_stmnt(tokens) do
      case tokens do 
        {:error, _} -> [tokens, ""]
        _-> {atom, _value, tokens} = parse(tokens, :return_Reserveword)
  
        #Parseando expresion
        case tokens do 
          {:error, _} -> [tokens, ""]
          _-> [tokens, exp_node] = parse_express(tokens)
              {_atom, _value, tokens} = parse(tokens, :semicolon)   #Revisa si existe el ;
              case tokens do 
              {:error, _} -> [tokens, ""]
              _ -> [tokens, {atom, "return", exp_node, {}}]
            end 
        end 
      end
    end

    def parse_express(tokens) do
      [tokens, node_term] = parse_term(tokens, "");
      case tokens do
      {:error, _} -> [tokens, ""]
      _-> if List.first(tokens) == :negation_Reserveword or List.first(tokens) == :add_Reserveword do
            next_t_exp(tokens, node_term)
          else
            [tokens, node_term]; 
          end
      end
    end

    def next_t_exp(tokens, node_term) do
        [tokens, operator] = parse_oper(tokens);

        # Se cambia el operador unario negación por el 
        # operador binario resta
        if operator == :negation_Reserveword do
          operator = :min_Reserveword
          [tokens, next_term] = parse_term(tokens, operator)

          case tokens do 
            {:error, _} -> [tokens, ""]
              _ ->
              #Construccion del nodo con resta.
              [tokens, node_term] = parse_bin_op(tokens, operator, node_term, next_term);
              [head|_] = tokens
              #recursividad
              case tokens do 
                  {:error, _} -> [tokens, ""]
                  _ -> if head == :negation_Reserveword or head ==:add_Reserveword do
                        next_t_exp(tokens, node_term)
                      else
                        [tokens, node_term]; #no hubo operacion
                      end 
              end 
          end
        else
              [tokens, next_term] = parse_term(tokens, operator)
              case tokens do 
                {:error, _} -> [tokens, ""]
                _->  #Construccion del nodo con resta.
                [tokens, node_term] = parse_bin_op(tokens, operator, node_term, next_term);
                [head|_] = tokens
                #recursividad
                case tokens do 
                  {:error, _} -> [tokens, ""]
                  _ -> if head == :negation_Reserveword or head ==:add_Reserveword do
                          next_t_exp(tokens, node_term)
                        else
                          [tokens, node_term]; #no hubo operacion
                        end 
                  end 
                end 
        end
      end #end

      def parse_term(tokens, last_op) do
        #envia el operador parseado con anterioridad por si ocurre un error
        [tokens, node_factor] = pars_factor(tokens, last_op); #oks
        case tokens do
          {:error, _} -> [tokens, ""]
          _ -> if List.first(tokens) == :multiplication_Reserveword or 
                  List.first(tokens) == :division_Reserveword do
                  next_fact_term(tokens, node_factor)
                else #cuando no hay multiplicacion o division
                  [tokens, node_factor]; 
                end
        end
      end

     def parse_constant(token, atom) do
      case token do
        {:error, _} -> {"", "", token};
        _ -> if elem(List.first(token), 0) == atom do
                [Enum.drop(token, 1), {elem(List.first(token),0), elem(List.first(token),1),{},{}}]
             else
                #{"", "", {:error, "Error de sintáxis. Constante inválida."}}
            end
      end
    end

    def next_fact_term(tokens, node_factor)  do
      [tokens, operator] = parse_oper(tokens); #extrae el operador 1
      [tokens, next_factor] = pars_factor(tokens, operator) #extrae el operador 2

      # construccion del nodo con suma o resta
      [tokens, node_factor] = parse_bin_op(tokens, operator, node_factor, next_factor);
      #recursividad
      case tokens do
        {:error, _} -> [tokens, ""]
        _ -> if List.first(tokens) == :multiplication_Reserveword or
                List.first(tokens) == :division_Reserveword do
                next_fact_term(tokens, node_factor)
              else #cuando no hay multiplicacion o division
                [tokens, node_factor];
              end  
      end
    end

    def pars_factor(tokens, last_op) do
      #Parsea tokens dentro de los parentesis
      if List.first(tokens) == :open_par do
        tokens=Enum.drop(tokens, 1);
        [tokens, node_exp] = parse_express(tokens);

        case tokens do
          {:error, _} -> [tokens, ""]
          _ -> if List.first(tokens) != :close_par do
                [{:error, "Se esperaba " <> dicc(:close_par) <> "después de la expresión y se encontró " <> dicc(List.first(tokens))}, ""]
              else
                tokens=Enum.drop(tokens, 1);
                [tokens, node_exp];
              end
        end

      #Parseando con operador unario
      else if List.first(tokens) == :negation_Reserveword or List.first(tokens) == :bitewise_Reserveword or List.first(tokens) == :logicalNeg  do
          [tokens, operator] = parse_oper(tokens);
          [tokens, factor] = pars_factor(tokens, "")
          #Operador unario con un operando solamente
          parse_un_op(tokens, operator, factor)
        else
          case List.first(tokens) do
            {:constant, _} -> parse_constant(tokens, :constant)
            _ -> if (List.first(tokens)) == :add_Reserveword  
                  or (List.first(tokens)) == :multiplication_Reserveword 
                  or (List.first(tokens)) == :division_Reserveword do
                  [{:error, "Error de sintaxis: Falta el primer operando antes de " <> dicc(List.first(tokens)) <> "."}, ""]
                else
                  if last_op == :addition_Reserveword or last_op == :min_Reserveword 
                    or last_op == :multiplication_Reserveword 
                    or last_op == :division_Reserveword do
                    [{:error, "Error de sintaxis: Falta el segundo operando después de " <> dicc(last_op) <> "."}, ""]
                  else
                    [{:error, "Error de sintaxis: Se esperaba una constante u operador y se encontró " <> dicc(List.first(tokens)) <> "."}, ""]
                  end
                end
          end
        end
      end
    end
  

    def parse_un_op(tokens, operator, factor) do
        [tokens, {operator, dicc(operator), factor, {}}]
    end

    def parse_oper(tokens) do   #Guardando en arbol el operador
      operator = List.first(tokens); 
      tokens = Enum.drop(tokens, 1) 
      [tokens, operator];
    end

#funcion que parsea el operador unario
    def parse_un_ops(token, atom) do
      case token do
        {:error, _} -> {"", "", token}; 
        _ -> if List.first(token) == atom do
                remain=Enum.drop(token, 1) 
                [token, inner_exp] = parse_express(remain)
                [token, {atom, dicc(atom), inner_exp,{}}]
            else
                [{:error, ""}, ""]
            end
      end
    end

    def parse_bin_op(tokens, operator, node_term, next_term) do
      [tokens, {operator, dicc(operator), node_term, next_term}]
    end


    #Muestra el árbol. Finaliza ejecución al devolver :only_ast
    def parsing_flag(ast, :show_ast) do
      IO.inspect(ast)
      {:only_ast, ast}
    end
  
    #Sólo devuelve el árbol 
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
            :bitewise_Reserveword -> "~"
            :negation_Reserveword->"-"
            :min_Reserveword -> "-"
            :add_Reserveword -> "+"
            :return_Reserveword->"return"
            :semicolon->";"
            :multiplication_Reserveword->"*"
            :division_Reserveword->"/"
            #Operadores binarios 4ta entrega
            :logicalAnd_Reserveword->"&&"
            :logicalOr_Reserveword->"||"
            :equalTo_Reserveword->"=="
            :notEqualTo_Reserveword->"!="
            :lessThan_Reserveword->"<"
            :lessEqual_Reserveword->"<="
            :greaterThan_Reserveword->">"
            :greaterEqual_Reserveword->">="
            _ -> "(empty)"
        end
    end
end 
