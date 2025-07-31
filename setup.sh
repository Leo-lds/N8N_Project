#!/bin/bash

echo "🚀 Iniciando o setup do ambiente N8N..."

# Verifica se o Docker está instalado
if ! command -v docker &> /dev/null
then
    echo "❌ Docker não está instalado. Instale o Docker antes de continuar."
    exit 1
fi

# Verifica se o Docker Compose está instalado
if ! command -v docker-compose &> /dev/null
then
    echo "❌ Docker Compose não está instalado. Instale o Docker Compose antes de continuar."
    exit 1
fi

# Cria diretórios de dados se não existirem
echo "📁 Verificando diretórios de dados..."
mkdir -p n8n-data postgres-data redis-data

# Cria o .env se não existir
if [ ! -f ".env" ]; then
    echo "📄 Arquivo .env não encontrado. Criando com base no .env.example..."
    cp .env.example .env
    echo "📝 Edite o arquivo .env com suas configurações antes de iniciar os containers."
    exit 0
fi

# Sobe os containers
echo "📦 Subindo os containers com Docker Compose..."
docker-compose up -d

echo "✅ Setup finalizado. Acesse o N8N em http://localhost:5678"
