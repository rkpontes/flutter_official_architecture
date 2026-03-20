# Architecture

Este documento define a arquitetura adotada neste projeto com base no guia oficial do Flutter:

- https://docs.flutter.dev/app-architecture/guide
- https://docs.flutter.dev/app-architecture/case-study

Ele serve como referência para evolução da base e para revisão de novas features.

## Objetivo

A arquitetura deve:

- facilitar manutenção e testes;
- reduzir acoplamento entre UI, regras de negócio e acesso a dados;
- manter fluxo de dados previsível;
- permitir crescimento por feature sem degradar a organização do código.

## Camadas

### UI layer

Responsável por:

- renderizar widgets;
- reagir a mudanças de estado;
- encaminhar interações do usuário;
- evitar lógica de negócio em widgets.

Componentes:

- `Views`: widgets e composições de widgets que representam uma feature.
- `ViewModels`: classes que preparam estado para a UI e expõem comandos.

Regras:

- cada feature deve ter uma relação 1:1 entre view e view model;
- widgets não devem acessar repositories nem services diretamente;
- lógica em widgets deve ficar restrita a:
  - condições simples de renderização;
  - layout responsivo;
  - animação;
  - roteamento simples.

### Data layer

Responsável por:

- acessar fontes externas de dados;
- aplicar caching, tratamento de erro e transformação de dados;
- ser a source of truth da aplicação.

Componentes:

- `Services`: wrappers stateless para APIs externas, storage e integrações.
- `Repositories`: coordenam acesso aos services e expõem dados em formato de domínio.

Regras:

- services não mantêm estado de negócio;
- repositories são o único ponto autorizado a mutar dados persistentes;
- repositories não devem conhecer outros repositories diretamente.

### Domain layer

No guia oficial, essa camada é opcional. Neste projeto ela existe e contém:

- `models/`
- `use_cases/`

Uso recomendado:

- quando a lógica é complexa;
- quando existe reutilização entre múltiplos view models;
- quando há composição de múltiplos repositories.

Evitar criar use cases triviais sem ganho real de clareza.

## Padrão arquitetural

Seguimos MVVM na UI:

- `View` exibe estado e repassa eventos;
- `ViewModel` prepara estado e executa ações;
- `Model` é representado principalmente por repositories, services e models de domínio.

## Fluxo de dados

O fluxo deve ser unidirecional:

1. A view dispara uma ação do usuário.
2. O view model executa um command ou método próprio.
3. O view model delega mutações e leitura para use cases e/ou repositories.
4. O repository consulta services e transforma os dados.
5. O resultado volta para o view model.
6. A UI é atualizada a partir do novo estado.

## Estrutura de pastas

Estrutura atual:

```text
lib/
  data/
    repositories/
      book/
    services/
      api_client/
      local_storage/
  domain/
    models/
      book/
    use_cases/
      book/
  routing/
  ui/
    add_update/
      widgets/
    home/
      view_models/
      widgets/
    show/
      widgets/
  utils/
```

Estrutura recomendada pelo guia oficial para evolução:

```text
lib/
  ui/
    core/
    <feature_name>/
      view_models/
      widgets/
  domain/
    models/
  data/
    repositories/
    services/
    models/
  routing/
  config/
  utils/
  main.dart
```

## Mapeamento do projeto atual

### UI

- `lib/ui/home/widgets/home_screen.dart`
- `lib/ui/home/view_models/home_view_model.dart`
- `lib/ui/add_update/widgets/add_update_screen.dart`
- `lib/ui/show/widgets/show_screen.dart`

### Data

- `lib/data/repositories/book/book_repository.dart`
- `lib/data/repositories/book/book_repository_local.dart`
- `lib/data/repositories/book/book_repository_remote.dart`
- `lib/data/services/api_client/api_client.dart`
- `lib/data/services/api_client/api_client_impl.dart`
- `lib/data/services/local_storage/local_storage.dart`
- `lib/data/services/local_storage/local_storage_impl.dart`

### Domain

- `lib/domain/models/book/book.dart`
- `lib/domain/use_cases/book/*.dart`

## Dependency injection

O guide/case study oficial recomenda `provider` como solução de DI.

Estado atual do projeto:

- DI implementada em `lib/injector.dart`;
- uso de `get_it` como service locator;
- view models resolvidos no roteador por `GetIt`.

Essa abordagem funciona, mas difere da recomendação principal do guia. Ao alterar a arquitetura no futuro, seguir esta ordem de preferência:

1. manter dependências explícitas via construtor;
2. evitar acesso global fora do bootstrap;
3. considerar migração gradual para `provider` caso a base cresça.

## Commands

O projeto usa `lib/utils/command.dart`, alinhado com a recomendação do case study para encapsular ações assíncronas da UI.

Responsabilidades dos commands:

- evitar execução concorrente indevida;
- expor `running`, `completed` e `error`;
- notificar a UI durante o ciclo assíncrono;
- padronizar tratamento de loading e erro.

## Models

Diretriz adotada:

- models de domínio devem representar o formato consumido pela aplicação;
- models de API, quando existirem, devem ficar separados dos models de domínio;
- preferir imutabilidade.

Hoje o projeto já possui models de domínio em `lib/domain/models/`. Conforme a base crescer, modelos específicos de API devem ser colocados em `lib/data/models/`.

## Testing

A estratégia de testes deve seguir o guia:

- unit tests para services;
- unit tests para repositories;
- unit tests para view models;
- widget tests para views;
- uso de fakes para dependências.

Estrutura atual já segue essa direção:

```text
test/
  data/
  domain/
  ui/
  utils/
```

## Regras para novas features

Ao adicionar uma nova feature:

1. criar a view em `lib/ui/<feature>/widgets/`;
2. criar o view model em `lib/ui/<feature>/view_models/`;
3. reutilizar repositories existentes quando o dado já tiver source of truth;
4. criar novo repository apenas para um novo tipo de dado;
5. criar service apenas quando houver nova fonte externa;
6. adicionar use case somente se houver ganho real de reutilização ou redução de complexidade;
7. adicionar testes por camada.

## Regras para revisão de código

Mudanças devem ser questionadas se:

- colocarem lógica de negócio em widgets;
- fizerem a UI acessar repository/service diretamente;
- espalharem mutação de estado fora do repository;
- adicionarem acoplamento entre repositories;
- criarem use cases sem necessidade;
- introduzirem dependências globais desnecessárias.

## Divergências atuais registradas

As seguintes divergências em relação ao case study oficial estão aceitas no estado atual:

- uso de `get_it` no lugar de `provider`;
- uso explícito de `use_cases` em uma aplicação ainda pequena;
- ausência de `ui/core/` para componentes compartilhados;
- ausência de models específicos de API em `lib/data/models/`.

Esses pontos não bloqueiam o projeto, mas devem orientar futuras refatorações.
