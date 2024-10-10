#!/usr/bin/env bash

prompt() {
    read -p "$1 ? [y/n] " answer
    case ${answer:0:1} in
        y|Y )
            return 0
        ;;
        * )
            return 1
        ;;
    esac
}