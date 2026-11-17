import 'dart:io';

// Original didactic diagrams. Run from the repository root; no dependencies.
void main() {
  Directory('doc/images').createSync(recursive: true);
  for (final pt in [false, true]) {
    final suffix = pt ? 'pt-BR' : 'en';
    String label(String en, String br) => pt ? br : en;
    void save(String name, String title, String content, {int height = 340}) {
      File('doc/images/$name.$suffix.svg').writeAsStringSync('''
<svg xmlns="http://www.w3.org/2000/svg" width="880" height="$height" viewBox="0 0 880 $height" role="img" aria-labelledby="title desc">
<title id="title">$title</title><desc id="desc">$title</desc>
<defs><marker id="arrow" markerWidth="8" markerHeight="8" refX="7" refY="4" orient="auto"><path d="M0 0L8 4L0 8" fill="#3561a5"/></marker></defs>
<rect width="880" height="$height" rx="16" fill="#f4f7fc"/>
<g font-family="Arial, sans-serif" fill="#152c48">$content</g></svg>
''');
    }

    final loopTitle = label('How reinforcement learning works',
        'Como funciona o aprendizado por reforço');
    save('learning-loop', loopTitle, '''
<text x="32" y="40" font-size="24" font-weight="bold">$loopTitle</text>
<rect x="48" y="95" width="255" height="100" rx="12" fill="#e3ddff" stroke="#6e55b3"/>
<text x="175" y="133" text-anchor="middle" font-size="21">${label('Agent', 'Agente')}</text>
<text x="175" y="164" text-anchor="middle" font-size="15">${label('Choose using Q(state, action)', 'Escolhe usando Q(estado, ação)')}</text>
<rect x="575" y="95" width="255" height="100" rx="12" fill="#d8f0e8" stroke="#288067"/>
<text x="702" y="133" text-anchor="middle" font-size="21">${label('Environment', 'Ambiente')}</text>
<text x="702" y="164" text-anchor="middle" font-size="15">${label('Advance and return feedback', 'Avança e devolve o resultado')}</text>
<path d="M303 122H568" stroke="#3561a5" stroke-width="3" fill="none" marker-end="url(#arrow)"/>
<text x="440" y="107" text-anchor="middle" font-size="16">${label('action', 'ação')}</text>
<path d="M575 177H312" stroke="#3561a5" stroke-width="3" fill="none" marker-end="url(#arrow)"/>
<text x="440" y="209" text-anchor="middle" font-size="16">${label('reward + next state', 'recompensa + próximo estado')}</text>
<text x="48" y="263" font-size="18">Q ← Q + α × (target − Q)</text>
<text x="48" y="300" font-size="16">${label('Train: update values. Evaluate: freeze learning and measure the policy.', 'Treino: atualiza valores. Avaliação: congela o aprendizado e mede a política.')}</text>
''');
    final mazeTitle = label(
        'GridWorld: one shortest path', 'GridWorld: um dos caminhos mínimos');
    final cells = StringBuffer();
    const path = {0, 1, 2, 3, 4, 9, 14, 19, 24};
    for (var s = 0; s < 25; s++) {
      final x = 34 + (s % 5) * 56, y = 75 + (s ~/ 5) * 56;
      final wall = {7, 12, 17}.contains(s);
      final color = wall
          ? '#40536a'
          : path.contains(s)
              ? '#c7eedd'
              : '#e1e7f0';
      cells.write(
          '<rect x="$x" y="$y" width="50" height="50" rx="7" fill="$color"/>');
      cells.write(
          '<text x="${x + 25}" y="${y + 30}" text-anchor="middle" font-size="16" fill="${wall ? '#ffffff' : '#152c48'}">$s</text>');
    }
    save(
        'maze',
        mazeTitle,
        '''
<text x="32" y="40" font-size="24" font-weight="bold">$mazeTitle</text>
$cells
<path d="M59 88H283V306" fill="none" stroke="#156549" stroke-width="3" marker-end="url(#arrow)"/>
<text x="365" y="105" font-size="19">${label('Start: 0   Goal: 24', 'Início: 0   Objetivo: 24')}</text>
<text x="365" y="149" font-size="18">${label('8 moves = 7 × (−1) + 10 = +3', '8 movimentos = 7 × (−1) + 10 = +3')}</text>
<text x="365" y="193" font-size="17">${label('Walls: 7, 12, 17', 'Paredes: 7, 12, 17')}</text>
<text x="365" y="237" font-size="16">${label('Green: illustrated route. Dark: blocked cells.', 'Verde: rota ilustrada. Escuro: células bloqueadas.')}</text>
<text x="365" y="281" font-size="16">${label('This route is an illustration, not a unique policy.', 'Esta rota é ilustrativa; outras rotas mínimas existem.')}</text>
<text x="365" y="325" font-size="16">${label('The terminal move returns +10 instead of −1.', 'O movimento terminal retorna +10 no lugar de −1.')}</text>
''',
        height: 385);
    final ucbTitle = label(
        'UCB1: value + uncertainty bonus', 'UCB1: valor + bônus de incerteza');
    save('ucb', ucbTitle, '''
<text x="32" y="40" font-size="24" font-weight="bold">$ucbTitle</text>
<text x="32" y="78" font-size="17">${label('Worked example: 101 observations (A: 100, B: 1)', 'Exemplo calculado: 101 observações (A: 100, B: 1)')}</text>
<text x="32" y="125" font-size="18">A</text><rect x="70" y="102" width="144" height="32" fill="#5274c8"/><rect x="214" y="102" width="55" height="32" fill="#d8942e"/>
<text x="290" y="125" font-size="17">0.800 + 0.304 = 1.104</text>
<text x="32" y="180" font-size="18">B</text><rect x="70" y="157" width="36" height="32" fill="#5274c8"/><rect x="106" y="157" width="547" height="32" fill="#d8942e"/>
<text x="70" y="220" font-size="17">0.200 + 3.038 = 3.238 → ${label('choose B', 'escolher B')}</text>
<text x="32" y="270" font-size="16">${label('Blue: observed mean. Orange: sqrt(2 × ln(101) / count).', 'Azul: média observada. Laranja: sqrt(2 × ln(101) / contagem).')}</text>
<text x="32" y="310" font-size="16">${label('The index may exceed 1. It is not a probability or a success prediction.', 'O índice pode superar 1. Ele não é uma probabilidade nem uma previsão de sucesso.')}</text>
''');
  }
}
