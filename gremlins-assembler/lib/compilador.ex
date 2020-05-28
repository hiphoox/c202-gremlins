defmodule Compilador do

  def main(args) do
    IO.puts args
    case args do
       ["-h"] -> help() |> IO.puts();
       [path] -> if path =~ ".c", do: compile(path, :no_output), else: errors(1) |> IO.puts;
       ["-st", path] -> compile(path, :gen_asm); #órden de generar asm
       ["-lt", path] -> compile(path, :show_token); #muestra la lista de tokens
       ["-aa", path] -> compile(path, :show_ast); #muestra el arbol AST
       ["-o", path, ej_name] ->compile(path, ej_name); #se recibe un nuevo nombre en vez de átomo
       _ -> errors(1) |> IO.puts;
            errors(1)
     end
   end

   def compile(path, flag_or_name) do
     if path =~ ".c" and File.exists?(path) do
       IO.puts "Valid path" <> path
       #Funcion que maneja pipeline de compilacion
       manager(File.read!(path), path, flag_or_name);
      else
        errors(3) |> IO.puts;
        errors(3);
      end
   end

   def help() do
     "
     Uso:\n ./compilador nombre del archivo.c | [option] nombre del archivo.c\n
     \b -lt      Muestra Tokens.
     \b -st      Muestra el Árbol Sintáctico.
     \b -sa      Genera el código en ensamblador (x86).
     \b -o [nombre del archivo] [nombre_ejecutable] Especifica el nombre del ejecutable a generar.
     "
   end

   def errors(num) do
      case num do
        1 -> "Compilador de C. Escriba -h para la ayuda." #no hay argumento
        2 -> "Comando(s) no válido. Escriba -h para la ayuda." #mensaje de error
        3 -> "Archivo inválido o no existe en el directorio." #mensaje de archivo inexistente
      end
    end

  def manager(file, path, opt) do
  with  {:ok, tok} <- Lexer.scan_word(file, opt),
        {:ok , ast} <- Parser.parse_token_list(tok, opt),
        {:ok, asm} <- Generador.code_gen(ast, opt, path),
        {:ok, _}  <- Linker.outputBin(asm, opt, path)
        do
        IO.puts("Finalizó la compilación de forma exitosa.")
  else
        {:error, error} -> IO.puts(error)
        {:only_tokens, _} -> IO.puts("Lista de tokens.")
        {:only_ast, _} -> IO.puts("Árbol Sintáctico.")
        {:only_asm, path_asm} ->IO.puts(path_asm)
      end
  end

end
