#include "rwmake.ch"  //producao
#include "Protheus.ch"  
#INCLUDE "TopConn.ch"
#DEFINE   c_ent      CHR(13)+CHR(10)  

/*
|----------------------------------------------------------------------------|
|Programa  |MT110TOK  |Autor  |TECNOSUM            | Data |  15/06/2016       |
|----------------------------------------------------------------------------|
|Descrição |Ponto de entrada para validar a ALTERAÇÃO DE UMA SC              |						  
|----------------------------------------------------------------------------|
|Uso       |REDEDOR                                                          |						  
|----------------------------------------------------------------------------|
*/
************************
User Function MT110TOK()
************************
	Local aArea:= GetArea()
	Local cCodFil   	:= xFilial("SC1")
	Local cSol	  	:= PARAMIXB[1]
	Local c_GrApro	:= Space(TAMSX3("PZY_GRAPRO")[1])
	Local nPosTot  	:= ASCAN(aHeader,{|x| AllTrim(x[2]) == "C1_XTOTAL"})
	Local nPosTipo 	:= ASCAN(aHeader,{|x| AllTrim(x[2]) == "C1_XTPSC"})
	Local nPosItem 	:= ASCAN(aHeader,{|x| AllTrim(x[2]) == "C1_ITEM"})
	Local nPosMot  	:= ASCAN(aHeader,{|x| AllTrim(x[2]) == "C1_XMOTIVO"})
	Local aItens	:= {}
	Local lRet		:= .T.
	Local nVlrEsti := 0
	Local lMVXAPROSC    := GetMv("MV_XAPROSC") //Parametro que indica se a empresa utiliza APROVAÇÃO DE SC
	Local cMVXTPSCAP    := ALLTRIM(GetMv("MV_XTPSCAP")) //Parametro que indica se O TIPO exige aprovação de SC
	Local aCabec:={"C1_XIDBIO", "C1_XENVBIO", "C1_XDTCOTA", "C1_XHRCOTA", "C1_XIDPROC" } 
	Local nX := 0
	Local nY := 0
	Local nPosProd := aScan(aHeader, {|x| AllTrim(x[2]) == 'C1_PRODUTO'})
	Local nDel := len(aHeader)+1

	//Validacao das funcoes F0702404 e F0900101
	If nPosProd > 0
		For nY := 1 To Len(aCols)
			if !aCols[nY][nDel]
				lRet := U_F0702404(aCols[nY][nPosProd]) .and. U_F0900101(aCols[nY][nPosProd])
	
				if !lRet
					exit
				endif
			endif
		Next nY
	EndIf

	If lRet .and. lMVXAPROSC .and. !(Acols[1][nPosTipo] $ cMVXTPSCAP) //Caso tenha aprovação de SC e o tipo exige aprovacao

		dbSelectArea("PZY")
		dbSetOrder(1)
		If !(dbSeek(xFilial("PZY") + Acols[1][nPosTipo] ))
			lRet := .F.
			Alert("O Tipo da SC "+Alltrim(Acols[1][nPosTipo])+" não tem grupo de aprovação associado a ele. Efetue a amarração do Tipo SC x Grupo de Aprovação. ")
		Endif
	Endif

	If lRet .and. LCOPIA
		For nX := 01 To Len(aCabec)
			nPos := aScan(aHeader, {|x| AllTrim(x[2]) == aCabec[nX]})		
			If nPos > 0
				If aCabec[nX] == "C1_XDTCOTA"
					For nY := 1 To Len(aCols)		
						aCols[nY][nPos] := CToD("  /  /    ")
					Next nY
				Else	
					For nY := 1 To Len(aCols)		
						aCols[nY][nPos] := ""
					Next nY
				EndIf
			EndIf			
		Next nX
	EndIf

	RestArea(aArea)
Return(lRet)   

