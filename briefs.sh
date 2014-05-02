orgmode_lisp_dir=~/.briefs/org-mode-current/lisp

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
            if $create_file; then
                filename=$1
                if [ -f $filename ]; then
                    echo "File already exists: $filename"
                    exit 0;
                fi
                cp ~/.briefs/base.org ./$filename
                sed -i.bak "s/__title__/$title/" ./$filename
                rm $filename.bak
            elif $render_file; then
                filename=$1
                
                if [ ! -d $orgmode_lisp_dir ]; then
                    echo "This is not a valid org-mode lisp directory: $orgmode_lisp_dir"
                    exit 0;
                fi

                emacs --batch -Q -L $orgmode_lisp_dir \
                    --visit=$filename \
                    -l ~/.briefs/env.el \
                    -l ~/.briefs/scopes/$render_scope.el \
                    -l ~/.briefs/formats/$render_format.el
                killall soffice
            else
                echo "No Args"
            fi

            break
            ;;
    esac
done
