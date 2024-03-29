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
    # password attempt function
    # password attempt
    PASSWORD_ATTEMPT(){
    NEWVAR=$(echo `expr $1 - 1`)
    if [[ $1 -gt 1 ]]
    then
        echo -e "\nSecond chance, what is your password?"
        sleep .25
        read PASSWORD
        # retrieve password from users table
        CURRENT_PASSWORD=$($PSQL "select password from users where password='$PASSWORD'")
        if [[ -z $CURRENT_PASSWORD ]]
        then
            # 3 password attempts with this function
            PASSWORD_ATTEMPT $NEWVAR
        else
            echo -e "\nWelcome, you have successfully logged in"
        sleep 1
        MENU
        fi
    else
    echo -e "\nLast chance, what is your password?"
        sleep .25
        read PASSWORD
        # retrieve password from users table
        CURRENT_PASSWORD=$($PSQL "select password from users where password='$PASSWORD'")
        if [[ -z $CURRENT_PASSWORD ]]
        then
            # 3 password attempts with this function
            MENU "\nToo many pw attempts"
        else
            echo -e "\nWelcome, you have successfully logged in"
        sleep 1
        MENU
        fi
    fi


        
    }
    if [[ $1 ]]
    then
    echo -e "\n$1"
    sleep .25
    fi
    echo -e "\nEnter Username"
    read USERNAME
    # What is the returning user's user_id
    USER_ID=$($PSQL "select user_id from users where username='$USERNAME'")
    # What is the returning user's account_id ? 
    ACCOUNT_ID=$($PSQL "select account_id from users where username='$USERNAME'")
    NO_AUTHENTICATION=$($PSQL "select account_id from accounts where authentication='f'")
    # if username contains special characters
    if [[ ! $USERNAME =~ ^[a-zA-Z0-9]+$ || -z $USER_ID ]]
        then
            sleep .75
            CREDENTIALS "Something went wrong"
        else
            echo -e "\nUsername passed"
            sleep .75
            if [[ $ACCOUNT_ID -eq $NO_AUTHENTICATION ]]
                then
                echo -e "\nWelcome, you have successfully logged in"
                sleep 1
                MENU
            else
            echo -e "\nWhat is your password? (3 attempts)"
            sleep .25
            read PASSWORD
            # retrieve password from users table
            CURRENT_PASSWORD=$($PSQL "select password from users where password='$PASSWORD'")
            if [[ -z $CURRENT_PASSWORD ]]
            then
                # 3 password attempts with this function
                sleep .5
                PASSWORD_ATTEMPT 2
            else
                echo -e "\nWelcome, you have successfully logged in"
            sleep 1
            MENU
            fi

            fi
        
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
        echo -e "\nEnter your name"
        sleep .25
        read NAME_ENTERED
        # enter username
        echo -e "\nEnter a username"
        sleep .25
        read USERNAME_ENTERED
        # We need to determine which account_id does NOT require authentication (guest)
        NO_AUTHENTICATION=$($PSQL "select account_id from accounts where authentication='f'")
        # (if user selected guest)
        if [[ $ACCOUNT_ID_SELECTED -eq $NO_AUTHENTICATION ]]
            then
            # no password is required
            INSERT_USER=$($PSQL "insert into users(name,account_id,username) values('$NAME_ENTERED',$ACCOUNT_ID_SELECTED,'$USERNAME_ENTERED')")
                if [[ $INSERT_USER == 'INSERT 0 1' ]]
                then
                echo -e "\n$NAME_ENTERED's account is created"
                fi
        else
        # program a password
        echo -e "\nEnter a password"
        sleep .25
        read PASSWORD_ENTERED
        # insert user information
        INSERT_USER=$($PSQL "insert into users(name,account_id,username,password) values('$NAME_ENTERED',$ACCOUNT_ID_SELECTED,'$USERNAME_ENTERED','$PASSWORD_ENTERED')")
                if [[ $INSERT_USER == 'INSERT 0 1' ]]
                then
                echo -e "\n$NAME_ENTERED's account is created"
                fi
        fi
    fi
    


}
EXIT(){
    echo -e "\nThank you for visiting the LOGIN experience!"
}
MENU  