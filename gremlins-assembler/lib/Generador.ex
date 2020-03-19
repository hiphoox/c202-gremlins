defmodule Generador do

  def code_gen(ast, flag, path) do
    #obtener stack con el recorido en post-orden primero
    post_stack = postorden_recorrido(ast, [])
    #IO.inspect(post_stack)
    #vuelve a recorrer pero con la lista del recorrido para revisar si sigue operacion binaria
    asm_string = postorden(ast, "", post_stack)
    #IO.puts(asm_string)
    #Según la bandera, escribe ensamblador en disco o continua hacia el linker para generar ejecutable
    if flag == :gen_asm, do: genera_archivo(asm_string, path), else: {:ok, asm_string}
  end
  #sin hijos el nodo

  defp postorden_recorrido({_, value, izquierda ,derecha }, l_rec) do
    l_rec = postorden_recorrido(izquierda, l_rec)
    l_rec = postorden_recorrido(derecha, l_rec)
    l_rec ++ [value]
  end

  defp postorden_recorrido({}, l_rec), do: l_rec;

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
        .globl  main         ## -- Begin function main
    _main:                    ## @main
    """  <> codigo 
  end

  def codigo_gen(:constant, value, codigo, post_stack) do
      
      codigo <> """
          mov     $#{value}, %rax
          push    %rax
      """
   

  end

end 