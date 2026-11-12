FROM python:3.12-slim-bookworm

# Declarar ARG para capturar la variable de entorno durante el build (docker build --build-arg PROJECT_NAME=...)
#ARG PROJECT_NAME=qnd04111app

# Evitar prompts interactivos durante la instalación
ENV DEBIAN_FRONTEND=noninteractive
ENV PROJECT_NAME=${PROJECT_NAME}

# Instalar dependencias del sistema necesarias: git, gh-cli (GitHub CLI), curl, build-essential
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Instalar la CLI oficial de GitHub (gh)
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# Instalar 'uv' (gestor ultrarrápido de Python)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.cargo/bin:$PATH"

# Definir dinámicamente el directorio de trabajo usando la variable
WORKDIR /${PROJECT_NAME}

# Copiar todo el contexto actual al directorio de trabajo dinámico
COPY . /${PROJECT_NAME}/

# Asegurar permisos de ejecución en los scripts principales de forma dinámica
RUN chmod +x /${PROJECT_NAME}/deploy.sh

# El contenedor ejecutará por defecto el script principal de despliegue
CMD ["/bin/bash", "deploy.sh"]