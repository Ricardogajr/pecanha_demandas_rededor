/*{Protheus.doc} F430GRAFIL
O Ponto de Entrada F430GRAFIL, grava na tabela FIG, a filial pertencente ao CNPJ da linha header, contido do arquivo .ret.
@type  User Function
@author Thiago Góes
@since 23/06/2021
@version P12
@param      Paramixb[1]	Array	    Array contendo as da empresa logada
---------------------------------------------------------------------------------------------*/	


User Function F430GRAFIL()
         Local cFilOrig := PARAMIXB
         //MsgInfo('Filial de Origem:' + cFilOrig)
Return Nil
