#Maciej Kasprzyk
#zbioryJulii ARKO 20.10.2018

.macro print_int (%x)
	li $v0, 1
	add $a0, $zero, %x
	syscall
.end_macro

.macro print_int_shift (%x)
	move $s6, %x
	sra $s6, $s6, 26
	li $v0, 1
	add $a0, $zero, $s6
	syscall
.end_macro

.macro print_str (%str)
	.data
myLabel: .asciiz %str
	.text
	li $v0, 4
	la $a0, myLabel
	syscall
.end_macro
		.data
				
fileName:	.asciiz "julio.bmp"
fileErrorMsg:	.asciiz "Blad pliku\n"

		.text
		.globl main
main:
	
prepareBmpHeader:
	##############################################################
	#t0 - 
	#t1 - 
	#t2 - iterator po bajtach headera
	#t3
	#t4
	#t5
	#t6
	#t7 - rejestr do wczytywania iteralow
	#t8 - adres buforu headera
	#t9 - 
	##############################################################
	
	#alokacja miejsca na buffer headeru pliku bmp
	#syscall 9 allocalte heap memory
	li $a0, 54
	li $v0, 9
	syscall
	
	move $t8, $v0 #zapamietanie adresu tablicy headera 
	move $t2, $v0 #wskaznik pomocniczy, uzyty do stworzenia headera
	
	# https://en.wikipedia.org/wiki/BMP_file_format#Example_1
	#'BM'
	
	li $t7, 0x42
	sb $t7, ($t2)
	addi $t2, $t2, 1
	
	li $t7, 0x4D
	sb $t7, ($t2)
	addi $t2, $t2, 1
	
	#FileSize
	li $t7, 0x24
	sb $t7, ($t2)
	addi $t2, $t2, 1
	li $t7, 0xEA
	sb $t7, ($t2)
	addi $t2, $t2, 1
	li $t7, 0x2D
	sb $t7, ($t2)
	addi $t2, $t2, 2
	
	#bajty aplikacji
	addi $t2, $t2, 4
	
	#offset of pixel array
	li $t7, 0x36
	sb $t7, ($t2)
	addi $t2, $t2, 4
	
	#liczba bitow w hederze od tego miejsca
	li $t7, 0x28
	sb $t7, ($t2)
	addi $t2, $t2, 4
	
	#width obrazka
	li $t7, 0xE9
	sb $t7, ($t2)
	addi $t2, $t2, 1
	li $t7, 0x03
	sb $t7, ($t2)
	addi $t2, $t2, 3
	
	#height obrazka
	li $t7, 0xE9
	sb $t7, ($t2)
	addi $t2, $t2, 1
	li $t7, 0x03
	sb $t7, ($t2)
	addi $t2, $t2, 3
	
	#numbler of color planes
	li $t7, 0x01
	sb $t7, ($t2)
	addi $t2, $t2, 2
	
	#number of bits per pixel
	li $t7, 0x18
	sb $t7, ($t2)
	addi $t2, $t2, 2
	
	#pozniej same zera
	addi $t2, $t2, 24
	
preparePixelTable:
	##############################################################
	#t0 - adres tablicy przechowujacej tablice pixeli
	#t1 - pomocnicyz do obliczen
	#t2 - licznik wierszy
	#t3 - licznik pikseli w wierszu
	#t4 - actual pixel real part
	#t5 - actual pixel imaginary part
	#t6 - pomocniczy do obliczen
	#t7 - pomocniczny do obliczen
	#t8 - adres buforu headera
	#t9 - pomocniczy wskaznik na aktualny element tablicy pixeli
	#s1 - ciag_r
	#s2 - ciag_i
	#s3
	#s4
	#s5 - kolor
	##############################################################
	
	#alokacja miejsca na tablice pixeli
	#(1001px/wiersz + 1px(padding do 4 bajtow)/wiersz) * 1001 wierszy * 3 bajty/pixel = 3,009,006 czyli ok 3 MB
	#syscall 9 allocalte heap memory
	li $a0, 3009006
	li $v0, 9
	syscall
	
	move $t0, $v0	# zapamietanie adresu pameci w rejestrze t0
	move $t9, $v0   # i pomocniczego wskaznika na tblice pixeli
	
	# X liczba bitow po przecinku
	
	li $t5, 134217728 #ustawienie actual pixel imaginary part 2 przesuniete w lewo o X bitow
	li $t2, 1001 #ustawienie licznika wierszy na 1001
	
	print_str("Start petli\n")
	
forEveryPixelRow: #repeat 1001 times
	
	li $t4, -134217728 #ustawienie actual pixel real part
	li $t3, 1001 #ustawienie licznika pixeli na 1001
	
	
	forEveryPixel:
		
		move $s1, $t4 #pierwszy wyraz real part
		move $s2, $t5 #pierwszy wyraz imaginary part
		move $s5 , $zero #zerujemy iterator koloru
		
		checkNextTermOfSequence:
			#liczymy nastepny wyraz ciagu
			#s1 czesc real wyrazu
			#s2 czesc im wyrazu
			#t1 przechowuje czasowo stara czesc rzeczywista, potrzebna do obliczen czesci urojonej
			move $t1, $s1
			#t6 bedzie przechowywac kwadrat czesci rzeczywitej
			#t7 bedzie przechowywac kwadrat czesci zespolonej
			
			#print_str("kolor:")
			#print_int($s5)
			#print_str("\n")
			
			#print_str("przed:")
			#print_int_shift($s1)
			
			mult $s1, $s1 #kwadrat czesci rzeczywitej
			mfhi $s3
			#print_str(" mfhi:")
			#print_int($s3)
			sll $s3, $s3, 6
			#print_str(" mfhi:")
			#print_int($s3)
			mflo $s4
			#print_str(" mflo:")
			#print_int($s4)
			srl $s4, $s4, 26
			#print_str(" mflo:")
			#print_int($s4)
			or $t6, $s3, $s4
			#print_str(" and:")
			#print_int_shift($t6)
			
			#print_str("przed:")
			#print_int($s2)
			mult $s2, $s2 #kwadrat czesci urojonej
			mfhi $s3
			#print_str(" mfhi:")
			#print_int($s3)
			sll $s3, $s3, 6
			#print_str(" mfhi:")
			#print_int($s3)
			mflo $s4
			#print_str(" mflo:")
			#print_int($s4)
			srl $s4, $s4, 26
			#print_str(" mflo:")
			#print_int($s4)
			or $t7, $s3, $s4
			#print_str(" and:")
			#print_int_shift($t7)
				
			
			#print_str("\n")
			
				
			sub $s1, $t6, $t7 # nowa czesc rzeczywista = real^2 - im^2 +...
			subi $s1, $s1, 8254390 # +c_r (<< X)
			
			mult $t1, $s2 #nowa czesc zespolona = real * im * 2
			mfhi $s3
			sll $s3, $s3, 6
			mflo $s4
			srl $s4, $s4, 26
			or $s2, $s3, $s4
			sll $s2, $s2, 1 # *2
			addi $s2, $s2, 49996104 #+ c_i (<< X)
			
			#print_int_shift($t6)
			#print_str(" ")
			#print_int_shift($t7)
			#print_str("\n")
			#t1 teraz bedzie przechowywac przechowuje kwadrat modulu
			add $t1, $t6, $t7
			
			addi $s5, $s5, 1 #zwieksz licnzik koory
			
			bge $t1, 268435456, endLoop #zakoncz jesl kwadrat modulu wiekszy niz 4 (<< X)
			#print_str("kwadrat modulu byl mniejszy niz 4\n")
			bge $s5, 31, endLoop #zmienic po debagu na 31
			j checkNextTermOfSequence
			
		endLoop:
			
		#zapisz obliczony odcien koloru do tablicy pixeli	
		#t9 pomocniczy wskazni na akt element tablicy pixeli 
	
		sll $s5, $s5, 3 # pomnozenie razy bo max_iter to 31 a kolorow moze byc 256
		
		sb $s5, ($t9)
		addi $t9, $t9, 1
		sb $s5, ($t9)
		addi $t9, $t9, 1
		sb $s5, ($t9)
		addi $t9, $t9, 1
			
			
		#zwiekszenie czesci rzeczywsitej 0.004 <<X
		addi $t4, $t4, 268435
		
		
		subi $t3, $t3, 1
		bnez $t3, forEveryPixel
	#dodanie paddingu 
	addi $t9, $t9, 1
	
	#zmniejszenie czesci urojonej
	subi $t5, $t5, 268435 #0.004 (<< X)
	
	#licznik petli
	subi $t2, $t2, 1
	
	print_int($t2)
	print_str("\n")
	
	bnez $t2, forEveryPixelRow
	
	print_str("Koniec petli\n")
	
saveTofile:
	##############################################################
	#t0 - adres tablicy przechowujacej tablice pixeli
	#t1 - 
	#t2
	#t3
	#t4
	#t5
	#t6
	#t7 - 
	#t8 - adres buforu headera
	#t9 - deskryptor pliku
	##############################################################
	
	#syscall 13 open file
	la $a0, fileName
	li $a1, 1
	li $a2, 0
	li $v0, 13
	syscall
	
	move $t9, $v0  #skopiowanie deskryptora pliku do t9
	
	#jesli nie otwarto pliku to skok do fileError
	bltz $v0, fileError
	
	#syscall write to file
	move $a0, $t9
	move $a1, $t8
	li $a2, 54
	li $v0, 15
	syscall
	
	#syscall write to file
	move $a0, $t9
	move $a1, $t0
	li $a2, 3009006
	li $v0, 15
	syscall
	
	#syscall close file
	move $a0, $t0
	li $v0, 16
	syscall

	b exit
	
fileError:
		
	#syscall print msg
	la $a0, fileErrorMsg
	li $v0, 4
	syscall
	
exit:	
	# syscall exit programu:
	li $v0, 10
	syscall
