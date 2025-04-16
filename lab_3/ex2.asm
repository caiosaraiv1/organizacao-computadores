# Nome: Caio Ariel Cardoso Saraiva	RA: 10439611
# Nome: Isabela Hissa Pinto	RA: 10441873
# Nome: Kaique Barros Paiva	RA: 10441787

.data
	menu: .asciiz "\n===== CONTROLE DE ESTOQUE =====\n1. Inserir\n2. Excluir\n3. Buscar\n4. Atualizar\n5. Imprimir\n6. Sair\n> Digite sua Opção: "
	err: .asciiz "\nNumero invalido.\n\n"
	msgCodigo: .asciiz "\nDigite o codigo do item: "
	msgQtd: .asciiz "Digite a quantidade: "
	msgBusca: .asciiz "\nBuscar item - informe o codigo: "
	msgAchou: .asciiz "Quantidade encontrada: "
	msgErroBusca: .asciiz "Item nao encontrado.\n"
	msgSucesso: .asciiz "Item inserido com sucesso.\n"
	msgTeste: .asciiz "Entrou no inicio lista.\n"
	nova_linha: .asciiz "\n"
	tituloImpressao: .asciiz "\n--- ESTOQUE ATUAL ---\n"
	msgCodigoImp: .asciiz "Codigo: "
	msgQtdImp:    .asciiz "Quantidade: "
	msgExcluir: .asciiz "\nExcluir item - informe o codigo: "
	msgExcluido: .asciiz "Item excluido com sucesso.\n"
	msgNaoEncontrado: .asciiz "Item nao encontrado para exclusao.\n"
	msgAtualizar: .asciiz "\nAtualizar quantidade - informe o codigo: "
	msgNovaQtd: .asciiz "Digite a nova quantidade: "
	msgAtualizado: .asciiz "Quantidade atualizada com sucesso.\n"
	msgNaoAtualizado: .asciiz "Item nao encontrado para atualizacao.\n"

.text
main:
	# Exibe menu
	li $v0, 4
	la $a0, menu
	syscall

	# Lê opção do usuário
	li $v0, 5
	syscall
	move $t0, $v0  # Armazena a opção em $t0

	# Compara com as opções válidas (1 a 6)
	li $t1, 1
	li $t2, 2
	li $t3, 3
	li $t4, 4
	li $t5, 5
	li $t6, 6

	beq $t0, $t1, inserir_item  
	beq $t0, $t2, excluir_item  
	beq $t0, $t3, buscar_item  
	beq $t0, $t4, atualizar_item  
	beq $t0, $t5, imprimir_itens  
	beq $t0, $t6, sair_programa  

	j erro  # Se não for nenhuma das opções, mostra erro

erro: 
	li $v0, 4
	la $a0, err
	syscall
	j main

##########################################
# Insere novo item no final da lista encadeada
inserir_item:
	# Pede código do item
	li $v0, 4
	la $a0, msgCodigo
	syscall

	li $v0, 5
	syscall
	move $t1, $v0  # Código do item

	# Pede quantidade
	li $v0, 4
	la $a0, msgQtd
	syscall

	li $v0, 5
	syscall
	move $t2, $v0  # Quantidade

	# Aloca espaço para novo nó (12 bytes: cod, qtd, prox)
	li $v0, 9
	li $a0, 12
	syscall
	move $t3, $v0  # Endereço do novo nó

	# Preenche o novo nó
	sw $t1, 0($t3)   # Código
	sw $t2, 4($t3)   # Quantidade
	sw $zero, 8($t3) # Próximo = NULL

	# Se a lista estiver vazia, novo item vira o início
	beq $s0, $zero, inserir_primeiro  

	# Caso contrário, percorre até o final da lista
	move $t4, $s0
percorre_fim:
	lw $t5, 8($t4)     # Pega próximo
	beq $t5, $zero, conecta_novo
	move $t4, $t5      # Avança
	j percorre_fim

conecta_novo:
	sw $t3, 8($t4)     # Conecta novo nó no final
	j main

inserir_primeiro:
	move $s0, $t3      # Atualiza início da lista
	j main

##########################################
# Busca item pelo código e exibe quantidade
buscar_item:
	# Pede código a ser buscado
	li $v0, 4
	la $a0, nova_linha
	syscall

	li $v0, 4
	la $a0, msgBusca
	syscall

	li $v0, 5
	syscall
	move $t1, $v0  # Código buscado

	move $t2, $s0  # Ponteiro para início da lista

busca_loop:
	beq $t2, $zero, nao_encontrado

	lw $t3, 0($t2)  # Lê código atual
	beq $t3, $t1, achou

	lw $t2, 8($t2)  # Vai para próximo
	j busca_loop

achou:
	# Exibe quantidade encontrada
	li $v0, 4
	la $a0, nova_linha
	syscall

	li $v0, 4
	la $a0, msgAchou
	syscall

	li $v0, 1
	lw $a0, 4($t2)  # Quantidade
	syscall

	li $v0, 4
	la $a0, nova_linha
	syscall

	j main

nao_encontrado:
	# Exibe mensagem de não encontrado
	li $v0, 4
	la $a0, nova_linha
	syscall

	li $v0, 4
	la $a0, msgErroBusca
	syscall

	li $v0, 4
	la $a0, nova_linha
	syscall

	j main

##########################################
# Exclui item pelo código
excluir_item:
	li $v0, 4
	la $a0, nova_linha
	syscall

	li $v0, 4
	la $a0, msgExcluir
	syscall

	li $v0, 5
	syscall
	move $t1, $v0  # Código a excluir

	move $t2, $s0  # Nó atual
	move $t3, $zero # Nó anterior

excluir_loop:
	beq $t2, $zero, excluir_nao_encontrado

	lw $t4, 0($t2)   # Lê código
	beq $t4, $t1, excluir_achou

	move $t3, $t2    # Atualiza anterior
	lw $t2, 8($t2)   # Avança
	j excluir_loop

excluir_achou:
	beq $t3, $zero, excluir_no_head  # Se for o primeiro

	lw $t4, 8($t2)   # Pega próximo
	sw $t4, 8($t3)   # Pula o excluído

	li $v0, 4
	la $a0, msgExcluido
	syscall

	j main

excluir_no_head:
	# Remove primeiro item da lista
	lw $t4, 8($t2)
	move $s0, $t4

	li $v0, 4
	la $a0, msgExcluido
	syscall

	j main

excluir_nao_encontrado:
	li $v0, 4
	la $a0, msgNaoEncontrado
	syscall
	j main

##########################################
# Atualiza quantidade de um item
atualizar_item:
	li $v0, 4
	la $a0, nova_linha
	syscall

	li $v0, 4
	la $a0, msgAtualizar
	syscall

	li $v0, 5
	syscall
	move $t1, $v0  # Código a atualizar

	move $t2, $s0  # Nó atual

atualizar_loop:
	beq $t2, $zero, atualizar_nao_encontrado

	lw $t3, 0($t2)
	beq $t3, $t1, atualizar_achou

	lw $t2, 8($t2)
	j atualizar_loop

atualizar_achou:
	# Pede nova quantidade
	li $v0, 4
	la $a0, msgNovaQtd
	syscall

	li $v0, 5
	syscall
	sw $v0, 4($t2)  # Atualiza campo de quantidade

	li $v0, 4
	la $a0, msgAtualizado
	syscall

	j main

atualizar_nao_encontrado:
	li $v0, 4
	la $a0, msgNaoAtualizado
	syscall
	j main

##########################################
# Imprime todos os itens da lista
imprimir_itens:
	li $v0, 4
	la $a0, tituloImpressao
	syscall

	move $t1, $s0  # Ponteiro para início

loop_impressao:
	beq $t1, $zero, fim_impressao

	li $v0, 4
	la $a0, msgCodigoImp
	syscall

	li $v0, 1
	lw $a0, 0($t1)
	syscall

	li $v0, 4
	la $a0, nova_linha
	syscall

	li $v0, 4
	la $a0, msgQtdImp
	syscall

	li $v0, 1
	lw $a0, 4($t1)
	syscall

	li $v0, 4
	la $a0, nova_linha
	syscall

	lw $t1, 8($t1)  # Avança
	j loop_impressao

fim_impressao:
	j main

##########################################
# Encerra o programa
sair_programa:
	li $v0, 10
	syscall

