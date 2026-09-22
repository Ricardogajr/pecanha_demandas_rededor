#INCLUDE 'PROTHEUS.CH'
/*'
{Protheus.doc} C02005
Função para carga de dados executada direto pelo Menu do Fstools
@author	FsTools V6.2.14
@since 15/07/2016
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN00000463301_EF_005
*/
User Function C02005(lReadOnly)
Local aInfo := {'02','005','CARGA RELATORIO DE AMOSTRA EM EXCEL','15/07/2016','16:52','','','',''}
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
 Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga} 
EndIf 
aAdd(aCarga,{'U_C020051(lReadOnly)'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga} 
