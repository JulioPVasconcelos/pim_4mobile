# 📱 Chamados TI - Sistema de Gerenciamento de Suporte

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)

**Sistema mobile multiplataforma para gerenciamento de chamados de suporte de TI**

[Características](#-características) • [Instalação](#-instalação) • [Uso](#-uso) • [Tecnologias](#-tecnologias) • [Autores](#-autores)

</div>

---

## 📋 Sobre o Projeto

O **Chamados TI** é um aplicativo mobile desenvolvido como Trabalho de Conclusão de Curso (TCC) que permite o gerenciamento eficiente de chamados de suporte técnico em ambientes corporativos.

O sistema oferece diferentes níveis de acesso (Usuário Comum, Técnico e Administrador) e permite a abertura, acompanhamento e resolução de chamados de forma prática e organizada.

### 🎯 Problema que Resolve

- ✅ Centraliza solicitações de suporte em um único lugar
- ✅ Facilita comunicação entre usuários e equipe técnica
- ✅ Organiza chamados por prioridade e categoria
- ✅ Permite anexar fotos para melhor descrição do problema
- ✅ Oferece filtros para fácil localização de chamados

---

## ✨ Características

### 📱 Para Usuários Comuns
- 🔐 Login seguro com autenticação JWT
- ➕ Abertura de novos chamados
- 📷 Anexar fotos aos chamados
- 📋 Visualizar histórico de seus chamados
- 🔍 Filtrar chamados por status e prioridade
- 🔔 Ver detalhes completos de cada chamado

### 👨‍💻 Para Técnicos
- 📊 Visualizar chamados atribuídos
- 🔍 Filtrar por status e prioridade
- 👁️ Consultar detalhes dos chamados

### 👑 Para Administradores
- 📈 Visualizar todos os chamados do sistema
- 🔍 Filtros avançados
- 📊 Visão completa da operação

---

## 🚀 Tecnologias

### Core
- **[Flutter](https://flutter.dev/)** - Framework UI multiplataforma
- **[Dart](https://dart.dev/)** - Linguagem de programação

### Principais Pacotes

| Pacote | Versão | Uso |
|--------|--------|-----|
| [dio](https://pub.dev/packages/dio) | ^5.4.0 | Cliente HTTP para comunicação com API |
| [provider](https://pub.dev/packages/provider) | ^6.1.1 | Gerenciamento de estado |
| [shared_preferences](https://pub.dev/packages/shared_preferences) | ^2.2.2 | Armazenamento local de preferências |
| [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) | ^9.0.0 | Armazenamento seguro de tokens |
| [image_picker](https://pub.dev/packages/image_picker) | ^1.0.7 | Captura e seleção de imagens |
| [intl](https://pub.dev/packages/intl) | ^0.19.0 | Formatação de datas e internacionalização |

---

## 📦 Instalação

### Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>=3.0.0)
- [Android Studio](https://developer.android.com/studio) ou [Xcode](https://developer.apple.com/xcode/) (para iOS)
- [Git](https://git-scm.com/)

### Passo a Passo

1. **Clone o repositório**
```bash
git clone https://github.com/seu-usuario/chamados-ti.git
cd chamados-ti
```

2. **Instale as dependências**
```bash
flutter pub get
```

3. **Configure as permissões (Android)**

Edite `android/app/src/main/AndroidManifest.xml` e adicione:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

4. **Configure a URL da API**

Edite `lib/utils/constants.dart`:

```dart
static const String baseUrl = 'http://SUA_API_URL/api';
```

5. **Execute o aplicativo**
```bash
flutter run
```

---

## 🎮 Uso

### Credenciais de Teste (Versão Demo)

**Usuário Comum:**
```
Email: usuario@teste.com
Senha: 1234
```

**Técnico:**
```
Email: tecnico@teste.com
Senha: 1234
```

**Administrador:**
```
Email: admin@teste.com
Senha: 1234
```

### Fluxo de Uso

#### 1️⃣ Usuário Comum
```
Login → Ver Chamados → Criar Novo Chamado → Anexar Foto → Enviar
```

#### 2️⃣ Técnico
```
Login → Ver Chamados Atribuídos → Filtrar → Ver Detalhes
```

---

## 📱 Gerar APK para Distribuição

### APK Universal (Recomendado para testes)
```bash
flutter build apk
```

O arquivo será gerado em:
```
build/app/outputs/flutter-apk/app-release.apk
```

### APK Otimizado por Arquitetura
```bash
flutter build apk --split-per-abi
```

Gera 3 arquivos menores:
- `app-armeabi-v7a-release.apk` (32-bit)
- `app-arm64-v8a-release.apk` (64-bit) ← Mais comum
- `app-x86_64-release.apk` (Emuladores)

---

## 🏗️ Arquitetura

```
lib/
├── main.dart                 # Ponto de entrada
├── models/                   # Modelos de dados
│   ├── user.dart
│   ├── chamado.dart
│   └── categoria.dart
├── services/                 # Lógica de negócio
│   ├── auth_service.dart     # Autenticação
│   └── api_service.dart      # Comunicação com API
├── screens/                  # Telas
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── novo_chamado_screen.dart
│   └── detalhes_chamado_screen.dart
├── widgets/                  # Componentes reutilizáveis
│   └── chamado_card.dart
└── utils/                    # Utilitários
    └── constants.dart
```

### Padrões Utilizados

- **MVC (Model-View-Controller)** - Separação de responsabilidades
- **Provider** - Gerenciamento de estado reativo
- **Repository Pattern** - Abstração da camada de dados
- **Singleton** - ApiService único na aplicação

---

## 🔒 Segurança

- 🔐 Autenticação via **JWT (JSON Web Token)**
- 🔒 Tokens armazenados de forma segura com **Flutter Secure Storage**
- 🔑 Criptografia nativa (Keystore no Android / Keychain no iOS)
- ⏱️ Sessão persistente com opção "Manter conectado"

---

## 🎨 Interface

### Telas Principais

#### Login
- Validação de formulário
- Opção "Manter conectado"
- Mostrar/ocultar senha
- Feedback visual de loading

#### Home
- Listagem de chamados
- Pull-to-refresh
- Filtros (Status, Prioridade)
- FloatingActionButton condicional
- Estados vazios com feedback

#### Novo Chamado
- Formulário com validação
- Upload de fotos (Câmera/Galeria)
- Preview de imagem
- Dropdowns para Categoria e Prioridade

#### Detalhes
- Visualização completa do chamado
- Exibição de imagens
- Informações do solicitante e técnico
- Hierarquia visual clara

---

## 🧪 Testes

### Rodar Testes
```bash
flutter test
```

### Cobertura de Código
```bash
flutter test --coverage
```

---

## 📄 Estrutura de Dados

### Chamado
```dart
{
  "id": "1",
  "titulo": "Computador não liga",
  "descricao": "Descrição detalhada...",
  "status": "Aberto",
  "prioridade": "Alta",
  "categoria": "Hardware",
  "dataAbertura": "2025-10-23T14:30:00Z",
  "usuarioNome": "João Silva",
  "tecnicoNome": "Carlos Tech",
  "imagemUrl": "https://..."
}
```

### Usuário
```dart
{
  "id": "1",
  "nome": "João Silva",
  "email": "joao@empresa.com",
  "nivel": 1
}
```

**Níveis de Usuário:**
- `1` - Usuário Comum
- `2` - Técnico
- `5` - Administrador

---

## 🐛 Problemas Conhecidos

- ⚠️ Upload de imagens não funciona no Flutter Web (use Android/iOS)
- ⚠️ Caminhos de projeto com acentos causam erro no Gradle (Windows)

### Soluções

**Erro de acentos no caminho:**
```bash
# Mova o projeto para caminho sem acentos
# ❌ C:\Área de Trabalho\projeto
# ✅ C:\projetos\chamados_ti
```

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Siga estes passos:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/NovaFuncionalidade`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/NovaFuncionalidade`)
5. Abra um Pull Request

---

## 📝 Roadmap

- [ ] Notificações push
- [ ] Chat em tempo real entre usuário e técnico
- [ ] Dashboard com gráficos e estatísticas
- [ ] Modo offline com sincronização
- [ ] Tema escuro
- [ ] Suporte a múltiplos idiomas

---

## 👥 Autores

- **[Seu Nome]** - Desenvolvimento - [GitHub](https://github.com/seu-usuario)
- **[Nome do Colega 2]** - Backend - [GitHub](https://github.com/colega2)
- **[Nome do Colega 3]** - Design - [GitHub](https://github.com/colega3)

---

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 🙏 Agradecimentos

- [Flutter Team](https://flutter.dev/) pela excelente documentação
- [Material Design](https://material.io/) pelas diretrizes de UI/UX
- [UNIP](https://www.unip.br/) pelo apoio acadêmico
- Professores orientadores

---

## 📞 Contato

Para dúvidas ou sugestões:

- 📧 Email: seu.email@exemplo.com
- 💼 LinkedIn: [Seu Perfil](https://linkedin.com/in/seu-perfil)
- 🐦 Twitter: [@seu_usuario](https://twitter.com/seu_usuario)

---

<div align="center">

**⭐ Se este projeto te ajudou, deixe uma estrela! ⭐**

Feito com ❤️ e ☕ por [Sua Turma] - UNIP 2025

</div>
