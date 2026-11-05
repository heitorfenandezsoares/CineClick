# CineClick - Aplicação Móvel para APS

Projeto desenvolvido no âmbito da disciplina de **Atividades Práticas Supervisionadas (APS)**. O CineClick é um cliente móvel construído em **Flutter** e **Dart**, integrado aos serviços RESTful da API global **The Movie Database (TMDb)** para consulta e exibição de metadados cinematográficos em tempo real.

---

## 🏛️ Estrutura Arquitetural

O projeto foi estruturado seguindo o princípio de separação de responsabilidades e padrões de arquitetura cliente-servidor:

```text
lib/
├── controllers/
│   └── movie_controller.dart     # Gestão de estado (ChangeNotifier), filtros e fluxo de telas
├── models/
│   └── movie_model.dart          # Modelo POO com desserialização e serialização JSON
├── services/
│   ├── api_exceptions.dart       # Hierarquia de exceções customizadas de rede e parsing
│   └── tmdb_service.dart         # Comunicação HTTP/HTTPS REST com endpoints do TMDb
├── views/
│   ├── home_view.dart            # GUI responsiva com busca em tempo real e filtros
│   └── movie_detail_view.dart    # Apresentação aprofundada dos metadados
├── widgets/
│   └── movie_card.dart           # Componente ergonômico de exibição em grid
└── main.dart                     # Inicialização do app e injeção de dependências
```

---

## 🎯 Atendimento aos Objetivos Específicos da APS

1. **Arquitetura Cliente-Servidor:**  
   O aplicativo funciona como cliente leve desacoplado, consumindo endpoints remotos via HTTP/HTTPS sem armazenar dados fixos localmente.
2. **Consumo de APIs RESTful:**  
   Implementado em `lib/services/tmdb_service.dart`, consumindo `/movie/popular` e `/search/movie`.
3. **Serialização e Desserialização JSON:**  
   Implementado em `lib/models/movie_model.dart` através dos métodos `Movie.fromJson()` e `toJson()`.
4. **GUI Responsiva e Ergonômica:**  
   Implementada em `lib/views/home_view.dart` através de `LayoutBuilder` (adaptação automática para 2, 3 ou 5 colunas conforme a largura do dispositivo/janela).
5. **Tratamento de Exceções e Feedback Visual:**  
   Mapeamento de falhas em `lib/services/api_exceptions.dart` e renderização de quatro estados na UI: *Carregamento* (Loading Spinner), *Erro* (Mensagem clara com botão "Tentar Novamente"), *Vazio* (Empty State) e *Sucesso* (Grid com dados).

---

## 🚀 Como Executar o Projeto

### Pré-requisitos
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (versão 3.0 ou superior)
* Uma chave de API gratuita do [The Movie Database (TMDb)](https://www.themoviedb.org/settings/api)

### Passo a passo
1. Clone o repositório ou navegue até a pasta do projeto:
   ```bash
   cd CineClick
   ```
2. Abra o arquivo `lib/main.dart` e substitua a constante `tmdbApiKey` pela sua chave:
   ```dart
   const String tmdbApiKey = 'SUA_CHAVE_AQUI';
   ```
3. Instale as dependências:
   ```bash
   flutter pub get
   ```
4. Execute o aplicativo em seu emulador, celular físico ou navegador:
   ```bash
   flutter run
   ```
