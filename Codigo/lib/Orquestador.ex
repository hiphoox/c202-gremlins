defmodule Orquestador do
  def manager(file, path, opt) do
  #Utilizando "with" se procesa el archivo. Si hay error deja de hacer la compilación.
  with  {:ok, tok} <- Lexer.scan_word(file, opt)
        do
        IO.puts("Finalizó la compilación correctamente.")
  else
  #Se muestra el motivo del error o la salida de la opción seleccionada al compilar
        {:error, error} -> IO.puts(error)
        {:only_tokens, _} -> IO.puts("Lista de tokens.")
      end
    end
end
