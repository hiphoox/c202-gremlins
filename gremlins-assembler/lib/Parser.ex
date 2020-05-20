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
      case tokens do 
        {:error, _} -> [tokens, ""]
        _-> {atom, _value, tokens} = parse(tokens, :return_Reserveword)
  
        #Parseando expresion
        case tokens do 
          {:error, _} -> [tokens, ""]
          _-> [tokens, exp_node] = pars_factor(tokens)
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
      #[head|tail] = tokens
      #Control de errores, ver si viene uno de ellos o una suma/resta después de un factor
      case tokens do
      {:error, _} -> [tokens, ""]
      _-> if List.first(tokens) == :negation_Keyword or List.first(tokens) == :addition_Keyword do
            next_t_exp(tokens, node_term)
          else
            [tokens, node_term]; #Sin operación de suma o resta
          end
      end
    end

    def next_t_exp(tokens, node_term) do
        #Extrae el operador binario
        [tokens, operator] = parse_operation(tokens);

        #Cambiar operador unario de negación a resta binaria
        if operator == :negation_Keyword do
          operator = :minus_Keyword
          #node_term es nodo hoja operando 1
          #next_term es nodo hoja operando 2, extraer con la siguiente función.
          [tokens, next_term] = parse_term(tokens, operator)

          #¿Faltó el segundo operando?
          case tokens do #case 1
            {:error, _} -> [tokens, ""]
              _ ->
              #Construccion del nodo con resta como operando.
              [tokens, node_term] = parse_bin_op(tokens, operator, node_term, next_term);
              [head|_] = tokens
              #recursividad
              #¿Hay más sumas o restas? Llama a esta misma función para parsear operadores y operandos.
              case tokens do #case 2
                  {:error, _} -> [tokens, ""]
                  _ -> if head == :negation_Keyword or head ==:addition_Keyword do
                        next_term_exp(tokens, node_term)
                      else
                        [tokens, node_term]; #no hubo operacion de suma ni resta
                      end #end if
              end #end case 2
          end #end case 1
        else
              #node_term es nodo hoja 1
              #next_termn es nodo hoja 2
              [tokens, next_term] = parse_term(tokens, operator)
              #¿Faltó el segundo operando?
              case tokens do #case 1
                {:error, _} -> [tokens, ""]
                _->  #Construccion del nodo con resta como operando.
                [tokens, node_term] = parse_bin_op(tokens, operator, node_term, next_term);
                [head|_] = tokens
                #recursividad
                #¿Hay más sumas o restas? Llama a esta misma función para parsear operadores y operandos.
                case tokens do #case 2
                  {:error, _} -> [tokens, ""]
                  _ -> if head == :negation_Keyword or head ==:addition_Keyword do
                          next_term_exp(tokens, node_term)
                        else
                          [tokens, node_term]; #no hubo operacion de suma ni resta
                        end #end if
                  end #end case 2
                end #end case 1
        end
      end #end

      def parse_term(tokens, last_op) do
        #envia el operador parseado con anterioridad por si ocurre un error
        [tokens, node_factor] = parse_factor(tokens, last_op); #oks
        case tokens do
          {:error, _} -> [tokens, ""]
          _ -> if List.first(tokens) == :multiplication_Keyword or List.first(tokens) == :division_Keyword do
                  next_fact_term(tokens, node_factor)
              else #sino hay mmultiplicacion o division
                  [tokens, node_factor]; #no hubo operacion de suma ni resta
              end
        end
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

    def next_fact_term(tokens, node_factor)  do
      [tokens, operator] = parse_operation(tokens); #extrae el operador 1
      [tokens, next_factor] = pars_factor(tokens, operator) #extrae el operador 2

      # construccion del nodo con suma o resta
      [tokens, node_factor] = parse_bin_op(tokens, operator, node_factor, next_factor);
      #recursividad
      case tokens do
        {:error, _} -> [tokens, ""]
        _ -> if List.first(tokens) == :multiplication_Keyword or List.first(tokens) ==:division_Keyword do
                next_factor_term(tokens, node_factor)
            else #sino hay mmultiplicacion o division, continua
                [tokens, node_factor];
            end
      end
    end

    def pars_factor(tokens) do
      #Parseando con operador unario
      if List.first(tokens) == :negation_Reserveword or List.first(tokens) == :bitewise_Reserveword  or List.first(tokens) == :logicalNeg  do
          [tokens, operator] = parse_oper(tokens);
          [tokens, factor] = pars_factor(tokens)
          #Operador unario con un operando solamente
          parse_un_op(tokens, operator, factor)
      else
          #Constante unicamente, parsear y devolver
          #Control de errores si no fue ninguno de los casos anteriores
          case List.first(tokens) do
            {:constant, _} -> parse_constant(tokens, :constant)
            _ -> [{:error, "Error de sintaxis: Se esperaba una constante u operador y se encontró " <> dicc(List.first(tokens)) <> "."}, ""]  
          end
      end
    end
  

    def parse_un_op(tokens, operator, factor) do
        [tokens, {operator, dicc(operator), factor, {}}]
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
                [token, inner_exp] = pars_factor(remain)
                [token, {atom, dicc(atom), inner_exp,{}}]
            else
                [{:error, ""}, ""]
            end
      end
    end

    def parse_bin_op(tokens, operator, node_term, next_term) do
      [tokens, {operator, diccionario(operator), node_term, next_term}]
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
            :bitewise_Reserveword -> "~"
            :negation_Reserveword->"-"
            :min_Reserveword -> "-"
            :add_Reserveword -> "+"
            :div_Reserveword -> "/"
            :mult_Reserveword -> "*"
            :return_Reserveword->"return"
            :semicolon->";"
            _ -> "(empty)"
        end
    end
end 
