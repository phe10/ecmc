create table if not exists corp_account_contract
(
    id                      bigint auto_increment
        primary key,
    contract_id             int                              null,
    user_id                 bigint                           null comment '用户ID',
    account_id              bigint                           null comment '角色账号ID',
    character_id            int                              null comment '角色ID',
    character_name          varchar(100) collate utf8mb4_bin null comment '角色名',
    acceptor_id             int                              null comment '接受人ID',
    acceptor_name           varchar(100)                     null comment '接受人名称',
    acceptor_type           varchar(255)                     null,
    assignee_id             int                              null comment '受让人ID',
    assignee_name           varchar(100)                     null comment '受让人名称',
    assignee_type           varchar(255)                     null,
    availability            varchar(20)                      null comment '有效范围',
    buyout                  double                           null comment '一口价',
    collateral              varchar(255)                     null comment '快递押金',
    date_accepted           timestamp                        null comment '接受时间',
    date_completed          timestamp                        null comment '完成时间',
    date_expired            timestamp                        null comment '过期时间',
    date_issued             timestamp                        null comment '发起时间',
    days_to_complete        int                              null comment '完成天数',
    end_location_id         bigint                           null comment '快递目的地',
    end_location_name       varchar(200)                     null comment '快递目的地名称',
    for_corporation         tinyint(1)                       null comment '是否是军团合同',
    issuer_corporation_id   int                              null comment '发起军团ID',
    issuer_corporation_name varchar(200)                     null comment '发起军团名称',
    issuer_id               int                              null comment '合同发起人ID',
    issuer_name             varchar(200)                     null comment '合同发起人名称',
    price                   double                           null comment '合同价格',
    reward                  double                           null comment '快递奖金',
    start_location_id       bigint                           null comment '快递开始地点ID',
    start_location_name     varchar(200)                     null comment '快递开始地点名称',
    status                  varchar(20)                      null comment '合同状态',
    title                   varchar(100)                     null comment '合同标题',
    type                    varchar(20)                      null comment '合同类型',
    volume                  double                           null comment '合同体积',
    create_time             timestamp                        null comment '创建时间',
    create_id               bigint                           null comment '创建人',
    create_by               varchar(200)                     null comment '创建人',
    update_time             timestamp                        null comment '更新时间',
    update_id               bigint                           null comment '更新人',
    update_by               varchar(200)                     null comment '更新人'
)
    comment '军团成员合同表' charset = utf8mb4;

create index idx_contract_id
    on corp_account_contract (contract_id);

create table if not exists corp_account_contract_item
(
    id           bigint auto_increment
        primary key,
    account_id   bigint       null,
    contract_id  int          null,
    is_included  tinyint(1)   null comment '如果合同签发人已将此项目与合同一起提交，则为true；如果isser要求在合同中提供此项目，则为false',
    is_singleton tinyint(1)   null comment '是否独立？',
    quantity     int          null comment '物品数量',
    raw_quantity int          null comment '-1表示该项是单例（不可堆叠）。如果项目恰好是蓝图，-1是原件，-2是蓝图副本',
    record_id    bigint       null comment '针对这个合同物品的记录ID',
    type_id      int          null comment '物品名称',
    type_name    varchar(200) null comment '物品价格',
    sell_price   double       null comment '物品SELL价',
    buy_price    double       null comment '物品BUY价'
)
    comment '军团成员合同物品表' charset = utf8mb4;

create index idx_account_id_contract_id
    on corp_account_contract_item (account_id, contract_id);

create table if not exists corp_account_kill_mail
(
    id                bigint auto_increment
        primary key,
    kill_mail_id      int                              null comment '击杀ID',
    kill_mail_hash    varchar(200)                     null comment '击杀Hash',
    kill_mail_time    timestamp                        null comment '击杀时间',
    is_npc            tinyint(1)                       null comment '是否是NPC击毁',
    solar_system_id   int                              null comment '所在星系ID',
    solar_system_name varchar(100)                     null comment '所在星系名称',
    damage_taken      decimal(20, 4)                   null comment '所受损失',
    ship_type_id      int                              null comment '舰船ID',
    ship_type_name    varchar(200)                     null comment '舰船名称',
    character_id      int                              null comment '角色ID',
    character_name    varchar(200)                     null comment '角色名称',
    corporation_id    int                              null comment '军团ID',
    corporation_name  varchar(200)                     null comment '军团名称',
    alliance_id       int                              null comment '联盟ID',
    alliance_name     varchar(200)                     null comment '联盟名称',
    user_id           bigint                           null,
    account_id        bigint                           null,
    create_time       timestamp                        null comment '创建时间',
    create_by         varchar(100) collate utf8mb4_bin null comment '创建人',
    create_id         bigint                           null comment '创建人ID',
    update_time       timestamp                        null comment '更新时间',
    update_id         bigint                           null comment '更新人',
    update_by         varchar(100) collate utf8_bin    null comment '更新时间'
)
    comment '军团成员KM记录表' charset = utf8mb4;

create index idx_account_id
    on corp_account_kill_mail (account_id);

create table if not exists corp_account_kill_mail_item
(
    id           bigint auto_increment
        primary key,
    kill_mail_id bigint                           null comment 'KMID',
    type_id      int                              null comment '物品类型ID',
    name         varchar(200)                     null comment '物品名称',
    num          bigint                           null comment '数量',
    type         varchar(255)                     null comment '类型，掉落/损毁',
    price        decimal(20, 4)                   null comment '估价',
    create_time  timestamp                        null comment '创建时间',
    create_by    varchar(100) collate utf8mb4_bin null comment '创建人',
    create_id    bigint                           null comment '创建人ID',
    update_time  timestamp                        null comment '更新时间',
    update_id    bigint                           null comment '更新人',
    update_by    varchar(100) collate utf8_bin    null comment '更新时间'
)
    comment '军团成员KM记录详细损失表' charset = utf8mb4;

create index idx_kill_mail_id
    on corp_account_kill_mail_item (kill_mail_id desc);

create table if not exists corp_account_order
(
    id             bigint auto_increment
        primary key,
    order_id       bigint                           null,
    user_id        bigint                           null comment '用户ID',
    account_id     bigint                           null comment '角色账号ID',
    character_id   int                              null comment '角色ID',
    character_name varchar(100) collate utf8mb4_bin null comment '角色名',
    client_id      int                              null comment '客户ID',
    client_name    varchar(200)                     null comment '客户名称',
    client_type    varchar(200)                     null,
    date           timestamp                        null comment '交易时间',
    is_buy         tinyint(1)                       null comment '是否是购买订单',
    is_personal    tinyint(1)                       null comment '是否是个人订单',
    journal_ref_id bigint                           null,
    location_id    bigint                           null,
    location_name  varchar(200)                     null,
    quantity       int                              null,
    unit_price     double                           null comment '单价',
    type_id        int                              null,
    type_name      varchar(200)                     null,
    create_time    timestamp                        null comment '创建时间',
    create_id      bigint                           null comment '创建人',
    create_by      varchar(200)                     null comment '创建人',
    update_time    timestamp                        null comment '更新时间',
    update_id      bigint                           null comment '更新人',
    update_by      varchar(200)                     null comment '更新人'
)
    comment '军团成员市场交易订单' charset = utf8mb4;

create index idx_user_id_account_id
    on corp_account_order (user_id, account_id);

create table if not exists corp_account_sale_order
(
    id             bigint auto_increment
        primary key,
    order_id       bigint                           null,
    user_id        bigint                           null comment '用户ID',
    account_id     bigint                           null comment '角色账号ID',
    character_id   int                              null comment '角色ID',
    character_name varchar(100) collate utf8mb4_bin null comment '角色名',
    duration       int                              null comment '时效',
    escrow         double                           null,
    is_buy_order   tinyint(1)                       null comment '是否是购买订单',
    is_corporation tinyint(1)                       null comment '是否是军团订单',
    issued         timestamp                        null comment '发布时间',
    location_id    bigint                           null comment '位置ID',
    location_name  varchar(255)                     null comment '位置名称',
    price          decimal(20, 4)                   null comment '价格',
    `range`        varchar(255)                     null comment '范围',
    region_id      int                              null comment '区域ID',
    region_name    varchar(255)                     null comment '区域名称',
    type_id        int                              null comment '物品ID',
    type_name      varchar(255)                     null comment '物品名称',
    volume_remain  int                              null comment '剩余数量',
    volume_total   int                              null comment '上架数量',
    create_time    timestamp                        null comment '创建时间',
    create_id      bigint                           null comment '创建人',
    create_by      varchar(200)                     null comment '创建人',
    update_time    timestamp                        null comment '更新时间',
    update_id      bigint                           null comment '更新人',
    update_by      varchar(200)                     null comment '更新人'
)
    comment '军团成员市场在售订单' charset = utf8mb4;

create index idx_user_id_account_id
    on corp_account_sale_order (user_id, account_id);

create table if not exists corp_account_skill
(
    id                    bigint auto_increment
        primary key,
    user_id               bigint                           null comment '用户ID',
    account_id            bigint                           null comment '角色账号ID',
    character_id          int                              null comment '角色ID',
    character_name        varchar(100) collate utf8mb4_bin null comment '角色名',
    skill_id              int                              null comment '技能ID',
    skill_name            varchar(255)                     null comment '技能名称',
    active_skill_level    int                              null,
    skill_points_in_skill bigint                           null,
    trained_skill_level   int                              null,
    create_time           timestamp                        null comment '创建时间',
    create_id             bigint                           null comment '创建人',
    create_by             varchar(200)                     null comment '创建人',
    update_time           timestamp                        null comment '更新时间',
    update_id             bigint                           null comment '更新人',
    update_by             varchar(200)                     null comment '更新人'
)
    comment '军团用户技能表' charset = utf8mb4;

create index idx_account_id
    on corp_account_skill (id, account_id);

create table if not exists corp_account_skill_queue
(
    id                bigint auto_increment
        primary key,
    user_id           bigint                           null comment '用户ID',
    account_id        bigint                           null comment '角色账号ID',
    character_id      int                              null comment '角色ID',
    character_name    varchar(100) collate utf8mb4_bin null comment '角色名',
    skill_id          int                              null comment '技能ID',
    skill_name        varchar(100)                     null comment '技能名称',
    finish_date       timestamp                        null comment '完成时间',
    finished_level    int                              null comment '完成等级',
    level_end_sp      int                              null comment '完成后技能点',
    level_start_sp    int                              null comment '开始前技能点',
    queue_position    int                              null comment '队列点数',
    start_date        timestamp                        null comment '开始时间',
    training_start_sp int                              null comment '培训开始技能点',
    create_time       timestamp                        null comment '创建时间',
    create_id         bigint                           null comment '创建人',
    create_by         varchar(200)                     null comment '创建人',
    update_time       timestamp                        null comment '更新时间',
    update_id         bigint                           null comment '更新人',
    update_by         varchar(200)                     null comment '更新人'
)
    comment '军团用户技能队列表' charset = utf8mb4;

create table if not exists corp_account_wallet
(
    id                bigint auto_increment
        primary key,
    journal_id        bigint                           null,
    user_id           bigint                           null comment '用户ID',
    account_id        bigint                           null comment '角色账号ID',
    character_id      int                              null comment '角色ID',
    character_name    varchar(100) collate utf8mb4_bin null comment '角色名',
    amount            decimal(20, 4)                   null comment '交易金额',
    balance           decimal(20, 4)                   null comment '余额',
    context_id        bigint                           null comment '上下文ID',
    context_id_type   varchar(100)                     null comment '上下文类型',
    date              timestamp                        null comment '交易时间',
    first_party_id    int                              null comment '第一方ID',
    first_party_name  varchar(200)                     null comment '第一方名称',
    first_party_type  varchar(200)                     null comment '第一方类型',
    description       varchar(200)                     null comment '交易描述',
    reason            varchar(500)                     null comment '交易原因',
    ref_type          varchar(100)                     null comment '交易类型',
    second_party_id   int                              null comment '第三方ID',
    second_party_name varchar(200)                     null comment '第三方名称',
    second_party_type varchar(200)                     null comment '第三方类型',
    tax               decimal(20, 4)                   null comment '纳税数额',
    tax_receiver_id   int                              null comment '税务记录ID',
    create_time       timestamp                        null comment '创建时间',
    create_id         bigint                           null comment '创建人',
    create_by         varchar(200)                     null comment '创建人',
    update_time       timestamp                        null comment '更新时间',
    update_id         bigint                           null comment '更新人',
    update_by         varchar(200)                     null comment '更新人'
)
    comment '军团成员钱包流水' charset = utf8mb4;

create index idx_user_id_account_id
    on corp_account_wallet (user_id, account_id);

create table if not exists corp_lp_goods
(
    id          bigint auto_increment
        primary key,
    title       varchar(200) collate utf8mb4_bin null comment '商品标题',
    type        varchar(200) collate utf8mb4_bin null comment '商品类型',
    lp          decimal(11, 2)                   null comment '所需要的LP',
    num         int                              null comment '商品总数量',
    shop_num    int default 0                    not null comment '已销售数量',
    pics        longtext collate utf8mb4_bin     null comment '商品图片',
    create_time timestamp                        null comment '创建时间',
    create_by   varchar(100) collate utf8mb4_bin null comment '创建人',
    create_id   bigint                           null comment '创建人ID',
    update_time timestamp                        null comment '更新时间',
    update_id   bigint                           null comment '更新人',
    update_by   varchar(100) collate utf8_bin    null comment '更新时间'
)
    comment 'LP商品表' charset = utf8mb4;

create table if not exists corp_lp_goods_order
(
    id              bigint auto_increment
        primary key,
    title           varchar(200) collate utf8mb4_bin null comment '标题',
    num             int                              null comment '数量',
    status          tinyint                          null comment '状态1=等待，2=通过，3=拒绝',
    content         varchar(200) collate utf8mb4_bin null comment '兑换备注',
    examine_content varchar(200) collate utf8mb4_bin null comment '审批备注',
    character_id    int                              null,
    character_name  varchar(100) collate utf8mb4_bin null comment '收货角色名称',
    create_time     timestamp                        null comment '创建时间',
    create_id       bigint                           null comment '创建人',
    create_by       varchar(200)                     null comment '创建人',
    update_time     timestamp                        null comment '更新时间',
    update_id       bigint                           null comment '更新人',
    update_by       varchar(200)                     null comment '更新人'
)
    comment '军团LP商品购买记录表' charset = utf8mb4;

create index idx_character_id
    on corp_lp_goods_order (character_id);

create table if not exists corp_lp_log
(
    id             bigint auto_increment
        primary key,
    user_id        bigint                              null comment '用户ID',
    account_id     bigint                              null comment '角色ID',
    character_name varchar(100) collate utf8mb4_bin    null comment '角色名',
    lp             decimal(11, 2)                      null comment 'LP数量',
    source         int                                 null comment '1=PAP自动转换,2=手动发放,3=用户转账，4=兑换商品,5=兑换退款,6=物品兑换,7=超网节点',
    type           int                                 null comment 'LP操作，1=支出，2=收入',
    content        varchar(200) collate utf8mb4_bin    null comment '说明',
    order_id       bigint                              null comment '兑换商品的日志ID',
    create_by      varchar(100) collate utf8mb4_bin    null,
    create_id      bigint                              null,
    create_time    timestamp default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    update_time    timestamp                           null comment '更新时间',
    update_id      bigint                              null comment '更新人',
    update_by      varchar(100) collate utf8_bin       null comment '更新时间'
)
    comment '军团LP发放记录表' charset = utf8mb4;

create index idx_user_id_account_id
    on corp_lp_log (user_id, account_id, order_id);

create table if not exists corp_member
(
    id              bigint auto_increment
        primary key,
    character_id    int          null comment '角色ID',
    character_name  varchar(100) null comment '角色名称',
    account_id      bigint       null comment '账号ID',
    user_id         bigint       null comment '用户ID',
    nick_name       varchar(255) null comment '用户昵称',
    corp_system     tinyint(1)   null comment '是否绑定军团系统',
    seat_system     tinyint(1)   null comment '是否绑定SEAT系统',
    last_login_time timestamp    null comment '上次上线时间',
    not_login_day   int          null comment '多少天未上线',
    create_time     timestamp    null,
    constraint uk_user_account_chart
        unique (user_id, account_id, character_id)
)
    comment '军团成员信息表' charset = utf8mb4;

create table if not exists corp_message_board
(
    id             bigint auto_increment
        primary key,
    account_id     bigint       null,
    character_name varchar(200) null comment '角色名称',
    character_id   int          null comment '角色ID',
    content        longtext     null comment '动态内容',
    likes          int          null comment '点赞数量',
    create_time    timestamp    null comment '创建时间',
    create_id      bigint       null comment '创建人',
    create_by      varchar(200) null comment '创建人',
    update_time    timestamp    null comment '更新时间',
    update_id      bigint       null comment '更新人',
    update_by      varchar(200) null comment '更新人'
)
    comment '留言板' charset = utf8mb4;

create index idx_account_id
    on corp_message_board (account_id);

create table if not exists corp_srp_blacklist
(
    id           bigint auto_increment
        primary key,
    user_id      bigint                           null,
    character_id bigint                           null,
    name         varchar(100) collate utf8mb4_bin null comment '角色名字',
    is_full      tinyint(1)                       null comment '是否连坐其他角色',
    end_time     varchar(200) collate utf8mb4_bin null comment '截至时间',
    start_time   timestamp                        null comment '开始时间',
    remark       varchar(200) collate utf8mb4_bin null comment '拦截原因',
    create_time  timestamp                        null comment '创建时间',
    create_id    bigint                           null comment '创建人',
    create_by    varchar(200) collate utf8mb4_bin null comment '创建人',
    update_time  timestamp                        null comment '更新时间',
    update_id    bigint                           null comment '更新人',
    update_by    varchar(100) collate utf8_bin    null comment '更新时间'
)
    comment '补损规则黑名单' charset = utf8mb4;

create index idx_user_id_char_id
    on corp_srp_blacklist (user_id, character_id);

create table if not exists corp_srp_log
(
    id           bigint auto_increment
        primary key,
    user_id      bigint                           null comment '用户ID',
    kill_mail_id bigint                           null comment '击毁邮件ID',
    status       int                              null comment '状态1=待审批，2=已通过，3=已拒绝',
    content      varchar(200)                     null comment '提交备注',
    sp_content   varchar(200)                     null comment '审批备注',
    create_time  timestamp                        null comment '创建时间',
    create_by    varchar(100) collate utf8mb4_bin null comment '创建人',
    create_id    bigint                           null comment '创建人ID',
    update_time  timestamp                        null comment '更新时间',
    update_id    bigint                           null comment '更新人',
    update_by    varchar(100) collate utf8_bin    null comment '更新时间'
)
    comment '军团补损申请记录' charset = utf8mb4;

create index idx_user_id
    on corp_srp_log (user_id);

create table if not exists corp_srp_rules
(
    id          bigint auto_increment
        primary key,
    ship_id     int                           null comment '舰船ID',
    ship_name   varchar(100)                  null comment '舰船名称',
    is_npc      tinyint(1) default 0          not null comment '是否支持NPC击杀',
    join_time   int                           null comment '入团多少天内支持补损',
    not_srp     tinyint(1) default 0          not null comment '是否禁止补损',
    create_time timestamp                     null,
    create_by   varchar(100)                  null,
    create_id   bigint                        null,
    update_time timestamp                     null comment '更新时间',
    update_id   bigint                        null comment '更新人',
    update_by   varchar(100) collate utf8_bin null comment '更新时间'
)
    comment '军团补损规则表' charset = utf8mb4;

create table if not exists corp_user_account
(
    id             bigint auto_increment
        primary key,
    character_name varchar(200)                     null comment '角色名称',
    character_id   int                              null comment '角色ID',
    user_id        bigint                           null comment '系统用户ID',
    is_main        tinyint(1)                       null comment '主角色',
    access_token   text collate utf8mb4_bin         null comment 'ESI/Token',
    access_exp     timestamp                        null comment 'AccessToken过期时间',
    refresh_token  varchar(200) collate utf8mb4_bin null comment 'ESI/Token',
    corp_id        bigint                           null comment '军团ID',
    corp_name      varchar(100) collate utf8mb4_bin null comment '军团名称',
    alliance_id    bigint                           null comment '联盟ID',
    alliance_name  varchar(100) collate utf8mb4_bin null comment '联盟名称',
    isk            double         default 0         not null comment 'ISK数量',
    skill          bigint         default 0         not null comment '技能点数量',
    unallocated_sp int                              null comment '未分配技能点',
    lp_now         decimal(11, 2) default 0.00      not null comment 'LP当前数量',
    lp_total       decimal(22, 2) default 0.00      not null comment 'LP总计获得数量',
    lp_use         decimal(11, 2) default 0.00      not null comment 'LP已使用数量',
    join_time      timestamp                        null comment '入团时间(加入主军团的时间)',
    create_time    timestamp                        null comment '创建时间',
    create_id      bigint                           null comment '创建人',
    create_by      varchar(200)                     null comment '创建人',
    update_time    timestamp                        null comment '更新时间',
    update_id      bigint                           null comment '更新人',
    update_by      varchar(200)                     null comment '更新人',
    constraint id
        unique (id)
)
    comment '军团用户角色表' charset = utf8mb4;

create index idx_user_id_char_id
    on corp_user_account (user_id, character_id);

create table if not exists discord_bot
(
    id            bigint auto_increment
        primary key,
    bot_id        bigint       null comment '机器人ID',
    bot_name      varchar(255) null comment '机器人名称',
    guild_id      bigint       null comment '频道ID',
    permissions   int          null comment '权限',
    access_token  varchar(200) null comment 'Discord认证Token',
    refresh_token varchar(200) null comment 'Discord刷新Token',
    expires_in    timestamp    null comment 'Discord认证Token过期时间'
)
    charset = utf8mb4;

create table if not exists eve_address
(
    id      int auto_increment
        primary key,
    name    varchar(100) null,
    name_en varchar(100) null
)
    comment 'EVE地名对照' charset = utf8mb4;

create table if not exists eve_blue_print
(
    id                     int          not null
        primary key,
    name                   varchar(200) null comment '蓝图名称',
    name_en                varchar(200) null comment '蓝图英文名称',
    max_limit              int          null comment '最大流程数',
    copy_time              int          null comment '复制基础时间',
    manufacturing_time     int          null comment '制造基础时间',
    research_material_time int          null comment '材料优化基础时间',
    research_time_time     int          null comment '时间优化基础时间',
    invention_time         int          null comment '发明基础时间',
    reaction_time          int          null comment '反应基础时间',
    group_id               int          null comment '分组ID ',
    group_name             varchar(200) null comment '分组名称',
    group_name_en          varchar(200) null comment '分组英文名称',
    meta_group_id          int          null comment '元组ID',
    meta_group_name        varchar(200) null comment '元组名称',
    meta_group_name_en     varchar(200) null comment '元组英文名称',
    market_group_id        int          null comment '市场分组ID',
    market_group_name      varchar(200) null comment '市场分组名称',
    market_group_name_en   varchar(200) null comment '市场分组英文名称',
    category_id            int          null comment '分类ID',
    category_name          varchar(200) null comment '分类名称',
    category_name_en       varchar(200) null comment '分类英文名称',
    create_time            timestamp    null comment '创建时间'
)
    comment 'EVE-蓝图表' charset = utf8mb4;

create table if not exists eve_blue_print_materials
(
    id            int auto_increment
        primary key,
    blue_print_id int          null comment '蓝图ID',
    type          int          null comment '类型 1=复制，2=材料优化，3=时间优化，4=发明，5=制造，6=反应',
    type_id       int          null comment '类型ID',
    type_name     varchar(255) null comment '类型名称',
    type_name_en  varchar(255) null comment '类型英文名称',
    quantity      varchar(255) null comment '数量',
    create_time   timestamp    null comment '创建时间'
)
    comment 'EVE-蓝图材料表' charset = utf8mb4;

create table if not exists eve_blue_print_products
(
    id                int auto_increment
        primary key,
    blue_print_id     int          null comment '蓝图ID',
    type              int          null comment '类型 1=发明产出，2=制造产出，3=反应产出',
    products_id       int          null comment '产出物品ID',
    products_name     varchar(255) null comment '产出物品名称',
    products_name_en  varchar(255) null comment '产出物品名称英文',
    products_quantity varchar(255) null comment '产出物品数量',
    probability       varchar(255) null comment '产出概率',
    create_time       timestamp    null
)
    comment 'EVE-蓝图产出表' charset = utf8mb4;

create table if not exists eve_blue_print_skill
(
    id             int auto_increment
        primary key,
    blue_print_id  int          null comment '蓝图ID',
    type           int          null comment '类型 1=复制，2=材料优化，3=时间优化，4=发明，5=制造，6=反应',
    skills_id      int          null comment '技能ID',
    skills_name    varchar(255) null comment '技能名称',
    skills_name_en varchar(255) null comment '技能名称英文',
    level          int          null comment '等级',
    create_time    timestamp    null comment '创建时间'
)
    comment 'EVE-蓝图技能表' charset = utf8mb4;

create table if not exists eve_category
(
    id          int          not null
        primary key,
    name        varchar(200) null comment '分类名称',
    name_en     varchar(200) null comment '分类英文名称',
    create_time timestamp    null comment '创建时间'
)
    comment 'EVE-分类表' charset = utf8mb4;

create table if not exists eve_group
(
    id               int          null,
    name             varchar(200) null comment '分组名称',
    name_en          varchar(200) null comment '分组英文名称',
    icon_id          int          null comment '图标ID',
    category_id      int          null comment '分类ID',
    category_name    varchar(200) null comment '分类名称',
    category_name_en varchar(200) null comment '分类英文名称',
    create_time      timestamp    null comment '创建时间'
)
    comment 'EVE-分组表' charset = utf8mb4;

create table if not exists eve_market_group
(
    id             int          null,
    pid            int          null comment '父级ID',
    name           varchar(200) null comment '市场分组名称',
    name_en        varchar(200) null comment '市场分组英文名称',
    icon_id        int          null comment '图标ID',
    description    text         null comment '描述',
    description_en text         null comment '描述英文',
    has_type       tinyint(1)   null comment '是否是类型了',
    crate_time     timestamp    null
)
    comment 'EVE-市场分组表' charset = utf8mb4;

create table if not exists eve_meta_group
(
    id          int          null,
    name        varchar(200) null comment '元分组名称',
    name_en     varchar(200) null comment '元分组英文名称',
    create_time timestamp    null comment '创建时间'
)
    comment 'EVE-元分组表' charset = utf8mb4;

create table if not exists eve_type
(
    id                   int          not null comment '物品ID'
        primary key,
    name                 varchar(200) null comment '物品名称',
    name_en              varchar(200) null comment '物品名称英文',
    description          longtext     null comment '物品描述',
    description_en       longtext     null comment '物品描述英文',
    group_id             int          null comment '分组ID',
    group_name           varchar(200) null comment '分组名称',
    group_name_en        varchar(200) null comment '分组名称英文',
    meta_group_id        int          null comment '元分组ID',
    meta_group_name      varchar(200) null comment '元分组名称',
    meta_group_name_en   varchar(200) null comment '元分组名称英文',
    market_group_id      int          null comment '市场分组ID',
    market_group_name    varchar(200) null comment '市场分组名称',
    market_group_name_en varchar(200) null comment '市场分组名称英文',
    category_id          int          null comment '分类ID',
    category_name        varchar(200) null comment '分类名称',
    category_name_en     varchar(200) null comment '分类名称中文',
    create_time          timestamp    null
)
    comment 'EVE所有的物品ID和名称' charset = utf8mb4;

create index groupId
    on eve_type (group_id);

create index id
    on eve_type (id);

create index market_group_id
    on eve_type (market_group_id);

create table if not exists eve_type_alias
(
    id    bigint auto_increment
        primary key,
    name  varchar(200) null,
    alias varchar(200) null,
    qq    varchar(11)  null
)
    charset = utf8mb4;

create table if not exists sys_attach
(
    id            bigint auto_increment
        primary key,
    upload_type   int                           null comment '上传类型',
    file_path     varchar(200) collate utf8_bin null comment '文件保存目录',
    url           varchar(500) collate utf8_bin null comment '文件访问URL',
    file_name     varchar(200)                  null comment '保存的文件名',
    original_name varchar(200)                  null comment '原始文件名',
    md5           varchar(32)                   null comment '文件MD5',
    create_time   timestamp                     null comment '创建时间',
    create_id     bigint                        null comment '创建人',
    create_by     varchar(200)                  null comment '创建人'
)
    comment '系统-附件表' charset = utf8mb4;

create table if not exists sys_config
(
    id          bigint auto_increment
        primary key,
    name        varchar(100) collate utf8_bin null comment '配置名称',
    value       text collate utf8_bin         null comment '配置值',
    title       varchar(200) collate utf8_bin null comment '标题',
    remark      varchar(200) collate utf8_bin null comment '备注',
    update_time timestamp                     null comment '更新时间',
    update_id   bigint                        null comment '更新人',
    update_by   varchar(100) collate utf8_bin null comment '更新时间',
    create_time timestamp                     null comment '创建时间',
    create_id   bigint                        null comment '创建人',
    create_by   varchar(200)                  null comment '创建人',
    constraint idx_name
        unique (name)
)
    comment '系统配置表' charset = utf8mb4;

create table if not exists sys_menu
(
    id          bigint auto_increment
        primary key,
    name        varchar(50)          null comment '菜单名称',
    pid         bigint               null comment '父级ID',
    type        int                  null comment '菜单类型 0=目录,1=菜单,2=按钮',
    icon        varchar(50)          null comment '菜单图标',
    is_link     tinyint(1) default 0 null comment '是否外链',
    frame       tinyint(1)           null comment '是否内嵌',
    link_url    varchar(500)         null comment '外链地址',
    hidden      tinyint(1)           null comment '是否可见',
    permission  varchar(100)         null comment '权限字符串',
    path        varchar(500)         null comment '路由地址',
    cache       tinyint(1)           null comment '是否缓存',
    component   varchar(200)         null comment '组件地址',
    sort        int                  null comment '排序号',
    create_time timestamp            null comment '创建时间',
    create_id   bigint               null comment '创建人',
    create_by   varchar(200)         null comment '创建人',
    update_time timestamp            null comment '更新时间',
    update_id   bigint               null comment '更新人',
    update_by   varchar(200)         null comment '更新人',
    affix       tinyint(1)           null comment '是否禁止关闭此选项卡'
)
    comment '系统-菜单表' charset = utf8mb4;

create table if not exists sys_role
(
    id          int auto_increment
        primary key,
    name        varchar(200) null comment '角色名',
    remark      varchar(200) null comment '备注',
    create_time timestamp    null comment '创建时间',
    create_id   bigint       null comment '创建人',
    create_by   varchar(200) null comment '创建人',
    update_time timestamp    null comment '更新时间',
    update_id   bigint       null comment '更新人',
    update_by   varchar(200) null comment '更新人'
)
    comment '系统-角色表' charset = utf8mb4;

create table if not exists sys_roles_menus
(
    role_id   bigint     not null comment '角色ID',
    menu_id   bigint     not null comment '菜单ID',
    virtually tinyint(1) null comment '是否是虚拟的',
    primary key (role_id, menu_id)
)
    comment '系统-角色菜单关联表' charset = utf8mb4;

create index FKc67smp0fqtqvu676ed5lt5yfg
    on sys_roles_menus (menu_id);

create table if not exists sys_user
(
    id                    bigint auto_increment
        primary key,
    username              varchar(200)      null comment '用户名',
    password              varchar(1000)     null comment '密码',
    nick_name             varchar(100)      null comment '用户昵称',
    avatar                varchar(500)      null comment '头像ID',
    status                tinyint default 0 not null comment '用户状态，0=正常，1=冻结，2=锁定',
    phone                 varchar(20)       null comment '手机号',
    email                 varchar(100)      null comment '邮箱',
    sex                   int               null comment '性别 0=女,1=男,2=未知',
    qq                    varchar(20)       null comment 'QQ',
    city                  varchar(20)       null comment '城市',
    discord_id            bigint            null comment 'DiscordID 此项不为空代表已经绑定',
    discord_name          varchar(200)      null comment 'Discord昵称',
    discord_email         varchar(200)      null comment 'Discord邮箱',
    discord_access_token  varchar(200)      null comment 'Discord认证Token',
    discord_refresh_token varchar(200)      null comment 'Discord刷新Token',
    discord_expires_in    timestamp         null comment 'Discord认证Token过期时间',
    login_time            timestamp         null comment '登录时间',
    login_ip              varchar(100)      null comment '登录IP',
    login_city            varchar(100)      null comment '登录城市',
    create_time           timestamp         null comment '创建时间',
    create_id             bigint            null comment '创建人',
    create_by             varchar(200)      null comment '创建人',
    update_time           timestamp         null comment '更新时间',
    update_id             bigint            null comment '更新人',
    update_by             varchar(200)      null comment '更新人'
)
    comment '系统-用户表' charset = utf8mb4;

create index FKloay4nqos33x012wmyx7lxunh
    on sys_user (avatar);

create index idx_user_name
    on sys_user (username);

create table if not exists sys_users_roles
(
    user_id bigint not null,
    role_id bigint not null,
    primary key (user_id, role_id)
)
    comment '系统-用户角色关联表' charset = utf8mb4;

# TODO init from orignal db
# insert into eve_corp_manager_cacx_test.sys_attach select * from eve_corp_manager_cacx.sys_attach;
# insert into eve_corp_manager_cacx_test.sys_config select * from eve_corp_manager_cacx.sys_config;
# insert into eve_corp_manager_cacx_test.sys_menu select * from eve_corp_manager_cacx.sys_menu;
# insert into eve_corp_manager_cacx_test.sys_role select * from eve_corp_manager_cacx.sys_role;
# insert into eve_corp_manager_cacx_test.sys_roles_menus select * from eve_corp_manager_cacx.sys_roles_menus;
