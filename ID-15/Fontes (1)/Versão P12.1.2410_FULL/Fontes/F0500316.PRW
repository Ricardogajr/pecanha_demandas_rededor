#INCLUDE 	"TOTVS.CH"          
#INCLUDE    'RWMAKE.CH'
#INCLUDE 	"FWMVCDEF.CH"


/*/{Protheus.doc} F0500316
Função que atualiza os dados da PA2 
@author Marcos Furtado
@since 14/101/2016
@version 12.1.17
@project 
/*/

User Function F0500316()

		@ 200,001 TO 380,380 DIALOG oLeTxt TITLE OemToAnsi("Atualização de Campos - PA2")
		@ 002,010 TO 080,190
		@ 010,018 Say " Este programa ira ler a tabela SQG e atualziar os campos: "
		@ 018,018 Say " PA2_NMCAND  e PA2_CPFCAN da tabela PA2. "

		@ 60,128 BMPBUTTON TYPE 01 ACTION Processa({||OkAtuPA2()},"Atualizando...")
		                                  
		
		@ 60,158 BMPBUTTON TYPE 02 ACTION Close(oLeTxt)

		Activate Dialog oLeTxt Centered
                        
Return()       

Static Function OkAtuPA2() 

Local _nQtd := 0
DbSelectArea("PA2")
DbSetOrder(1)
DbGoTop()
ProcRegua(PA2->(RecCount()))
While !Eof()
    IncProc()
	DbSelectArea("SQG")    
	DbSetOrder(1)
    If DbSeek(xFilial("SQG")+PA2->PA2_CDCAND)
		RecLock("PA2",.F.)                  
		PA2->PA2_NMCAND := SQG->QG_NOME
		PA2->PA2_CPFCAN := SQG->QG_CIC    
		
		MsUnlock()
		_nQtd ++
	EndIf	             
	
	DbSelectArea("PA2")  
	DbSkip()         
End          
If _nQtd > 0
	Alert("Update Finalizado!")
Else
	Alert("Nenhum registo foi alterado!")	
EndIF

Return()
                   
