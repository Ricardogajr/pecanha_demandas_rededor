#Include 'Protheus.ch'

/*/{Protheus.doc} F0700802 
Metodo deletar Fabricante via WS
@author Fernando Carvalho
@since 27/01/2017
@version 1.0
@param oFabriCod, objeto, (Descrição do parâmetro)
@Project MAN0000007423041_EF_008
/*/
User Function F0700802(oFabriCod)
    Local cRetorno := ""
    Local aCampos  := {}


    aCampos := {;
                    {"P13_FILIAL", oFabriCod:cFilial     },;
                    {"P13_COD"   , oFabriCod:cCOD        }; //-- função pra pegar o ID
                }
    
    cRetorno := U_F0700006("P13", {2}, "F0700701", 1, aCampos) //-- chamar função de log

    aCampos := ASize(aCampos,0)
    aCampos := Nil

Return cRetorno

