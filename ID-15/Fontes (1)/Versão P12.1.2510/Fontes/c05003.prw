#INCLUDE 'PROTHEUS.CH'
/*'
{Protheus.doc} C05003
Função para carga de dados executada direto pelo Menu do Fstools
@author	FsTools V6.2.14
@since 08/11/2016
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN0000007423039_EF_003
@Project MAN00000463301_EF_003
*/
User Function C05003(lReadOnly)
Local aInfo := {'05', '003', 'CARGA CONTROLE SOLICITAÇÃO', '08/11/2016', '15:49', '', '', '', ''}
Local aSIX	:= {} 
Local aSX1	:= {}  
Local aSX2	:= {} 
Local aSX3	:= {} 
Local aSX6	:= {} 
Local aSX7	:= {} 
Local aSXA	:= {} 
Local aSXB	:= {} 
Local aSX3Hlp := {} 
Local aCarga  := {} 
DEFAULT lReadOnly := .f. 
If lReadOnly 
 Return {aInfo, aSIX, aSX1, aSX2, aSX3, aSX6, aSX7, aSXA, aSXB, aSX3Hlp, aCarga} 
EndIf 
aAdd(aCarga, {'U_C050031(lReadOnly)'})
Return {aInfo, aSIX, aSX1, aSX2, aSX3, aSX6, aSX7, aSXA, aSXB, aSX3Hlp, aCarga}

