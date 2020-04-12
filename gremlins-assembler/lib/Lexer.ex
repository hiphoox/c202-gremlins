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
    {token, resto} =
    case program do
        "{" <> resto -> {:open_brace, resto}
        "}" <> resto -> {:close_brace, resto}
        "(" <> resto -> {:open_par, resto}
        ")" <> resto-> {:close_par, resto}
        ";" <> resto -> {:semicolon, resto}
        "return" <> resto -> {:return_Reserveword, resto}
        "int" <> resto -> {:int_Reserveword, resto}
        "main" <> resto -> {:main_Reserveword, resto}
        "-" <> resto -> {:negation_Reserveword, resto}
        "!" <> resto -> {:logicalNeg, resto}
        "~" <> resto -> {:bitewise_Reserveword, resto}
        

        :error -> {:error, nil}
        #Si no hubo ninguna coincidencia, inserta el atomo error
        #si se encontró un error, guarda en cadena restante {:error, motivo}
        resto -> get_constant_chk_error(resto)
        end

        tokens_faltantes = lex_raw_tokens(resto)
        [token | tokens_faltantes]

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