//#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"

/*
|----------------------------------------------------------------------------|
|Programa  |RDDA002  |Autor  |TECNOSUM            | Data |  31/03/2016       |
|----------------------------------------------------------------------------|
|Descrição |Amarração Tipo SC x Grupo de Aprovação                         |						  
|----------------------------------------------------------------------------|
|Uso       |REDEDOR                                                          |						  
|----------------------------------------------------------------------------|
*/


User Function RDDA002()


Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "PZY"

dbSelectArea("PZY")
dbSetOrder(1)

AxCadastro(cString,"Amarração Tipo SC x Grupo de Aprovação",cVldExc,cVldAlt)
Return

