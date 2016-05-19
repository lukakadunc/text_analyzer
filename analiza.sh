#!/bin/bash

st_arg=$#
dat=${@: -1}

LANG=en_US.utf-8  #testiral sem s: dn2test.sh

#Napacni vpisi exit 12 napacno stikalo exit 10 napacna datoteka
if [ ${!#:0:1} = '-' ];then
	echo "Napaka: neznano stikalo $dat.">&2
	exit 12
fi
if [ ! -e $dat ];then
	echo "Napaka: datoteka $dat ne obstaja.">&2
	exit 10
fi


if [[ ${dat:0:1} = '-' ]]; then
	echo "Napaka: neznano stikalo $dat.">&2
	exit 12
fi

#pregledam katero stikalo je vpisano in pa če je -l ali pa -n
funkcija_n=false
funkcija_l=false

for((i=1; i<st_arg ; i++))
do
	prej=$(($i-1))
	if [ ${!i} = '-n' ];then  #ce je -n
		funkcija_n=true

	elif  [ ${!i} = '-l' ];then  #ce je -l
		funkcija_l=true

 	elif [[ ${!i} =~ ^-?[0-9]+$ ]] && [ ${!prej} = '-n' ]; then #ce je stevilka za -n
		stevilo_n=${!i}
	

	elif [[ ${!i} =~ ^-?[0-9]+$ ]] && [ ${!prej} = '-l' ]; then #ce je stevilka za -l
		stevilo_l=${!i}
		

	else
		echo 'Napaka: neznano stikalo '${!i}'.'>&2   #ce vpisemo npr -b
		exit 12
	
	fi
done



#ce ne navedemo stikala
function brez_stikala
{
	besedilo=$(tr -cs '[^[:alpha:]*[čšž]^]' '\n' < $dat | tail -n +2 | tr " A-Z" "\na-z" | sort | uniq -c) 	
	dolzina=$(cat $dat | tr -d "1234567890" | wc -w | cut -f 1 -d " ")
	tab=($besedilo)
	i=0

	for ponovitev in $besedilo
	do
		if [[ $ponovitev =~ ^-?[0-9]+$ ]];then
		 proc=$(($ponovitev*100))
		 proc=$(echo "2k$proc $dolzina/p" |dc)
		 pomozna="$pomozna$ponovitev" 
		else
			pomozna="$pomozna $ponovitev $proc% ${#ponovitev}˘" 	
		fi
		
	done
	echo $pomozna | tr "˘" "\n" | sort -k1,1nr -k4,4nr | cut -d ' ' -f 4 --complement | grep -v '^$'	


}


#racuna ce damo stikalo -n
function pojavitve
{
	besedilo=$(tr -cs '[^[:alpha:]*[čšž]^]' '\n' < $dat | tr " A-Z" "\na-z" | sort | uniq -c | sort -k1,1nr -k2,2 ) #vse sortiram in dam v en string
	
	dolzina=$(cat $dat | tr -d "1234567890" | wc -w | cut -f 1 -d " ") #st vseh besed

	tab=($besedilo)
	i=0
	for ponovitev in $besedilo  
	do
		nasl=$((i+1))
		if [[ $ponovitev =~ ^-?[0-9]+$ ]] && [ $ponovitev -ge $stevilo_n ];then #ce je cifra ker imam v stringu zapis oblike  #kolikokrat se povaji BESEDA ...
			proc=$(($ponovitev*100))		#
			proc=$(echo "2k$proc $dolzina/p" |dc)   #racunanje procentov
			printf "%s %s %.2f%%\n" $ponovitev ${tab[$nasl]} $proc #izpis
		fi
		i=$(($i+1)) 
	done	

}



# ce navedemo stikalo -l

function do_dolzine
{
	
	besedilo=$(tr -cs '[^[:alpha:]*[čšž]^]' '\n' < $dat | tr " A-Z" "\na-z" | sort | uniq -c | sort -k1,1nr -k2,2 )

	dolzina=$(cat $dat | tr -d "1234567890" | wc -w | cut -f 1 -d " ") #st vseh besed
	tab=($besedilo)
	i=0
	for ponovitev in $besedilo  
	do

		if [ ${#ponovitev} -eq $stevilo_l ];then
			manj=$(($i-1))
			proc=$((${tab[$manj]}*100))		#
			proc=$(echo "2k$proc $dolzina/p" |dc)   #racunanje procentov
			
			echo "${tab[$manj]} $ponovitev $proc%"
		fi
		i=$(($i+1)) 
	done		


}
#Funkcija če kličemo oba stikala hkrati.
function presek
{
#-l
	besedilo=$(tr -cs '[^[:alpha:]*[čšž]^]' '\n' < $dat | tr " A-Z" "\na-z" | sort | uniq -c | sort -k1,1nr -k2,2 )
	dolzina=$(cat $dat | tr -d "1234567890" | wc -w | cut -f 1 -d " ")
	tab=($besedilo)
	i=0

	for ponovitev in $besedilo  
	do

		if [ ${#ponovitev} -eq $stevilo_l ];then
			manj=$(($i-1))
			proc=$((${tab[$manj]}*100))		
			proc=$(echo "2k$proc $dolzina/p" |dc)   
			
			string1=$(echo "$string1${tab[$manj]} $ponovitev $proc%˘")
		fi
		i=$(($i+1)) 
	done
	
#-n	



	string1=$(echo "$string1" | tr "˘" " ") 


	tab=($string1)
	i=0
	for ponovitev in $string1  
	do
		nasl=$((i+1))
		if [[ $ponovitev =~ ^-?[0-9]+$ ]] && [ $ponovitev -ge $stevilo_n ];then 
			proc=$(($ponovitev*100))	
			proc=$(echo "2k$proc $dolzina/p" |dc)   
			printf "%s %s %.2f%%\n" $ponovitev ${tab[$nasl]} $proc 
		fi
		i=$(($i+1)) 
	done	

}


if [ $funkcija_n = true ] && [ $funkcija_l = false ];then
	pojavitve
fi

if [ $funkcija_n = false ] && [ $funkcija_l = true ]; then
	 do_dolzine
fi 

if [ $funkcija_n = true ] && [ $funkcija_l = true ]; then
	 presek
fi 

if [[ $funkcija_n = false ]] && [[ $funkcija_l = false ]];then
	brez_stikala

fi

	
