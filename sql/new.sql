use eve_corp_manager_cacx;
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

create table if not exists corp_pap_log
(
    id             bigint auto_increment
        primary key,
    user_id        bigint                              null comment '用户ID',
    account_id     bigint                              null comment '角色ID',
    character_name varchar(100) collate utf8mb4_bin    null comment '角色名',
    fleet_id       bigint                              null comment '舰队id',
    pap            decimal(11, 2)                      null comment 'PAP数量',
    content        varchar(200) collate utf8mb4_bin    null comment '说明',
    create_by      varchar(100) collate utf8mb4_bin    null,
    create_id      bigint                              null,
    create_time    timestamp default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    update_time    timestamp                           null,
    update_id      bigint                              null,
    update_by      varchar(100)                        null
)
    comment '军团PAP登记表' charset = utf8mb4;

create index corp_pap_log_user_id_account_id_index
    on eve_corp_manager_cacx.corp_pap_log (user_id, account_id);

# TODO init from orignal db
# insert into eve_corp_manager_cacx_test.sys_attach select * from eve_corp_manager_cacx.sys_attach;
# insert into eve_corp_manager_cacx_test.sys_config select * from eve_corp_manager_cacx.sys_config;
# insert into eve_corp_manager_cacx_test.sys_menu select * from eve_corp_manager_cacx.sys_menu;
# insert into eve_corp_manager_cacx_test.sys_role select * from eve_corp_manager_cacx.sys_role;
# insert into eve_corp_manager_cacx_test.sys_roles_menus select * from eve_corp_manager_cacx.sys_roles_menus;

BEGIN;
INSERT INTO `sys_config` (`id`, `name`, `value`, `title`, `remark`, `update_time`, `update_id`, `update_by`, `create_time`, `create_id`, `create_by`) VALUES (1, 'aliyun.access.key', NULL, '阿里云key', NULL, '2022-12-13 21:48:58', 1, 'Sir丶雨轩', '2022-12-13 21:31:21', NULL, 'Sir丶雨轩');
INSERT INTO `sys_config` (`id`, `name`, `value`, `title`, `remark`, `update_time`, `update_id`, `update_by`, `create_time`, `create_id`, `create_by`) VALUES (2, 'aliyun.access.secret', NULL, '阿里云密钥', NULL, '2022-12-13 21:49:59', 1, 'Sir丶雨轩', '2022-12-13 21:31:21', NULL, 'Sir丶雨轩');
INSERT INTO `sys_config` (`id`, `name`, `value`, `title`, `remark`, `update_time`, `update_id`, `update_by`, `create_time`, `create_id`, `create_by`) VALUES (3, 'aliyun.oss.endpoint', NULL, '阿里云OSS的地域', NULL, '2022-12-13 21:47:14', 1, 'Sir丶雨轩', '2022-12-13 21:31:21', NULL, 'Sir丶雨轩');
INSERT INTO `sys_config` (`id`, `name`, `value`, `title`, `remark`, `update_time`, `update_id`, `update_by`, `create_time`, `create_id`, `create_by`) VALUES (4, 'aliyun.oss.bucket', NULL, '阿里云OSS的bucket', NULL, '2022-12-13 21:48:38', 1, 'Sir丶雨轩', '2022-12-13 21:31:21', NULL, 'Sir丶雨轩');
INSERT INTO `sys_config` (`id`, `name`, `value`, `title`, `remark`, `update_time`, `update_id`, `update_by`, `create_time`, `create_id`, `create_by`) VALUES (5, 'mail.user', NULL, '邮件发送账号', NULL, '2022-12-23 13:52:57', 1, 'Sir丶雨轩', NULL, NULL, NULL);
INSERT INTO `sys_config` (`id`, `name`, `value`, `title`, `remark`, `update_time`, `update_id`, `update_by`, `create_time`, `create_id`, `create_by`) VALUES (6, 'mail.pass', NULL, '邮件发送密码', NULL, '2022-12-23 13:52:57', 1, 'Sir丶雨轩', NULL, NULL, NULL);
INSERT INTO `sys_config` (`id`, `name`, `value`, `title`, `remark`, `update_time`, `update_id`, `update_by`, `create_time`, `create_id`, `create_by`) VALUES (7, 'mail.from', NULL, '邮件发送人', NULL, '2022-12-23 13:52:57', 1, 'Sir丶雨轩', NULL, NULL, NULL);
INSERT INTO `sys_config` (`id`, `name`, `value`, `title`, `remark`, `update_time`, `update_id`, `update_by`, `create_time`, `create_id`, `create_by`) VALUES (8, 'mail.host', NULL, '邮件域名', NULL, '2022-12-23 13:52:57', 1, 'Sir丶雨轩', NULL, NULL, NULL);
INSERT INTO `sys_config` (`id`, `name`, `value`, `title`, `remark`, `update_time`, `update_id`, `update_by`, `create_time`, `create_id`, `create_by`) VALUES (9, 'mail.port', NULL, '邮件端口', NULL, '2022-12-23 13:52:57', 1, 'Sir丶雨轩', NULL, NULL, NULL);
INSERT INTO `sys_config` (`id`, `name`, `value`, `title`, `remark`, `update_time`, `update_id`, `update_by`, `create_time`, `create_id`, `create_by`) VALUES (13, 'rsaPrivate', NULL, 'RSA私钥', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_config` (`id`, `name`, `value`, `title`, `remark`, `update_time`, `update_id`, `update_by`, `create_time`, `create_id`, `create_by`) VALUES (14, 'rsaPublic', NULL, 'RSA公钥', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_config` (`id`, `name`, `value`, `title`, `remark`, `update_time`, `update_id`, `update_by`, `create_time`, `create_id`, `create_by`) VALUES (20, 'eve.esi.client', NULL, 'EVE ESI ClientID', NULL, '2022-12-23 13:52:57', 1, 'Sir丶雨轩', '2022-12-13 21:31:21', NULL, 'Sir丶雨轩');
INSERT INTO `sys_config` (`id`, `name`, `value`, `title`, `remark`, `update_time`, `update_id`, `update_by`, `create_time`, `create_id`, `create_by`) VALUES (21, 'eve.esi.secret', NULL, 'EVE ESI SecretKey', NULL, '2022-12-13 21:50:47', 1, 'Sir丶雨轩', '2022-12-13 21:31:21', NULL, 'Sir丶雨轩');
INSERT INTO `sys_config` (`id`, `name`, `value`, `title`, `remark`, `update_time`, `update_id`, `update_by`, `create_time`, `create_id`, `create_by`) VALUES (22, 'eve.es.callback', NULL, 'EVE ESI 授权回调', NULL, '2022-12-13 21:51:11', 1, 'Sir丶雨轩', '2022-12-13 21:31:21', NULL, 'Sir丶雨轩');
INSERT INTO `sys_config` (`id`, `name`, `value`, `title`, `remark`, `update_time`, `update_id`, `update_by`, `create_time`, `create_id`, `create_by`) VALUES (264, 'web.site', NULL, '前端地址', NULL, '2022-12-13 21:41:28', 1, 'Sir丶雨轩', '2022-12-13 21:31:21', NULL, 'Sir丶雨轩');
INSERT INTO `sys_config` (`id`, `name`, `value`, `title`, `remark`, `update_time`, `update_id`, `update_by`, `create_time`, `create_id`, `create_by`) VALUES (644, 'eve.main.corp', NULL, 'EVE主军团ID', NULL, '2022-12-13 21:50:25', 1, 'Sir丶雨轩', '2022-12-13 21:31:21', NULL, 'Sir丶雨轩');
INSERT INTO `sys_config` (`id`, `name`, `value`, `title`, `remark`, `update_time`, `update_id`, `update_by`, `create_time`, `create_id`, `create_by`) VALUES (646, 'upload.local.path', NULL, '本地上传保存目录', NULL, NULL, NULL, 'Sir丶雨轩', '2022-12-13 21:31:21', NULL, 'Sir丶雨轩');
INSERT INTO `sys_config` (`id`, `name`, `value`, `title`, `remark`, `update_time`, `update_id`, `update_by`, `create_time`, `create_id`, `create_by`) VALUES (647, 'upload.local.url', NULL, '本地上传保存URL', NULL, NULL, NULL, 'Sir丶雨轩', '2022-12-13 21:31:21', NULL, 'Sir丶雨轩');
INSERT INTO `sys_config` (`id`, `name`, `value`, `title`, `remark`, `update_time`, `update_id`, `update_by`, `create_time`, `create_id`, `create_by`) VALUES (648, 'upload.type', NULL, '上传类型', '上传类型：1=本地文件，2=阿里云', '2022-12-13 21:45:00', 1, 'Sir丶雨轩', '2022-12-13 21:31:21', NULL, 'Sir丶雨轩');
INSERT INTO `sys_config` (`id`, `name`, `value`, `title`, `remark`, `update_time`, `update_id`, `update_by`, `create_time`, `create_id`, `create_by`) VALUES (649, 'seat.cookie', NULL, '联盟通讯Cookie', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_config` (`id`, `name`, `value`, `title`, `remark`, `update_time`, `update_id`, `update_by`, `create_time`, `create_id`, `create_by`) VALUES (650, 'discord.client.id', NULL, 'Discord客户端ID', NULL, NULL, NULL, NULL, '2023-01-11 11:34:13', 1, 'Sir丶雨轩');
INSERT INTO `sys_config` (`id`, `name`, `value`, `title`, `remark`, `update_time`, `update_id`, `update_by`, `create_time`, `create_id`, `create_by`) VALUES (651, 'discord.public.key', NULL, 'Discord客户端密钥', NULL, NULL, NULL, NULL, '2023-01-11 11:34:42', 1, 'Sir丶雨轩');
INSERT INTO `sys_config` (`id`, `name`, `value`, `title`, `remark`, `update_time`, `update_id`, `update_by`, `create_time`, `create_id`, `create_by`) VALUES (652, 'discord.redirect.uri', NULL, 'discord 授权回调', NULL, '2023-01-11 15:18:22', 1, 'Sir丶雨轩', '2023-01-11 13:04:42', 1, 'Sir丶雨轩');
INSERT INTO `sys_config` (`id`, `name`, `value`, `title`, `remark`, `update_time`, `update_id`, `update_by`, `create_time`, `create_id`, `create_by`) VALUES (653, 'discord.client.secret', NULL, 'Discord客户端密钥', '', NULL, NULL, NULL, '2023-01-11 13:48:26', 1, 'Sir丶雨轩');
INSERT INTO `sys_config` (`id`, `name`, `value`, `title`, `remark`, `update_time`, `update_id`, `update_by`, `create_time`, `create_id`, `create_by`) VALUES (654, 'discord.bot.token', NULL, 'Discord机器人Token', NULL, '2023-01-12 10:37:18', 1, 'Sir丶雨轩', '2023-01-12 09:17:44', 1, 'Sir丶雨轩');
INSERT INTO `sys_config` (`id`, `name`, `value`, `title`, `remark`, `update_time`, `update_id`, `update_by`, `create_time`, `create_id`, `create_by`) VALUES (655, 'discord.corp.guilds', NULL, 'Discord军团频道ID', NULL, NULL, NULL, NULL, '2023-01-12 09:21:47', 1, 'Sir丶雨轩');
INSERT INTO `sys_config` (`id`, `name`, `value`, `title`, `remark`, `update_time`, `update_id`, `update_by`, `create_time`, `create_id`, `create_by`) VALUES (656, 'discord.role.corp.member', NULL, 'Discord军团成员组ID', NULL, NULL, NULL, NULL, '2023-01-12 10:03:22', 1, 'Sir丶雨轩');
INSERT INTO `sys_config` (`id`, `name`, `value`, `title`, `remark`, `update_time`, `update_id`, `update_by`, `create_time`, `create_id`, `create_by`) VALUES (657, 'discord.role.corp.admin', NULL, '军团总监组ID', NULL, NULL, NULL, NULL, '2023-01-12 10:03:49', 1, 'Sir丶雨轩');
INSERT INTO `sys_config` (`id`, `name`, `value`, `title`, `remark`, `update_time`, `update_id`, `update_by`, `create_time`, `create_id`, `create_by`) VALUES (658, 'template.path', NULL, '图片模板目录', NULL, '2023-01-13 16:50:01', 1, 'Sir丶雨轩', '2023-01-13 16:01:16', 1, 'Sir丶雨轩');
COMMIT;

BEGIN;
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (1, '系统设置', 0, 0, 'setting|svg', 0, NULL, NULL, 0, 'system', '/system', 1, 'LAYOUT', 999, '2021-06-23 16:09:11', NULL, NULL, '2022-12-13 09:29:34', 1, 'Sir丶雨轩', NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (2, '用户管理', 1, 1, 'user|svg', 0, NULL, NULL, 0, 'user', 'user', 1, 'sys/user/index', 1, NULL, NULL, NULL, '2022-12-12 12:38:03', 1, 'Sir丶雨轩', NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (3, '菜单管理', 1, 1, 'menu|svg', 0, NULL, NULL, 0, 'menu', 'menu', 1, 'sys/menu/index', 2, NULL, NULL, NULL, NULL, 0, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (4, '角色管理', 1, 1, 'role|svg', 0, NULL, NULL, 0, 'role', 'role', 1, 'sys/role/index', 3, NULL, NULL, NULL, NULL, 0, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (5, '新增', 2, 2, NULL, 0, NULL, NULL, 0, 'user:add', NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (6, '编辑', 2, 2, NULL, 0, NULL, NULL, 0, 'user:edit', NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (7, '删除', 2, 2, NULL, 0, NULL, NULL, 0, 'user:del', NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (8, '新增', 4, 2, NULL, 0, NULL, NULL, 0, 'role:add', NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (9, '编辑', 4, 2, NULL, 0, NULL, NULL, 0, 'role:edit', NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (10, '删除', 4, 2, NULL, 0, NULL, NULL, 0, 'role:del', NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (11, '新增', 3, 2, NULL, 0, NULL, NULL, 0, 'menu:add', NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (12, '编辑', 3, 2, NULL, 0, NULL, NULL, 0, 'menu:edit', NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (13, '删除', 3, 2, NULL, 0, NULL, NULL, 0, 'menu:del', NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (14, '工作台', 0, 1, 'dashboard|svg', 0, NULL, NULL, 0, 'dashboard', 'dashboard', 1, 'dashboard/workbench/index', 1, NULL, NULL, NULL, NULL, NULL, NULL, 1);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (16, '详情', 2, 2, NULL, 0, NULL, NULL, NULL, 'user:details', NULL, 1, NULL, 999, '2022-12-12 12:45:57', 1, 'Sir丶雨轩', NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (17, 'ESI授权', 0, 1, 'anquan|svg', 0, NULL, NULL, 0, NULL, 'esi', 1, 'esi/index', 2, '2022-12-12 15:00:41', 1, 'Sir丶雨轩', NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (18, 'LP中心', 0, 0, 'lp|svg', 0, NULL, NULL, 0, NULL, '/lp', 1, 'LAYOUT', 4, '2022-12-13 09:30:39', 1, 'Sir丶雨轩', '2022-12-14 17:15:24', 1, 'Sir丶雨轩', NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (19, '发放LP', 18, 1, 'fly|svg', 0, NULL, NULL, 0, NULL, 'send', 1, 'lp/send/index', 1, '2022-12-13 09:36:05', 1, 'Sir丶雨轩', NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (20, '我的LP', 18, 1, 'yelp|svg', 0, NULL, NULL, 0, NULL, 'me', 1, 'lp/me/index', 2, '2022-12-13 13:00:12', 1, 'Sir丶雨轩', NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (21, '商品管理', 18, 1, 'goods|svg', 0, NULL, NULL, 0, NULL, 'goods', 1, 'lp/goods/index', 3, '2022-12-13 15:40:38', 1, 'Sir丶雨轩', NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (23, '系统配置', 1, 1, 'dept|svg', 0, NULL, NULL, 0, NULL, 'config', 1, 'sys/config/index', 4, '2022-12-13 21:08:51', 1, 'Sir丶雨轩', NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (24, '订单管理', 18, 1, 'order|svg', 0, NULL, NULL, 0, NULL, 'order', 1, 'lp/order/index', 4, '2022-12-14 09:07:04', 1, 'Sir丶雨轩', NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (25, '审批', 24, 2, NULL, 0, NULL, NULL, NULL, 'order:approval', NULL, NULL, NULL, 1, '2022-12-14 09:40:42', 1, 'Sir丶雨轩', NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (26, '查看', 24, 2, NULL, 0, NULL, NULL, NULL, 'order:view', NULL, NULL, NULL, 999, '2022-12-14 10:39:38', 1, 'Sir丶雨轩', NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (27, '发放记录', 18, 1, 'task|svg', 0, NULL, NULL, 0, NULL, 'log', 1, 'lp/log/index', 5, '2022-12-14 16:21:22', 1, 'Sir丶雨轩', NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (28, 'LP商城', 0, 1, 'shop|svg', 0, NULL, NULL, 0, NULL, 'shop', 1, 'lp/shop/index', 3, '2022-12-14 17:21:10', 1, 'Sir丶雨轩', NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (30, '发放', 19, 2, NULL, 0, NULL, NULL, NULL, 'lp:send', NULL, NULL, NULL, 1, '2022-12-22 11:17:57', 1, 'Sir丶雨轩', NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (31, '常用工具', 0, 0, 'util|svg', 0, NULL, NULL, 0, NULL, '/utils', 1, 'LAYOUT', 5, '2022-12-22 11:42:00', 1, 'Sir丶雨轩', NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (32, '留言板', 31, 1, 'liuyan|svg', 0, NULL, NULL, 0, NULL, 'talk', 1, 'utils/talk/index', 4, '2022-12-22 11:44:21', 1, 'Sir丶雨轩', '2022-12-22 11:44:41', 1, 'Sir丶雨轩', NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (33, '补损提交', 31, 1, 'kill|svg', 0, NULL, NULL, 0, NULL, 'srp', 1, 'utils/srp/index', 2, '2022-12-22 13:49:46', 1, 'Sir丶雨轩', '2023-01-11 10:53:16', 1, 'Sir丶雨轩', NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (34, '数据维护', 0, 0, 'database|svg', 0, NULL, NULL, 0, NULL, '/data', 1, 'LAYOUT', 6, '2022-12-24 15:24:29', 1, 'Sir丶雨轩', NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (35, '军团成员', 34, 1, 'dynamic-avatar-4|svg', 0, NULL, NULL, 0, NULL, 'member', 1, 'data/member/index', 1, '2022-12-24 15:25:38', 1, 'Sir丶雨轩', NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (36, '补损规则', 34, 1, 'rules|svg', 0, NULL, NULL, 0, NULL, 'srpRules', 1, 'data/srp/rules/index', 2, '2022-12-25 11:20:56', 1, 'Sir丶雨轩', NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (37, '新增', 36, 2, NULL, 0, NULL, NULL, NULL, 'srpRules:add', NULL, NULL, NULL, 1, '2022-12-25 12:21:00', 1, 'Sir丶雨轩', NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (38, '编辑', 36, 2, NULL, 0, NULL, NULL, NULL, 'srpRules:edit', NULL, NULL, NULL, 1, '2022-12-25 12:21:15', 1, 'Sir丶雨轩', NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (39, '删除', 36, 2, NULL, 0, NULL, NULL, NULL, 'srpRules:del', NULL, NULL, NULL, 1, '2022-12-25 12:21:27', 1, 'Sir丶雨轩', NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (40, '列表', 36, 2, NULL, 0, NULL, NULL, NULL, 'srpRules', NULL, NULL, NULL, 1, '2022-12-25 12:22:38', 1, 'Sir丶雨轩', NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (41, '补损黑名单', 34, 1, 'blacklist|svg', 0, NULL, NULL, 0, NULL, 'srpBlacklist', 1, 'data/srp/blacklist/index', 3, '2022-12-25 13:04:45', 1, 'Sir丶雨轩', '2022-12-25 13:07:48', 1, 'Sir丶雨轩', NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (42, '查看', 41, 2, NULL, 0, NULL, NULL, NULL, 'srpBlacklist', NULL, NULL, NULL, 1, '2022-12-25 13:06:11', 1, 'Sir丶雨轩', NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (43, '新增', 41, 2, NULL, 0, NULL, NULL, NULL, 'srpBlacklist:add', NULL, NULL, NULL, 1, '2022-12-25 13:06:25', 1, 'Sir丶雨轩', NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (44, '编辑', 41, 2, NULL, 0, NULL, NULL, NULL, 'srpBlacklist:edit', NULL, NULL, NULL, 1, '2022-12-25 13:06:36', 1, 'Sir丶雨轩', NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (45, '删除', 41, 2, NULL, 0, NULL, NULL, NULL, 'srpBlacklist:del', NULL, NULL, NULL, 1, '2022-12-25 13:06:55', 1, 'Sir丶雨轩', NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (46, '补损审批', 34, 1, 'sh|svg', 0, NULL, NULL, 0, NULL, 'srpExamine', 1, 'data/srp/examine/index', 4, '2022-12-25 13:49:43', 1, 'Sir丶雨轩', NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (47, '个人信息', 0, 0, 'dynamic-avatar-6|svg', 0, NULL, NULL, 0, NULL, '/account', 1, 'LAYOUT', 7, '2022-12-25 15:09:25', 1, 'Sir丶雨轩', NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (48, '钱包流水', 47, 1, 'wallet|svg', 0, NULL, NULL, 0, NULL, 'wallet', 1, 'account/wallet/index', 2, '2022-12-25 15:12:34', 1, 'Sir丶雨轩', '2022-12-26 17:19:00', 1, 'Sir丶雨轩', NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (49, '交易历史', 47, 1, 'order|svg', 0, NULL, NULL, 0, NULL, 'order', 1, 'account/order/index', 3, '2022-12-26 14:26:36', 1, 'Sir丶雨轩', '2022-12-26 17:19:04', 1, 'Sir丶雨轩', NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (50, '数据分析', 47, 1, 'total-sales|svg', 0, NULL, NULL, 0, NULL, 'analysis', 1, 'dashboard/analysis/index', 1, '2022-12-26 17:18:34', 1, 'Sir丶雨轩', NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (51, '查看', 50, 2, NULL, 0, NULL, NULL, NULL, 'view', NULL, NULL, NULL, 1, '2022-12-26 20:33:38', 1, 'Sir丶雨轩', NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (52, '查询全部', 50, 2, NULL, 0, NULL, NULL, NULL, 'analysis:all', NULL, NULL, NULL, 1, '2022-12-26 20:34:02', 1, 'Sir丶雨轩', NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (53, '合同管理', 47, 1, 'menu|svg', 0, NULL, NULL, 0, NULL, 'contract', 1, 'account/contract/index', 4, '2022-12-27 10:46:23', 1, 'Sir丶雨轩', NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`id`, `name`, `pid`, `type`, `icon`, `is_link`, `frame`, `link_url`, `hidden`, `permission`, `path`, `cache`, `component`, `sort`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`, `affix`) VALUES (54, '加入Discord', 31, 1, 'discord|svg', 1, 0, 'http://discord.hd-eve.com/discord/auth', 0, NULL, 'http://discord.hd-eve.com/discord/auth', 1, NULL, 1, '2023-01-11 10:38:11', 1, 'Sir丶雨轩', '2023-01-11 15:07:46', 1, 'Sir丶雨轩', NULL);
COMMIT;

BEGIN;
INSERT INTO `sys_role` (`id`, `name`, `remark`, `create_time`, `create_id`, `create_by`, `update_time`, `update_id`, `update_by`) VALUES (1, '超级管理员', '系统最高权限', '2022-09-19 14:09:02', NULL, NULL, '2022-12-14 10:19:07', 1, 'Sir丶雨轩');
COMMIT;

BEGIN;
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 1, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 2, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 3, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 4, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 5, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 6, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 7, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 8, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 9, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 10, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 11, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 12, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 13, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 14, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 16, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 17, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 18, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 19, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 20, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 21, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 23, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 24, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 25, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 26, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 27, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 28, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 30, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 31, 1);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 32, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 33, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 34, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 35, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 36, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 37, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 38, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 39, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 40, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 41, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 42, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 43, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 44, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 45, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 46, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 47, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 48, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 49, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 50, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 51, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 52, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 53, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (1, 54, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (2, 1, 1);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (2, 2, 1);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (2, 3, 1);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (2, 4, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (2, 5, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (2, 7, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (2, 8, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (2, 9, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (2, 10, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (2, 12, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (2, 14, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (3, 14, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (3, 17, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (4, 14, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (4, 17, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (4, 18, 1);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (4, 20, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (4, 24, 1);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (4, 26, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (4, 27, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (4, 28, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (4, 31, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (4, 32, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (4, 33, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (4, 34, 1);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (4, 36, 1);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (4, 40, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (4, 41, 1);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (4, 42, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (4, 47, 1);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (4, 48, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (4, 49, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (4, 50, 1);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (4, 51, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (4, 53, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (4, 54, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (5, 18, 1);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (5, 19, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (5, 30, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (6, 34, 1);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (6, 36, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (6, 37, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (6, 38, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (6, 39, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (6, 40, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (6, 41, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (6, 42, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (6, 43, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (6, 44, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (6, 45, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (6, 46, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (10, 18, 1);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (10, 21, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (10, 24, 1);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (10, 25, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (11, 14, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (11, 17, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (11, 18, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (11, 19, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (11, 20, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (11, 21, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (11, 24, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (11, 25, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (11, 26, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (11, 27, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (11, 28, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (11, 30, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (11, 31, 1);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (11, 32, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (11, 33, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (11, 34, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (11, 35, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (11, 36, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (11, 37, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (11, 38, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (11, 39, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (11, 40, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (11, 41, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (11, 42, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (11, 43, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (11, 44, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (11, 45, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (11, 46, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (11, 47, 1);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (11, 48, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (11, 49, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (11, 50, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (11, 51, 0);
INSERT INTO `sys_roles_menus` (`role_id`, `menu_id`, `virtually`) VALUES (11, 52, 0);
COMMIT;
