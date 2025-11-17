# Peçanha — RedeD’or · Lista de Demandas

Este repositório consolida as demandas solicitadas pelo cliente Peçanha — RedeD’or e serve como base de versionamento de artefatos, fontes e documentação de entrega.

Fonte dos itens: Lista de Demandas no Notion.[[1]](https://www.notion.so/2aa4a28b9f2380fb9f7cf2d8a0b482c5?pvs=21)

Itens detalhados: ID‑1, ID‑2, ID‑3 e ID‑4.[[2]](https://www.notion.so/ID-1-2aa4a28b9f238011a1ded9e7d6218850?pvs=21)[[3]](https://www.notion.so/ID-2-2aa4a28b9f23805ebaf7f2e0c77be50e?pvs=21)[[4]](https://www.notion.so/ID-3-2aa4a28b9f238016ab31efa5769f0979?pvs=21)[[5]](https://www.notion.so/ID-4-2aa4a28b9f23802f9c2efa214221bafa?pvs=21)

---

## Etapas do Trabalho

1) Levantamento e especificação

- Alinhar objetivo, escopo e campos envolvidos em SP, SE2 e SC7.
- Validar restrições de acesso para “Portador” e regras de somatório de retenção.

2) Modelagem e desenho técnico

- Definir novos campos e impactos em integrações e lançamentos padrão.
- Mapear origem dos dados: M0_MUNICIPIO → SE2.

3) Desenvolvimento

- Implementar campos nas telas/rotinas e nas tabelas (SE2, SC7).
- Adequar lançamentos para considerar retenção contratual.

4) Testes e validação

- Casos de teste por cenário de pagamento, retenção e desconto.
- Homologação funcional com o solicitante.

5) Implantação e handover

- Publicar fontes e scripts.
- Entregar documentação final e atualizar o histórico.

---

## Demandas

### ID‑1 — Retenção contratual no contas a pagar

- Status: Concluído
- Prioridade: Alta
- Prazo: 2025‑11‑18
- Conclusão: 2025‑11‑15
- Solicitante: Marcus Peçanha
- Descrição: Criar novo campo na SP e no contas a pagar para indicar retenção contratual e ajustar lançamentos padrão para considerar a retenção.
- Regra na SE2: carregar o valor de retenção em E2_DECRES somando ao desconto de C7_XDESFIN quando houver.[[2]](https://www.notion.so/ID-1-2aa4a28b9f238011a1ded9e7d6218850?pvs=21)

Entrega esperada

- Campo de retenção disponível na SP e refletido em SE2.
- Lançamentos padrão atualizados para considerar a retenção.

Métricas de aceite

- Título em SE2 com E2_DECRES = Retenção + C7_XDESFIN quando aplicável.
- Sem regressão em cenários sem retenção.

---

### ID‑2 — CNPJ gerador da despesa (serviço)

- Status: Não iniciada
- Prioridade: Alta
- Prazo: 2025‑11‑21
- Solicitante: Marcus Peçanha
- Descrição: Criar novo campo na SP e no contas a pagar para destacar o CNPJ da empresa geradora da despesa. O campo deve ser alimentado pela NF‑se do sistema de captura de notas (integração).[[3]](https://www.notion.so/ID-2-2aa4a28b9f23805ebaf7f2e0c77be50e?pvs=21)

Entrega esperada

- Campo de CNPJ visível na SP e persistido em SE2.
- Alimentação automática via integração da NF‑se.

Critérios de aceite

- CNPJ preenchido corretamente para NFs de serviço integradas.
- Logs de integração sem erros de mapeamento.

---

### ID‑3 — Município e descrição do município no contas a pagar

- Status: Não iniciada
- Prioridade: Alta
- Prazo: 2025‑11‑23
- Solicitante: Marcus Peçanha
- Descrição: Criar novo campo na transação de SP e na SE2 para identificar Município e Descrição do Município da unidade tomadora. Carregar a partir de M0_MUNICIPIO (SYS_COMPANY).[[4]](https://www.notion.so/ID-3-2aa4a28b9f238016ab31efa5769f0979?pvs=21)

Entrega esperada

- Novos campos em SP e SE2.
- Carga automática a partir de SYS_COMPANY.M0_MUNICIPIO.

Critérios de aceite

- Preenchimento consistente entre SP e SE2.
- Validação cruzada com a filial/unidade tomadora.

---

### ID‑4 — Portador de pagamento com acesso restrito

- Status: Não iniciada
- Prioridade: Alta
- Prazo: 2025‑11‑27
- Solicitante: Marcus Peçanha
- Descrição: Criar campo “Portador” na SP para informar o portador do título a pagar. Edição somente para usuários com o grupo “ACESSO PORTADOR SP”.[[5]](https://www.notion.so/ID-4-2aa4a28b9f23802f9c2efa214221bafa?pvs=21)

Entrega esperada

- Campo Portador disponível na SP.
- Regra de permissão por grupo aplicada na edição.

Critérios de aceite

- Usuário sem o grupo não consegue editar o campo.
- Auditoria de alteração registrando usuário e data.

---

## Tabela Resumo

| Código | Prioridade | Status | Prazo | Conclusão | Solicitante |
| --- | --- | --- | --- | --- | --- |
| ID‑1 | Alta | Concluído | 2025‑11‑18 | 2025‑11‑15 | Marcus Peçanha |
| ID‑2 | Alta | Não iniciada | 2025‑11‑21 | — | Marcus Peçanha |
| ID‑3 | Alta | Não iniciada | 2025‑11‑23 | — | Marcus Peçanha |
| ID‑4 | Alta | Não iniciada | 2025‑11‑27 | — | Marcus Peçanha |

---

## Como contribuir

- Abra issues por demanda, vinculando o ID correspondente.
- Commits devem referenciar o ID: feat(ID‑3): descrição curta.
- Use PRs com checklist de testes funcionais e validação de dados.

## Licença

Defina aqui a licença do repositório.

[[1]](https://www.notion.so/2aa4a28b9f2380fb9f7cf2d8a0b482c5?pvs=21): Página “Lista de Demandas”.

[[2]](https://www.notion.so/ID-1-2aa4a28b9f238011a1ded9e7d6218850?pvs=21): Detalhes da demanda ID‑1.

[[3]](https://www.notion.so/ID-2-2aa4a28b9f23805ebaf7f2e0c77be50e?pvs=21): Detalhes da demanda ID‑2.

[[4]](https://www.notion.so/ID-3-2aa4a28b9f238016ab31efa5769f0979?pvs=21): Detalhes da demanda ID‑3.

[[5]](https://www.notion.so/ID-4-2aa4a28b9f23802f9c2efa214221bafa?pvs=21): Detalhes da demanda ID‑4.