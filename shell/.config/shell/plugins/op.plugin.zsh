# Read command shortcuts
opr(){
    help='false'
    # opr -h
    while getopts 'h' flag; do
        case "${flag}" in
            h) help='true' ;;
        esac
    done
    if [ $help = 'true' ]; then
        echo "\nUsage:\n"
        echo "  opr <vault> <item-name> <field>\n"
        return
    fi
    op read "op://$1/$2/$3" 
}

# Item command shortcuts
alias opic='op item create --category '

# Shell plugin configurations
if [ -f "${HOME}/.config/op/plugins.sh" ]
then
  source ${HOME}/.config/op/plugins.sh
fi
