<template>
	<transition name="modal-fade">
		<div class="modal-backdrop">
			<div class="modal" :class="{deletemodal: deleteAction}" role="dialog">
				<slot name="modal-body">
					<div class="mdoal__header">
						<h2> Add todo </h2>
						<button type="reset" class="close" @click="$emit('close')">X</button>
					</div>
					<div v-if="errors.length" class="errors">
						<ul>
							<li v-for="(error, index) in errors" :key="index"> {{ error }}</li>
						</ul>
					</div>
					<form @submit.prevent="addTodo">
						<div class="modal__body">
							<label for="title">Title</label>
							<input type="text" name="title" placeholder="title" v-model="form.title">
							<label for="description">Description</label>
							<textarea cols="40" rows="10" placeholder="description" v-model="form.description"></textarea>
						</div>
						<div class="modal__footer">
							<div>
								<input type="reset" value="Cancel" @click="$emit('close')">
								<input type="submit" value="Add">
							</div>
						</div>
					</form>
				</slot>
			</div>
		</div>
	</transition>
</template>

<script>
	import vuex from 'vuex'

	export default {
		name: 'ModalCreate',
		data() {
			return {
				form: {
					title: '',
					description: '',
					validate: false,
					terminate: false
				},
				errors: [],
			}
		},
		computed: {
			...vuex.mapGetters(['todos', 'todosValid', 'todosTerminate', 'deleteAction']),
		},
		methods: {
			addTodo() {
				this.errors = []
				if (!this.form.title) {
					this.errors.push('the name is required')
				}

				let allTodos = this.todosValid.concat(this.todos, this.todosTerminate);
				if (allTodos.length > 0) {
					allTodos.map(todo => {
						if (this.form.title == todo.title) {
							this.errors.push('this title already exists')
						}
					})
				}

				if (this.errors.length === 0) {
					this.$emit('add-new-todo', this.form)
					this.form = {
						title: '',
						description: '',
						validate: false
					}
					this.$emit('close')
				}
			},
		}
	}
</script>

<style>
@import "../styles/modal.css";
</style>