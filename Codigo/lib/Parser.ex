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
      {_atom, _value, tokens} = parse(tokens, :return)
      {_atom, _value, tokens} = parse_constant(tokens, :constant)
      {_atom, _value, tokens} = parse(tokens, :semicolon)
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
            :return_Reserveword->"return"
            :semicolon->";"
            _ -> "(vacío)"
        end
    end
end 
