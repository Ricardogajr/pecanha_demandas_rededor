#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} FILEMOT
PE para customizar as opções do motivo da baixa de título
@type User function
@author Paulo D
@since 022/06/2021
@version 12.1.27
@project DOR09011948 	
@return cFile
/*/
User Function FILEMOT()

Local cFile  := PARAMIXB[1] //  arquivo original
Local cParBx := GetMv('FS_XBAI') // parâmetro que pega qual o arquivo usar na system
Local cColab := GetMv('FS_XUSR') // parâmetro que pega qual usuário pode acessar 

If FunName() $ 'FINA080' 
        If RetCodUsr() $ cColab
            cFile := cParBx // "_SIGAADV.MOT"// pasta System
        EndIf
Else 
    If FunName() $ 'FINA750' .AND. !ALTERA
        If RetCodUsr() $ cColab
            cFile := cParBx // "_SIGAADV.MOT"// pasta System
        EndIf
    EndIf
EndIf

Return cFile


