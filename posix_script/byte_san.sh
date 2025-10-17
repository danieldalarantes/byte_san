#!/bin/sh
if [ -f "$1" ] && [ -r "$1" ] && [ -w "$1" ]
then
    unset IFS
    backslash=\\
    count_chars=0
    count_empty_inputs=0
    count_main_newlines=0
    count_misc_newlines=0
    count_spaces=0
    io_block_size=8192
    limit_blank_lines=1
    limit_empty_inputs=1
    limit_spaces=100
    old_byte=000
    output_char=
    output_line=
    output_newline=${backslash}012
    output_space=${backslash}040
    tab_size=4
    while [ ${count_empty_inputs} -le ${limit_empty_inputs} ]
    do
        new_byte=
        for new_byte in $(od -A n -N ${io_block_size} -t o1 -v)
        do
            case ${new_byte} in
                *[123][01234567][01234567])
                    new_byte=${new_byte#${new_byte%???}}
                    ;;
                *[1234567][01234567])
                    new_byte=0${new_byte#${new_byte%??}}
                    ;;
                *[1234567])
                    new_byte=00${new_byte#${new_byte%?}}
                    ;;
                *)
                    new_byte=000
                    ;;
            esac
            case ${new_byte} in
                011)
                    line_size=$((count_chars + count_spaces))
                    tab_offset=$((line_size % tab_size))
                    count_spaces=$((count_spaces + tab_size - tab_offset))
                    ;;
                012)
                    count_main_newlines=$((count_main_newlines + 1))
                    count_chars=0
                    count_spaces=0
                    ;;
                01[345])
                    count_misc_newlines=$((count_misc_newlines + 1))
                    count_chars=0
                    count_spaces=0
                    ;;
                040)
                    count_spaces=$((count_spaces + 1))
                    ;;
                04[1234567]|0[567][01234567]|1[0123456][01234567]|17[0123456])
                    output_char=${backslash}${new_byte}
                    count_chars=$((count_chars + 1))
                    ;;
                2[04][012347]|2[15][01234567]|2[26][123456]|2[37][1234])
                    if [ ${old_byte} = 303 ]
                    then
                        output_char=${backslash}${old_byte}${backslash}${new_byte}
                        count_chars=$((count_chars + 1))
                    fi
                    ;;
            esac
            if [ ${#output_char} -ge 1 ]
            then
                if [ ${count_chars} = 1 ]
                then
                    if [ ${count_misc_newlines} -ge 1 ]
                    then
                        if [ ${count_main_newlines} -lt ${count_misc_newlines} ]
                        then
                            count_main_newlines=${count_misc_newlines}
                        fi
                        count_misc_newlines=0
                    fi
                    if [ ${#output_line} -ge 1 ]
                    then
                        printf ${output_line}${output_newline}
                        output_line=
                        count_main_newlines=$((count_main_newlines - 1))
                    fi
                    if [ ${count_main_newlines} -ge 1 ]
                    then
                        if [ ${count_main_newlines} -gt ${limit_blank_lines} ]
                        then
                            count_main_newlines=${limit_blank_lines}
                        fi
                        while [ ${count_main_newlines} -ge 1 ]
                        do
                            printf ${output_newline}
                            count_main_newlines=$((count_main_newlines - 1))
                        done
                    fi
                    if [ ${count_spaces} -ge 1 ]
                    then
                        tab_offset=$((count_spaces % tab_size))
                        if [ ${tab_offset} -ge 1 ]
                        then
                            if [ ${tab_offset} -lt $((tab_size / 2)) ]
                            then
                                count_spaces=$((count_spaces - tab_offset))
                            else
                                count_spaces=$((count_spaces + tab_size - tab_offset))
                            fi
                        fi
                    fi
                fi
                if [ ${count_spaces} -ge 1 ]
                then
                    if [ ${count_spaces} -gt ${limit_spaces} ]
                    then
                        count_spaces=${limit_spaces}
                    fi
                    count_chars=$((count_chars + count_spaces))
                    while [ ${count_spaces} -ge 1 ]
                    do
                        output_line=${output_line}${output_space}
                        count_spaces=$((count_spaces - 1))
                    done
                fi
                output_line=${output_line}${output_char}
                output_char=
            fi
            old_byte=${new_byte}
        done
        if [ ${#new_byte} -ge 1 ]
        then
            count_empty_inputs=0
        else
            if [ ${count_empty_inputs} = ${limit_empty_inputs} ] && [ ${#output_line} -ge 1 ]
            then
                printf ${output_line}${output_newline}
            fi
            count_empty_inputs=$((count_empty_inputs + 1))
        fi
    done < "$1" | dd ibs=${io_block_size} obs=${io_block_size} > "$1.$$"
    if [ -f "$1.$$" ] && [ -r "$1.$$" ] && [ -w "$1.$$" ]
    then
        mv "$1.$$" "$1"
    fi
fi
