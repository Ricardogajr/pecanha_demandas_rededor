#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'   

/*{Protheus.doc} AVALCOPC()
PE para manipular cada PC gravado pela analise da cotacao.
@Author     robson william
@Since      05/04/2017
@Version    P12.7
@Project    MAN0000007423043
*/
User Function AVALCOPC()
Local aRet := ParamIxb //{cFilAnt,SC7->C7_NUM,aRatFin,MaFisRet(1,"IT_TOTAL")}

U_F0900202(aRet)

Return aRet
