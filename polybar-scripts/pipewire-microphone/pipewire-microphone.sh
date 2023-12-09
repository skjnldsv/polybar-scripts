#!/bin/sh

get_mic_default() {
    # pactl info | awk '/Default Source:/ {print $3}'
    echo "alsa_input.usb-BIRD_UM1_BIRD_UM1-00.mono-fallback"
}

is_mic_muted() {
    pactl get-source-mute "$(get_mic_default)" | awk '{print $2}'
}

get_mic_status() {
    if [ "$(is_mic_muted)" = "yes" ]; then
        echo '%{F#ab4642}%{F-}'
    else
        echo ""
    fi
}

listen() {
    get_mic_status
    LANG=EN; pactl subscribe | while read -r event; do
        if printf "%s\n" "${event}" | grep -qE '(source|server)'; then
            get_mic_status
        fi
    done
}

toggle() {
    pactl set-source-mute "$(get_mic_default)" toggle
}

case "${1}" in
    --toggle)
        toggle
        ;;
    *)
        listen
        ;;
esac
