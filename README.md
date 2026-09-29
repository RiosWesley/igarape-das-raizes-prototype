# Igarape das Raizes

Primeira fase jogavel do prototipo de aventura 2.5D em Godot 4.7.2.

## Controles

- `WASD` ou setas: mover Eric.
- `E` / `Enter`: conversar com Teodoro e avancar o dialogo.
- `Esc`: fechar o dialogo.

## Conteudo desta iteracao

- Fase exploravel com colisoes de borda, agua, raizes, pedras, NPC e passarelas.
- Fundo animado usa o clipe original de 2 segundos em ida e volta, sem corte no loop; inclui mata alagada, igarape, ponte, casa, canoa, flores e lanternas.
- Efeitos vivos adicionais sobre o fundo: ondulacoes e vagalumes; os videos OGV ficam em `assets/backgrounds/`.
- HUD dinamica em 1280x720, composta por Controls e draw calls do Godot: retrato, vida, folego, objetivo e itens rapidos; o menu de acoes permanece fechado durante a exploracao.
- Eric com atlas v2 de 11 linhas, corrida baseada na faixa fornecida de 6 quadros (espelhada para a esquerda), idle, aceno, salto e olhares direcionais.
- Teodoro Barcos com sprite pixel-art proprio e dialogo em quatro falas.

Abra `project.godot` no Godot ou execute o projeto pelo editor. Os assets usados em runtime ficam em `assets/`.
