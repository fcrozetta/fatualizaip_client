#!/bin/bash -
# Autor: Fernando H. Crozetta
# Data : 16/09/2016
# Descricao: O script realiza a instalacao do maximo possivel automaticamente.

if [[ $EUID -ne 0 ]]; then
	echo "you need to be root"
	exit 1
fi

#Buscar o tipo do instalador para jogar no comando
instalar='apt-get install'
if [[ $(which yum) ]]; then
	instalar='yum install'
fi

# Instalação de programas necessários
$instalar -y lynx mysql-client sed

diretorio_default='/usr/local/share/fatualizaip'
mkdir -p $diretorio_default
config=$diretorio_default/config

echo "#Gerado automaticamente. nao alterar" > $config
echo "diretorio=$( cd $(dirname $0) ; pwd -P)" >> $config

chmod 600 $config

# Dados que serao passados ao server remoto:
read -p "Alias do servidor: " nome
echo "nome=$nome" >> $config
read -p "Tempo entre atualizacoes(minutos):" tempo
echo "tempo=$tempo" >> $config

# Dados para acesso ao BD
read -p "Mysql Usuario      :" mysql_usuario
read -p "Mysql IP           :" mysql_ip
read -p "Mysql Porta(3306)  :" mysql_porta
echo "Senha para conexao no banco de dados remoto:"

#copia para o diretorio correto
cp fatualizaip.sh $diretorio_default/

# Configura um login sem deixar usuario e senha expostos
mysql_config_editor set --login-path=fatualizaip --host=$mysql_ip --user=$mysql_usuario --port=$mysql_porta --password
echo "criando dados no server"
mysql --login-path=fatualizaip -e"insert into fatualizaip.dados_servers set alias='$nome', ip='$(lynx --dump http://ipecho.net/plain)',tempoUpdate='$tempo',ultimoUpdate=current_timestamp;"

#adiciona uma linha ao final do rc.local (é preciso checar se esta ok no arquivo)
read -p "deseja adicionar uma linha ao rc.local?(s/N): " option
if [[ $option == "s" ]]; then
	sed -i -e "$ i\\$diretorio_default/fatualizaip.sh &\n" /etc/rc.local
fi