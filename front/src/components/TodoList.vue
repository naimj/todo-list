<template>
	<div class="todo-list">
		<div class="todo-list__head">
			<span> ToDo {{ status }}</span>
			<span> items </span>
		</div>
		<div class="todo-list__body">
			<ul>
				<li v-for="(item, index) in data" :key="index" :class="{gray: item.validate}">
					{{ item.title }}
					<div>
						<img src="../assets/check.png" @click="terminateTodo(index)" v-if="item.validate && !item.terminate">
						<img src="../assets/delete.png" @click="callDeleteModal(index, 'valid')" v-if="item.validate">
					</div>
				</li>
			</ul>
		</div>
	</div>
</template>

<script>
	import vuex from 'vuex'
	export default {
		name: 'TodoList',
		props: ['status', 'data'],
		methods: {
			...vuex.mapActions(['terminateTodo']),
			callDeleteModal(id, status) {
				this.$emit('delete-todo', {id, status})
			}
		}
	};
</script>
