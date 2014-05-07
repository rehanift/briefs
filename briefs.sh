create_file=false
render_file=false
filename=""
title="New Brief"
render_with_toc=true
render_scope="full"
render_format="pdf"

while test $# -gt 0; do
    case "$1" in
        create)
            shift
            create_file=true
            ;;
        --title)
            shift
            title=$1
            shift
            ;;
        render)
            shift
            render_file=true            
            ;;
        --format)
            shift
            render_format=$1
            shift
            ;;
        --scope)
            shift
            render_scope=$1
            shift
            ;;
        --hide-toc)
            shift
            render_with_toc=false
            ;;
        *) 
            filename=$1

            if $create_file; then
                if [ -f $filename ]; then
                    echo "File already exists: $filename"
                    exit 0;
                fi

                git rev-parse
                if [ $? -ne 0 ];then
                    git init
                    cp ~/.briefs/gitignore-template .gitignore
                    git add .gitignore
                    git commit -m "Added gitignore"
                fi

                cp ~/.briefs/base.org ./$filename
                sed -i.bak "s/__title__/$title/" ./$filename
                rm $filename.bak

                exit 0;
            elif $render_file; then                
                if [ ! -f $filename ]; then
                    echo "File does not exist: $filename"
                    exit 0;
                fi

                brief_name=${filename%.*}

                mkdir -p ./exports/$brief_name
                
                if [ ! -d $orgmode_lisp_dir ]; then
                    echo "This is not a valid org-mode lisp directory: $orgmode_lisp_dir"
                    exit 0;
                fi
                
                scoped_brief_name=$brief_name.$render_scope.org
                scoped_brief_path=./exports/$brief_name/$scoped_brief_name

                cp $filename $scoped_brief_path

                if [ ! -f ~/.briefs/scopes/$render_scope.el ]; then
                    echo "Could not find scope: $render_scope"
                    exit 0;
                fi

                if [ ! -f ~/.briefs/formats/$render_format.el ]; then
                    echo "Could not find format: $render_format"
                    exit 0;
                fi

                if [ ! -f ~/.briefs/env.el ]; then
                    touch ~/.briefs/env.el
                fi

                emacs --batch -Q \
                    --visit=$scoped_brief_path \
                    -l ~/.briefs/env.el \
                    -l ~/.briefs/functions.el \
                    -l ~/.briefs/scopes/$render_scope.el \
                    -l ~/.briefs/formats/$render_format.el 
                killall soffice
                
                exit 0;
            else
                echo "No Args"
            fi

            break
            ;;
    esac
done
