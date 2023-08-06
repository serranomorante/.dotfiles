#!/bin/sh

case ${MONS_NUMBER} in
    1)
        # mons -o
        # feh --bg-scale /usr/share/wallpapers/SafeLanding/contents/images/5120x2880.jpg 
        echo "1"
        ;;
    2)
        # mons -e top
        # feh --bg-scale /usr/share/wallpapers/SafeLanding/contents/images/5120x2880.jpg 
        echo "2"
        ;;
    *)
        # Handle it manually
        echo "default"
        feh --bg-scale /usr/share/wallpapers/SafeLanding/contents/images/5120x2880.jpg 
        ;;
esac
