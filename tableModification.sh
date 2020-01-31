#!/bin/bash
# exported variables: $scriptDir, $selectedTable

echo "selected table exported : $selectedTable"

select tableModifications in "Print Table" "Insert Data" "Update Row" "Delete Row" "Go back to previous menu"
do
case $tableModifications in
    "Print Table")
        awk 'BEGIN {FS=":";OFS="\t"} NR>1{i=1;while(i<=NF){printf $i "\t"; i++;} printf"\n"}' $selectedTable
    ;;
    "Insert Data")
        # TODO -condition if field is empty -condition if doesn't match types entered
        read rowInput;
        if [ -z "$rowInput" ]  # Check if string is empty using -z
        then
            echo "row can't be empty, please enter row data to continue"
        else
            oldId=$(awk -F : 'END{printf $1}' $selectedTable) #assign id of final row in table
            id=$((oldId + 1))
            echo -e "Enter fields [Separate each field with a space]\n"
            awk 'BEGIN {FS=":";OFS="\t"} {if(NR == 3){exit} i=2;while(i<=NF){printf $i "\t"; i++;} printf"\n"}' $selectedTable
            echo -e "$id\c" >> $selectedTable
            rowInputArray=($rowInput) #convert the input into array to iterate over the spaces
        for row in "${rowInputArray[@]}"
        do 
            echo -e ":$row\c" >> $selectedTable # \c for continuous text concatination (changing the default echo \n behavior)
        done
        echo "" >> $selectedTable
    ;;
    "Update Row")

    ;;
    "Delete Row")
        echo -e "Please enter the id of the row to be deleted: \c"
        read id
        awk -F : -v id=$id '{if($1==id){next}print}' $selectedTable > tmpfile && mv tmpfile $selectedTable
        #can't read and write to same file in the same pipe
        echo "line $id was deleted successfully"

    ;;
    "Go back to previous menu")
        exit
    ;;
    *)
esac
done