.data
	head: .word 0 # endereço do primeiro nó, ou 0 (NULL) se lista vazia
	menu: .asciiz "\n===== CONTROLE DE ESTOQUE =====\n1. Inserir\n2. Excluir\n3. Buscar\n4. Atualizar\n5. Imprimir\n6. Sair\n> Digite sua Opção: "
	opcao_invalida: .asciiz "Opção invalida.\n"

.text
main:
	# Exibe o menu
	li $v0, 4
	la $a0, menu
	syscall
	
	# Le a opção do usuario
	li $v0, 5
	syscall
	move $t0, $v0
	
	# Verifica as opções
	li $t1, 1
	li $t2, 2
	li $t3, 3
	li $t4, 4
	li $t5, 5
	li $t6, 6
	
	beq $t0, $t1, chama_inserir
    	beq $t0, $t2, chama_excluir
    	beq $t0, $t3, chama_buscar
    	beq $t0, $t4, chama_atualizar
    	beq $t0, $t5, chama_imprimir
    	beq $t0, $t6, sair
	
	li $v0, 4
    	la $a0, opcao_invalida
    	syscall
    	j main

# Tive que fazer desse jeito porque o professor pediu para usar JAL e JR

chama_inserir:
    jal inserir_item
    j main

chama_excluir:
    jal excluir_item
    j main

chama_buscar:
    jal buscar_item
    j main

chama_atualizar:
    jal atualizar_item
    j main

chama_imprimir:
    jal imprimir_itens
    j main

inserir_item:


excluir_item:


buscar_item:


atualizar_item:
	

imprimir_itens:


sair:
	li $v0,10
	syscall
