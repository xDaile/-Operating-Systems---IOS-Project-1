#!/bin/bash
# MICHAL ZELENAK
# PROJEKT 1 IOS
# WRAPPER WEDI
# XZELEN24
# VUT FIT 
#
#############################first tests################################################################
realpath . >/dev/null 2>&1 || ( echo "Realpath is missing. Wedi will not be work fine."
exit 1)



#############################**Checking file***##########################################################
check_file()
{
	if [ ! -s "$WEDI_RC" ];then	#if wedirc is not set
		echo "No records in log file ""$WEDI_RC"
		exit 3
	fi
}
#########################################################################################################

#############################**Checking date***##########################################################
check_date()
{
	check=$(echo "$1" | grep "[0-9][0-9][0-9][0-9]-[0-1][1-9]-[0-3][0-9]")
	if [ -z "$check" ];then    #if Both variabiles editor and visual are not set
		echo "BAD DATE FORMAT"
		exit 10				#succesfull exit
	fi
}
#########################################################################################################

###############################**EDITING ARGUMENT FILE***################################################
start_edit_file()
{
	if [ -z "$EDITOR" ] && [ -z "$VISUAL" ];then    #if Both variabiles editor and visual are not set
		vi "$1"
		exit "$?"					#succesfull exit
	fi

if [ -z "$EDITOR" ];then 				#if the variabile editor
	$VISUAL "$1"					# is not set
	exit "$?"
else							#no one of above case
	$EDITOR "$1"
	exit "$?"
fi
}
###########################################################################################################

####################**Saving one line to file WEDI_RC of file**############################################
save_WRC() 
	{
	DIR=$(dirname "$(readlink -f "$1")")
	p_tofile=$(realpath "$1")			#path to file
	year_towrite=$(date +'%Y')			#separated year
	month_towrite=$(date +'%D' | cut -d'/' -f'1')	#separated month
	day_towrite=$(date +'%D' | cut -d'/' -f'2') 	#separated day
	echo "$DIR:$p_tofile:$year_towrite$month_towrite$day_towrite" >> "$WEDI_RC"	#line to WEDI_RC	
	}
############################################################################################################

####################**Saving one line to file WEDI_RC of filepath**#########################################
save_inf_WRC() 
	{
	p_tofile="$1"			#path to file
	DIR=$(dirname "$1")	
	year_towrite=$(date +'%Y')			#separated year
	month_towrite=$(date +'%D' | cut -d'/' -f'1')	#separated month
	day_towrite=$(date +'%D' | cut -d'/' -f'2') 	#separated day
	echo "$DIR:$p_tofile:$year_towrite$month_towrite$day_towrite" >> "$WEDI_RC"	#line to WEDI_RC
	}
############################################################################################################


##########################################**Write the most editted file**###################################
write_most_edits()
{

if [ "-m" = "$1" ];then
	fil=$(pwd)
	filtedt=$( grep "$fil:" < "$WEDI_RC" | cut -d':' -f'2' | sort -r | uniq -c | sort -r | head -1  | awk '{$1=$1;print}' | cut -d' ' -f'2')  
else
	filtedt=$( grep "$1:" < "$WEDI_RC" | cut -d':' -f'2' | sort -r | uniq -c | sort -r | head -1  | awk '{$1=$1;print}' | cut -d' ' -f'2') 
fi   				#path of file to edit...upper line / or one above it... 
save_inf_WRC "$filtedt"		#saving info about starting text editor
start_edit_file "$filtedt"		#editing file

}
############################################################################################################


########################################**Edit afbf**#####################################################
edit_afbf()
{
#$1 is the date after which the user wants the data
comparedate="$(echo "$1" |cut -d'-' -f'1')$(echo "$1" |cut -d'-' -f'2')$(echo "$1" |cut -d'-' -f'3')" 
#comparedate has format yyyymmdd for comparing
if [ "$3" = "0" ];then	#test if we have three or two arguments, depends on that will be dates_infile set
	dates_infile=$(cut -d':' -f'3' < "$WEDI_RC" ) 	#choose the path/file
else
	dates_infile=$(grep "$3:"  < "$WEDI_RC" )	#grep filter paths with argument
	dates_infile=$(echo "$dates_infile" | cut -d':' -f'3' )	#choosing path/file from filtered lines
fi 
Count=0	 #number of lines that will cut the filtered content of variabile output by the head or tail
zero=0
if [ "$2" = "after" ]; then 	#test what case we should do
		for item in $dates_infile; do	#cycle for counting lines that lower than user input
			comparevariabile=$(echo "$comparedate" "$item"  | awk '{ print $1 - $2}')

			#AWK will substract date from user from date in log_file
        		if [ "$comparevariabile" -le "$zero" ]; then	#if we are under zero				
				Count=$(echo "$Count"  | awk '{ print $1 + 1}')	#count one line
			fi	#we need that number of lines for creating output after we grep log file
		done

	if [ "$3" = "0" ];then	#in case that we do not have directory we will filter lines this way, 
		output=$( tail -"$Count"< "$WEDI_RC" | cut -d':' -f'2'  | rev | cut -d'/' -f'1' | rev | sort | uniq )
	else 		#if we have directory, rev is for cutting path to file
		output=$( grep "$3:" < "$WEDI_RC" | tail -"$Count" | cut -d':' -f'2'  | rev | cut -d'/' -f'1' | rev | sort | uniq ) # 
	fi
	echo "$output"
	
		exit 0
	
fi
if [ "$2" = "before" ]; then  #again like 'after', but filtering head instead of tail
		for item in $dates_infile; do	#awk substracting in opposite way
			comparevariabile=$(echo "$comparedate" "$item"  | awk '{ print $2 - $1}')
        		if [ "$comparevariabile" -le "$zero" ]; then			
				Count=$(echo "$Count"  | awk '{ print $1 + 1}')
			fi
		done
	if [ "$3" = "0" ];then
		output=$( head -"$Count"< "$WEDI_RC" | cut -d':' -f'2'  | rev | cut -d'/' -f'1' | rev | sort | uniq )
	else 
		output=$( grep "$3:" < "$WEDI_RC" | head -"$Count" | cut -d':' -f'2'  | rev | cut -d'/' -f'1' | rev | sort | uniq ) # 
	fi


		echo "$output"
		exit 0
	
fi


}
############################################################################################################



####################################################**code section**###################################################

#program is made by selecting what arguments we have, depends on that program is going to some of if dow    

if [ $# -gt 3 ] ;then			#if we have more than 3 arg
	echo Too much arguments		#error and end
	exit 1 
fi

if [ $# -eq 1 ] ;then			#if we have one argument

	if [ "$1" = "-l" ];then #last editet files
		check_file
		argument=$(pwd) ##actual adress
		output=$(grep "$argument:" <"$WEDI_RC" | cut -d':' -f '2' | rev | cut -d'/' -f '1' | rev | sort | uniq)
		echo "$output" #filtered, last files in the actual directory
		exit 0		
		if [[ -z "$output" ]]; then
  			echo "ERROR, no lines about directory" 
			exit 1
		fi
		
	fi

	if [ "$1" = "-m" ];then #the most eddited file
		write_most_edits "$1"
	fi

	

	if [ -d "$1" ];then  #if the first argument is the directory
		ftoedit=$(grep "$1:" < "$WEDI_RC" | cut -d':' -f '2' | tail -1 )
		save_WRC "$ftoedit"
		start_edit_file "$ftoedit"

	fi

	if [ -e "$1" ] ;then	#if the argument is file
		
		#rightfile=$( realpath "$1")
		
		if [ -f "$1" ] ;then	#if the argument is not empty file

			save_WRC "$1"	#save log into file
			start_edit_file "$1" #choosing editor and run him
       		
		fi
		else
			echo "File do not exists"
			exit 1
	fi

fi

if [ $# -eq 2 ] ;then #if we got two arguments
	if [ "$1" = "-m" ];then	
		write_most_edits "$2"
	fi
	
	if [ "$1" = "-l" ];then #writing files that was edited in the directory
		output=$(grep "$2" < "$WEDI_RC" | cut -d':' -f '2' | rev | cut -d'/' -f'1' | rev | sort | uniq )
		if [ -z "$output" ];then    #if 
		echo "BAD FILE WEDI_RC FORMAT"
		exit 10				#succesfull exit
	fi
		echo "$output"
		exit 0
		
	fi	

	if [ "$1" = "-b" ];then
		check_file				#check if the file exists
		argument=$(pwd)				#actual path
		check_date "$2"				#checking format
		edit_afbf "$2" "before" "$argument" #look at edit_afbf
	fi
	
	if [ "$1" = "-a" ];then				#look to if up this if
		check_file				
		argument=$(pwd)
		check_date "$2"
		edit_afbf "$2" "after" "$argument"
	fi
	
fi

if [ $# -eq 0 ];then					#if we do not have argument
	check_file					#check variabile "wedi_rc"
	forgrep=$(pwd)
	Files=$(grep "$forgrep"  < "$WEDI_RC")		#actual adress, filtered lines
	toedit=$(echo "$Files" | tail -1 | cut -d':' -f '2') 
	save_inf_WRC "$toedit"
	start_edit_file "$toedit"
	
fi

if [ $# -eq 3 ];then					#three arguments
	if [ "$1" = "-b" ];then				
		check_date "$2"			
		edit_afbf "$2" "before" "$3"		#look at edit_afbf
	fi
	
	if [ "$1" = "-a" ];then				#look at the if up this
		check_date "$2"
		edit_afbf "$2" "after" "$3"
	fi

fi
echo "Program can not work with this arguments"
exit 1

#echo "ERROR: Program cannot pass the arguments"
