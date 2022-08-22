#!/bin/bash

recursive_Function_To_TravelPath()
{

Extended_APIPath=${Extended_APIPath}
file_name=${file_name}

  for i in `curl ${Extended_APIPath}`
   do

     Extended_APIPath=${Extended_APIPath}$i

     last_character=${Extended_APIPath: -1}

        if [ "${last_character}" == "/" ]
            then

             #Extended_APIPath=${Extended_APIPath}

             continue

        else

           output=`curl ${Extended_APIPath}`

           echo -e "$i : ${Extended_APIPath}" >> result.txt

        fi

   done
}

convert_To_Json()
{


rm -rf instance-metadata.json

file_name=$file_name
last_line=$(wc -l < $file_name)
current_line=0
json_file_name=instance-metadata.json

echo "{" >> ${json_file_name}

while read line
do
  current_line=$(($current_line + 1))
  if [[ $current_line -ne $last_line ]]; then
  [ -z "$line" ] && continue
     echo $line|awk -F':'  '{ print " \""$1"\" : \""$2"\","}'|grep -iv '\"#'  >> ${json_file_name}
  else
    echo $line|awk -F':'  '{ print " \""$1"\" : \""$2"\""}'|grep -iv '\"#'  >> ${json_file_name}
  fi
done < $file_name

echo "}"  >> ${json_file_name}

rm -rf result.txt

}


main()
{

rm -rf result.txt

Base_APIPath="http://169.254.169.254/latest/meta-data/"
file_name="result.txt"

	for i in `curl ${Base_APIPath}`
	do

		Extended_APIPath=${Base_APIPath}$i

		Last_Character_of_path=${Extended_APIPath: -1}

		echo $Last_Character_of_path

		if [ "$Last_Character_of_path" == "/" ]
		then

			recursive_Function_To_TravelPath ${Extended_APIPath} ${file_name}

		else

			output=`curl ${Extended_APIPath}`

			echo -e "${i} : ${output}" >> ${file_name}
		fi


	done

}



main

convert_To_Json  $file_name



