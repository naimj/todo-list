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
					<img src="../assets/delete.png" @click="callDeleteModal(index, 'terminate')" v-if="item.terminate">
				</li>
			</ul>
		</div>
	</div>
</template>

<script>
	import vuex from 'vuex'
	export default {
		name: 'TodoTerminate',
		props: ['status', 'data'],
		methods: {
			...vuex.mapActions(['terminateTodo']),
			callDeleteModal(id, status) {
				this.$emit('delete-todo', {id, status})
			}
		}
	};
</script>
