defmodule Generador do

  def code_gen(ast, flag, path) do
    #primero obtener stack 
    post_stack = postorden_rec(ast, [])
    #vuelve a recorrer pero con la lista del recorrido para generar ensamblador
    asm_string = postorden(ast, "", post_stack)
    #Según la bandera, escribe ensamblador en disco o continua hacia el linker para generar ejecutable
    if flag == :gen_asm, do: genera_archivo(asm_string, path), else: {:ok, asm_string}
  end
  

  defp postorden_rec({_, value, izquierda ,derecha }, l_rec) do
    l_rec = postorden_rec(izquierda, l_rec)
    l_rec = postorden_rec(derecha, l_rec)
    l_rec ++ [value]
  end

  defp postorden_rec({}, l_rec), do: l_rec;

  #Búsqueda en postorden (izquierda, derecha y arriba)
  defp postorden({atomo, value, izquierda ,derecha }, code, post_stack) do
    [code, post_stack] = postorden(izquierda, code, post_stack)
    [code, post_stack] = postorden(derecha, code, post_stack)
    #IO.puts(code)
    post_stack = Enum.drop(post_stack, 1)
    [codigo_gen(atomo, value, code, post_stack ), post_stack];
  end

  defp postorden({}, code, post_stack), do: [code, post_stack];


  def codigo_gen(:program, _, codigo, _) do
    """
    .p2align        4, 0x90
    """ <> codigo 
  end

  def codigo_gen(:function, _, codigo, _) do
    """
        .globl  main         ## --Function main
    _main:                    ## @main
    """  <> codigo 
  end

  def codigo_gen(:constant, value, codigo, post_stack) do
      
      codigo <> """
          mov     $#{value}, %rax
          push    %rax
      """
  end

  ##Anexa la constante y añade una instruccion return
  def codigo_gen(:return_Reserveword, _, codigo, _) do
    codigo <> """
        ret
    """
  end

  def genera_archivo(code,path) do
    asm_path = String.replace_trailing(path, ".c", ".s")
    File.write!((asm_path), code)
    {:only_asm, "Archivo ensamblador generado correctamente,  ir a ruta: " <> asm_path}
  end

end 