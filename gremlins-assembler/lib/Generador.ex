defmodule Generador do

  def code_gen(ast, flag, path) do
    post_stack = postorden_rec(ast, [])
    asm_string = postorden(ast, "", post_stack)
    if flag == :gen_asm, do: genera_archivo(asm_string, path), else: {:ok, asm_string}
  end
  

  defp postorden_rec({_, value, izquierda ,derecha }, l_rec) do
    l_rec = postorden_rec(izquierda, l_rec)
    l_rec = postorden_rec(derecha, l_rec)
    l_rec ++ [value]
  end

  defp postorden_rec({}, l_rec), do: l_rec;

  #Búsqueda en postorden
  defp postorden({atomo, value, izquierda ,derecha }, code, post_stack) do
    [code, post_stack] = postorden(izquierda, code, post_stack)
    [code, post_stack] = postorden(derecha, code, post_stack)
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
        .globl  _main         ## -- Begin function main
    _main:                    ## @main
    """  <> codigo 
  end

def codigo_gen(:constant, value, codigo, post_stack) do
    if "+" in post_stack or "-" in post_stack or "*" in post_stack or "/" in post_stack do 
        if List.first(post_stack) == "+" or List.first(post_stack) == "-" or List.first(post_stack) == "*" or List.first(post_stack) == "/" or List.first(post_stack) == "~"  or List.first(post_stack) == "!" do 
            codigo <> """
                movl $#{value},%eax
            """
        else 
            codigo <> """
                mov  $#{value}, %eax
                push    %rax
            """
        end  
    else
      codigo <> """
          movl $#{value},%eax
      """
    end
end

  def codigo_gen(:negation_Reserveword, _, codigo, _) do
    codigo <> """
        neg  %eax
    """
  end

  def codigo_gen(:logicalNeg, _, codigo, _) do
    codigo <> """
        cmpl     $0, %eax
        movl     $0, %eax
        sete    %al
    """
  end

  def codigo_gen(:return_Reserveword, _, codigo, _) do
    codigo <> """
        ret
    """
  end

  def codigo_gen(:bitewise_Reserveword, _, codigo,post_stack) do
     if List.first(post_stack) == "return" do
       codigo <> """
           not     %eax
       """
     else
       codigo <> """
           not     %eax
           push    %eax
       """
     end

  end

  def codigo_gen(:min_Reserveword, _, codigo, _) do
     codigo <> """
        pop     %rcx
        sub     %rax, %rcx
        mov     %rcx, %rax
    """
  end

  def codigo_gen(:add_Reserveword, _, codigo, _) do
     codigo <> """
          pop     %rcx
          add     %rcx, %rax
      """
  end

  def codigo_gen(:multiplication_Reserveword, _, codigo, _) do
      codigo <> """
          pop    %rcx
          imul    %rcx, %rax
      """
  end

  def codigo_gen(:division_Reserveword, _, codigo, _) do
    codigo <> """
        pop     %rcx
        div     %rcx
    """
  end


  def genera_archivo(code,path) do
    asm_path = String.replace_trailing(path, ".c", ".s")
    File.write!((asm_path), code)
    {:only_asm, "Archivo ensamblador generado correctamente,  ir a ruta: " <> asm_path}
  end

end 