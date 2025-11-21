# CPU Cooler Display Controller

*[Português](#português) | [English](#english)*

An automated script to control USB CPU temperature displays on Linux systems.

## English

### 📋 Prerequisites

- Linux with systemd
- Python 3.6 or higher
- USB temperature display device (VID: 0xaa88, PID: 0x8666)
- sudo access (only for initial setup)

### 🚀 Automatic Installation

To install on a new machine, simply run:

```bash
git clone https://github.com/martiniano/cpu-cooler
cd cpu-cooler
./install.sh
```

#### What the script does:

1. **Automatic CPU detection**: Automatically identifies if you have Intel CPU (coretemp) or AMD (k10temp)
2. **Python environment setup**: Creates a virtual environment and installs necessary dependencies
3. **Permission configuration**: Installs udev rules for USB device access
4. **systemd service**: Configures the script to start automatically on boot
5. **Testing**: Verifies everything is working correctly

### 🔧 Manual Installation

If you prefer to install manually:

#### 1. Clone and configure environment:
```bash
git clone https://github.com/martiniano/cpu-cooler
cd cpu-cooler
python3 -m venv .venv
source .venv/bin/activate
pip install psutil pyusb
```

#### 2. Configure USB permissions:
```bash
sudo cp 99-cpu-cooler.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger
```

#### 3. Configure service:
```bash
# Edit cpu-cooler.service with correct paths
mkdir -p ~/.config/systemd/user
cp cpu-cooler.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now cpu-cooler.service
```

### 🛠️ Useful Commands

#### Check service status:
```bash
systemctl --user status cpu-cooler.service
```

#### View real-time logs:
```bash
journalctl --user -u cpu-cooler.service -f
```

#### Stop/start service:
```bash
systemctl --user stop cpu-cooler.service
systemctl --user start cpu-cooler.service
```

#### Test manually:
```bash
./.venv/bin/python cpu_cooler.py
```

### 🔍 Troubleshooting

#### Device not found:
- Check if device is connected: `lsusb | grep aa88:8666`
- Make sure udev rules were applied

#### Permission error:
- Check if udev file exists: `/etc/udev/rules.d/99-cpu-cooler.rules`
- Restart or disconnect/reconnect USB device

#### Temperature sensor not found:
- List available sensors: `python3 -c "import psutil; print(psutil.sensors_temperatures().keys())"`
- Edit `cpu_cooler.py` to use correct sensor

### 📁 Project Structure

```
cpu-cooler/
├── cpu_cooler.py           # Main script
├── cpu-cooler.service      # systemd service file
├── 99-cpu-cooler.rules     # udev rules for USB permissions
├── install.sh              # Automatic installation script
├── uninstall.sh            # Automatic uninstallation script
└── README.md               # This file
```

### 🎯 Compatibility

- **Intel CPUs**: Uses `coretemp` sensor
- **AMD CPUs**: Uses `k10temp` sensor
- **Others**: Script will try to use first available sensor

### ⚡ How it works

The script monitors CPU temperature every second and sends the value to the USB display. The display smooths temperature transitions for a more pleasant visualization.

### 🗑️ Uninstallation

To completely remove the CPU cooler service and all configurations:

```bash
./uninstall.sh
```

The uninstall script will:
- Stop and disable the systemd service
- Remove udev rules
- Optionally remove the Python virtual environment
- Optionally remove the entire project directory
- Terminate any running processes

---

## Português

### 📋 Pré-requisitos

- Linux com systemd
- Python 3.6 ou superior
- Dispositivo USB de display de temperatura (VID: 0xaa88, PID: 0x8666)
- Acesso sudo (apenas para configuração inicial)

### 🚀 Instalação Automática

Para instalar em uma máquina nova, simplesmente execute:

```bash
git clone https://github.com/martiniano/cpu-cooler
cd cpu-cooler
./install.sh
```

#### O que o script faz:

1. **Detecção automática do processador**: Identifica automaticamente se você tem CPU Intel (coretemp) ou AMD (k10temp)
2. **Configuração do ambiente Python**: Cria um ambiente virtual e instala as dependências necessárias
3. **Configuração de permissões**: Instala regras udev para acesso ao dispositivo USB
4. **Serviço systemd**: Configura o script para iniciar automaticamente no boot
5. **Teste**: Verifica se tudo está funcionando corretamente

### 🔧 Instalação Manual

Se preferir instalar manualmente:

#### 1. Clone e configure o ambiente:
```bash
git clone https://github.com/martiniano/cpu-cooler
cd cpu-cooler
python3 -m venv .venv
source .venv/bin/activate
pip install psutil pyusb
```

#### 2. Configure permissões USB:
```bash
sudo cp 99-cpu-cooler.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger
```

#### 3. Configure o serviço:
```bash
# Edite cpu-cooler.service com os caminhos corretos
mkdir -p ~/.config/systemd/user
cp cpu-cooler.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now cpu-cooler.service
```

### 🛠️ Comandos Úteis

#### Verificar status do serviço:
```bash
systemctl --user status cpu-cooler.service
```

#### Ver logs em tempo real:
```bash
journalctl --user -u cpu-cooler.service -f
```

#### Parar/iniciar o serviço:
```bash
systemctl --user stop cpu-cooler.service
systemctl --user start cpu-cooler.service
```

#### Testar manualmente:
```bash
./.venv/bin/python cpu_cooler.py
```

### 🔍 Resolução de Problemas

#### Dispositivo não encontrado:
- Verifique se o dispositivo está conectado: `lsusb | grep aa88:8666`
- Certifique-se de que as regras udev foram aplicadas

#### Erro de permissão:
- Verifique se o arquivo udev está em `/etc/udev/rules.d/99-cpu-cooler.rules`
- Reinicie ou desconecte/reconecte o dispositivo USB

#### Sensor de temperatura não encontrado:
- Liste sensores disponíveis: `python3 -c "import psutil; print(psutil.sensors_temperatures().keys())"`
- Edite `cpu_cooler.py` para usar o sensor correto

### 📁 Estrutura do Projeto

```
cpu-cooler/
├── cpu_cooler.py           # Script principal
├── cpu-cooler.service      # Arquivo de serviço systemd
├── 99-cpu-cooler.rules     # Regras udev para permissões USB
├── install.sh              # Script de instalação automática
├── uninstall.sh            # Script de desinstalação automática
└── README.md               # Este arquivo
```

### 🎯 Compatibilidade

- **CPUs Intel**: Usa sensor `coretemp`
- **CPUs AMD**: Usa sensor `k10temp`
- **Outros**: O script tentará usar o primeiro sensor disponível

### ⚡ Funcionamento

O script monitora a temperatura da CPU a cada segundo e envia o valor para o display USB. O display suaviza a transição de temperatura para uma visualização mais agradável.

### 🗑️ Desinstalação

Para remover completamente o serviço do CPU cooler e todas as configurações:

```bash
./uninstall.sh
```

O script de desinstalação irá:
- Parar e desabilitar o serviço systemd
- Remover regras udev
- Opcionalmente remover o ambiente virtual Python
- Opcionalmente remover todo o diretório do projeto
- Finalizar quaisquer processos em execução

---

## 📜 Documentação Original

This script capture the CPU temperature and show on Water Cooler display on Linux.

Since the manufacture supply a software only for Windows.

Tested with Water Cooler Husky Glacier

Tested with Water Cooler Rise Mode Water Cooler Aura Ice ARGB
