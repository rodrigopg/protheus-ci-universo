# protheus-ci-universo

Repositório com o exemplo de CI/CD apresentado na palestra code no code: **Linha Protheus - Jornada CI/CD Protheus** no Universo TOTVS 2024.

Para baixá-lo, faça um clone deste repositório em seu ambiente local: `git clone https://github.com/totvs/protheus-ci-universo`.

Dúvidas podem ser encaminhadas via issue neste repositório. Sugestões via Pull Requests.

## Exemplo Protheus com Docker

Se deseja subir o ambiente Protheus via Docker deste exemplo veja o tópico [Ambiente Protheus com Docker](#ambiente-protheus-com-docker).

## Pipeline (etapas)

Esta pipeline de exemplo consiste em 4 etapas (veja aba Actions deste repositório):

```
on push
  ├── 1. Code Analysis (inspeção - CI) -> Realiza a execução da análise de qualidade de código;
  ├── 2. Build (construção - CI) -> Compila os fontes e gera o RPO Custom;
  ├── 3. TIR (teste - CD*/CI) -> Baixa o RPO custom e realiza os testes usando o TIR sem interface;
  └── 4. Patch Gen (artefato final - CD) -> Gera um patch com os fontes Protheus do repositório.
```

Esta pipeline foi configurada para executar sequencialmente, cada uma das etapas depende que a anterior tenha sido executada com sucesso para continuar.

A definição está no arquivo `.github/workflows/pipeline.yml`, onde cada etapa é um job do GitHub Actions que executa alguns scripts para realizar a tarefa da etapa em questão.

\* Como explicamos na apresentação, o TIR depende de um ambiente Protheus em execução para funcionar, logo precisamos subir um ambiente de teste com o RPO atualizado, neste ponto fazemos uma espécie de CD para subir um ambiente local em Docker.

### Solução para execução do TIR em ambiente local

Conforme explicado no tópico [Ambiente Protheus com Docker](#ambiente-protheus-com-docker), para subir o ambiente com essas imagens Docker de desenvolvimento e base iniciada, é necessário passar como volume os RPOs, includes, dicionários e INIs.

Como alguns artefatos são privados e não podemos disponibilizar publicamente (como RPO e dicionários), deixamos esses arquivos num servidor privado e na pipeline apenas fazemos o download deles na hora de subir a base Protheus.

Você pode seguir o mesmo conceito (usando um servidor HTTP ou repositório privado) para baixar os artefatos na pipeline ou criar uma imagem customizada já contendo os artefatos embarcados, veja o tópico: [Herdando imagem base](#herdando-imagem-base).

Uma outra solução seria executar um agent on promise (hospedado em sua infraestrutura) dos runners do GitHub ([veja aqui a documentação sobre isso](https://docs.github.com/pt/actions/hosting-your-own-runners/managing-self-hosted-runners/about-self-hosted-runners)) conectado a uma instância Docker para execução dos jobs da pipeline. Dessa forma os artefatos ainda estariam seguros e poderiam ser passados por volume para o runner e container protheus.

### Tratamento de falhas nos testes do TIR

Para tratar os erros e falhas dos scripts de testes do TIR, é necessário que o script da suíte tenha um tratamento para quebrar em caso de falhas. Para isso adicione a seguinte instrução no final da suíte:

```python
runner = unittest.TextTestRunner(verbosity=2)
result = runner.run(suite)

if len(result.errors) > 0 or len(result.failures) > 0:
    print("custom exit")
    exit(1)
```

### Visão aba Actions

Na imagem* abaixo é possível ver uma execução com sucesso da pipeline, onde foram executadas as 4 etapas e gerado os artefatos (custom rpo e patch) para aplicação no ambiente.

![image](https://github.com/totvs/protheus-ci-universo/assets/10109480/92e4c354-76b1-4432-982f-2fc44bf75aea)

\* Imagem anexada pois a retenção máxima do GitHub Actions é de 90 dias.

## Ambiente Protheus com Docker

As imagens Docker de desenvolvimento que fornecemos contém apenas os arquivos binários (ex.: AppServer e DBAccess), portanto os outros artefatos como RPO, dicionário e INI devem ser passados por volume.

Se deseja subir o ambiente Protheus via Docker deste exemplo (que usamos para executar os testes do TIR), siga os seguintes passos:

1. Baixe os seguintes artefatos: **includes** (apenas para compilações), **rpo** default e o **dicionário**;
2. Adicione na [pasta protheus](#estrutura-de-pastas) os artefatos baixados em suas respectivas subpastas (essas subpastas são volumes no compose que sobe o ambiente: `./ci/docker/docker-compose.yml`);
3. Execute o script: `cd protheus-ci-universo && bash ci/scripts/up_env.sh` para iniciar o compose do ambiente;
4. Configure os dados do ambiente (ip/porta webapp) nas configs do TIR (`tir/config.json`) caso tenha alterado o INI.

Após isso o ambiente pode ser acessado via webapp: `http://localhost:8080`.

O banco de dados é uma imagem PostgreSQL já com a estrutura de dicionário iniciada (empresa 99).

### Herdando imagem base

Caso deseje você também pode criar uma nova imagem (Dockerfile) adicionando os artefatos (RPO e/ou dicionário) e herdando (FROM) as nossas imagens como base para não precisar volumar os arquivos.

Porém não recomendados essa prática para o `custom.rpo` por exemplo, pois dessa forma cada vez que o container for encerrado, tudo que foi compilado será perdido.

## Scripts extras

Estes são os scripts extras desta pipeline de exemplo:

1. `up_env.sh`: Sobe a stack ambiente Protheus local em Docker;
2. `down_env.sh`: Remove a stack do ambiente Protheus;
4. `list-files.sh`: Lista os arquivos de código fonte Protheus para geração do patch;

## Estrutura de pastas

Este projeto contém a seguinte estrutura de pastas e seus respectivos propósitos:

```
.
├── .github
│    └── workflows
│         └── pipeline.yml (pipeline GitHub Actions)
├── analyser               (arquivos do analisador estático)
│    ├── config.json       (arquivo de configuração do analisador)
│    └── output            (saída da execução da análise)
├── ci
│    ├── scripts           (scripts externos da pipeline)
│    └── docker            (arquivos para execução do ambiente Protheus local)
├── protheus               (arquivos para execução local do Protheus e AppServer command line via Docker)
│    ├── apo               (volume dos RPOs do ambiente Protheus)
│    ├── includes          (volume dos includes da compilação)
│    └── systemload        (volume dos arquivos de dicionário)
├── src                    (códigos-fonte)
└── tir                    (suítes de testes e configuração para execução do TIR)
```

## Links e documentações relacionadas

- [Protheus via Docker](https://docker-Protheus.engpro.totvs.com.br)
- [Imagens Docker Protheus](https://hub.docker.com/u/totvsengpro)
- [Code Analysis via Docker](https://hub.docker.com/r/totvsengpro/advpl-tlpp-code-analyzer)
- [Sonar/Code Analysis Rules](https://sonar-rules.engpro.totvs.com.br/menu/rules)
- [AppServer command line](https://tdn.totvs.com/pages/viewpage.action?pageId=6064914)
- [TIR](https://github.com/totvs/tir)
- [Git](https://git-scm.com)
- [Docker](https://docs.docker.com)
- [CodeAnalysis](https://codeanalysis.totvs.com.br)
