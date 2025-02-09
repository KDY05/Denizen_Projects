# 랜덤 점프 스크립트 (v1.0)
# 사용 방법: /randjump on|off (서버의 모든 플레이어에게 적용됩니다.)
# 기능: 점프의 강도가 매번 랜덤으로 변동합니다.
# Script written by 어라랍(https://github.com/KDY05)

randjump_init:
    type: world
    events:
        on scripts loaded:
        - if !<server.has_flag[randjump]>:
            - flag server randjump:false

randjump_world:
    type: world
    enabled: <server.flag[randjump]>
    events:
        after player jumps:
        - define rand <util.random.int[1].to[100]>
        # 70%로 확률로 강화 0단계
        - if <[rand].is_more_than[30]>:
            - define power <util.random.decimal[0.25].to[0.7]>
        # 20% 확률로 강화 1단계
        - else if <[rand].is_more_than[10]>:
            - define power <util.random.decimal[0.7].to[1.4]>
        # 9% 확률로 강화 2단계
        - else if <[rand].is_more_than[1]>:
            - define power <util.random.decimal[1.4].to[2.6]>
        # 1% 확률로 강화 3단계
        - else:
            - define power 8.0
        # attribute 적용 (점프 이벤트를 받으면 다음 점프의 강도가 정해짐)
        - definemap spec:
               generic_jump_strength: <[power]>
        - adjust <player> attribute_base_values:<[spec]>

randjump_command:
    type: command
    name: randjump
    description: randjump command
    usage: /randjump on|off
    tab completions:
        1: on|off
    script:
    - if <context.args.is_empty>:
            - narrate "<&e>/randjump on|off" targets:<player>
            - stop
    - else:
        - choose <context.args.first>:
            - case on:
                - flag server randjump:true
                - reload scripts_now
                - narrate "<&2>랜덤 점프를 활성화합니다." targets:<server.online_players>
                - stop
            - case off:
                - flag server randjump:false
                - reload scripts_now
                # 비활성화 시 기본 점프 강도로 복구. 놀랍게도 기본값이 저렇다.
                - definemap spec:
                    generic_jump_strength: 0.41999998688697815
                - foreach <server.players> as:origin:
                    - adjust <[origin]> attribute_base_values:<[spec]>
                - narrate "<&c>랜덤 점프를 비활성화합니다." targets:<server.online_players>
                - stop
            - default:
                - narrate "<&e>/randjump on|off" targets:<player>

# 점프 강도에 따른 제자리 점프하였을 때 낙하 데미지를 기록한 문서.
# 낙하 데미지는 방어력에 영향을 안 받으므로 1부터 20 데미지 까지만 기록함.

# generic_jump_strength: damage
# 0.8: 1
# 0.9: 2
# 1.0: 3
# 1.1: 4
# 1.2: 5
# 1.3: 6
# 1.4: 8
# 1.5: 10
# 1.6: 11
# 1.7: 12
# 1.8: 14
# 1.9: 15
# 2.0: 17
# 2.1: 19
# 2.2: 20+