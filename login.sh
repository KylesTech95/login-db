PSQL="psql -U postgres -d login --tuples-only -c"
# RESET=$($PSQL "truncate users; alter sequence users_user_id_seq restart with 1;")
# echo $RESET


# Menu selection
MENU(){
    if [[ $1 ]]
            then
            echo -e "\n$1"
        sleep .5
    fi
    echo -e "\n~~~~ Main Menu ~~~~\n"
    sleep .5

    echo "How may I help you?"
    echo -e "\n1. login\n2. create account\n3. Exit"
    read MAIN_MENU_SELECTION
    sleep .25
    case $MAIN_MENU_SELECTION in
    1) LOGIN ;;
    2) CREATE_ACCOUNT ;;
    3) EXIT ;;
    *) MAIN_MENU "Please enter a valid option." ;;
    esac
}


CREDENTIALS(){
    if [[ $1 ]]
    then
    echo -e "\n$1"
    sleep .25
    fi
    echo -e "\nEnter Username"
    read USERNAME
    USER_ID=$($PSQL "select user_id from users where username='$USERNAME'")
    # if username contains special characters
    if [[ ! $USERNAME =~ ^[a-zA-Z0-9]+$ || -z $USER_ID ]]
    then
        sleep .25
        CREDENTIALS "\nSomething went wrong"
    else
        echo -e "\nUsername passed"
    fi
}
# login
LOGIN(){
    # total number of users
    USERS_PROGRAMMED=$($PSQL "select user_id from users")
    if [[ -z $USERS_PROGRAMMED ]]
    then
    MENU "\nThere are no user-accounts programmed."
    else 
    CREDENTIALS
    fi
}

# Create account
LIST_ACCOUNT_TYPES(){
    if [[ $1 ]]
        then
        echo -e "\n$1"
        sleep .5
    fi
    echo "$ACCOUNT_TYPES"| while read ACCOUNT_ID BAR TYPE BAR AUTH
    do
        sleep .25
        echo -e "$ACCOUNT_ID. $TYPE"
    done
    read ACCOUNT_ID_SELECTED
}
CREATE_ACCOUNT(){
    if [[ $1 ]]
        then
        echo -e "\n$1"
    fi
    # CREATE_ACCOUNT variables
    # retrieve account types
    ACCOUNT_TYPES=$($PSQL "select * from accounts") 
    # 1. total num of account-types
    ACCOUNT_COUNT=$($PSQL "select count(type) from accounts")    
    echo -e "\n~~~~ Create an account ~~~~\n"
    sleep .5
    LIST_ACCOUNT_TYPES
    # if input is invalid
    if [[ $ACCOUNT_ID_SELECTED -gt $ACCOUNT_COUNT || ! $ACCOUNT_ID_SELECTED =~ ^[0-9]$ ]]
    then
        LIST_ACCOUNT_TYPES "\nInvalid option.\nTry again."
        # if still wrong
        if [[ $ACCOUNT_ID_SELECTED -gt $ACCOUNT_COUNT || ! $ACCOUNT_ID_SELECTED =~ ^[0-9]$ ]]
        then
        # Menu
        CREATE_ACCOUNT "\nInvalid option.\nBack to CREATE_ACCOUNT"
        fi
    else
        CREATE_ACCOUNT "\nGood Work!"
    fi
    


}
MENU  