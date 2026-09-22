#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"

/*
{Protheus.doc} A300MLDR()
Ponto de Entrada para liberação dos Modelos para edição, de acordo com a Revisão que deseja customizar
@authora Thais Paiva - 9897642
@data 08/10/2020
*/
User Function A300MLDR()
Local oMdlCn9 := FwModelActive()

oMdlCn9:GetModel("CN9MASTER"):GetStruct():SetProperty("CN9_GRPAPR",MODEL_FIELD_WHEN,{||.T.})
oMdlCn9:GetModel("CN9MASTER"):GetStruct():SetProperty("CN9_APROV",MODEL_FIELD_WHEN,{||.T.})

Return 
