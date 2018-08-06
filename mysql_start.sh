#!/bin/bash
export DATA=${1-data};
DC_FOLDER=/home/rafael/Projetos/mysql
DATA_LIST=()

if [ ! -d "$DC_FOLDER/datadir" ]; then
  mkdir "$DC_FOLDER/datadir";
fi

if [ "$1" == "-h" ]; then
  echo "Usage: `basename $0` PASTA_DATA PASTA_DOCKER_COMPOSE"
  exit 0
fi

if [ -n "$2" ]; then
  DC_FOLDER="$2"
fi

DC_FILE="$DC_FOLDER/docker-compose.yml"

dc_exec() {
  /usr/bin/docker-compose --project-directory $DC_FOLDER -f $DC_FILE $@
}

start() {
  if [ -d "$DC_FOLDER/datadir/$DATA" ]; then
    if [ ! -f "$DC_FILE" ]; then
      echo "Parece que a pasta apontada não é uma pasta do docker-compose, o arquivo \"$DC_FILE\" não foi encontrado.";
      exit 1;
    fi
    if dc_exec up -d --force-recreate ; then
      echo "MYSQL rodando usando a pasta de dados: \"$DC_FOLDER/datadir/$DATA\"";
      exit 0;
    else
      echo "Ocorreu um erro ao tentar iniciar o MYSQL, verifique suas configurações no arquivo \"$DC_FILE\"";
      exit 1;
    fi
  else
    echo "A pasta de dados do MYSQL ($DC_FOLDER/datadir/$DATA) não foi encontrada."
    echo "Escolha uma das opções abaixo:"
    for D in $DC_FOLDER/datadir/*; do
      if [ -d "${D}" ] && [ -f "${D}/ibdata1" ] ; then
        DATA_LIST=("${DATA_LIST[@]}" "${D##*/}")
      fi
    done

    DATA=$(for i in "${DATA_LIST[@]}"
    do
      echo "$i";
    done | /usr/bin/fzf --height 1% --reverse)
    if [ -n "$DATA" ]; then
      start
    else
      echo "Ação Cancelada.";
      exit 1;
    fi
  fi
}

start
exit 0;
