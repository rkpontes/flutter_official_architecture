# Flutter Official Architecture

Este projeto passa a seguir como referência o guia oficial do Flutter para arquitetura de aplicações:

- https://docs.flutter.dev/app-architecture/guide
- https://docs.flutter.dev/app-architecture/case-study

O objetivo é manter uma base escalável, testável e previsível, com separação explícita entre UI e Data layer, uso de MVVM na camada de apresentação e fluxo de dados unidirecional.

## Princípios adotados

- Separação de responsabilidades entre UI, domínio e dados.
- Views e ViewModels com relação 1:1 por feature.
- Repositories como source of truth dos dados da aplicação.
- Services como wrappers stateless de APIs externas e storage.
- Modelos de domínio imutáveis sempre que possível.
- Commands para encapsular ações assíncronas iniciadas pela UI.
- Testes separados por camada.

## Estrutura do projeto

Atualmente o projeto está organizado assim:

```text
lib/
  data/
    repositories/
    services/
  domain/
    models/
    use_cases/
  routing/
  ui/
    add_update/
    home/
      view_models/
      widgets/
    show/
  utils/
  injector.dart
  main.dart
```

Essa estrutura segue parcialmente a recomendação oficial:

- `ui/` concentra views e view models por feature.
- `data/` concentra repositories e services por tipo.
- `domain/` concentra models e use cases.

## Aderência ao guia oficial

O projeto já está alinhado com estes pontos do guia:

- Separação entre UI layer e Data layer.
- Uso de repositories e services.
- Uso de views e view models.
- Uso de `go_router` para navegação.
- Uso de commands para eventos assíncronos da UI.
- Presença de testes por camada.

Diferenças atuais em relação ao guia/case study:

- A injeção de dependência está implementada com `get_it`, enquanto o case study oficial usa `provider`.
- Existe uma camada de domínio com `use_cases`, que no guia é opcional e recomendada apenas quando a complexidade justificar.
- Nem todo ViewModel expõe estado via `ChangeNotifier`; hoje os `Command`s usam `ChangeNotifier`, mas os ViewModels ainda podem evoluir para se aproximar mais do padrão do case study oficial.

Essas diferenças são conscientes e devem ser consideradas em futuras refatorações.

## Documentação complementar

As decisões de arquitetura e o mapeamento detalhado para o guia oficial estão em:

- [docs/architecture.md](docs/architecture.md)

## Dependências principais

- `flutter`
- `go_router`
- `dio`
- `shared_preferences`
- `logging`
- `get_it`

## Como executar

```bash
flutter pub get
flutter run --dart-define-from-file=.env
```

## Como testar

```bash
flutter test
```
