# 랜덤 스왑 스크립트
# 사용 방법: /randswap on|off
# 기능: 데미지를 받으면 랜덤한 플레이어와 위치 및 인벤토리가 스왑됩니다.
# Script written by 어라랍(https://github.com/KDY05)

randswap_init:
    type: world
    events:
        on scripts loaded:
        - if !<server.has_flag[randswap]>:
            - flag server randswap:false

randswap_command:
    type: command
    name: randswap
    description: randswap command
    usage: /randswap on|off
    tab completions:
        1: on|off
    script:
    - if <context.args.is_empty>:
            - narrate "<&e>/randswap on|off" targets:<player>
            - stop
    - else:
        - choose <context.args.first>:
            - case on:
                - flag server randswap:true
                - reload scripts_now
                - narrate "<&2>랜덤 스왑을 활성화합니다." targets:<server.online_players>
                - stop
            - case off:
                - flag server randswap:false
                - reload scripts_now
                - narrate "<&c>랜덤 스왑을 비활성화합니다." targets:<server.online_players>
                - stop
            - default:
                - narrate "<&e>/randswap on|off" targets:<player>

randswap_world:
    type: world
    enabled: <server.flag[randswap]>
    debug: true
    events:
        on player damaged:
            - if <server.online_players.size> > 1:
                - define target <player>
                - while <[target]> == <player>:
                    - define target <server.online_players.random>
                - define origin <player.location>
                - teleport <player> <[target].location>
                - teleport <[target]> <[origin]>
                - inventory swap d:<[target].inventory> o:<player.inventory>
                - playsound <[origin]>|<[target].location> sound:ENTITY_ENDERMAN_TELEPORT