/* eslint-disable */

import Vue from 'vue'
import Vuex from 'vuex'
import { callApi } from '../utils/utils.js'

Vue.use(Vuex)

const state = {
	todos: [],
	todosTerminate: [],
	todosValid: [],
	todosDelete: [],
	isTodosValidate: false,
	isModalVisible: false,
	deleteAction: false,
	action: '',
	todoId: ''
}

const mutations = {
	GET_TODOS(state, payload) {
		state.todosValid = payload.filter(todo => !todo.terminate)
		state.todosTerminate = payload.filter(todo => todo.terminate)
		state.isTodosValidate = false
	},

	ADD_TODO: (state, payload) => {
		state.todos.push(payload)
		state.isTodosValidate = true
		state.action = 'add'
	},

	VALIDATE_TODO: (state) => {
		state.isTodosValidate = false
		state.todos= []
	},

	DELETE_TODO: (state, {id, status}) => {
		let data = status === 'valid' ? state.todosValid : state.todosTerminate
		state.todosDelete.push(data[id])
		data.splice(id, 1)
		state.isTodosValidate = true
		state.isModalVisible = false
		state.deleteAction = false
		state.action = 'delete'
	},

	DELETE_TODO_TERMINATED: (state, id) => {
		state.todosDelete.push(state.todosTerminate[id])
		state.todosTerminate.splice(id, 1)
		state.isTodosValidate = true
		state.action = 'delete'
	},

	TERMINATE_TODO: (state, id) => {
		state.todosTerminate.push(state.todosValid[id])
		state.todosValid.splice(id, 1)
		state.isTodosValidate = true
		state.action = 'update'
	},

	CANCEL: (state) => { //it work only for cancel add lol
		state.todos = []
		state.isTodosValidate = false
	}
}

const getters = {
	todos: state => state.todos,
	isTodosValidate: state => state.isTodosValidate,
	todosTerminate: state => state.todosTerminate.concat(state.todosValid.filter(todo => todo.terminate)),
	todosValid: state => (state.todosValid.filter(todo => !todo.terminate)).concat(state.todos),
	isModalVisible: state => state.isModalVisible,
	deleteAction: state => state.deleteAction

}

const actions = {
	addTodo({ commit }, payload) {
		commit('ADD_TODO', payload)
	},

	deleteTodo({ commit }, data) {
		commit('DELETE_TODO', data)
	},

	terminateTodo({ commit }, id) {
		commit('TERMINATE_TODO', id)
	},

	cancel({ commit }) {
		commit('CANCEL')
	},

	async getTodos({ commit }) {
		try {
			await callApi('get', 'read.php').then(result => {
				if(result.data.message === 'Found Todo') {
					commit('GET_TODOS', result.data.data)
				}
			})
		}
		catch (error) {
			console.log(error)
		}
	},

	async validAction({ commit, dispatch }) {
		switch (state.action) {
			case 'add':
				await callApi('post', 'create.php', state.todos).then((result) => {
					if(result.data.message === 'Todo Created') {
						dispatch('getTodos')
						commit('VALIDATE_TODO')
					}
				}).catch((response) => {
					console.log('response', response)
				})
				break
			case 'update':
				state.todosTerminate.forEach(todo => { todo.terminate = 1});
				await callApi('put', 'update.php', state.todosTerminate).then(() => {
					state.isTodosValidate = false
				})
				break
			case 'delete':
				await callApi('post', 'delete.php', state.todosDelete).then(() => {
					state.isTodosValidate = false
				})
				break
		}
	}
}

const store = new Vuex.Store({
	state: state,

	mutations: mutations,

	getters: getters,

	actions: actions
})
export default store