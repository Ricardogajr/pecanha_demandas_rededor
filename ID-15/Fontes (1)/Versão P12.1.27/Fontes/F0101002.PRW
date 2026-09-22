#Include 'Protheus.ch'

/*
{Protheus.doc} F0101002()
PE F050ROT para adicionar botões de recusa na rotina FINA050.
@Author     Tiago Paulo Silva
@Since      28/04/2016
@Version    P12.7
@Project    MAN00000462901_EF_010
@param      aRotina, array, descricao
@Return		aRet, Vetor aRotina
*/
User Function F0101002(aRotina)

	Local lBloq := OAPP:CMODNAME $ SuperGetMV("FS_XBLOQCP",,.T.)

	IF  !lBloq .And. Funname() == 'FINA050'
		AAdd(aRotina, {'Recusar'        , 'U_F010101A'              , 0, 3} )
		AAdd(aRotina, {'Cancelar Recusa', 'U_F010101PCANCELARECUSA' , 0, 3} )
	Endif

	AAdd(aRotina, {'Hist. Recusa'   , 'U_F010101G'              , 0, 3})

Return aRotina