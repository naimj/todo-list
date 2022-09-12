<template>
  <div class="container">
    <div>
      <button type="button" class="button" @click="showModal">Create</button>
      <span v-if="isTodosValidate">
        <button type="button" class="button" @click="validAction">Validate</button>
        <button type="button" class="button" @click="cancel">Cancel</button>
      </span>
    </div>
    <div class="content">
      <todo-list :status="'Active'" :data="todosValid" @delete-todo="deleteTodoModal($event)"/>
      <todos-terminate :status="'Terminated'" :data="todosTerminate" @delete-todo="deleteTodoModal($event)"/>
    </div>
    <modal v-show="isModalVisible" @close="closeModal" @add-new-todo="addTodo($event)">
      <template v-slot:modal-body v-if="deleteAction">
        <button type="reset" class="close" @click="closeModal">X</button>
        <div>
          <p> You really want to delete this todo </p>
          <button type="button" class="button" @click="deleteTodo({id, status})">Delete</button>
        </div>
      </template>
    </modal>
  </div>
</template>

<script>
import todoList from './TodoList.vue'
import TodoTerminate from './TodoTerminate.vue'
import modal from './Modal.vue'
import vuex from 'vuex'

export default {
  name: 'HomePage',
  components: {
    modal,
    'todo-list': todoList,
    'todos-terminate': TodoTerminate
  },
  data() {
    return {
      allTodo: [],
      id: '',
      status: ''
    }
  },

  beforeMount() {
    this.$store.dispatch('getTodos')
  },

  computed: {
    ...vuex.mapGetters(['isTodosValidate', 'todosTerminate', 'todosValid', 'isModalVisible', 'deleteAction']),
  },
  methods: {
    ...vuex.mapActions(['addTodo', 'validAction', 'cancel', 'deleteTodo']),

    showModal() {
      this.$store.state.isModalVisible = true
    },
    closeModal() {
      this.$store.state.isModalVisible = false
      this.$store.state.deleteAction = false
    },
    deleteTodoModal(event) {
      this.$store.state.deleteAction = true
      this.$store.state.isModalVisible = true
      this.id = event.id
      this.status = event.status
    }
  },
}
</script>

<style>
@import "../styles/home.css";
</style>