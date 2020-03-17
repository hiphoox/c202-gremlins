defmodule Orquestador do
  def manager(file, path, opt) do
  #Utilizando "with" se procesa el archivo. Si hay error deja de hacer la compilación.
  with  {:ok, tok} <- Lexer.scan_word(file, opt)
        {:ok , ast} <- Parser.parse_token_list(tok, opt)
        do
        IO.puts("Finalizó la compilación de forma exitosa.")
  else
  #Se muestra el motivo del error o la salida de la opción seleccionada al compilar
        {:error, error} -> IO.puts(error)
        {:only_tokens, _} -> IO.puts("Lista de tokens.")
        {:only_ast, _} -> IO.puts("Árbol Sintáctico.")
      end
    end
end
