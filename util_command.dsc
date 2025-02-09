heal_command:
    type: command
    name: dheal
    usage: /dheal
    description: heal player
    script:
        - heal <player>
        - feed <player> saturation:0
        - adjust <player> fire_time:0
        - adjust <player> remove_effects
        - narrate "<&e>플레이어가 회복되었습니다." targets:<player>

back_command:
    type: command
    name: back
    usage: /back
    description: back to a proper point
    script:
    - teleport <player> <player.flag[point]>

back_world:
    type: world
    events:
        on player death:
        - flag player point:<player.location>

jump_command:
    type: command
    name: jump
    usage: /jump [value]
    description: jump
    script:
    - if <context.args.is_empty>:
            - narrate "<&e>/jump [value]" targets:<player>
    - else:
        - if <context.args.first.is_decimal>:
            - define power <context.args.first>
            - definemap spec:
                generic_jump_strength: <[power]>
            - foreach <server.players> as:origin:
                - adjust <[origin]> attribute_base_values:<[spec]>
        - else if <context.args.first> == default:
            - definemap spec:
                generic_jump_strength: 0.41999998688697815
            - foreach <server.players> as:origin:
                - adjust <[origin]> attribute_base_values:<[spec]>
        - else:
            - narrate "<&e>/jump [value]" targets:<player>