#!/bin/bash
# Autor: Fernando H. Crozetta
# Data : 16/09/2016
# Descricao: Script realiza a conexao com o banco de dados para gravar os dados de ip
while [[ true ]]; do
	source /usr/local/share/fatualizaip/config
	ip=$(lynx --dump http://ipecho.net/plain)
mysql --login-path=fatualizaip -e "update fatualizaip.dados_servers set ip='$ip', tempoUpdate='$tempo', ultimoUpdate=current_timestamp where (alias='$nome')"
	sleep ${tempo}m
done
