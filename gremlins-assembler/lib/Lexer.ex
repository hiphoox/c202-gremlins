defmodule Lexer do

  def scan_word(string, flag) do
    #Realiza scaneo del código con expresiones regulares
    words = Scanner.fix_format(string)
    case words do
      [""] -> {:error, "Error. Archivo código fuente vacío."}
        _ ->  start_lexing(words, flag) #Comenzamos con lista de Tokens
    #devuelve la lista de tokens en caso de que todo salga bien
    end
  end


  def start_lexing(words, flag) do
    token_list = Enum.flat_map(words, &lex_raw_tokens/1)
    #Si hubo error, debe de haber un token llamado ":error".
    if Enum.member?(token_list, :error) do
      #Si dicho token no existe, entonces devuelve tupla de error
      {:error, "Error léxico." }
    else
      #La bandera determina si  mostrara  o no en pantalla la lista de tokens
       if flag == :show_token do

        IO.inspect(token_list)
      
         #Solo mostrar lista de tokens y finalizar ejecución.
         {:only_tokens, token_list}
     
       else

         {:ok, token_list}
       end
     end
  end


  def lex_raw_tokens(program) when program != "" do #Búsqueda de patrones en la cadena de código
    {token, cadena_restante} =
    case program do
        "{" <> cadena_restante -> {:open_brace, cadena_restante}
        "}" <> cadena_restante -> {:close_brace, cadena_restante}
        "(" <> cadena_restante -> {:open_par, cadena_restante}
        ")" <> cadena_restante -> {:close_par, cadena_restante}
        ";" <> cadena_restante -> {:semicolon, cadena_restante}
        "return" <> cadena_restante -> {:return_Reserveword, cadena_restante}
        "int" <> cadena_restante -> {:int_Reserveword, cadena_restante}
        "main" <> cadena_restante -> {:main_Reserveword, cadena_restante}
        

        :error -> {:error, nil}
        #Si no hubo ninguna coincidencia, inserta el atomo error
        #si se encontró un error, guarda en cadena restante {:error, motivo}
        cadena_restante -> get_constant_chk_error(cadena_restante)
        end

        tokens_restantes = lex_raw_tokens(cadena_restante)
        [token | tokens_restantes]

  end

    def lex_raw_tokens(_program) do
      []
    end

  def get_constant_chk_error(remain_string) do
    #Constante o cadena no valida, procesar
    if Regex.run(~r/-?\d+/, remain_string) != nil do
        case Regex.run(~r/\d+/, remain_string) do
           [valor] -> {{:constant, String.to_integer(valor)}, String.trim_leading(remain_string, valor)}
        end
      else #Si no fue una constante. Mostrar en pantalla error , string invalido.
          IO.puts("La palabra " <> remain_string <> " es inválida." )
          {:error, ""}
      end
    end
end