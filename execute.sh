#!/bin/bash


Help()
{
  #Print Help
  echo 'Skrypt uruchamiający konter ansible, uruchamia doceker-compose a następnie wykonuje playbook podany w parametrze -p'
  echo
  echo "Syntax: [-p|-c|-d|-V|-h]"
  echo "Opcje:"
  echo "    -p | --path Wprowadź ścieżkę do pliku playbook"
  echo "    -h | --help Pomoc"
  echo "    -c | --check Sprawdź playbook bez wykonywania - dry run"
  echo "    -d | --diff Jakie zmiany robi skrypt "
}

version='Version 1.0'

# if [ $# -gt 0 ] ; then
#   echo 'Brak argumentów'
#   Help
#   exit 0
# fi
if [ -z "$2" ]
  then
    echo "No argument supplied"
    Help
    exit;
fi


check=false
diff=false

#Get options
while [ -n "$1" ]; do
  case "$1" in
    -p | --path)
      path="$2"
      shift;;

    -c|--check)
      check=true
      shift;;

    -d|--diff)
      diff=true
      shift;;

    -h|--help)
      Help
      exit;;
    -V|--version)
      echo "$version"
      exit;;
    *)
      echo "Error: Brak opcji $1"
      Help
      exit;;
    esac
    shift
done


clear
echo "Autor: kaszlikowski.s@gmail.com"
cat << "EOF"
          _   _  _____ _____ ____  _      ______
    /\   | \ | |/ ____|_   _|  _ \| |    |  ____|
   /  \  |  \| | (___   | | | |_) | |    | |__
  / /\ \ | . ` |\___ \  | | |  _ <| |    |  __|
 / ____ \| |\  |____) |_| |_| |_) | |____| |____
/_/    \_\_| \_|_____/|_____|____/|______|______|

######## ##     ## ########  ######  ##     ## ########  #######  ########
##        ##   ##  ##       ##    ## ##     ##    ##    ##     ## ##     ##
##         ## ##   ##       ##       ##     ##    ##    ##     ## ##     ##
######      ###    ######   ##       ##     ##    ##    ##     ## ########
##         ## ##   ##       ##       ##     ##    ##    ##     ## ##   ##
##        ##   ##  ##       ##    ## ##     ##    ##    ##     ## ##    ##
######## ##     ## ########  ######   #######     ##     #######  ##     ##
EOF

echo ""
echo "Uruchamiam kontener ansible"

pwd=$(pwd)

#Get directory name
result="${pwd%"{pwd##*[!/]}"}"
result="${result##*/}"
echo "Result: $result"
docker-compose up -d

if $check ; then
  echo "Sprawdź playbook $path bez uruchamia"
  logger "[ansible-executor] Uruchamiam playbook $path bez uruchamia"
  docker exec -it "ansiblerunner" ansible-playbook -i hosts $path --check -vv

elif $diff ; then
  docker exec -it "ansiblerunner" ansible-playbook -i hosts $path --check --diff -vv

fi

echo ""
echo "Czyszczę po sobie"
docker-compose stop && docker-compose rm -f
# docker stop "${result}_ansible_1"
# docker rm "${result}_ansible_1"
