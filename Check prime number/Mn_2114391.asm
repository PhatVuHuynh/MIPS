.data
#Bien
n1: .word 0 # So nguyen to
n2: .word 0 # So khong nguyen to
n1_str: .space 4 # Buffer cho n1
n2_str: .space 4 # Buffer cho n2

str_exit: .asciiz "NGUYENTO.txt"
str_so: .asciiz "So "
str_ko: .asciiz " khong nguyen to"
str_nguyento: .asciiz " nguyen to\n"
fdescr: .word 0

#Cac cau nhac xuat du lieu
str_tc: .asciiz "Thanh cong." 
str_loi: .asciiz "Mo file bi loi." 

.text

main:
	addi $t4, $0, 2 # So dem de xuat file, khi $t4 = 0 thi xuat file
		
	addi $v0, $0, 30     # Syscall 30: System Time syscall
	syscall                 
	add $t3, $0, $a0     # Luu gia tri cua $a0 vao $t3
	
	addi $v0, $0, 40     # Syscall 40: Random seed
	add $a0, $0, $0      # Dat RNG ID la 0
	add $a1, $0, $t3     # Dung $t3 lam seed ngau nhien
	syscall

Tao_so_ngau_nhien:
	beq $t4, $0, Tao_file	# Neu da du 2 so thi tien hanh xuat file

	addi $v0, $0, 42     # Syscall 42: Random int range
	addi $a0, $0, 0      # Dat RNG ID la 0 (Luu y: RNG ID nay phai bang voi RNG ID o syscall 40)
	addi $a1, $0, 9998   # Dat upper bound la 9998 (ko co 9998)
	syscall              # Tao 1 so ngau nhien trong doan [0, 9997]

	addi $a0, $a0, 2     # Tao 1 so ngau nhien trong doan [2, 9999] (Do yeu cau de bai la so trong khoang (1, 10000)

	jal Kiem_tra_so_nguyen_to
		
	#Neu la so khong nguyen to, gan so do cho n2
	beq $v1, $0, So_khong_nguyen_to
	
	#Neu la so nguyen to, gan so do cho n1		
	j So_nguyen_to	

##################################
#Xuat ket qua ra file NGUYENTO.TXT
##################################
Tao_file:
	lw $a0, n1 
	la $a1, n1_str 

	jal int_to_string # Chuyen n1 tu number -> string

	addi $t6, $v0, 0 # So ki tu can ghi cua buffer n1

	lw $a0, n2
	la $a1, n2_str

	jal int_to_string # Chuyen n2 tu number -> string

	addi $t7, $v0, 0 # So ki tu can ghi cua buffer n2

file_open:
	addi $v0, $0, 13
        la $a0, str_exit # Ten file
        addi $a1, $0, 1
        addi $a2, $0, 0
        syscall  # File descriptor tra ve $v0
        
        bltz $v0, baoloi # mo file khong duoc 
	sw $v0, fdescr
    
file_write:
	lw $a0, fdescr  # Syscall 15 can file descriptor vao $a0
    
        addi $v0, $0, 15
        la $a1, str_so
        addi $a2, $0, 3
        syscall		# Ghi chuoi "So " vao file
    
        la $a1, n1_str
        add $a2, $0, $t6
        addi $v0, $0, 15
        syscall		# Ghi chuoi cua n1 vao file
    
        la $a1, str_nguyento
        addi $a2, $0, 11
        addi $v0, $0, 15
        syscall		# Ghi chuoi " nguyen to\n" vao file
    
        addi $v0, $0, 15
        la $a1, str_so 
        addi $a2, $0, 3
        syscall		# Ghi chuoi "So " vao file
    
        la $a1, n2_str
        add $a2, $0, $t7
        addi $v0, $0, 15
        syscall		# Ghi chuoi cua n2 vao file
    
        la $a1, str_ko
        addi $a2, $0, 17
        addi $v0, $0, 15
        syscall		# Ghi chuoi " khong nguyen to" vao file
        
file_close:
        addi $v0, $0, 16  
        syscall
    
        j Xuat_ket_qua
   
int_to_string:
	addi $sp, $sp, -12
	sw $ra, 8($sp)	# Luu returned address vao stack
	sw $a1, 4($sp)	# Luu dia chi cua buffer vao stack
	sw $a0, ($sp)   # Luu gia tri cua $a0 vao stack

	addi $t0, $0, 10 
	addi $t5, $0, 10 # Dung de so sanh voi $a0 den khi nao $t5 > $a0
	addi $t1, $0, 1  # Dung de dem $a0 co bao nhieu chu so
	
buffer:	
	mul $t5, $t5, $t0 # $t5 = $t5 * 10
	
	# if($t5 < $a0) ++$t1;	
	slt $t4, $t5, $a0 
	beq $t4, $0, buffer_end
	addi $t1, $t1, 1
	bne $t4, $0, buffer

buffer_end:
	add $a1, $a1, $t1    # chi vao duoi cua buffer

#while($a0 != 0)
loop:
	div $a0, $t0
	mfhi $t3	# $t3 %= 10;
	mflo $a0 	# $a0 /= 10;
	
	addi $t3, $t3, 48	# $t3 = $t3 + '0'
	sb $t3, 0($a1)
	addi $a1, $a1, -1	# tro ve dia chi phia truoc dia chi hien tai
		
	bne $a0, $0, loop
	
	addi $v0, $t1, 1 	# tra ve so chu so cua $a0
		
	lw $a0, ($sp)
	lw $a1, 4($sp)	
	lw $ra, 8($sp)	
	addi $sp, $sp, 12
	jr $ra
	
########################
# Xuat ket qua (syscall) 
########################
Xuat_ket_qua:
	la $a0,str_tc 
	addi $v0,$zero,4 
	syscall 
	j Ket_thuc
	 
baoloi: 
	la $a0,str_loi 
	addi $v0,$zero,4 
	syscall 
	
########################
#ket thuc chuong trinh
########################
Ket_thuc:
	addi $v0,$0,10 
	syscall 
	
Kiem_tra_so_nguyen_to:
	addi $sp, $sp, -8
	sw $a0, ($sp)
	sw $ra, 4($sp)	
	
	addi $t5, $0, 2 	# $t5 = 2
	addi $v1, $0, 1 	# $v1 = 1 (Tra ve la 1 neu la so nguyen to, nguoc lai la 0)
	
	#if($a0 == 2) return 1;
	beq $t5, $a0, Kiem_tra_so_nguyen_to_done
	
	addi $t5, $0, 3 	# $t5 = 3
	
	#if($a0 == 3) return 1;
	beq $t5, $a0, Kiem_tra_so_nguyen_to_done
	
	addi $t5, $0, 2 	# $t5 = 2	

# while($t5 * $t5 <= $a0)
ktra_loop:
	#if($a0 % i == 0) return 0;
	divu $a0, $t5
	
	mfhi $t6 	# Lay so du
	
	beq $t6, $0, return_0 # Kiem tra $a0 co chia het cho $t5 khong
	
	addi $t5, $t5, 1 # ++$t5
	
	mulu $t7, $t5, $t5 # $t7 = $t5 * $t5
	
	#if($t7 <= $a0) <=> if($t7 < $a0 + 1) 
	addi $a0, $a0, 1
	slt $t8, $t7, $a0
	addi $a0, $a0, -1
		
	beq $t8, $0, Kiem_tra_so_nguyen_to_done
	
	j ktra_loop
	
return_0:
	addi $v1, $0, 0

Kiem_tra_so_nguyen_to_done:
	lw $a0, ($sp)
	lw $ra, 4($sp)	
	addi $sp, $sp, 8
	
	jr $ra

So_khong_nguyen_to:	
	#Truoc khi gan can kiem tra n2 co bang 0 
	lw $s1, n2
	bne $s1, $0, Tao_so_ngau_nhien # Neu n2 khac 0 thi tien hanh tao so ngau nhien moi
	
	# Neu n2 = 0 thi gan n2 = $a0
	sw $a0, n2
	addi $t4, $t4, -1	
	j Tao_so_ngau_nhien
	
So_nguyen_to:
	#Truoc khi gan can kiem tra n1 co bang 0 
	lw $s0, n1
	bne $s0, $0, Tao_so_ngau_nhien # Neu n1 khac 0 thi tien hanh xuat file

	# Neu n1 = 0 thi gan n1 = $a0
	sw $a0, n1
	addi $t4, $t4, -1
	j Tao_so_ngau_nhien



