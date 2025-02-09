# 몹 크리퍼화 스크립트
# 사용 방법: /creeper on|off
# 기능: 모든 몹(몬스터, 동물, 주민 등)이 크리퍼와 같이 행동합니다.
# Script written by 어라랍(https://github.com/KDY05)

creeper_init:
    type: world
    events:
        on scripts loaded:
        - if !<server.has_flag[creeper]>:
            - flag server creeper:false
        - flag server except:<list[creeper|ender_dragon]>
        - flag server neutral:<list[zombified_piglin|enderman]>

creeper_command:
    type: command
    name: creeper
    description: creeper command
    usage: /creeper on|off
    tab completions:
        1: on|off
    script:
    - if <context.args.is_empty>:
            - narrate "<&e>/creeper on|off" targets:<player>
            - stop
    - else:
        - choose <context.args.first>:
            - case on:
                - flag server creeper:true
                - reload scripts_now
                - narrate "<&2>몹 크리퍼화를 활성화합니다." targets:<server.online_players>
                - stop
            - case off:
                - flag server creeper:false
                - reload scripts_now
                - narrate "<&c>몹 크리퍼화를 비활성화합니다." targets:<server.online_players>
                - stop
            - default:
                - narrate "<&e>/creeper on|off" targets:<player>

creeper_world:
    type: world
    enabled: <server.flag[creeper]>
    debug: false
    events:
        on delta time secondly:
        # 대상 몹 플래그 & 어그로
        - foreach <server.online_players> as:origin:
            - foreach <[origin].location.find_entities.within[16]> as:entity:
                - if ( <[entity].is_mob> ) && ( !<server.flag[except].contains[<[entity].entity_type>]> ):
                    - if ( ( !<[entity].is_monster> ) || ( <server.flag[neutral].contains[<[entity].entity_type>]> ) ) && !<[entity].glowing>:
                        - follow followers:<[entity]> target:<[origin]> lead:1.0 max:16.0 speed:0.15 no_teleport
                        - if !<[entity].has_flag[following]>:
                            - flag <[entity]> following:<[origin]> expire:10s
                    - flag <[entity]> creeper:true expire:1m
        on tick every:5:
        # 자폭 시도
        - foreach <server.online_players> as:origin:
            - foreach <[origin].location.find_entities.within[3]> as:entity:
                - if <[entity].has_flag[creeper]> && !<[entity].glowing> && ( <[entity].can_see[<[origin]>]> ):
                    - if <[entity].is_monster> && ( <[entity].target> == <[origin]> ):
                        #- announce "monster"
                        - if <[entity].has_flag[following]>:
                            - follow followers:<[entity]> stop
                        - run explosion_task def.entity:<[entity]> def.player:<[origin]>
                    - else if <[entity].has_flag[following]> && ( <[entity].flag[following]> == <[origin]> ):
                        #- announce "not monster"
                        - follow followers:<[entity]> stop
                        - run explosion_task def.entity:<[entity]> def.player:<[origin]>

explosion_task:
    type: task
    definitions: entity|player
    script:
    - playsound <[entity].location> sound:ENTITY_CREEPER_PRIMED
    - define speed <[entity].speed>
    - adjust <[entity]> speed:0
    - adjust <[entity]> glowing:true
    #- announce <[origin].location.distance[<[entity].location>]>
    - wait 30t
    - if ( <[player].location.distance[<[entity].location>]> < 7.0 ) && ( <[entity].can_see[<[player]>]> ):
        #- announce <[origin].location.distance[<[entity].location>]>
        - explode power:3.0 <[entity].location> breakblocks source:<[entity]>
        - remove <[entity]>
    - else:
        - adjust <[entity]> speed:<[speed]>
        - adjust <[entity]> glowing:false