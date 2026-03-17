; Second Project
; P3.4 is used for output to buzzer
; Timer 0 將用來處理與音階相關,並設定 Timer 0 為mode 1
; Timer 1 將用來處理與節拍相關,並設定 Timer 1 為mode 1
;此程式將不斷循環播放,每次播完將停4拍當作間隔,所以最後的節拍將是4拍的休止符
;依據音階的高低,得出音頻所相對應的頻率
;再由此頻率,求出要產此頻率的clock在Timer上相對應的count數,並將此count數,load到Timer 0的 TH0/TL0
;例如 以G4為例,  G4相對應的頻率是 392Hz
;		F = 391Hz,  T = 1/392 = 2551微渺
;		One half of T for the high and Low = 1275.5微渺
;
;		(假設此實驗板頻率為11.0592 MHz,1 machine cycle=12 clock)
;		則 1 machine cycle = 1.085微秒
;		所以count數 = 65535 - (1275.5/1.085) + 1 = 65537-1175+1 = 64361
;		64361 => FB69H(16進位)
;		TH0 = FB,  TL0 = 69

;以下是根據所要播出曲子的音階,所算出相對應Timer的TH0, TL0值, 
;若為休止符則設定 TH0=0, TL0=0, 並在程式中以此來判斷是否為休止符
;播完曲子後停4拍後,再重新播放
;
NOTE:	DB	0FDH,0B5H	;i
	DB	0FDH,92H	;7
	DB	0FCH,5BH	;3
	DB	0FDH,45H	;6
	DB	0FCH,0F0H	;5
	DB	0FBH,69H	;1
	DB	0FBH,0E9H	;2
	DB	0FCH,5BH	;3
	DB	0FCH,90H	;4
	DB	00H,00H		; 1拍休止符
	DB	0FAH,8AH	; 6
	DB	0FBH,23H	; 7
	DB	0FBH,69H	;1
	DB	0FBH,0E9H	;2
	DB	0FCH,5BH	;3
	DB	0FCH,90H	;4
	DB	0FCH,0F0H	;5
	DB	0FDH,45H	;6
	DB	0FDH,92H	;7
	DB	0FEH,2EH	;3^
	DB	00H,00H		; 2.5拍休止符
	DB	0FDH,0B5H	;i
	DB	0FDH,92H	;7
	DB	0FCH,5BH	;3
	DB	0FDH,45H	;6
	DB	0FCH,0F0H	;5
	DB	0FBH,69H	;1
	DB	0FCH,24H	;#2
	DB	0FCH,5BH	;#3
	DB	0FCH,0C1H	;4
	DB	00H,00H		;休止符,最後停4拍後,重新播放	


;產生節拍的方法:
;(1)以 ♩=70, 一拍的時間長度約是 0.857秒.   ( ♩=60, 一拍的時間長度是 1秒)
;(2)Timer register(16 bits)的最大值是65535, number of count = 65535-0+1=65536
;	1 count 約 1.085微秒 ( 頻率=11.0592 MHz/12=921.6 kHz.  週期=1/921.6 kHz=1.085微秒)

; 	所以Timer能產生的最大時間值是 1.085微秒 X 65536 = 0.0711秒

;(3) 一拍的時間長度約 0.857秒.  要利用Timer產生一拍的時間長度 0.857秒,則需循環使用Timer M 次
;	M = 0.857/0.0711 = ~12
;(4)所以要產生一拍的時間0.857秒 M=12, 產生半拍時間 M=6, 產生二拍時間 M=24, 以此類推
;(5)在本程式中,設定 R2=M值, 利用DJNZ指令, 當 R2=0時, 表示完成節拍的時間

;以下是根據所要播出曲子的節拍,所算出相對應 循環使用Timer 的次數 M
;產生一拍的時間(0.857秒) M=12, 產生半拍時間 M=6, 產生二拍時間 M=24, 以此類推
;播完曲子後停4拍後,再重新播放
TEMPO:	DB	12	;i
	DB	12	;7
	DB	12	;3
	DB	12	;6
	DB	12	;5
	DB	12	;1
	DB	30	;2
	DB	6	;3
	DB	24	;4
	DB	12	; 1拍休止符	
	DB	24	; 6
	DB	6	; 7
	DB	6	;1	
	DB	6	;2
	DB	6	;3
	DB	6	;4
	DB	6	;5
	DB	6	;6
	DB	6	;7
	DB	42	;3^
	DB	30	; 2.5拍休止符		
	DB	12	;i
	DB	12	;7
	DB	12	;3
	DB	12	;6
	DB	12	;5
	DB	12	;1
	DB	30	;#2
	DB	6	;#3
	DB	36	;4
	DB	48	; 休止符,最後停4拍後,重新播放	


	ORG	00H

	MOV 	TMOD,#00010001B ;設定Timer 0,Timer 1為mode 1 (16-bit timer)

START:	MOV	R0,#0	;R0作為index of DPTR來提取儲存音階高低的TH0,TL0值
	MOV	R1,#0	;R1作為暫時index,用來提取儲存音階高低的TL0位置內的內容(音階高低的TL0的數值),
	MOV	R2,#0	;R2作為控制節拍的長短用,每次減1,當減至0時,代表當次音階的拍子結束
	MOV	R3,#0	;R3作為index來提取儲存代表 節拍長短需循環使用 Timer的次數值(控制節拍長短的數值)
	CLR 	P3.4	;Clear P3.4

	CLR	TR0	;停止Timer 0
	CLR	TR1	;停止Timer 1
	CLR 	TF0	;初始化TF0,Clear Timer 0 flag,TF0
	CLR 	TF1	;初始化TF1,Clear Timer 1 flag,TF1

;根據所要求的頻率,將算出相對應的Timer number of count值,load到Timer’s registers TH0及TL0,因而產生所要求的音頻
NEXT:	MOV	DPTR,#TEMPO	;將儲存音階節拍的address放入DPTR
	MOV	A,R3		;將目前的R3值(index) load到A
	MOVC	A,@A+DPTR	;利用此index值來提取儲存代表節拍長短需循環使用 Timer的次數值
	MOV	R2,A		;再將此代表節拍長短的數值load到R2
	
	MOV	TH1,#0		;設定Timer 1, TH1為0
	MOV	TL1,#0		;設定Timer 1, TL1為0,當TH1,TL1皆為0時,將產生使用Timer能產生的最大時間值 
				;播放的音階的節拍是此最大時間值的倍數
	SETB 	TR1		;啟動Timer 1(Mode 1)
	CJNE	R1,#62,THERE	;檢查目前播放的音階是否為最後的一個音階(最後的一個音階設定為4拍的休止符(無聲))
				;若不是最後的一個音階 go to THERE繼續下一個音階的播放
	JMP 	START		;若是最後的一個音階,jump to START結束此段撥放的音階,然後重新開始播放

NEXT_1:	INC	R1		;將index R1加2,以便提取下一個音階的TH0,TL0值
	INC	R1
	INC	R3		;將index R3加1,以便提取下一個節拍 需循環使用Timer 的次數
	CLR 	P3.4		;Clear P3.4
	JMP	NEXT		;Jump to NEXT,準備播放下一個音階
	
THERE:	JNB	TF1,HERE	;判斷目前正在播放的音階的時間長度(即節拍)是否結束,若未結束Jump to 
				;HERE,繼續目前音階的播放
	CLR 	TR1 		;若結束,停止 Timer 1
	CLR 	TF1		;Clear Timer 1 flag,TF1
	MOV	TH1,#0		;設定Timer 1, TH1為0
	MOV	TL1,#0		;設定Timer 1, TL1為0,當TH1,TL1皆為0時,將產生使用Timer能產生的最大時間值 
				;播放的音階的節拍是此最大時間值的倍數
	SETB 	TR1		;啟動Timer 1,開始下一個最大時間值的計時
	DJNZ	R2,HERE		;將R2減1,然後判斷目前正在播放的音階的時間長度(即節拍)是否結束,若 
				;未結束Jump to HERE,繼續目前音階的播放				
	JMP	NEXT_1		;若結束,Jump to NEXT_1,準備播放下一個音階及節拍

;以下程式是將根據音階高低所對應的的頻率,計算出Timer register TH0,TL0的對應值(16進位)
;以此TH0,TL0值產生播放音階所對應的頻率的Clock輸出到P3.4(Buzzer)來產生不同高低的音階
HERE:	MOV	A,R1		;將index R1,load到A,以便提取下一個要播放音階的TH0值
	MOV	R0,A		;暫存此Index到R0,使R0的值可用於提取TL0值	
	MOV	DPTR,#NOTE	;將存放播放音階相對應的TH0,TL0值的起始Address, load到DPTR
	MOVC	A,@A+DPTR	;利用A為index,提取放播放音階相對應的TH0值,並將此值load到A
	JZ	THERE		;處理休止符:檢查並判斷目前的音階是否為休止符(TH0=0),若是Jump to THERE
				;去處理休止符時間長度(即節拍)
 	MOV 	TH0,A 		;若不是則將放播放音階相對應的TH0值load到TH0
	INC	R0		;增加index R0+1,以便提取下一個Byte,TL0值
	MOV	A,R0		;將index R0,load到A,以便提取將要播放音階的TL0值	
	MOVC	A,@A+DPTR	;利用A為index,提取放播放音階相對應的TL0值,並將此值load到A
	MOV	TL0,A		;將放播放音階相對應的TL0值load到TL0
	
	CPL 	P3.4 		;toggle P3.4
	ACALL 	DLY 		;Call DLY去產生此Clock 1/2週期的時間
	SJMP 	THERE 		;Jump到THERE 檢查判斷目前正在播放的音階的時間長度(即節拍)是否結束,
				;若未結束Jump to HERE,繼續目前音階的播放
			
DLY: 	SETB 	TR0 		;啟動Timer 0
CHECK: 	JNB 	TF0,CHECK 	;檢查Timer 0是否rolls over,若沒有繼續檢查
	CLR 	TR0 		;若有,表示所設定的Clock 1/2週期的時間到了,停掉Timer 0
	CLR 	TF0 		;clear timer 0 flag,TF0
	RET 			;返回主程式

	END