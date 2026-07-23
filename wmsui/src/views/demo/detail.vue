<template>
  <div class="page-container">
    <div class="page-header">
      <h2>详情页缓存演示</h2>
      <p>路由参数 ID: {{ route.params.id }}</p>
    </div>
    <div class="page-content">
      <el-card shadow="hover">
        <template #header>
          <span>详情信息</span>
        </template>
        <el-descriptions :column="2" border>
          <el-descriptions-item label="ID">{{ route.params.id }}</el-descriptions-item>
          <el-descriptions-item label="状态">已激活</el-descriptions-item>
          <el-descriptions-item label="创建时间">2024-01-01 00:00:00</el-descriptions-item>
          <el-descriptions-item label="更新时间">2024-01-01 00:00:00</el-descriptions-item>
        </el-descriptions>
      </el-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useRoute } from "vue-router";

const route = useRoute();
</script>

<style lang="scss" scoped>
.page-container {
  padding: 20px;
}

.page-header {
  margin-bottom: 20px;
}

.page-content {
  min-height: 400px;
}
</style>
