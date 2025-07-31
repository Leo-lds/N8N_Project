# Tutorial : Instalando o N8N a partir desse Repositório

Este guia completo irá detalhar o processo de configuração do seu ambiente no Windows, desde a instalação das ferramentas essenciais até a clonagem e execução do seu projeto N8N personalizado.

---

### **Entendendo a Arquitetura (Por que usar N8N em Modo Fila?)**

Antes de começar, é importante entender os componentes que estamos usando e por que eles tornam sua automação mais poderosa e robusta.

#### **N8N em Modo Fila (`Queue Mode`)**
Em vez de rodar o N8N como um único processo, nós o separamos em múltiplos serviços especializados. Isso evita que a interface do usuário (o editor) trave ou fique lenta enquanto fluxos de trabalho pesados ou demorados estão sendo executados. Sua configuração divide o trabalho da seguinte forma:
* **Editor (`n8n-editor`):** Onde você cria e gerencia seus workflows.
* **Workers (`n8n-workers`):** Processos dedicados exclusivamente a executar os workflows. Você pode ter vários workers para processar muitas tarefas em paralelo. (docker-compose up -d --scale n8n-workers=X para escalar a quantidade de trabalhadores.)
* **Webhooks (`n8n-webhooks`):** Um serviço otimizado apenas para receber chamadas de webhooks instantaneamente, sem sobrecarregar o editor.

#### **PostgreSQL + `pgvector` (O Cérebro Persistente)**
O PostgreSQL é o banco de dados que atua como a memória permanente do seu N8N. Ele armazena:
* Todos os seus workflows.
* Suas credenciais de forma segura.
* O histórico de todas as execuções.

A imagem `ankane/pgvector` que você escolheu adiciona um superpoder: a capacidade de armazenar e consultar "vetores". Isso é essencial para aplicações de Inteligência Artificial, permitindo que você crie workflows com busca semântica, assistentes de IA e muito mais.

#### **Redis (O Gerenciador de Filas)**
O Redis funciona como um sistema de mensagens ou um "gerenciador de tráfego" extremamente rápido. Quando um workflow precisa ser executado (seja por um webhook ou manualmente), a solicitação não vai direto para o worker. Em vez disso, ela é colocada em uma fila no Redis. Os workers, que estão sempre monitorando essa fila, pegam a próxima tarefa disponível e a executam. Isso garante que nenhuma tarefa seja perdida e que o sistema possa lidar com picos de demanda de forma eficiente.

---

### **Passo 1: Instalação das Ferramentas de Desenvolvimento (Manual)**

Vamos instalar cada ferramenta de desenvolvimento manualmente, baixando os instaladores de seus sites oficiais.

#### **1.1. Visual Studio Code**

* Acesse o [site oficial do Visual Studio Code](https://code.visualstudio.com/download).
* Baixe o instalador "User Installer" para Windows (64 bit).
* Execute o arquivo `.exe` baixado e siga as instruções do assistente de instalação. Você pode manter as opções padrão.

#### **1.2. Python**

* Acesse a [página de downloads do Python](https://www.python.org/downloads/windows/).
* Clique no link para a versão estável mais recente do Python 3.
* Execute o instalador.
* **Importante:** Na primeira tela do instalador, certifique-se de marcar a caixa de seleção **"Add Python to PATH"** antes de clicar em "Install Now".

#### **1.3. Git**

* Acesse o [site oficial do Git](https://git-scm.com/download/win).
* O download do instalador para Windows 64-bit deve começar automaticamente.
* Execute o instalador e prossiga com as opções padrão. Durante a instalação, será incluído o **Git Bash**, um terminal que usaremos mais tarde.

---

### **Passo 2: Instalação e Configuração do Docker Desktop**

O Docker é a peça central para executar o N8N.

1.  **Habilitando os Recursos Necessários do Windows:**
    * Abra o PowerShell como Administrador (`Win + X` > "Terminal do Windows (Admin)").
    * Execute os seguintes comandos:
        ```powershell
        dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
        dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
        ```
    * **Reinicie o seu computador** para que as alterações sejam aplicadas.

2.  **Instalando o Kernel do WSL 2:**
    * Após reiniciar, abra o PowerShell e execute:
        ```powershell
        wsl --install
        ```
    * Pode ser necessário reiniciar o computador novamente.

3.  **Instalando o Docker Desktop:**
    * Acesse o [site oficial do Docker Desktop](https://www.docker.com/products/docker-desktop/) e baixe o instalador para Windows.
    * Execute o instalador e siga as instruções, garantindo que a opção para usar o WSL 2 esteja marcada.
    * Após a instalação, inicie o Docker Desktop.

4.  **Verificando a Instalação do Docker:**
    * Abra um novo terminal (PowerShell) e execute:
        ```bash
        docker --version
        docker-compose --version
        ```
    * Você deverá ver as versões do Docker e do Docker Compose sendo exibidas.

---

### **Passo 3: Clonando e Configurando seu Projeto N8N**

Agora vamos baixar seu projeto e usar o script de setup para configurar o ambiente.

#### **3.1. Abrir o Git Bash**

O script `setup.sh` é um script de shell (Linux/macOS). Para executá-lo no Windows, usaremos o **Git Bash**, que foi instalado junto com o Git.

* No menu Iniciar, procure por "**Git Bash**" e abra-o.

#### **3.2. Clonar o Repositório**

* Dentro do terminal Git Bash, execute o comando abaixo para baixar os arquivos do seu projeto:
    ```bash
    git clone [https://github.com/Leo-lds/N8N_Project.git](https://github.com/Leo-lds/N8N_Project.git)
    ```

#### **3.3. Acessar a Pasta do Projeto**

* Agora, entre na pasta que acabou de ser criada:
    ```bash
    cd N8N_Project
    ```

#### **3.4. Executar o Setup (1ª Vez)**

* Seu repositório contém um script para facilitar a configuração. Execute-o pela primeira vez para criar o arquivo de variáveis de ambiente:
    ```bash
    ./setup.sh
    ```
* O script irá detectar que o arquivo `.env` não existe, criá-lo a partir do `.env.example` e exibir uma mensagem pedindo para você editá-lo.

#### **3.5. Editar o Arquivo `.env`**

* Abra a pasta `N8N_Project` no **Visual Studio Code**.
* Localize o novo arquivo chamado `.env` e abra-o.
* Altere as variáveis de USER, PASSWORD`:
    ```env
    # Postgres
    DB_TYPE=postgresdb
    DB_POSTGRESDB_HOST=n8n-postgres
    DB_POSTGRESDB_PORT=5432
    DB_POSTGRESDB_DATABASE=n8n
    DB_POSTGRESDB_USER=your_user
    DB_POSTGRESDB_PASSWORD=your_password

    ```
* **Salve o arquivo** após fazer as alterações.

#### **3.6. Finalizar o Setup (2ª Vez)**

* Volte para o terminal **Git Bash**.
* Agora que o arquivo `.env` está configurado corretamente, execute o script de setup novamente. Desta vez, ele irá iniciar os contêineres do Docker.
    ```bash
    ./setup.sh
    ```
* O Docker começará a baixar as imagens e a iniciar os serviços. Aguarde a conclusão do processo.

---

### **Passo 4: Verificação Final**

1.  **Verifique os Contêineres:** Para confirmar que tudo está rodando, execute no Git Bash:
    ```bash
    docker-compose ps
    ```
    Você deverá ver os serviços `n8n-editor`, `n8n-postgres` e `n8n-redis` com o status "running" ou "up".

2.  **Acesse o N8N:** Abra seu navegador e acesse [http://localhost:5678](http://localhost:5678). Você deverá ver a interface do N8N pronta para ser configurada.