source ./tableInnerOperation.sh
dataTypesSupported=('string' 'numbers')
function tableOuterOperation() {
    id=0;
    
    outerOperation=$(whiptail --cancel-button "Exit" --title "Outer table operation menu" --fb --menu "Choose an option" 15 60 6 \
        "1" "Create table" \
        "2" "List tables" \
        "3" "Delete table" \
        "4" "Modify table [Inner operation]" \
    "5" "Go back to DBeng main menu" 3>&1 1>&2 2>&3)
    exitstatus=$?
    [[ "$exitstatus" = 1 ]] && exit;	#test if exit button is pressed
    
    
    case $outerOperation in
        1) #Create Table
            userInput=$(whiptail --title "Create a table" --inputbox "Enter table name:" 10 80 3>&1 1>&2 2>&3)
            exitstatus=$?	#test if cancel button is pressed	if existstatus == 1 then it is pressed
            if [[ "$exitstatus" = 0 ]]
            then
                if [ -z "$userInput" ] #if input is empty
                then
                    whiptail --title "Input can't be empty" --msgbox "Please enter a valid table name." 8 45
                elif [ -f "$(pwd)/$userInput.tbeng" ] #check if the table already exists
                then whiptail --title "Table already exist" --msgbox "Currently there's already a table named $userInput.tbeng in this Database." 8 45
                else
                    newTable="$userInput"
                    touch "$newTable.tbeng"
                    whiptail --title "Table created successfully" --msgbox "Table $userInput was created at $(pwd) on $(date)" 10 55
                    flag=1
                    while [ $flag -eq 1 ]
                    do
                        columnInput=$(whiptail --inputbox "Enter column names\nSeparate each column name with a space" 15 80 --title "Define table columns"  3>&1 1>&2 2>&3)
                        exitstatus=$?	#test if cancel button is pressed	if existstatus == 1 then it is pressed
                        if [[ "$exitstatus" = 1 ]] #handle cancel button press
                        then
                            rm "$newTable.tbeng"
                            whiptail --title "Table creation cancelled" --msgbox "Table $newTable was removed upon your cancellation." 10 55
                            flag=0 && break
                        fi
                        typeInput=$(whiptail --inputbox "Enter data type of each column (String | numbers)\nSeparate each column name with a space" 15 80 --title "Define table data types"  3>&1 1>&2 2>&3)
                        exitstatus=$?	#test if cancel button is pressed	if existstatus == 1 then it is pressed
                        if [[ "$exitstatus" = 1 ]]
                        then
                            rm "$newTable.tbeng"
                            whiptail --title "Table creation cancelled" --msgbox "Table $newTable was removed upon your cancellation." 10 55
                            flag=0 && break
                        fi
                        
                        #count number of fields entered in columnInput & typeInput
                        columnNF=$(echo $columnInput | awk '{print NF}')
                        typeNF=$(echo $typeInput | awk '{print NF}')
                        
                        if [[ $columnNF -ne $typeNF ]]; #if number of fields enetered don't match.
                        then whiptail --title "Number of fields don't match!" --msgbox "Number of columns entered doesn't match with the number of data types." 10 55
                            continue
                        else echo -e "id\c" >> $userInput.tbeng #insert id column at the beginning of the row.
                            
                            typeInputArray=($typeInput) #convert the input into array to iterate over the spaces.
                            for type in "${typeInputArray[@]}"
                            do
                                if [[ ! " ${dataTypesSupported[@]} " =~ " ${type} " ]]; then
                                    # when the type entered is not in our typesSupported array
                                    echo "entered1"
                                    flag=0
                                fi
                                echo -e ":$type\c" >> $userInput.tbeng #\c for continuous text concatenation (changing the default echo \n behavior)
                            done
                            echo "" >> $userInput.tbeng  #do echo <default behaviour of exiting line> ==> aka \n
                            
                            echo -e "id\c" >> $userInput.tbeng #insert id column at start of row
                            columnInputArray=($columnInput) #convert the input into array and iterate over the spaces.
                            for column in "${columnInputArray[@]}"
                            do
                                echo -e ":$column\c" >> $userInput.tbeng
                            done
                            echo "" >> $userInput.tbeng
                            if [ $flag -eq 0 ]
                            #if a condition above marked the flag as 0 then a corruption happened and data will not be written and the loop must again
                            then
                                # empties contents of file for a new loop by redirecting null (nothing) and shows error
                                > $userInput.tbeng && whiptail --title "Invalid datatype" --msgbox "Invalid datatype entered, please try again." 10 55
                                flag=1	#resets the flag to retake inputs from user
                                echo "entered2"
                            else # case of success and all conditions passed
                                whiptail --title "Success" --msgbox "Table header was initialized at `date`" 8 45
                                flag=0 #get out of the loop
                            fi
                        fi
                    done
                fi
            fi
            
        ;;
        
        2) #List tables
            #Check if no tables currently exist in the database first.
            countTables=$(ls | egrep '\.tbeng$' | wc -l)
            if [ $countTables -eq 0 ]
            then whiptail --title "No tables found!" --msgbox "This database currently have no existing tables." 10 55
            else whiptail --title "Current tables list" --msgbox "Current tables in the database are:\n`find . -type f -name "*.tbeng" -printf "%f\n" | cut -f1 -d .`" 20 55
            fi
        ;;
        
        3) #Delete Table
            
            #check if no tables exist
            countTables=$(ls | egrep '\.tbeng$' | wc -l)
            if [ $countTables -eq 0 ]
            then whiptail --title "No tables found!" --msgbox "This database currently has no existing tables." 10 55
                
            else
                userInput=$(whiptail --inputbox "Enter the name of the Table to be deleted\nCurrent available Tables are:\n`find . -name "*.tbeng" -printf "%f\n" | cut -f1 -d .`" 20 80 --title "Delete Table"  3>&1 1>&2 2>&3)
                exitstatus=$?	#test if cancel button is pressed	if existstatus == 1 then it is pressed
                if [[ "$exitstatus" = 0 ]]
                then
                    find . -name "$userInput.tbeng" | grep $userInput 1> /dev/null
                    if [ ! $? -eq 0 ]
                    then whiptail --title "Table doesn't exist" --msgbox "No Table named $userInput found." 8 45
                    else
                        rm -rf "$userInput.tbeng"
                        if [ $? -eq 0 ]
                        then  whiptail --title "Table Successfully removed" --msgbox "Table $userInput.tbeng was removed at `date`" 8 45
                        else
                            whiptail --title "Unknown error occured" --msgbox "For some reason we were unable to remove $userInput Table" 8 45
                        fi
                    fi
                fi
            fi
        ;;
        
        4) #Modify table [Inner operation]
            #check if no tables exist
            countTables=$(ls | egrep '\.tbeng$' | wc -l)
            if [ $countTables -eq 0 ]
            then whiptail --title "No tables found!" --msgbox "This database currently has no existing tables." 10 55
                
            else
                userInput=$(whiptail --inputbox "Enter the name of the Table to be modified\nCurrent available Tables are:\n`find . -name "*.tbeng" -printf "%f\n" | cut -f1 -d .`" 20 80 --title "Modify Table"  3>&1 1>&2 2>&3)
                exitstatus=$?	#test if cancel button is pressed	if existstatus == 1 then it is pressed
                if [[ "$exitstatus" = 0 ]]
                then
                    find . -name "$userInput.tbeng" | grep $userInput 1> /dev/null
                    if [ ! $? -eq 0 ]
                    then whiptail --title "Table doesn't exist" --msgbox "No Table named $userInput found." 8 45
                    else
                        export selectedTable="$userInput.tbeng"
                        tableInnerOperation
                    fi
                fi
            fi
            
        ;;
        5) #Go back to DBeng Main menu
            mainMenu
        ;;
    esac
    tableOuterOperation
}

