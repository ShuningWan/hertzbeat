use usthe;

-- ----------------------------
-- Table structure for monitor
-- ----------------------------
DROP TABLE IF EXISTS  monitor ;
CREATE TABLE  monitor
(
     id           bigint       not null auto_increment comment '监控ID',
     job_id       bigint       not null comment '监控对应下发的任务ID',
     name         varchar(100) not null comment '监控的名称',
     app          varchar(100) not null comment '监控的类型:linux,mysql,jvm...',
     host         varchar(100) not null comment '监控的对端host:ipv4,ipv6,域名',
     intervals    int          not null default 600 comment '监控的采集间隔时间,单位秒',
     status       tinyint      not null default 1 comment '监控状态 0:未监控,1:可用,2:不可用,3:不可达,4:挂起',
     description  varchar(255) comment '描述备注信息',
     creator      varchar(100) comment '创建者',
     modifier     varchar(100) comment '最新修改者',
     gmt_create   timestamp    default current_timestamp comment 'create time',
     gmt_update   datetime     default current_timestamp on update current_timestamp comment 'update time',
     primary key (id),
     index query_index (app, host, name)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Table structure for param
-- ----------------------------
DROP TABLE IF EXISTS  param ;
CREATE TABLE  param
(
    id           bigint       not null auto_increment comment '参数ID',
    monitor_id   bigint       not null comment '监控ID',
    field        varchar(100) not null comment '参数标识符',
    value        varchar(255) not null comment '参数值,最大字符长度255',
    type         tinyint      not null default 0 comment '参数类型 0:数字 1:字符串 2:加密串',
    gmt_create   timestamp    default current_timestamp comment 'create time',
    gmt_update   datetime     default current_timestamp on update current_timestamp comment 'update time',
    primary key (id),
    index monitor_id (monitor_id),
    unique key unique_param (monitor_id, field)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Table structure for param
-- ----------------------------
DROP TABLE IF EXISTS  param_define ;
CREATE TABLE  param_define
(
    id           bigint           not null auto_increment comment '参数ID',
    app          varchar(100)     not null comment '监控的类型:linux,mysql,jvm...',
    name         varchar(100)     not null comment '参数字段对外显示名称',
    field        varchar(100)     not null comment '参数字段标识符',
    type         varchar(20)      not null default 'text' comment '字段类型,样式(大部分映射input标签type属性)',
    required     boolean          not null default false comment '是否是必输项 true-必填 false-可选',
    param_range  varchar(100)     not null comment '当type为number时,用range表示范围 eg: 0-233',
    param_limit  tinyint unsigned not null comment '当type为text时,用limit表示字符串限制大小.最大255',
    param_option varchar(255)     not null comment '当type为radio单选框,checkbox复选框时,option表示可选项值列表',
    creator      varchar(100)     comment '创建者',
    modifier     varchar(100)     comment '最新修改者',
    gmt_create   timestamp        default current_timestamp comment 'create time',
    gmt_update   datetime         default current_timestamp on update current_timestamp comment 'update time',
    primary key (id),
    unique key unique_param_define (app, field)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4;


-- ----------------------------
-- Table structure for alert_define
-- ----------------------------
DROP TABLE IF EXISTS  alert_define ;
CREATE TABLE  alert_define
(
    id           bigint           not null auto_increment comment '告警定义ID',
    app          varchar(100)     not null comment '配置告警的监控类型:linux,mysql,jvm...',
    metric       varchar(100)     not null comment '配置告警的指标集合:cpu,memory,info...',
    field        varchar(100)     not null comment '配置告警的指标:usage,cores...',
    preset       boolean          not null default false comment '是否是全局默认告警，是则所有此类型监控默认关联此告警',
    expr         varchar(255)     not null comment '告警触发条件表达式',
    priority     tinyint          not null default 0 comment '告警级别 0:高-emergency-紧急告警-红色 1:中-critical-严重告警-橙色 2:低-warning-警告告警-黄色',
    times        int              not null default 1 comment '触发次数,即达到触发阈值次数要求后才算触发告警',
    enable       boolean          not null default true comment '告警阈值开关',
    template     varchar(255)     not null comment '告警通知模板内容',
    creator      varchar(100)     comment '创建者',
    modifier     varchar(100)     comment '最新修改者',
    gmt_create   timestamp        default current_timestamp comment 'create time',
    gmt_update   datetime         default current_timestamp on update current_timestamp comment 'update time',
    primary key (id)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Table structure for alert_define_monitor_bind
-- ----------------------------
DROP TABLE IF EXISTS  alert_define_monitor_bind ;
CREATE TABLE  alert_define_monitor_bind
(
    id               bigint           not null auto_increment comment '告警定义与监控关联ID',
    alert_define_id  bigint           not null comment '告警定义ID',
    monitor_id       bigint           not null comment '监控ID',
    monitor_name     varchar(100)     not null comment '监控的名称(拢余字段方便展示)',
    gmt_create       timestamp        default current_timestamp comment 'create time',
    gmt_update       datetime         default current_timestamp on update current_timestamp comment 'update time',
    primary key (id),
    index index_bind (alert_define_id, monitor_id)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Table structure for alert
-- ----------------------------
DROP TABLE IF EXISTS  alert ;
CREATE TABLE  alert
(
    id               bigint           not null auto_increment comment '告警ID',
    target           varchar(255)     not null comment '告警目标对象: 监控可用性-available 指标-app.metrics.field',
    monitor_id       bigint           not null comment '告警对象关联的监控ID',
    monitor_name     varchar(100)     comment '告警对象关联的监控名称',
    alert_define_id  bigint           comment '告警关联的告警定义ID',
    priority         tinyint          not null default 0 comment '告警级别 0:高-emergency-紧急告警-红色 1:中-critical-严重告警-橙色 2:低-warning-警告告警-黄色',
    content          varchar(255)     not null comment '告警通知实际内容',
    status           tinyint          not null default 0 comment '告警状态: 0-正常告警(待处理) 1-阈值触发但未达到告警次数 2-恢复告警 3-已处理',
    times            int              not null comment '触发次数,即达到告警定义的触发阈值次数要求后才会发告警',
    gmt_create       timestamp        default current_timestamp comment 'create time',
    primary key (id)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Table structure for notice_rule
-- ----------------------------
DROP TABLE IF EXISTS  notice_rule ;
CREATE TABLE  notice_rule
(
    id             bigint           not null auto_increment comment '通知策略主键索引ID',
    name           varchar(100)     not null comment '策略名称',
    receiver_id    bigint           not null comment '消息接收人ID',
    receiver_name  varchar(100)     not null comment '消息接收人标识',
    enable         boolean          not null default true comment '是否启用此策略',
    filter_all     boolean          not null default true comment '是否转发所有',
    creator        varchar(100)     comment '创建者',
    modifier       varchar(100)     comment '最新修改者',
    gmt_create     timestamp        default current_timestamp comment 'create time',
    gmt_update     datetime         default current_timestamp on update current_timestamp comment 'update time',
    primary key (id)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Table structure for notice_receiver
-- ----------------------------
DROP TABLE IF EXISTS  notice_receiver ;
CREATE TABLE  notice_receiver
(
    id           bigint           not null auto_increment comment '消息接收人ID',
    name         varchar(100)     not null comment '消息接收人姓名',
    type         tinyint          not null comment '通知信息方式: 0-手机短信 1-邮箱 2-webhook 3-微信公众号',
    phone        varchar(100)     comment '手机号, 通知方式为手机短信时有效',
    email        varchar(100)     comment '邮箱账号, 通知方式为邮箱时有效',
    hook_url     varchar(100)     comment 'URL地址, 通知方式为webhook有效',
    wechat_id    varchar(100)     comment 'wechat用户openId, 通知方式为微信公众号有效',
    creator      varchar(100)     comment '创建者',
    modifier     varchar(100)     comment '最新修改者',
    gmt_create   timestamp        default current_timestamp comment 'create time',
    gmt_update   datetime         default current_timestamp on update current_timestamp comment 'update time',
    primary key (id)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4;

COMMIT;