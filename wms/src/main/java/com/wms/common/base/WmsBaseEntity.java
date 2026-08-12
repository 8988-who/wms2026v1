package com.wms.common.base;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * WMS 业务实体基类
 *
 * <p>主键采用 MyBatis-Plus 内置雪花算法（IdType.ASSIGN_ID）生成，
 * 区别于脚手架 {@link BaseEntity} 的数据库自增（IdType.AUTO）。
 * wms_* 自建业务表实体继承本类。</p>
 *
 * @author SenyangHe
 * @since 2026-08-12
 */
@Data
@EqualsAndHashCode(callSuper = true)
public class WmsBaseEntity extends BaseEntity {

    /**
     * 主键ID（雪花算法生成，写入时回填）
     */
    @TableId(type = IdType.ASSIGN_ID)
    private Long id;
}
